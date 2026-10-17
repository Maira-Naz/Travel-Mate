import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tiny key-value store on top of shared_preferences (saved on the device).
class Store {
  static late SharedPreferences _p;
  /// Bumped on every save so other open screens can refresh.
  static final changed = ValueNotifier<int>(0);

  static Future<void> init() async => _p = await SharedPreferences.getInstance();

  static String? getString(String k) => _p.getString(k);
  static Future<void> setString(String k, String? v) async =>
      v == null ? _p.remove(k) : _p.setString(k, v);

  static dynamic getJson(String k) {
    final s = _p.getString(k);
    if (s == null) return null;
    try {
      return jsonDecode(s);
    } catch (_) {
      return null;
    }
  }

  static Future<void> setJson(String k, Object v) async {
    await _p.setString(k, jsonEncode(v));
    changed.value++;
  }
}
