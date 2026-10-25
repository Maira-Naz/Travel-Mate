import 'package:flutter/material.dart';
import '../core.dart';
import '../models/models.dart';
import 'place_service.dart';
import 'storage.dart';

/// All trips, stops, expenses, places-to-visit and bookings of the signed-in user.
/// Saved to Firestore through Store; screens listen to this object and rebuild.
class TripStore extends ChangeNotifier {
  static final TripStore i = TripStore._();
  TripStore._();

  List<Trip> trips = [];
  List<Stop> stops = [];
  List<Expense> expenses = [];
  List<TripPlace> places = [];
  List<Booking> bookings = [];

  List<T> _read<T>(String k, T Function(Map<String, dynamic>) f) {
    final s = Store.getJson(k);
    if (s is! List) return [];
    return s.map((e) => f(Map<String, dynamic>.from(e as Map))).toList();
  }

  void load() {
    trips = _read('trips', Trip.fromJson);
    stops = _read('trip_stops', Stop.fromJson);
    expenses = _read('trip_expenses', Expense.fromJson);
    places = _read('trip_places', TripPlace.fromJson);
    bookings = _read('bookings', Booking.fromJson);
    notifyListeners();
  }

  void reset() {
    trips = [];
    stops = [];
    expenses = [];
    places = [];
    bookings = [];
    notifyListeners();
  }

  /// Save the lists that changed (t trips, s stops, e expenses, p places, b bookings) and refresh screens.
  void touch({bool t = false, bool s = false, bool e = false, bool p = false, bool b = false}) {
    if (t) Store.setJson('trips', trips.map((x) => x.toJson()).toList());
    if (s) Store.setJson('trip_stops', stops.map((x) => x.toJson()).toList());
    if (e) Store.setJson('trip_expenses', expenses.map((x) => x.toJson()).toList());
    if (p) Store.setJson('trip_places', places.map((x) => x.toJson()).toList());
    if (b) Store.setJson('bookings', bookings.map((x) => x.toJson()).toList());
    notifyListeners();
  }

  // ---- lookups ----
  Trip? tripById(String? id) {
    for (final t in trips) {
      if (t.id == id) return t;
    }
    return null;
  }

  Booking? bookingById(String? id) {
    for (final b in bookings) {
      if (b.id == id) return b;
    }
    return null;
  }

  /// Ongoing trip, else the next upcoming one, else the most recent.
  Trip? get active {
    if (trips.isEmpty) return null;
    final cur = trips.where((t) => t.status == 'Ongoing').toList();
    if (cur.isNotEmpty) return cur.first;
    final up = trips.where((t) => t.status == 'Upcoming').toList()..sort((a, b) => a.start.compareTo(b.start));
    if (up.isNotEmpty) return up.first;
    final past = [...trips]..sort((a, b) => b.end.compareTo(a.end));
    return past.first;
  }

  List<Stop> stopsFor(String tid) => stops.where((s) => s.tripId == tid).toList();
  List<Expense> expensesFor(String tid) => expenses.where((e) => e.tripId == tid).toList();
  List<TripPlace> placesFor(String tid) => places.where((p) => p.tripId == tid).toList();
  int spentFor(String tid) => expensesFor(tid).fold(0, (a, e) => a + e.amount);

  // ---- trips ----
  void addTrip(Trip t) {
    trips.add(t);
    touch(t: true);
  }

  void updateTrip(Trip t) {
    for (final s in stops) {
      if (s.tripId == t.id && s.day >= t.days) s.day = t.days - 1; // keep stops inside the new dates
    }
    touch(t: true, s: true);
  }

  void deleteTrip(Trip t) {
    trips.remove(t);
    stops.removeWhere((s) => s.tripId == t.id);
    expenses.removeWhere((e) => e.tripId == t.id);
    places.removeWhere((p) => p.tripId == t.id);
    touch(t: true, s: true, e: true, p: true);
  }

  // ---- stops / expenses / places ----
  void addStop(Stop s) { stops.add(s); touch(s: true); }
  void removeStop(Stop s) { stops.remove(s); touch(s: true); }
  void addExpense(Expense e) { expenses.add(e); touch(e: true); }
  void removeExpense(Expense e) { expenses.remove(e); touch(e: true); }
  void addPlace(TripPlace p) { places.add(p); touch(p: true); }
  void removePlace(TripPlace p) { places.remove(p); touch(p: true); }

  // ---- bookings ----
  void addBooking(Booking b) { bookings.add(b); touch(b: true); }
  void removeBooking(Booking b) { bookings.remove(b); touch(b: true); }

  List<String> facilitiesFor(Place p) => [
        p.name == 'Hunza Valley' ? 'Stay: ${hotels[0][0]}, 4 nights' : 'Hotel stay, 4 nights',
        'Breakfast included',
        'Local transport and guide',
        for (final a in activities) '${a[0]} (${a[1]})',
      ];

  /// A booking made inside Roam: creates the booking AND a linked trip with a starter plan.
  Booking bookPlace(Place p, DateTime start, int travellers, String payment, int total) {
    final tid = newId(), bid = newId();
    final s = dateOnly(start), e = s.add(const Duration(days: 4));
    final payLater = payment == 'Pay later';
    final trip = Trip(
        id: tid, name: '${p.name} trip', destination: p.name, type: 'Booked with Roam',
        start: s, end: e, travellers: travellers, budget: total + 25000, source: 'app', bookingId: bid);
    final booking = Booking(
        id: bid, source: 'app', kind: 'Trip package', title: '${p.name}, 5 days', place: p.name,
        start: s, end: e, createdAt: DateTime.now(), amount: total,
        reference: 'RM-${bid.substring(bid.length - 6)}', tripId: tid, facilities: facilitiesFor(p),
        travellers: travellers, payment: payment, status: payLater ? 'Pay later' : 'Confirmed');
    trips.add(trip);
    bookings.add(booking);
    stops.add(Stop(id: newId(), tripId: tid, day: 0, time: const TimeOfDay(hour: 9, minute: 0), title: 'Travel to ${p.name}', sub: 'Check in and rest'));
    for (var k = 0; k < activities.length; k++) {
      stops.add(Stop(id: newId(), tripId: tid, day: k + 1, time: const TimeOfDay(hour: 10, minute: 0), title: activities[k][0], sub: activities[k][1]));
      places.add(TripPlace(id: newId(), tripId: tid, name: activities[k][0]));
    }
    if (!payLater) expenses.add(Expense(id: newId(), tripId: tid, name: 'Roam trip package', cat: 'Other', amount: total));
    touch(t: true, s: true, e: true, p: true, b: true);
    PlaceService.notify('Booking confirmed', '${p.name}, ${rangeText(s, e)}, $travellers traveller${travellers == 1 ? '' : 's'}.');
    return booking;
  }
}
