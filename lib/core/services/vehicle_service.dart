import '../models/vehicle_type_model.dart';
import '../models/api_response.dart';
import 'api_client.dart';
import '../constants/api_constants.dart';

class VehicleService {
  final ApiClient _apiClient = ApiClient();

  // Get all vehicle types
  Future<ApiResponse<List<VehicleType>>> getVehicleTypes({
    String? category, // 'ride' or 'delivery'
  }) async {
    try {
      // Backend:
      // - Ride vehicle types: GET /vehicle-types?category=ride -> { status, data:{ vehicleTypes:[...] } }
      // - Parcel vehicles:     GET /parcel-vehicles/active   -> { success:true, data:[...] }
      if (category == 'delivery') {
        final response = await _apiClient.get<List<VehicleType>>(
          '/parcel-vehicles/active',
          fromJson: (json) {
            final vehicles = (json as List);
            return vehicles.map((v) => VehicleType.fromJson(v as Map<String, dynamic>)).toList();
          },
        );
        return response;
      }

      final queryParams = category != null ? {'category': category} : null;
      final response = await _apiClient.get<List<VehicleType>>(
        ApiConstants.vehicleTypes,
        queryParameters: queryParams,
        fromJson: (json) {
          final vehicles = (json as Map<String, dynamic>)['vehicleTypes'] as List;
          return vehicles.map((v) => VehicleType.fromJson(v as Map<String, dynamic>)).toList();
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

  // Get vehicle types by category
  Future<ApiResponse<List<VehicleType>>> getRideVehicles() async {
    return getVehicleTypes(category: 'ride');
  }

  Future<ApiResponse<List<VehicleType>>> getDeliveryVehicles() async {
    return getVehicleTypes(category: 'delivery');
  }

  // Get single vehicle type by ID
  Future<ApiResponse<VehicleType>> getVehicleTypeById(String id) async {
    try {
      final response = await _apiClient.get<VehicleType>(
        '${ApiConstants.vehicleTypes}/$id',
        fromJson: (json) => VehicleType.fromJson(json['vehicleType']),
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
