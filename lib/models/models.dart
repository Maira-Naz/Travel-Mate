import 'package:flutter/material.dart' show TimeOfDay, DayPeriod;

// ---------------- helpers ----------------
const _mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
int _seq = 0;
String newId() => '${DateTime.now().microsecondsSinceEpoch}${_seq++}';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
int daysBetween(DateTime a, DateTime b) =>
    DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
String fmtDate(DateTime d, {bool year = false}) => '${d.day} ${_mon[d.month - 1]}${year ? ' ${d.year}' : ''}';
String fmtWeekday(DateTime d) => _wd[d.weekday - 1];
String fmtTod(TimeOfDay t) {
  final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  return '$h:${t.minute.toString().padLeft(2, '0')} ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
}
String fmtClock(DateTime d) => fmtTod(TimeOfDay(hour: d.hour, minute: d.minute));
String money(int n) => 'PKR ${n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';
String rangeText(DateTime a, DateTime b) => '${fmtDate(a)} to ${fmtDate(b, year: true)}';

/// Upcoming / Ongoing / Completed from dates.
String timelineOf(DateTime start, DateTime? end) {
  final t = dateOnly(DateTime.now());
  final s = dateOnly(start), e = dateOnly(end ?? start);
  if (t.isBefore(s)) return 'Upcoming';
  if (t.isAfter(e)) return 'Completed';
  return 'Ongoing';
}

// ---------------- models ----------------
class Trip {
  String id, name, destination, type, notes, source; // source: 'manual' | 'app'
  DateTime start, end;
  int travellers, budget;
  String? bookingId;
  Trip({required this.id, required this.name, required this.destination, required this.type,
      required this.start, required this.end, this.travellers = 1, this.budget = 0,
      this.notes = '', this.source = 'manual', this.bookingId});
  int get days => daysBetween(start, end) + 1;
  String get status => timelineOf(start, end);
  String get countdown {
    final today = dateOnly(DateTime.now());
    if (today.isBefore(dateOnly(start))) {
      final n = daysBetween(today, start);
      return n == 1 ? 'starts tomorrow' : 'starts in $n days';
    }
    if (today.isAfter(dateOnly(end))) return 'completed';
    return 'day ${daysBetween(start, today) + 1} of $days';
  }
  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'dest': destination, 'type': type, 'notes': notes, 'src': source,
        'start': start.toIso8601String(), 'end': end.toIso8601String(),
        'pax': travellers, 'budget': budget, 'bid': bookingId,
      };
  factory Trip.fromJson(Map<String, dynamic> j) => Trip(
      id: j['id'], name: j['name'], destination: j['dest'], type: j['type'] ?? 'Other',
      start: DateTime.parse(j['start']), end: DateTime.parse(j['end']),
      travellers: j['pax'] ?? 1, budget: j['budget'] ?? 0, notes: j['notes'] ?? '',
      source: j['src'] ?? 'manual', bookingId: j['bid']);
}

class Stop {
  String id, tripId, title, sub;
  int day; // 0-based
  TimeOfDay time;
  Stop({required this.id, required this.tripId, required this.day, required this.time, required this.title, this.sub = ''});
  int get minutes => time.hour * 60 + time.minute;
  Map<String, dynamic> toJson() => {'id': id, 'tid': tripId, 'day': day, 'h': time.hour, 'm': time.minute, 't': title, 's': sub};
  factory Stop.fromJson(Map<String, dynamic> j) => Stop(
      id: j['id'], tripId: j['tid'], day: j['day'], time: TimeOfDay(hour: j['h'], minute: j['m']), title: j['t'], sub: j['s'] ?? '');
}

class Expense {
  String id, tripId, name, cat;
  int amount;
  Expense({required this.id, required this.tripId, required this.name, required this.cat, required this.amount});
  Map<String, dynamic> toJson() => {'id': id, 'tid': tripId, 'n': name, 'c': cat, 'a': amount};
  factory Expense.fromJson(Map<String, dynamic> j) =>
      Expense(id: j['id'], tripId: j['tid'], name: j['n'], cat: j['c'], amount: j['a']);
}

class TripPlace {
  String id, tripId, name;
  bool visited;
  String? visitedOn; // ISO date
  TripPlace({required this.id, required this.tripId, required this.name, this.visited = false, this.visitedOn});
  Map<String, dynamic> toJson() => {'id': id, 'tid': tripId, 'n': name, 'v': visited, 'on': visitedOn};
  factory TripPlace.fromJson(Map<String, dynamic> j) => TripPlace(
      id: j['id'], tripId: j['tid'], name: j['n'], visited: j['v'] ?? false, visitedOn: j['on']);
}

/// A booking. source 'app' = made in Roam (opens trip details), 'external' = added by the user (tracking only).
class Booking {
  String id, source, kind, title, place, reference, notes, payment, status;
  DateTime start, createdAt;
  DateTime? end;
  int amount, travellers;
  String? tripId;
  List<String> facilities;
  Booking({required this.id, required this.source, required this.kind, required this.title, required this.place,
      required this.start, this.end, required this.createdAt, this.amount = 0, this.reference = '', this.notes = '',
      this.tripId, this.facilities = const [], this.travellers = 1, this.payment = '', this.status = 'Confirmed'});
  bool get fromApp => source == 'app';
  String get timeline => timelineOf(start, end);
  Map<String, dynamic> toJson() => {
        'id': id, 'src': source, 'kind': kind, 'title': title, 'place': place, 'ref': reference, 'notes': notes,
        'pay': payment, 'status': status, 'start': start.toIso8601String(), 'end': end?.toIso8601String(),
        'created': createdAt.toIso8601String(), 'amount': amount, 'pax': travellers, 'tid': tripId, 'fac': facilities,
      };
  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
      id: j['id'], source: j['src'] ?? 'external', kind: j['kind'] ?? 'Other', title: j['title'], place: j['place'] ?? '',
      reference: j['ref'] ?? '', notes: j['notes'] ?? '', payment: j['pay'] ?? '', status: j['status'] ?? 'Confirmed',
      start: DateTime.parse(j['start']), end: j['end'] == null ? null : DateTime.parse(j['end']),
      createdAt: DateTime.parse(j['created']), amount: j['amount'] ?? 0, travellers: j['pax'] ?? 1,
      tripId: j['tid'], facilities: List<String>.from(j['fac'] ?? const []));
}
