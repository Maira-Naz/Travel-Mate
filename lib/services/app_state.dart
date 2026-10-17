import 'package:flutter/foundation.dart';
import 'storage.dart';

/// Saved places, language and notification settings (all persisted).
class AppState {
  static final saved = ValueNotifier<List<String>>([]);
  static final language = ValueNotifier<String>('English');
  static final notifs = ValueNotifier<Map<String, bool>>({
    'Safety alerts': true, 'Weather updates': true, 'Booking reminders': true, 'Offers and tips': false,
  });

  static void init() {
    final s = Store.getJson('saved_places');
    if (s != null) saved.value = List<String>.from(s);
    language.value = Store.getString('language') ?? 'English';
    final n = Store.getJson('notif_settings');
    if (n != null) notifs.value = {...notifs.value, ...Map<String, bool>.from(n)};
    saved.addListener(() => Store.setJson('saved_places', saved.value));
    language.addListener(() => Store.setString('language', language.value));
    notifs.addListener(() => Store.setJson('notif_settings', notifs.value));
  }

  static void toggleSaved(String name) {
    final l = [...saved.value];
    l.contains(name) ? l.remove(name) : l.add(name);
    saved.value = l;
  }
}
