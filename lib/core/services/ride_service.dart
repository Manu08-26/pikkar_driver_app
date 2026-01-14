import '../models/ride_model.dart';
import '../models/api_response.dart';
import 'api_client.dart';
import '../constants/api_constants.dart';

class RideService {
  final ApiClient _apiClient = ApiClient();

  // Driver: fetch available ride requests near current location
  Future<ApiResponse<List<RideModel>>> getAvailableRides({
    required double latitude,
    required double longitude,
    double radiusKm = 5,
  }) async {
    try {
      final response = await _apiClient.get<List<RideModel>>(
        ApiConstants.ridesAvailable,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radiusKm': radiusKm,
        },
        fromJson: (json) {
          final rides = (json['rides'] ?? []) as List;
          return rides.map((r) => RideModel.fromJson(r)).toList();
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

  // Request a new ride (User functionality, but included for completeness)
  Future<ApiResponse<RideModel>> requestRide({
    required List<double> pickupCoordinates,
    required String pickupAddress,
    required List<double> dropoffCoordinates,
    required String dropoffAddress,
    required String vehicleType,
    required String paymentMethod,
    DateTime? scheduledTime,
  }) async {
    try {
      final response = await _apiClient.post<RideModel>(
        ApiConstants.rides,
        data: {
          'pickupLocation': {
            'coordinates': pickupCoordinates,
            'address': pickupAddress,
          },
          'dropoffLocation': {
            'coordinates': dropoffCoordinates,
            'address': dropoffAddress,
          },
          'vehicleType': vehicleType,
          'paymentMethod': paymentMethod,
          if (scheduledTime != null) 
            'scheduledTime': scheduledTime.toIso8601String(),
        },
        fromJson: (json) => RideModel.fromJson(json['ride']),
      );

      return response;
    } catch (e) {
      return ApiResponse(
        status: 'fail',
        message: e.toString(),
      );
    }
  }

  // Get all rides (filtered by user role)
  Future<ApiResponse<List<RideModel>>> getRides({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
      };

      final response = await _apiClient.get<List<RideModel>>(
        ApiConstants.rides,
        queryParameters: queryParams,
        fromJson: (json) {
          final rides = json['rides'] as List;
          return rides.map((r) => RideModel.fromJson(r)).toList();
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

  // Get single ride by ID
  Future<ApiResponse<RideModel>> getRideById(String rideId) async {
    try {
      final response = await _apiClient.get<RideModel>(
        '${ApiConstants.rides}/$rideId',
        fromJson: (json) => RideModel.fromJson(json['ride']),
      );

      return response;
    } catch (e) {
      return ApiResponse(
        status: 'fail',
        message: e.toString(),
      );
    }
  }

  // Accept ride (Driver only)
  Future<ApiResponse<RideModel>> acceptRide(String rideId) async {
    try {
      final response = await _apiClient.put<RideModel>(
        '${ApiConstants.rides}/$rideId/accept',
        fromJson: (json) => RideModel.fromJson(json['ride']),
      );

      return response;
    } catch (e) {
      return ApiResponse(
        status: 'fail',
        message: e.toString(),
      );
    }
  }

  // Update ride status (Driver only)
  // Status can be: 'arrived', 'started', or 'completed'
  Future<ApiResponse<RideModel>> updateRideStatus({
    required String rideId,
    required String status,
    String? otp,
  }) async {
    try {
      final response = await _apiClient.put<RideModel>(
        '${ApiConstants.rides}/$rideId/status',
        data: {
          'status': status,
          if (otp != null) 'otp': otp,
        },
        fromJson: (json) => RideModel.fromJson(json['ride']),
      );

      return response;
    } catch (e) {
      return ApiResponse(
        status: 'fail',
        message: e.toString(),
      );
    }
  }

  // Mark driver as arrived
  Future<ApiResponse<RideModel>> markArrived(String rideId) async {
    return updateRideStatus(rideId: rideId, status: 'arrived');
  }

  // Start ride
  Future<ApiResponse<RideModel>> startRide(String rideId, {required String otp}) async {
    return updateRideStatus(rideId: rideId, status: 'started', otp: otp);
  }

  // Complete ride
  Future<ApiResponse<RideModel>> completeRide(String rideId) async {
    return updateRideStatus(rideId: rideId, status: 'completed');
  }

  // Cancel ride
  Future<ApiResponse<RideModel>> cancelRide({
    required String rideId,
    required String reason,
  }) async {
    try {
      final response = await _apiClient.put<RideModel>(
        '${ApiConstants.rides}/$rideId/cancel',
        data: {'reason': reason},
        fromJson: (json) => RideModel.fromJson(json['ride']),
      );

      return response;
    } catch (e) {
      return ApiResponse(
        status: 'fail',
        message: e.toString(),
      );
    }
  }

  // Rate ride
  Future<ApiResponse<RideModel>> rateRide({
    required String rideId,
    required double rating,
    String? review,
  }) async {
    try {
      final response = await _apiClient.put<RideModel>(
        '${ApiConstants.rides}/$rideId/rate',
        data: {
          'rating': rating,
          if (review != null) 'review': review,
        },
        fromJson: (json) => RideModel.fromJson(json['ride']),
      );

      return response;
    } catch (e) {
      return ApiResponse(
        status: 'fail',
        message: e.toString(),
      );
    }
  }

  // Get ride statistics (Admin/Driver)
  Future<ApiResponse<Map<String, dynamic>>> getRideStats() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.rideStats,
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

  // Get active ride for driver
  Future<ApiResponse<RideModel?>> getActiveRide() async {
    try {
      final response = await getRides(
        page: 1,
        limit: 1,
        status: 'accepted,arrived,started',
      );

      if (response.isSuccess && response.data != null && response.data!.isNotEmpty) {
        return ApiResponse(
          status: 'success',
          data: response.data!.first,
        );
      }

      return ApiResponse(
        status: 'success',
        data: null,
        message: 'No active ride',
      );
    } catch (e) {
      return ApiResponse(
        status: 'fail',
        message: e.toString(),
      );
    }
  }

  // Get ride history
  Future<ApiResponse<List<RideModel>>> getRideHistory({
    int page = 1,
    int limit = 20,
  }) async {
    return getRides(
      page: page,
      limit: limit,
      status: 'completed',
    );
  }
}
