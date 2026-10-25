import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-user data store backed by Cloud Firestore.
///   users/{uid}/data/{key}  ->  { v: <value>, updatedAt }
/// Everything is cached in memory (loaded once after login) so screens can
/// read synchronously; writes go to Firestore in the background and Firestore's
/// offline cache keeps them safe until the phone is online again.
class Store {
  static late SharedPreferences _p;
  static final Map<String, dynamic> _cache = {};
  static String? _uid;
  /// Bumped on every save so other open screens can refresh.
  static final changed = ValueNotifier<int>(0);

  static Future<void> init() async => _p = await SharedPreferences.getInstance();

  // ---- device-only values (e.g. profile photo path) ----
  static String? localGet(String k) => _p.getString(k);
  static Future<void> localSet(String k, String? v) async => v == null ? _p.remove(k) : _p.setString(k, v);

  // ---- per-user cloud data ----
  static CollectionReference<Map<String, dynamic>> _col(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('data');

  static Future<void> loadUser(String uid) async {
    _uid = uid;
    _cache.clear();
    Future<bool> fill(Source src, {Duration? wait}) async {
      try {
        final f = _col(uid).get(GetOptions(source: src));
        final snap = wait == null ? await f : await f.timeout(wait);
        for (final d in snap.docs) {
          final m = d.data();
          _cache[d.id] = m.containsKey('json') ? jsonDecode(m['json'] as String) : m['v'];
        }
        return snap.docs.isNotEmpty;
      } catch (_) {
        return false;
      }
    }

    // 1) instant and works offline: whatever is already saved on this phone
    final onPhone = await fill(Source.cache);
    // 2) nothing on this phone yet (first login on this device): ask the server
    if (!onPhone) await fill(Source.server, wait: const Duration(seconds: 8));
  }

  static void clear() {
    _uid = null;
    _cache.clear();
  }

  static String? getString(String k) {
    final v = _cache[k];
    return v is String ? v : null;
  }

  static dynamic getJson(String k) => _cache[k];

  static Future<void> setString(String k, String? v) async => _put(k, v);

  static Future<void> setJson(String k, Object v) async {
    _put(k, v);
    changed.value++;
  }

  static void _put(String k, dynamic v) {
    final uid = _uid;
    if (uid == null) return;
    if (v == null) {
      _cache.remove(k);
      _col(uid).doc(k).delete().catchError((_) {});
      return;
    }
    _cache[k] = v;
    // Firestore does not allow lists inside lists, so those are stored as a JSON string.
    final nested = v is List && v.any((e) => e is List);
    _col(uid).doc(k).set({
      nested ? 'json' : 'v': nested ? jsonEncode(v) : v,
      'updatedAt': FieldValue.serverTimestamp(),
    }).catchError((_) {});
  }
}
