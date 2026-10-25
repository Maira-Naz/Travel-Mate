import 'package:flutter/foundation.dart';
import 'storage.dart';

/// Saved places, language and notification settings (synced per user via Store).
class AppState {
  static final saved = ValueNotifier<List<String>>([]);
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
    language.addListener(() { if (!_loading) Store.setString('language', language.value); });
    notifs.addListener(() { if (!_loading) Store.setJson('notif_settings', notifs.value); });
  }

  /// Call after login (Store already loaded).
  static void load() {
    _loading = true;
    final s = Store.getJson('saved_places');
    saved.value = s == null ? [] : List<String>.from(s);
    language.value = Store.getString('language') ?? 'English';
    final n = Store.getJson('notif_settings');
    notifs.value = {..._defaultNotifs(), if (n != null) ...Map<String, bool>.from(n)};
    _loading = false;
  }

  /// Call on logout.
  static void reset() {
    _loading = true;
    saved.value = [];
    language.value = 'English';
    notifs.value = _defaultNotifs();
    _loading = false;
  }

  static void toggleSaved(String name) {
    final l = [...saved.value];
    l.contains(name) ? l.remove(name) : l.add(name);
    saved.value = l;
  }
}
