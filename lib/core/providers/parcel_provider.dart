import 'package:flutter/material.dart';
import '../models/parcel_model.dart';
import '../services/parcel_service.dart';
import '../services/parcel_storage_service.dart';
import '../services/socket_service.dart';

class ParcelProvider with ChangeNotifier {
  final ParcelService _parcelService = ParcelService();
  final ParcelStorageService _storage = ParcelStorageService();
  final SocketService _socketService = SocketService();

  bool _isLoading = false;
  String? _errorMessage;
  List<ParcelModel> _available = [];
  ParcelModel? _activeParcel;

  double? _lastLatitude;
  double? _lastLongitude;
  double _lastRadiusKm = 5;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ParcelModel> get availableParcels => _available;
  ParcelModel? get activeParcel => _activeParcel;

  ParcelProvider() {
    _restoreActive();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    // New parcel available for drivers
    _socketService.onParcelNew.listen((data) async {
      // If we have last known coords, refresh to apply backend geo filtering.
      if (_lastLatitude != null && _lastLongitude != null) {
        await refreshAvailable(
          latitude: _lastLatitude!,
          longitude: _lastLongitude!,
          radiusKm: _lastRadiusKm,
        );
      } else {
        // No location yet: show a lightweight signal by appending (best-effort).
        try {
          final parcel = ParcelModel.fromJson(data);
          final exists = _available.any((p) => p.id == parcel.id);
          if (!exists) {
            _available = [parcel, ..._available];
            notifyListeners();
          }
        } catch (_) {
          // ignore parsing issues
        }
      }
    });

    // Parcel removed from availability (claimed/cancelled)
    _socketService.onParcelUnavailable.listen((data) {
      final id = (data['id'] ?? data['_id'] ?? '').toString();
      if (id.isEmpty) return;
      _available.removeWhere((p) => p.id == id);
      notifyListeners();
    });

    // Updates for active parcel / multi-device
    _socketService.onParcelUpdate.listen((data) async {
      try {
        final updated = ParcelModel.fromJson(data);
        // Update active parcel snapshot
        if (_activeParcel?.id == updated.id) {
          if (updated.status == 'cancelled' || updated.status == 'delivered') {
            _activeParcel = null;
            await _storage.clearActiveParcel();
          } else {
            _activeParcel = updated;
            await _storage.saveActiveParcel(parcelId: updated.id, snapshot: updated.toJson());
          }
          notifyListeners();
          return;
        }

        // If it's an available parcel, update list entry
        final idx = _available.indexWhere((p) => p.id == updated.id);
        if (idx >= 0) {
          // If it is no longer pending, remove from available list
          if (updated.status != 'pending') {
            _available.removeAt(idx);
          } else {
            _available[idx] = updated;
          }
          notifyListeners();
        }
      } catch (_) {
        // ignore
      }
    });
  }

  Future<void> _restoreActive() async {
    try {
      final id = await _storage.getActiveParcelId();
      if (id == null || id.isEmpty) return;
      final res = await _parcelService.getById(id);
      if (res.isSuccess && res.data != null) {
        _activeParcel = res.data;
        notifyListeners();
        return;
      }
      await _storage.clearActiveParcel();
    } catch (_) {
      // ignore
    }
  }

  Future<void> refreshAvailable({required double latitude, required double longitude, double radiusKm = 5}) async {
    _lastLatitude = latitude;
    _lastLongitude = longitude;
    _lastRadiusKm = radiusKm;
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _parcelService.getAvailableParcels(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      if (res.isSuccess && res.data != null) {
        _available = res.data!;
        _errorMessage = null;
      } else {
        _errorMessage = res.message ?? 'Failed to load parcels';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> accept(String parcelId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _parcelService.acceptParcel(parcelId);
      if (res.isSuccess && res.data != null) {
        _activeParcel = res.data;
        await _storage.saveActiveParcel(parcelId: _activeParcel!.id, snapshot: _activeParcel!.toJson());
        _available.removeWhere((p) => p.id == parcelId);
        _errorMessage = null;
        return true;
      }
      _errorMessage = res.message ?? 'Failed to accept parcel';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> pickup({required String otp}) async {
    if (_activeParcel == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _parcelService.pickupParcel(parcelId: _activeParcel!.id, otp: otp);
      if (res.isSuccess && res.data != null) {
        _activeParcel = res.data;
        await _storage.saveActiveParcel(parcelId: _activeParcel!.id, snapshot: _activeParcel!.toJson());
        _errorMessage = null;
        return true;
      }
      _errorMessage = res.message ?? 'Pickup failed';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deliver({required String otp}) async {
    if (_activeParcel == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _parcelService.deliverParcel(parcelId: _activeParcel!.id, otp: otp);
      if (res.isSuccess && res.data != null) {
        _activeParcel = null; // completed
        await _storage.clearActiveParcel();
        _errorMessage = null;
        return true;
      }
      _errorMessage = res.message ?? 'Delivery failed';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markInTransit() async {
    if (_activeParcel == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _parcelService.markInTransit(parcelId: _activeParcel!.id);
      if (res.isSuccess && res.data != null) {
        _activeParcel = res.data;
        await _storage.saveActiveParcel(parcelId: _activeParcel!.id, snapshot: _activeParcel!.toJson());
        _errorMessage = null;
        return true;
      }
      _errorMessage = res.message ?? 'Update failed';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

