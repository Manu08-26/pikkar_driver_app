// API endpoints
class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://api.pikkar.com/v1';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  
  // Driver endpoints
  static const String driverProfile = '/driver/profile';
  static const String updateLocation = '/driver/location';
  static const String toggleOnline = '/driver/toggle-online';
  static const String updateDocuments = '/driver/documents';
  
  // Ride endpoints
  static const String rides = '/rides';
  static const String acceptRide = '/rides/{id}/accept';
  static const String startRide = '/rides/{id}/start';
  static const String completeRide = '/rides/{id}/complete';
  static const String cancelRide = '/rides/{id}/cancel';
  
  // Earnings endpoints
  static const String earnings = '/earnings';
  static const String earningsSummary = '/earnings/summary';
  
  // Socket events
  static const String socketConnect = 'driver:connect';
  static const String socketNewRideRequest = 'ride:new-request';
  static const String socketRideCancelled = 'ride:cancelled';
}

