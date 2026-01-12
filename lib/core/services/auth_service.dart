import '../models/user_model.dart';
import '../models/driver_model.dart';
import '../models/auth_tokens.dart';
import '../models/api_response.dart';
import 'api_client.dart';
import 'token_storage_service.dart';
import '../constants/api_constants.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final TokenStorageService _tokenStorage = TokenStorageService();

  UserModel? _currentUser;
  DriverModel? _currentDriver;

  UserModel? get currentUser => _currentUser;
  DriverModel? get currentDriver => _currentDriver;

  // Register new user/driver
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    String role = 'driver',
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.register,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'password': password,
          'role': role,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        // Save user and tokens
        final user = UserModel.fromJson(response.data!['user']);
        final tokens = AuthTokens.fromJson(response.data!['tokens']);
        
        await _tokenStorage.saveUser(user);
        await _tokenStorage.saveTokens(tokens);
        _currentUser = user;
      }

      return response;
    } catch (e) {
      return ApiResponse(
        status: 'fail',
        message: e.toString(),
      );
    }
  }

  // Login with email and password
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        // Save user and tokens
        final user = UserModel.fromJson(response.data!['user']);
        final tokens = AuthTokens.fromJson(response.data!['tokens']);
        
        await _tokenStorage.saveUser(user);
        await _tokenStorage.saveTokens(tokens);
        _currentUser = user;

        // If user is a driver, fetch driver profile
        if (user.role == 'driver') {
          await getCurrentDriver();
        }
      }

      return response;
    } catch (e) {
      return ApiResponse(
        status: 'fail',
        message: e.toString(),
      );
    }
  }

  // Request OTP for phone login (sends OTP to phone)
  Future<ApiResponse<Map<String, dynamic>>> requestLoginOtp({
    required String phone,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {
          'phone': phone,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      return response;
    } catch (e) {
      return ApiResponse(
        status: 'fail',
        message: e.toString(),
      );
    }
  }

  // Verify OTP for phone login (exchanges OTP for tokens)
  Future<ApiResponse<Map<String, dynamic>>> verifyLoginOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.verifyOtp,
        data: {
          'phone': phone,
          'otp': otp,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        final payload = response.data!;

        final userJson = payload['user'];
        final tokensJson = payload['tokens'];
        final driverJson = payload['driver'];

        if (userJson is Map<String, dynamic> && tokensJson is Map<String, dynamic>) {
          final user = UserModel.fromJson(userJson);
          final tokens = AuthTokens.fromJson(tokensJson);

          await _tokenStorage.saveUser(user);
          await _tokenStorage.saveTokens(tokens);
          _currentUser = user;

          if (driverJson is Map<String, dynamic>) {
            final driver = DriverModel.fromJson(driverJson);
            await _tokenStorage.saveDriver(driver);
            _currentDriver = driver;
          } else if (user.role == 'driver') {
            // If user is a driver, try loading driver profile from storage
            await getCurrentDriver();
          }
        }
      }

      return response;
    } catch (e) {
      return ApiResponse(
        status: 'fail',
        message: e.toString(),
      );
    }
  }

  // Exchange Firebase ID token for backend JWT tokens
  Future<ApiResponse<Map<String, dynamic>>> loginWithFirebaseIdToken({
    required String idToken,
    String role = 'driver',
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.firebaseAuth,
        data: {
          'idToken': idToken,
          'role': role,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        final payload = response.data!;

        final userJson = payload['user'];
        final tokensJson = payload['tokens'];
        final driverJson = payload['driver'];

        if (userJson is Map<String, dynamic> && tokensJson is Map<String, dynamic>) {
          final user = UserModel.fromJson(userJson);
          final tokens = AuthTokens.fromJson(tokensJson);

          await _tokenStorage.saveUser(user);
          await _tokenStorage.saveTokens(tokens);
          _currentUser = user;

          if (driverJson is Map<String, dynamic>) {
            final driver = DriverModel.fromJson(driverJson);
            await _tokenStorage.saveDriver(driver);
            _currentDriver = driver;
          } else if (user.role == 'driver') {
            await getCurrentDriver();
          }
        }
      }

      return response;
    } catch (e) {
      return ApiResponse(
        status: 'fail',
        message: e.toString(),
      );
    }
  }

  // Get current user profile
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    try {
      final response = await _apiClient.get<UserModel>(
        ApiConstants.me,
        fromJson: (json) => UserModel.fromJson(json['user']),
      );

      if (response.isSuccess && response.data != null) {
        _currentUser = response.data;
        await _tokenStorage.saveUser(response.data!);
      }

      return response;
    } catch (e) {
      return ApiResponse(
        status: 'fail',
        message: e.toString(),
      );
    }
  }

  // Get current driver profile (if user is a driver)
  Future<ApiResponse<DriverModel>> getCurrentDriver() async {
    try {
      // This would need a driver profile endpoint
      // For now, we'll check if driver data exists in storage
      final driver = await _tokenStorage.getDriver();
      if (driver != null) {
        _currentDriver = driver;
        return ApiResponse(
          status: 'success',
          data: driver,
        );
      }

      return ApiResponse(
        status: 'fail',
        message: 'Driver profile not found',
      );
    } catch (e) {
      return ApiResponse(
        status: 'fail',
        message: e.toString(),
      );
    }
  }

  // Refresh access token
  Future<ApiResponse<AuthTokens>> refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        return ApiResponse(
          status: 'fail',
          message: 'No refresh token found',
        );
      }

      final response = await _apiClient.post<AuthTokens>(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
        fromJson: (json) => AuthTokens.fromJson(json['tokens']),
      );

      if (response.isSuccess && response.data != null) {
        await _tokenStorage.saveTokens(response.data!);
      }

      return response;
    } catch (e) {
      return ApiResponse(
        status: 'fail',
        message: e.toString(),
      );
    }
  }

  // Logout
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _apiClient.post<void>(
        ApiConstants.logout,
      );

      // Clear local storage regardless of API response
      await _tokenStorage.clearAll();
      _currentUser = null;
      _currentDriver = null;

      return response;
    } catch (e) {
      // Still clear local storage on error
      await _tokenStorage.clearAll();
      _currentUser = null;
      _currentDriver = null;

      return ApiResponse(
        status: 'fail',
        message: e.toString(),
      );
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _tokenStorage.isLoggedIn();
  }

  // Load user from storage
  Future<void> loadUserFromStorage() async {
    _currentUser = await _tokenStorage.getUser();
    _currentDriver = await _tokenStorage.getDriver();
  }
}
