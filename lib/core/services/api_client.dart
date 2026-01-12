import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/auth_tokens.dart';
import '../models/api_response.dart';
import 'token_storage_service.dart';

class ApiClient {
  late final Dio _dio;
  final TokenStorageService _tokenStorage = TokenStorageService();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  // Request interceptor - Add auth token
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add token to headers if available
    final token = await _tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    print('🌐 ${options.method} ${options.path}');
    print('📤 Request Data: ${options.data}');
    
    handler.next(options);
  }

  // Response interceptor
  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    print('✅ Response [${response.statusCode}]: ${response.data}');
    handler.next(response);
  }

  // Error interceptor - Handle token refresh
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    print('❌ Error [${error.response?.statusCode}]: ${error.message}');

    // Handle 401 - Unauthorized (Token expired)
    if (error.response?.statusCode == 401) {
      try {
        // Try to refresh token
        final refreshToken = await _tokenStorage.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final newTokens = await _refreshToken(refreshToken);
          
          if (newTokens != null) {
            // Retry the original request with new token
            final requestOptions = error.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer ${newTokens.accessToken}';
            
            final response = await _dio.fetch(requestOptions);
            return handler.resolve(response);
          }
        }
      } catch (e) {
        print('Failed to refresh token: $e');
        // Clear tokens and redirect to login
        await _tokenStorage.clearAll();
      }
    }

    handler.next(error);
  }

  // Refresh token
  Future<AuthTokens?> _refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final tokensJson = response.data['data']?['tokens'];
        if (tokensJson is Map<String, dynamic>) {
          final tokens = AuthTokens.fromJson(tokensJson);
          await _tokenStorage.saveTokens(tokens);
          return tokens;
        }
      }
      return null;
    } catch (e) {
      print('Refresh token error: $e');
      return null;
    }
  }

  // GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  // POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  // PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  // DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  // Handle errors
  ApiResponse<T> _handleError<T>(DioException error) {
    String message = 'An error occurred';

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      // Same symptom as connectionError when pointing at emulator-only hostnames.
      final baseUrl = ApiConstants.baseUrl;
      if (Platform.isAndroid &&
          (baseUrl.contains('10.0.2.2') || baseUrl.contains('localhost'))) {
        message =
            'Connection timeout.\n'
            'If you are running on a PHYSICAL Android device, it cannot reach '
            'your laptop backend via 10.0.2.2/localhost.\n\n'
            'Fix:\n'
            '--dart-define=API_BASE_URL=http://<YOUR_LAN_IP>:5001/api/v1\n'
            '--dart-define=SOCKET_URL=http://<YOUR_LAN_IP>:5001\n'
            'or (USB) run: adb reverse tcp:5001 tcp:5001';
      } else {
        message = 'Connection timeout. Please check your internet connection.';
      }
    } else if (error.type == DioExceptionType.connectionError) {
      // Common local-dev pitfall:
      // - Android emulator can reach host machine at 10.0.2.2
      // - Physical Android device CANNOT; it needs your machine LAN IP
      final baseUrl = ApiConstants.baseUrl;
      if (Platform.isAndroid && baseUrl.contains('10.0.2.2')) {
        message =
            'Cannot connect to server. On a physical Android device, 10.0.2.2 only works on emulators.\n'
            'Run with:\n'
            '--dart-define=API_BASE_URL=http://<YOUR_LAN_IP>:5001/api/v1\n'
            '--dart-define=SOCKET_URL=http://<YOUR_LAN_IP>:5001\n'
            'and ensure the backend is running.';
      } else {
        message =
            'Cannot connect to server. Check API URL and ensure backend is running.';
      }
    } else if (error.response != null) {
      final responseData = error.response!.data;
      if (responseData is Map<String, dynamic>) {
        message = responseData['message'] ?? message;
      }
    }

    return ApiResponse<T>(
      status: 'fail',
      message: message,
      data: null,
    );
  }

  // Upload file with multipart
  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required File file,
    required String fieldName,
    Map<String, dynamic>? data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        if (data != null) ...data,
      });

      final response = await _dio.post(
        path,
        data: formData,
      );
      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }
}
