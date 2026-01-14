import 'package:flutter/material.dart';
import '../models/ride_model.dart';
import '../services/ride_service.dart';
import '../services/socket_service.dart';

class RideProvider with ChangeNotifier {
  final RideService _rideService = RideService();
  final SocketService _socketService = SocketService();

  RideModel? _currentRide;
  List<RideModel> _rideHistory = [];
  List<RideModel> _pendingRides = [];
  bool _isLoading = false;
  String? _errorMessage;

  RideModel? get currentRide => _currentRide;
  List<RideModel> get rideHistory => _rideHistory;
  List<RideModel> get pendingRides => _pendingRides;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasActiveRide => _currentRide != null;

  RideProvider() {
    _loadActiveRide();
    _setupSocketListeners();
  }

  // Load active ride
  Future<void> _loadActiveRide() async {
    try {
      final response = await _rideService.getActiveRide();
      if (response.isSuccess && response.data != null) {
        _currentRide = response.data;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading active ride: $e');
    }
  }

  // Setup socket listeners
  void _setupSocketListeners() {
    // Listen for new ride requests
    _socketService.onRideRequest.listen((ride) {
      _pendingRides.add(ride);
      notifyListeners();
    });

    // Listen for ride status updates
    _socketService.onRideStatusUpdate.listen((ride) {
      if (_currentRide?.id == ride.id) {
        _currentRide = ride;
        notifyListeners();
      }
    });
  }

  /// Driver: refresh available rides list (polling/fallback)
  Future<void> refreshAvailableRides({
    required double latitude,
    required double longitude,
    double radiusKm = 5,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _rideService.getAvailableRides(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      if (response.isSuccess && response.data != null) {
        _pendingRides = response.data!;
        _errorMessage = null;
      } else {
        _errorMessage = response.message ?? 'Failed to load available rides';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get rides with pagination
  Future<void> getRides({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _rideService.getRides(
        page: page,
        limit: limit,
        status: status,
      );

      if (response.isSuccess && response.data != null) {
        if (status == 'completed') {
          _rideHistory = response.data!;
        }
        _errorMessage = null;
      } else {
        _errorMessage = response.message ?? 'Failed to load rides';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Accept ride
  Future<bool> acceptRide(String rideId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _rideService.acceptRide(rideId);

      if (response.isSuccess && response.data != null) {
        _currentRide = response.data;
        _pendingRides.removeWhere((r) => r.id == rideId);
        _errorMessage = null;
        
        // Notify via socket
        _socketService.notifyRideAccepted(response.data!);
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to accept ride';
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

  // Mark arrived
  Future<bool> markArrived() async {
    if (_currentRide == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _rideService.markArrived(_currentRide!.id);

      if (response.isSuccess && response.data != null) {
        _currentRide = response.data;
        _errorMessage = null;
        
        // Update via socket
        _socketService.updateRideStatus(response.data!);
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to update status';
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

  // Start ride
  Future<bool> startRide({required String otp}) async {
    if (_currentRide == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _rideService.startRide(_currentRide!.id, otp: otp);

      if (response.isSuccess && response.data != null) {
        _currentRide = response.data;
        _errorMessage = null;
        
        // Update via socket
        _socketService.updateRideStatus(response.data!);
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to start ride';
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

  // Complete ride
  Future<bool> completeRide() async {
    if (_currentRide == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _rideService.completeRide(_currentRide!.id);

      if (response.isSuccess && response.data != null) {
        _currentRide = null;
        _errorMessage = null;
        
        // Update via socket
        _socketService.updateRideStatus(response.data!);
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to complete ride';
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

  // Cancel ride
  Future<bool> cancelRide(String reason) async {
    if (_currentRide == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _rideService.cancelRide(
        rideId: _currentRide!.id,
        reason: reason,
      );

      if (response.isSuccess) {
        _currentRide = null;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to cancel ride';
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

  // Rate customer
  Future<bool> rateCustomer({
    required double rating,
    String? review,
  }) async {
    if (_currentRide == null) return false;

    try {
      final response = await _rideService.rateRide(
        rideId: _currentRide!.id,
        rating: rating,
        review: review,
      );

      return response.isSuccess;
    } catch (e) {
      print('Error rating customer: $e');
      return false;
    }
  }

  // Load ride history
  Future<void> loadRideHistory({int page = 1}) async {
    await getRides(page: page, limit: 20, status: 'completed');
  }

  // Fetch ride history (alias for backward compatibility)
  Future<void> fetchRideHistory({int page = 1}) async {
    await loadRideHistory(page: page);
  }

  // Fetch ride stats
  Map<String, dynamic>? _rideStats;
  Map<String, dynamic>? get rideStats => _rideStats;

  Future<void> fetchRideStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Calculate stats from ride history
      await getRides(status: 'completed', limit: 100);
      
      final today = DateTime.now();
      final todayRides = _rideHistory.where((ride) {
        if (ride.createdAt == null) return false;
        return ride.createdAt!.day == today.day &&
            ride.createdAt!.month == today.month &&
            ride.createdAt!.year == today.year;
      }).toList();

      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final weekRides = _rideHistory.where((ride) {
        if (ride.createdAt == null) return false;
        return ride.createdAt!.isAfter(weekStart);
      }).toList();

      final monthRides = _rideHistory.where((ride) {
        if (ride.createdAt == null) return false;
        return ride.createdAt!.month == today.month &&
            ride.createdAt!.year == today.year;
      }).toList();

      double todayEarnings = 0.0;
      double todayDistance = 0.0;
      double weeklyEarnings = 0.0;
      double monthlyEarnings = 0.0;

      for (var ride in todayRides) {
        todayEarnings += ride.actualFare ?? ride.estimatedFare ?? 0.0;
        todayDistance += ride.distance ?? 0.0;
      }

      for (var ride in weekRides) {
        weeklyEarnings += ride.actualFare ?? ride.estimatedFare ?? 0.0;
      }

      for (var ride in monthRides) {
        monthlyEarnings += ride.actualFare ?? ride.estimatedFare ?? 0.0;
      }

      _rideStats = {
        'todayRides': todayRides.length,
        'todayEarnings': todayEarnings,
        'todayDistance': todayDistance,
        'todayHours': todayRides.length * 0.5, // Approximate
        'lastRidePayment': todayRides.isNotEmpty
            ? (todayRides.last.actualFare ?? todayRides.last.estimatedFare ?? 0.0)
            : 0.0,
        'weeklyEarnings': weeklyEarnings,
        'monthlyEarnings': monthlyEarnings,
      };

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _rideStats = {
        'todayRides': 0,
        'todayEarnings': 0.0,
        'todayDistance': 0.0,
        'todayHours': 0.0,
        'lastRidePayment': 0.0,
        'weeklyEarnings': 0.0,
        'monthlyEarnings': 0.0,
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear current ride (for testing)
  void clearCurrentRide() {
    _currentRide = null;
    notifyListeners();
  }

  // Remove pending ride
  void removePendingRide(String rideId) {
    _pendingRides.removeWhere((r) => r.id == rideId);
    notifyListeners();
  }
}
