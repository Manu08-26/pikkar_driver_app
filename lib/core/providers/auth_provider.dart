import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/driver_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

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
    } catch (e) {
      print('Error loading user from storage: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        role: 'driver',
      );

      if (response.isSuccess) {
        _user = _authService.currentUser;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Registration failed';
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

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
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
