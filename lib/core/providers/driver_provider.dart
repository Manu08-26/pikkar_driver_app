import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../services/driver_service.dart';

class DriverProvider with ChangeNotifier {
  final DriverService _driverService = DriverService();

  DriverModel? _driver;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOnline = false;

  DriverModel? get driver => _driver;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOnline => _isOnline;

  DriverProvider() {
    _loadDriverFromStorage();
  }

  // Load driver from storage
  Future<void> _loadDriverFromStorage() async {
    try {
      final driver = await _driverService.getDriverFromStorage();
      if (driver != null) {
        _driver = driver;
        _isOnline = driver.isOnline;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading driver from storage: $e');
    }
  }

  // Register as driver
  Future<bool> registerDriver({
    required String licenseNumber,
    required String licenseExpiry,
    required String vehicleType,
    required String vehicleModel,
    required String vehicleMake,
    required int vehicleYear,
    required String vehicleColor,
    required String vehicleNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _driverService.registerDriver(
        licenseNumber: licenseNumber,
        licenseExpiry: licenseExpiry,
        vehicleType: vehicleType,
        vehicleModel: vehicleModel,
        vehicleMake: vehicleMake,
        vehicleYear: vehicleYear,
        vehicleColor: vehicleColor,
        vehicleNumber: vehicleNumber,
      );

      if (response.isSuccess && response.data != null) {
        _driver = response.data;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Driver registration failed';
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

  // Update location
  Future<bool> updateLocation({
    required double longitude,
    required double latitude,
  }) async {
    try {
      final response = await _driverService.updateLocation(
        longitude: longitude,
        latitude: latitude,
      );

      if (response.isSuccess && response.data != null) {
        _driver = response.data;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating location: $e');
      return false;
    }
  }

  // Toggle online status
  Future<bool> toggleOnlineStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _driverService.toggleOnlineStatus();

      if (response.isSuccess && response.data != null) {
        _isOnline = response.data!['isOnline'] as bool;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to toggle status';
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

  // Set driver
  void setDriver(DriverModel driver) {
    _driver = driver;
    _isOnline = driver.isOnline;
    notifyListeners();
  }

  // Load driver from storage (public method)
  Future<void> loadDriverFromStorage() async {
    await _loadDriverFromStorage();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
