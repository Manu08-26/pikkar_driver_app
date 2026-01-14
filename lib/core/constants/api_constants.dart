import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// API endpoints
class ApiConstants {
  /// Backend API base URL.
  ///
  /// Runtime overrides:
  /// - flutter run --dart-define=PIKKAR_API_BASE_URL=http://10.0.2.2:5001/api/v1
  static String get baseUrl {
    const override = String.fromEnvironment('PIKKAR_API_BASE_URL');
    if (override.isNotEmpty) return override;

    if (kIsWeb) return 'http://localhost:5001/api/v1';
    if (Platform.isAndroid) return 'http://10.0.2.2:5001/api/v1';
    return 'http://localhost:5001/api/v1';
  }

  /// Backend socket base URL.
  ///
  /// Runtime overrides:
  /// - flutter run --dart-define=PIKKAR_SOCKET_URL=http://10.0.2.2:5001
  static String get socketUrl {
    const override = String.fromEnvironment('PIKKAR_SOCKET_URL');
    if (override.isNotEmpty) return override;

    if (kIsWeb) return 'http://localhost:5001';
    if (Platform.isAndroid) return 'http://10.0.2.2:5001';
    return 'http://localhost:5001';
  }

  // Auth endpoints
  // NOTE: Driver app should use Firebase phone OTP on client, then exchange idToken here.
  static const String firebaseLogin = '/auth/firebase';
  static const String login = '/auth/login'; // admin only (kept for compatibility)
  static const String register = '/auth/register'; // optional legacy
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String me = '/auth/me';
  
  // Driver endpoints
  static const String driverRegister = '/drivers/register';
  // Driver self profile (matches backend GET /api/v1/drivers/me)
  static const String driverProfile = '/drivers/me';
  static const String updateLocation = '/drivers/location';
  static const String toggleOnline = '/drivers/toggle-online';
  static const String nearbyDrivers = '/drivers/nearby';
  
  // Ride endpoints
  static const String rides = '/rides';
  static const String ridesAvailable = '/rides/available';
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

