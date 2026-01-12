import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kReleaseMode;

// API endpoints
class ApiConstants {
  /// Override these at runtime with:
  /// `--dart-define=API_BASE_URL=http://<ip>:5001/api/v1`
  /// `--dart-define=SOCKET_URL=http://<ip>:5001`
  ///
  /// Defaults:
  /// - Android emulator: `10.0.2.2` maps to your host machine's localhost
  /// - iOS simulator / desktop: `localhost`
  static String get baseUrl {
    const defined = String.fromEnvironment('API_BASE_URL');
    if (defined.isNotEmpty) return defined;

    if (kReleaseMode) return 'http://localhost:5001/api/v1';
    if (Platform.isAndroid) return 'http://10.0.2.2:5001/api/v1';
    return 'http://localhost:5001/api/v1';
  }

  static String get socketUrl {
    const defined = String.fromEnvironment('SOCKET_URL');
    if (defined.isNotEmpty) return defined;

    if (kReleaseMode) return 'http://localhost:5001';
    if (Platform.isAndroid) return 'http://10.0.2.2:5001';
    return 'http://localhost:5001';
  }
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String firebaseAuth = '/auth/firebase';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String me = '/auth/me';
  
  // Driver endpoints
  static const String driverRegister = '/drivers/register';
  static const String driverProfile = '/driver/profile';
  static const String updateLocation = '/drivers/location';
  static const String toggleOnline = '/drivers/toggle-online';
  static const String nearbyDrivers = '/drivers/nearby';
  
  // Ride endpoints
  static const String rides = '/rides';
  static const String rideStats = '/rides/stats';
  
  // Vehicle endpoints
  static const String vehicleTypes = '/vehicle-types';
  
  // Earnings endpoints
  static const String earnings = '/earnings';
  static const String earningsSummary = '/earnings/summary';
  
  // Socket events
  static const String socketJoin = 'join';
  static const String socketDriverLocation = 'driver:location';
  static const String socketRideRequest = 'ride:request';
  static const String socketRideAccepted = 'ride:accepted';
  static const String socketRideStatus = 'ride:status';
  static const String socketDriverLocationUpdate = 'driver:location:update';
  static const String socketRideNew = 'ride:new';
  static const String socketRideStatusUpdate = 'ride:status:update';
}

