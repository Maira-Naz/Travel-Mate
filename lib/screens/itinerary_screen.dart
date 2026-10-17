import 'package:flutter/material.dart';
import '../core.dart';
import '../services/storage.dart';

// ---------------- SCHEDULE / ITINERARY (add / edit / delete stops) ----------------
class Stop {
  String title, sub;
  int day; // 0-based
  TimeOfDay time;
  Stop(this.day, this.time, this.title, this.sub);
  int get minutes => time.hour * 60 + time.minute;
  Map<String, dynamic> toJson() => {'d': day, 'h': time.hour, 'm': time.minute, 't': title, 's': sub};
  factory Stop.fromJson(Map<String, dynamic> j) =>
      Stop(j['d'], TimeOfDay(hour: j['h'], minute: j['m']), j['t'], j['s']);
}

String fmtTime(TimeOfDay t) {
  final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  return '$h:${t.minute.toString().padLeft(2, '0')} ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
}

class ItineraryScreen extends StatefulWidget {
  final bool embedded; // true when used as the "Trips" tab (no back button)
  const ItineraryScreen({super.key, this.embedded = false});
  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  static const dayCount = 5;
  int day = 0;
  static bool _loaded = false;
  // static: the Trips tab and the Home > Schedule screen share the same list
  static final stops = <Stop>[
    Stop(0, const TimeOfDay(hour: 9, minute: 0), 'Drive to Karimabad', 'Check in and rest, about 4 hours'),
    Stop(0, const TimeOfDay(hour: 13, minute: 0), 'Lunch at the bazaar', 'Local walnut cake and tea'),
    Stop(0, const TimeOfDay(hour: 16, minute: 0), 'Baltit Fort', 'Guided visit, 90 minutes'),
    Stop(1, const TimeOfDay(hour: 10, minute: 0), 'Attabad Lake boating', '2 hours, easy'),
    Stop(2, const TimeOfDay(hour: 15, minute: 0), "Eagle's Nest sunset hike", '3 hours, moderate'),
  ];

  @override
  void initState() {
    super.initState();
    if (!_loaded) {
      _loaded = true;
      final saved = Store.getJson('stops');
      if (saved != null) {
        stops
          ..clear()
          ..addAll((saved as List).map((e) => Stop.fromJson(Map<String, dynamic>.from(e))));
      }
    }
    Store.changed.addListener(_refresh);
  }

  @override
  void dispose() {
    Store.changed.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) super.setState(() {});
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    Store.setJson('stops', stops.map((e) => e.toJson()).toList());
  }

  List<Stop> get todays => (stops.where((s) => s.day == day).toList()..sort((a, b) => a.minutes.compareTo(b.minutes)));

  Future<void> _editor([Stop? s]) async {
    final title = TextEditingController(text: s?.title ?? '');
    final sub = TextEditingController(text: s?.sub ?? '');
    int d = s?.day ?? day;
    TimeOfDay t = s?.time ?? const TimeOfDay(hour: 9, minute: 0);
    final ok = await showDialog<bool>(
        context: context,
        builder: (_) => StatefulBuilder(
            builder: (ctx, set) => AlertDialog(
                  title: Text(s == null ? 'Add stop' : 'Edit stop'),
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(controller: title, decoration: const InputDecoration(labelText: 'Place or activity')),
                    TextField(controller: sub, decoration: const InputDecoration(labelText: 'Note (optional)')),
                    const SizedBox(height: 12),
                    DropdownButton<int>(
                        value: d, isExpanded: true,
                        items: [for (var i = 0; i < dayCount; i++) DropdownMenuItem(value: i, child: Text('Day ${i + 1}  ·  ${12 + i} Nov'))],
                        onChanged: (v) => set(() => d = v!)),
                    ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.access_time),
                        title: Text(fmtTime(t)),
                        trailing: const Text('Change'),
                        onTap: () async {
                          final p = await showTimePicker(context: ctx, initialTime: t);
                          if (p != null) set(() => t = p);
                        }),
                  ]),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s == null ? 'Add' : 'Save')),
                  ],
                )));
    if (ok == true && title.text.trim().isNotEmpty) {
      setState(() {
        if (s == null) {
          stops.add(Stop(d, t, title.text.trim(), sub.text.trim().isEmpty ? 'Added by you' : sub.text.trim()));
        } else {
          s.title = title.text.trim();
          s.sub = sub.text.trim();
          s.day = d;
          s.time = t;
        }
        day = d; // jump to the day the stop now lives on
      });
    }
  }

  void _delete(Stop s) {
    final i = stops.indexOf(s);
    setState(() => stops.remove(s));
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
          content: Text('Deleted "${s.title}"'),
          action: SnackBarAction(label: 'Undo', onPressed: () => setState(() => stops.insert(i.clamp(0, stops.length), s)))));
  }

  @override
  Widget build(BuildContext context) {
    final list = todays;
    return Scaffold(
      backgroundColor: C.cream,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _editor(), backgroundColor: C.sky, foregroundColor: C.forest,
          icon: const Icon(Icons.add), label: const Text('Add stop', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (!widget.embedded) ...[const BackDot(), const SizedBox(width: 14)],
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hunza, 5 days', style: head(26)),
                Text('12 Nov to 16 Nov', style: body(14)),
              ]),
            ]),
            const SizedBox(height: 18),
            Row(children: [
              for (var i = 0; i < dayCount; i++)
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.only(right: i == dayCount - 1 ? 0 : 6),
                  child: GestureDetector(
                    onTap: () => setState(() => day = i),
                    child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                            color: day == i ? C.forest : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: C.line)),
                        child: Center(
                            child: Text('Day ${i + 1}',
                                style: body(13, c: day == i ? C.cream : C.forest,
                                    w: day == i ? FontWeight.w800 : FontWeight.w400)))),
                  ),
                )),
            ]),
            const SizedBox(height: 22),
            Expanded(
              child: list.isEmpty
                  ? Center(child: Text('Nothing planned yet. Tap Add stop.', style: body(16)))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: list.length,
                      itemBuilder: (_, i) => IntrinsicHeight(
                        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          SizedBox(
                              width: 30,
                              child: Column(children: [
                                Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    width: 14, height: 14,
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: i == 0 ? C.sky : C.sage)),
                                if (i != list.length - 1) Expanded(child: Container(width: 3, color: const Color(0xFFD9D0B8))),
                              ])),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(fmtTime(list[i].time), style: body(15)),
                              const SizedBox(height: 6),
                              Box(
                                  onTap: () => _editor(list[i]),
                                  padding: const EdgeInsets.fromLTRB(18, 12, 4, 12),
                                  child: Row(children: [
                                    Expanded(
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(list[i].title, style: body(17, c: C.forest, w: FontWeight.w800)),
                                      if (list[i].sub.isNotEmpty) Text(list[i].sub, style: body(14)),
                                    ])),
                                    IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: C.muted), onPressed: () => _editor(list[i])),
                                    IconButton(icon: const Icon(Icons.delete_outline, size: 22, color: C.rust), onPressed: () => _delete(list[i])),
                                  ])),
                            ]),
                          )),
                        ]),
                      ),
                    ),
            ),
          ]),
        ),
      ),
    );
  }
}
