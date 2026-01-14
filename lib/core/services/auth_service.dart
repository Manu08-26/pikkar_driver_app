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

  // OTP-only app:
  // We intentionally do not support email/password login/register in the driver app.
  // Keeping these methods out avoids accidental API usage in production.
  @Deprecated('OTP-only app: use loginWithFirebase()')
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    String role = 'driver',
  }) async {
    throw UnsupportedError('OTP-only app: use Firebase phone OTP + /auth/firebase exchange.');
  }

  @Deprecated('OTP-only app: use loginWithFirebase()')
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    throw UnsupportedError('OTP-only app: use Firebase phone OTP + /auth/firebase exchange.');
  }

  /// Login via Firebase Phone OTP (recommended for drivers)
  /// Backend exchange: POST /auth/firebase { idToken, role: 'driver' }
  Future<ApiResponse<Map<String, dynamic>>> loginWithFirebase({
    required String idToken,
    String role = 'driver',
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.firebaseLogin,
        data: {
          'idToken': idToken,
          'role': role,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
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
      final response = await _apiClient.get<DriverModel>(
        ApiConstants.driverProfile,
        fromJson: (json) => DriverModel.fromJson((json as Map<String, dynamic>)['driver']),
      );

      if (response.isSuccess && response.data != null) {
        _currentDriver = response.data;
        await _tokenStorage.saveDriver(response.data!);
      }

      return response;
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
