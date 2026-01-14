import '../models/api_response.dart';
import '../models/parcel_model.dart';
import 'api_client.dart';

class ParcelService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<List<ParcelModel>>> getAvailableParcels({
    required double latitude,
    required double longitude,
    double radiusKm = 5,
  }) async {
    try {
      final response = await _apiClient.get<List<ParcelModel>>(
        '/parcels/available',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radiusKm': radiusKm,
        },
        fromJson: (json) {
          final parcels = (json['parcels'] ?? []) as List;
          return parcels.map((p) => ParcelModel.fromJson(p)).toList();
        },
      );
      return response;
    } catch (e) {
      return ApiResponse(status: 'fail', message: e.toString());
    }
  }

  Future<ApiResponse<ParcelModel>> acceptParcel(String parcelId) async {
    try {
      final response = await _apiClient.put<ParcelModel>(
        '/parcels/$parcelId/accept',
        fromJson: (json) => ParcelModel.fromJson(json['parcel']),
      );
      return response;
    } catch (e) {
      return ApiResponse(status: 'fail', message: e.toString());
    }
  }

  Future<ApiResponse<ParcelModel>> getById(String parcelId) async {
    try {
      final response = await _apiClient.get<ParcelModel>(
        '/parcels/$parcelId',
        fromJson: (json) => ParcelModel.fromJson(json['parcel']),
      );
      return response;
    } catch (e) {
      return ApiResponse(status: 'fail', message: e.toString());
    }
  }

  Future<ApiResponse<ParcelModel>> pickupParcel({required String parcelId, required String otp}) async {
    try {
      final response = await _apiClient.put<ParcelModel>(
        '/parcels/$parcelId/pickup',
        data: {'otp': otp},
        fromJson: (json) => ParcelModel.fromJson(json['parcel']),
      );
      return response;
    } catch (e) {
      return ApiResponse(status: 'fail', message: e.toString());
    }
  }

  Future<ApiResponse<ParcelModel>> markInTransit({required String parcelId}) async {
    try {
      final response = await _apiClient.put<ParcelModel>(
        '/parcels/$parcelId/in-transit',
        fromJson: (json) => ParcelModel.fromJson(json['parcel']),
      );
      return response;
    } catch (e) {
      return ApiResponse(status: 'fail', message: e.toString());
    }
  }

  Future<ApiResponse<ParcelModel>> deliverParcel({required String parcelId, required String otp}) async {
    try {
      final response = await _apiClient.put<ParcelModel>(
        '/parcels/$parcelId/deliver',
        data: {'otp': otp},
        fromJson: (json) => ParcelModel.fromJson(json['parcel']),
      );
      return response;
    } catch (e) {
      return ApiResponse(status: 'fail', message: e.toString());
    }
  }

  Future<ApiResponse<List<ParcelModel>>> getMyParcels({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiClient.get<List<ParcelModel>>(
        '/parcels',
        queryParameters: {'page': page, 'limit': limit},
        fromJson: (json) {
          final parcels = (json['parcels'] ?? []) as List;
          return parcels.map((p) => ParcelModel.fromJson(p)).toList();
        },
      );
      return response;
    } catch (e) {
      return ApiResponse(status: 'fail', message: e.toString());
    }
  }
}

