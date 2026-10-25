import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core.dart';
import 'storage.dart';

/// Destinations from the cloud, "place requests" and the in-app inbox.
///
/// Flow when a user searches a place we do not have:
///   1. the app saves a request (users/{uid}/data/place_requests) and adds a
///      document to the top-level `placeRequests` collection for the team to see;
///   2. you add the place to the `destinations` collection in the Firebase console;
///   3. next time the app loads, it finds the place and drops a notification in the inbox.
class PlaceService {
  static final remote = ValueNotifier<List<Place>>([]);
  static final requests = ValueNotifier<List<Map<String, dynamic>>>([]);
  static final inbox = ValueNotifier<List<Map<String, dynamic>>>([]);

  /// Built-in places + places added to Firestore `destinations`.
  static List<Place> get all {
    final names = places.map((p) => p.name.toLowerCase()).toSet();
    return [...places, ...remote.value.where((p) => !names.contains(p.name.toLowerCase()))];
  }

  static List<Map<String, dynamic>> _readList(String k) {
    final s = Store.getJson(k);
    if (s is! List) return [];
    return s.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Call after login. Local data is immediate, the cloud refresh runs in the background.
  static void load() {
    requests.value = _readList('place_requests');
    inbox.value = _readList('inbox');
    refreshRemote();
  }

  static void reset() {
    remote.value = [];
    requests.value = [];
    inbox.value = [];
  }

  static Future<void> refreshRemote() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('destinations').get().timeout(const Duration(seconds: 8));
      remote.value = snap.docs.map((d) => Place.fromMap(d.data())).toList();
      _checkReady();
    } catch (_) {}
  }

  static void _checkReady() {
    final reqs = requests.value.map((r) => Map<String, dynamic>.from(r)).toList();
    final box = [...inbox.value];
    var changed = false;
    for (final r in reqs) {
      if (r['status'] != 'pending') continue;
      final q = (r['q'] as String).toLowerCase();
      final hit = remote.value.any((p) => p.name.toLowerCase().contains(q) || q.contains(p.name.toLowerCase()));
      if (hit) {
        r['status'] = 'ready';
        box.insert(0, {'title': 'Place details are ready', 'body': 'We found details for "${r['q']}". Search for it to see them.', 'at': DateTime.now().toIso8601String()});
        changed = true;
      }
    }
    if (changed) {
      requests.value = reqs;
      inbox.value = box;
      Store.setJson('place_requests', reqs);
      Store.setJson('inbox', box);
    }
  }

  static bool isRequested(String q) =>
      requests.value.any((r) => (r['q'] as String).toLowerCase() == q.trim().toLowerCase());

  static Future<void> request(String q) async {
    q = q.trim();
    if (q.isEmpty || isRequested(q)) return;
    final reqs = [{'q': q, 'status': 'pending', 'at': DateTime.now().toIso8601String()}, ...requests.value];
    requests.value = reqs;
    Store.setJson('place_requests', reqs);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance
          .collection('placeRequests')
          .add({'uid': uid, 'query': q, 'status': 'pending', 'createdAt': FieldValue.serverTimestamp()})
          .then((_) {}, onError: (_) {});
    }
  }

  static void notify(String title, String body) {
    final box = [{'title': title, 'body': body, 'at': DateTime.now().toIso8601String()}, ...inbox.value];
    inbox.value = box;
    Store.setJson('inbox', box);
  }
}
