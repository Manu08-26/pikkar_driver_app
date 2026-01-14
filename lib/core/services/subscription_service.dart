import '../models/api_response.dart';
import 'api_client.dart';

class SubscriptionService {
  final ApiClient _apiClient = ApiClient();

  /// Driver app UI payload (recommended)
  Future<ApiResponse<Map<String, dynamic>>> getUi() async {
    try {
      return await _apiClient.get<Map<String, dynamic>>(
        '/subscriptions/ui',
        fromJson: (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      return ApiResponse(status: 'fail', message: e.toString());
    }
  }

  Future<ApiResponse<List<dynamic>>> getPlans() async {
    try {
      return await _apiClient.get<List<dynamic>>(
        '/subscriptions/plans',
        fromJson: (json) {
          // Backend returns { status, data:{ plans:[...] } } OR { status, data:[...] } depending on impl.
          if (json is Map<String, dynamic>) {
            final plans = json['plans'];
            if (plans is List) return plans;
          }
          if (json is List) return json;
          return <dynamic>[];
        },
      );
    } catch (e) {
      return ApiResponse(status: 'fail', message: e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getActive() async {
    try {
      return await _apiClient.get<Map<String, dynamic>>(
        '/subscriptions/active',
        fromJson: (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      return ApiResponse(status: 'fail', message: e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> subscribe({
    String? planId,
    String? planCode,
    String paymentMethod = 'wallet',
  }) async {
    try {
      return await _apiClient.post<Map<String, dynamic>>(
        '/subscriptions/subscribe',
        data: {
          if (planId != null) 'planId': planId,
          if (planCode != null) 'planCode': planCode,
          'paymentMethod': paymentMethod,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      return ApiResponse(status: 'fail', message: e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> cancel({String? reason}) async {
    try {
      return await _apiClient.post<Map<String, dynamic>>(
        '/subscriptions/cancel',
        data: {if (reason != null) 'reason': reason},
        fromJson: (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      return ApiResponse(status: 'fail', message: e.toString());
    }
  }
}

