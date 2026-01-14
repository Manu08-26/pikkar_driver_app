import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ParcelStorageService {
  static const _keyActiveParcelId = 'activeParcelId';
  static const _keyActiveParcelSnapshot = 'activeParcelSnapshot';

  Future<void> saveActiveParcel({required String parcelId, Map<String, dynamic>? snapshot}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyActiveParcelId, parcelId);
    if (snapshot != null) {
      await prefs.setString(_keyActiveParcelSnapshot, jsonEncode(snapshot));
    }
  }

  Future<String?> getActiveParcelId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyActiveParcelId);
  }

  Future<Map<String, dynamic>?> getActiveParcelSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyActiveParcelSnapshot);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearActiveParcel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyActiveParcelId);
    await prefs.remove(_keyActiveParcelSnapshot);
  }
}

