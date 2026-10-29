import 'package:flutter/foundation.dart';
import 'storage.dart';

/// Saved places, language and notification settings (synced per user via Store).
class AppState {
  static final saved = ValueNotifier<List<String>>([]);
  /// Places saved from the map: {name, sub, lat, lon, at}
  static final savedMap = ValueNotifier<List<Map<String, dynamic>>>([]);
  static final language = ValueNotifier<String>('English');
  static final notifs = ValueNotifier<Map<String, bool>>(_defaultNotifs());
  static bool _hooked = false, _loading = false;

  static Map<String, bool> _defaultNotifs() =>
      {'Safety alerts': true, 'Weather updates': true, 'Booking reminders': true, 'Offers and tips': false};

  /// Call once at app start.
  static void init() {
    if (_hooked) return;
    _hooked = true;
    saved.addListener(() { if (!_loading) Store.setJson('saved_places', saved.value); });
    savedMap.addListener(() { if (!_loading) Store.setJson('saved_map_places', savedMap.value); });
    language.addListener(() { if (!_loading) Store.setString('language', language.value); });
    notifs.addListener(() { if (!_loading) Store.setJson('notif_settings', notifs.value); });
  }

  /// Call after login (Store already loaded).
  static void load() {
    _loading = true;
    final s = Store.getJson('saved_places');
    saved.value = s == null ? [] : List<String>.from(s);
    final sm = Store.getJson('saved_map_places');
    savedMap.value = sm is List ? sm.map((e) => Map<String, dynamic>.from(e as Map)).toList() : [];
    language.value = Store.getString('language') ?? 'English';
    final n = Store.getJson('notif_settings');
    notifs.value = {..._defaultNotifs(), if (n != null) ...Map<String, bool>.from(n)};
    _loading = false;
  }

  /// Call on logout.
  static void reset() {
    _loading = true;
    saved.value = [];
    savedMap.value = [];
    language.value = 'English';
    notifs.value = _defaultNotifs();
    _loading = false;
  }

  static bool isMapSaved(double lat, double lon) =>
      savedMap.value.any((m) => ((m['lat'] as num) - lat).abs() < 0.0005 && ((m['lon'] as num) - lon).abs() < 0.0005);

  /// Save or un-save a place picked on the map (the saved place keeps its map position).
  static void toggleMapSaved(String name, String sub, double lat, double lon) {
    final l = [...savedMap.value];
    final i = l.indexWhere((m) => ((m['lat'] as num) - lat).abs() < 0.0005 && ((m['lon'] as num) - lon).abs() < 0.0005);
    if (i >= 0) {
      l.removeAt(i);
    } else {
      l.insert(0, {'name': name, 'sub': sub, 'lat': lat, 'lon': lon, 'at': DateTime.now().toIso8601String()});
    }
    savedMap.value = l;
  }

  static void toggleSaved(String name) {
    final l = [...saved.value];
    l.contains(name) ? l.remove(name) : l.add(name);
    saved.value = l;
  }
}
