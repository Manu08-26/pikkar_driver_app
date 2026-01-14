import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/driver_model.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final SocketService _socketService = SocketService();

  UserModel? _user;
  DriverModel? _driver;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  DriverModel? get driver => _driver;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isDriver => _user?.role == 'driver';

  AuthProvider() {
    _loadUserFromStorage();
  }

  // Load user from storage on app start
  Future<void> _loadUserFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.loadUserFromStorage();
      _user = _authService.currentUser;
      _driver = _authService.currentDriver;

      // If user session exists, ensure socket is connected for real-time updates.
      if (_user != null) {
        await _socketService.connect();
      }
    } catch (e) {
      print('Error loading user from storage: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // NOTE: OTP-only app.
  // We intentionally do not expose email/password auth methods here to avoid accidental usage.

  // Login via Firebase Phone OTP (recommended)
  Future<bool> loginWithFirebase({required String idToken}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.loginWithFirebase(
        idToken: idToken,
        role: 'driver',
      );

      if (response.isSuccess) {
        _user = _authService.currentUser;
        _driver = _authService.currentDriver;
        _errorMessage = null;
        // Start socket real-time after successful auth (token now available).
        await _socketService.connect();
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Login failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Request OTP for phone login
  Future<bool> requestLoginOtp({
    required String phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.requestLoginOtp(phone: phone);

      if (response.isSuccess) {
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to send OTP';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verify OTP for phone login
  Future<bool> verifyLoginOtp({
    required String phone,
    required String otp,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.verifyLoginOtp(phone: phone, otp: otp);

      if (response.isSuccess) {
        _user = _authService.currentUser;
        _driver = _authService.currentDriver;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Invalid OTP';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Exchange Firebase ID token for backend JWT tokens
  Future<bool> loginWithFirebaseIdToken({
    required String idToken,
    String role = 'driver',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.loginWithFirebaseIdToken(
        idToken: idToken,
        role: role,
      );

      if (response.isSuccess) {
        _user = _authService.currentUser;
        _driver = _authService.currentDriver;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Login failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    try {
      final response = await _authService.getCurrentUser();
      if (response.isSuccess) {
        _user = response.data;
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing user: $e');
    }
  }

  // Load user from storage (public method)
  Future<void> loadUserFromStorage() async {
    await _loadUserFromStorage();
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _socketService.disconnect();
      _user = null;
      _driver = null;
      _errorMessage = null;
    } catch (e) {
      print('Error during logout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Update driver
  void updateDriver(DriverModel driver) {
    _driver = driver;
    notifyListeners();
  }
}
