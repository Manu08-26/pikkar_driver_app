// API endpoints
class ApiConstants {
  // Base URL
  static const String baseUrl = 'http://localhost:5000/api/v1';
  
  // Socket URL
  static const String socketUrl = 'http://localhost:5000';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
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

