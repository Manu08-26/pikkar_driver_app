import '../models/driver_model.dart';
import '../models/api_response.dart';
import 'api_client.dart';
import 'token_storage_service.dart';
import '../constants/api_constants.dart';

class DriverService {
  final ApiClient _apiClient = ApiClient();
  final TokenStorageService _tokenStorage = TokenStorageService();

  // Register as a driver
  Future<ApiResponse<DriverModel>> registerDriver({
    required String licenseNumber,
    required String licenseExpiry,
    required String vehicleType,
    required String vehicleModel,
    required String vehicleMake,
    required int vehicleYear,
    required String vehicleColor,
    required String vehicleNumber,
  }) async {
    try {
      final response = await _apiClient.post<DriverModel>(
        ApiConstants.driverRegister,
        data: {
          'licenseNumber': licenseNumber,
          'licenseExpiry': licenseExpiry,
          'vehicleType': vehicleType,
          'vehicleModel': vehicleModel,
          'vehicleMake': vehicleMake,
          'vehicleYear': vehicleYear,
          'vehicleColor': vehicleColor,
          'vehicleNumber': vehicleNumber,
        },
        fromJson: (json) => DriverModel.fromJson(json['driver']),
      );

      if (response.isSuccess && response.data != null) {
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

  // Get nearby drivers
  Future<ApiResponse<List<DriverModel>>> getNearbyDrivers({
    required double longitude,
    required double latitude,
    int maxDistance = 5000,
    String? vehicleType,
  }) async {
    try {
      final queryParams = {
        'longitude': longitude.toString(),
        'latitude': latitude.toString(),
        'maxDistance': maxDistance.toString(),
        if (vehicleType != null) 'vehicleType': vehicleType,
      };

      final response = await _apiClient.get<List<DriverModel>>(
        ApiConstants.nearbyDrivers,
        queryParameters: queryParams,
        fromJson: (json) {
          final drivers = json['drivers'] as List;
          return drivers.map((d) => DriverModel.fromJson(d)).toList();
        },
      );

      return response;
    } catch (e) {
      return ApiResponse(
        status: 'fail',
        message: e.toString(),
      );
    }
  }

  // Update driver location
  Future<ApiResponse<DriverModel>> updateLocation({
    required double longitude,
    required double latitude,
  }) async {
    try {
      final response = await _apiClient.put<DriverModel>(
        ApiConstants.updateLocation,
        data: {
          'longitude': longitude,
          'latitude': latitude,
        },
        fromJson: (json) => DriverModel.fromJson(json['driver']),
      );

      if (response.isSuccess && response.data != null) {
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

  // Toggle online/offline status
  Future<ApiResponse<Map<String, dynamic>>> toggleOnlineStatus() async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        ApiConstants.toggleOnline,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.isSuccess) {
        // Update local driver data
        final driver = await _tokenStorage.getDriver();
        if (driver != null && response.data != null) {
          final updatedDriver = driver.copyWith(
            isOnline: response.data!['isOnline'] as bool,
          );
          await _tokenStorage.saveDriver(updatedDriver);
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

  // Get driver profile from storage
  Future<DriverModel?> getDriverFromStorage() async {
    return await _tokenStorage.getDriver();
  }

  // Verify driver (Admin only - included for completeness)
  Future<ApiResponse<DriverModel>> verifyDriver({
    required String driverId,
    required String status, // 'approved' or 'rejected'
  }) async {
    try {
      final response = await _apiClient.put<DriverModel>(
        '/drivers/$driverId/verify',
        data: {'status': status},
        fromJson: (json) => DriverModel.fromJson(json['driver']),
      );

      return response;
    } catch (e) {
      return ApiResponse(
        status: 'fail',
        message: e.toString(),
      );
    }
  }

  // Get driver statistics (if available)
  Future<ApiResponse<Map<String, dynamic>>> getDriverStats() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/drivers/stats',
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
}
