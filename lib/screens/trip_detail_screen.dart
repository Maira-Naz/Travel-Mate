import 'package:flutter/material.dart';
import '../core.dart';
import '../models/models.dart';
import '../services/trip_store.dart';
import 'add_trip_screen.dart';
import 'booking_detail_screen.dart';

/// One trip: Itinerary, Budget, Places and Details tabs.
class TripDetailScreen extends StatefulWidget {
  final String tripId;
  final int tab;
  const TripDetailScreen({super.key, required this.tripId, this.tab = 0});
  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  static const tabNames = ['Itinerary', 'Budget', 'Places', 'Details'];
  static const cats = ['Stay', 'Transport', 'Food', 'Activities', 'Other'];
  late int tab = widget.tab;
  int day = 0;

  void _snackUndo(String text, VoidCallback undo) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(text), action: SnackBarAction(label: 'Undo', onPressed: undo)));
  }

  // ---------------- stops ----------------
  Future<void> _stopEditor(Trip t, [Stop? s]) async {
    final title = TextEditingController(text: s?.title ?? '');
    final sub = TextEditingController(text: s?.sub ?? '');
    int d = s?.day ?? day.clamp(0, t.days - 1);
    TimeOfDay tm = s?.time ?? const TimeOfDay(hour: 9, minute: 0);
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
                        items: [for (var i = 0; i < t.days; i++) DropdownMenuItem(value: i, child: Text('Day ${i + 1}  ·  ${fmtDate(t.start.add(Duration(days: i)))}'))],
                        onChanged: (v) => set(() => d = v!)),
                    ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.access_time),
                        title: Text(fmtTod(tm)),
                        trailing: const Text('Change'),
                        onTap: () async {
                          final p = await showTimePicker(context: ctx, initialTime: tm);
                          if (p != null) set(() => tm = p);
                        }),
                  ]),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s == null ? 'Add' : 'Save')),
                  ],
                )));
    if (ok != true || title.text.trim().isEmpty) return;
    if (s == null) {
      TripStore.i.addStop(Stop(id: newId(), tripId: t.id, day: d, time: tm, title: title.text.trim(), sub: sub.text.trim()));
    } else {
      s.title = title.text.trim();
      s.sub = sub.text.trim();
      s.day = d;
      s.time = tm;
      TripStore.i.touch(s: true);
    }
    setState(() => day = d);
  }

  Widget _itinerary(Trip t) {
    final d = day.clamp(0, t.days - 1);
    final list = TripStore.i.stopsFor(t.id).where((s) => s.day == d).toList()..sort((a, b) => a.minutes.compareTo(b.minutes));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (var i = 0; i < t.days; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Tap(
                radius: 22,
                onTap: () => setState(() => day = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(color: d == i ? C.forest : Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: C.line)),
                  child: Column(children: [
                    Text('Day ${i + 1}', style: body(14, c: d == i ? C.cream : C.forest, w: FontWeight.w800)),
                    Text(fmtDate(t.start.add(Duration(days: i))), style: body(11, c: d == i ? const Color(0xFFD5DDD6) : C.muted)),
                  ]),
                ),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 18),
      if (list.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Center(child: Text('Nothing planned for this day. Tap Add stop.', style: body(15)))),
      for (var i = 0; i < list.length; i++)
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
                width: 30,
                child: Column(children: [
                  Container(margin: const EdgeInsets.only(top: 4), width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle, color: i == 0 ? C.sky : C.sage)),
                  if (i != list.length - 1) Expanded(child: Container(width: 3, color: const Color(0xFFD9D0B8))),
                ])),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(fmtTod(list[i].time), style: body(15)),
                const SizedBox(height: 6),
                Box(
                    onTap: () => _stopEditor(t, list[i]),
                    padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
                    child: Row(children: [
                      Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(list[i].title, style: body(17, c: C.forest, w: FontWeight.w800)),
                        if (list[i].sub.isNotEmpty) Text(list[i].sub, style: body(14)),
                      ])),
                      const SizedBox(width: 8),
                      EditDelete(
                          onEdit: () => _stopEditor(t, list[i]),
                          onDelete: () async {
                            final s = list[i];
                            if (await confirmDelete(context, s.title)) {
                              TripStore.i.removeStop(s);
                              _snackUndo('Deleted "${s.title}"', () => TripStore.i.addStop(s));
                            }
                          }),
                    ])),
              ]),
            )),
          ]),
        ),
    ]);
  }

  // ---------------- expenses ----------------
  Future<void> _expenseEditor(Trip t, [Expense? e]) async {
    final name = TextEditingController(text: e?.name ?? '');
    final amt = TextEditingController(text: e == null ? '' : '${e.amount}');
    String cat = e?.cat ?? cats.first;
    String? err;
    final ok = await showDialog<bool>(
        context: context,
        builder: (_) => StatefulBuilder(
            builder: (ctx, set) => AlertDialog(
                  title: Text(e == null ? 'Add expense' : 'Edit expense'),
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
                    TextField(controller: amt, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (PKR)')),
                    const SizedBox(height: 12),
                    DropdownButton<String>(
                        value: cat, isExpanded: true,
                        items: [for (final k in cats) DropdownMenuItem(value: k, child: Text(k))],
                        onChanged: (v) => set(() => cat = v!)),
                    if (err != null) Text(err!, style: const TextStyle(color: C.rust)),
                  ]),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(
                        onPressed: () {
                          final v = int.tryParse(amt.text.trim());
                          if (name.text.trim().isEmpty || v == null || v <= 0) {
                            set(() => err = 'Enter a name and a valid amount');
                          } else {
                            Navigator.pop(ctx, true);
                          }
                        },
                        child: Text(e == null ? 'Add' : 'Save')),
                  ],
                )));
    if (ok != true) return;
    final v = int.parse(amt.text.trim());
    if (e == null) {
      TripStore.i.addExpense(Expense(id: newId(), tripId: t.id, name: name.text.trim(), cat: cat, amount: v));
    } else {
      e.name = name.text.trim();
      e.amount = v;
      e.cat = cat;
      TripStore.i.touch(e: true);
    }
  }

  Widget _budget(Trip t) {
    final ex = TripStore.i.expensesFor(t.id);
    final spent = ex.fold(0, (a, e) => a + e.amount);
    final left = t.budget - spent;
    int catSum(String c) => ex.where((e) => e.cat == c).fold(0, (a, e) => a + e.amount);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: C.forest, borderRadius: BorderRadius.circular(28)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Spent so far', style: body(14, c: const Color(0xFFD5DDD6))),
          Text(money(spent), style: head(34, c: C.cream)),
          const SizedBox(height: 10),
          if (t.budget > 0) ...[
            Bar(spent / t.budget, color: spent > t.budget ? C.rust : C.sky, track: const Color(0xFF586F66)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${(spent * 100 / t.budget).round()}% of ${money(t.budget)}', style: body(14, c: C.cream)),
              Text(left >= 0 ? '${money(left)} left' : '${money(-left)} over', style: body(14, c: C.cream, w: FontWeight.w800)),
            ]),
          ] else
            Text('No budget set. Edit the trip to add one.', style: body(14, c: const Color(0xFFD5DDD6))),
        ]),
      ),
      const SizedBox(height: 20),
      Text('By category', style: head(20)),
      const SizedBox(height: 10),
      for (final c in cats)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Box(
              child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(c, style: body(16, c: C.forest, w: FontWeight.w800)),
              Text(money(catSum(c)), style: body(15)),
            ]),
            const SizedBox(height: 8),
            Bar(spent == 0 ? 0 : catSum(c) / spent),
          ])),
        ),
      const SizedBox(height: 10),
      Text('Expenses', style: head(20)),
      const SizedBox(height: 10),
      if (ex.isEmpty) Padding(padding: const EdgeInsets.all(16), child: Center(child: Text('No expenses yet. Tap Add expense.', style: body(15)))),
      for (final e in ex)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Box(
              onTap: () => _expenseEditor(t, e),
              padding: const EdgeInsets.fromLTRB(18, 10, 12, 10),
              child: Row(children: [
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(e.name, style: body(16, c: C.forest, w: FontWeight.w800)),
                  Text('${e.cat}  ·  ${money(e.amount)}', style: body(14, c: C.forest, w: FontWeight.w700)),
                ])),
                EditDelete(
                    onEdit: () => _expenseEditor(t, e),
                    onDelete: () async {
                      if (await confirmDelete(context, e.name)) {
                        TripStore.i.removeExpense(e);
                        _snackUndo('Deleted "${e.name}"', () => TripStore.i.addExpense(e));
                      }
                    }),
              ])),
        ),
    ]);
  }

  // ---------------- places ----------------
  Future<void> _placeEditor(Trip t, [TripPlace? p]) async {
    final name = TextEditingController(text: p?.name ?? '');
    final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(p == null ? 'Add a place to visit' : 'Edit place'),
              content: TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'Place name')),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(p == null ? 'Add' : 'Save')),
              ],
            ));
    if (ok != true || name.text.trim().isEmpty) return;
    if (p == null) {
      TripStore.i.addPlace(TripPlace(id: newId(), tripId: t.id, name: name.text.trim()));
    } else {
      p.name = name.text.trim();
      TripStore.i.touch(p: true);
    }
  }

  Widget _places(Trip t) {
    final list = TripStore.i.placesFor(t.id);
    final done = list.where((p) => p.visited).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Box(
          child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('$done of ${list.length} places visited', style: body(16, c: C.forest, w: FontWeight.w800)),
          Text(list.isEmpty ? '0%' : '${(done * 100 / list.length).round()}%', style: body(16)),
        ]),
        const SizedBox(height: 10),
        Bar(list.isEmpty ? 0 : done / list.length),
      ])),
      const SizedBox(height: 14),
      if (list.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Center(child: Text('Add the places you want to visit, then tick them off.', textAlign: TextAlign.center, style: body(15)))),
      for (final p in list)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Box(
              onTap: () {
                p.visited = !p.visited;
                p.visitedOn = p.visited ? dateOnly(DateTime.now()).toIso8601String() : null;
                TripStore.i.touch(p: true);
              },
              padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
              child: Row(children: [
                Icon(p.visited ? Icons.check_circle : Icons.radio_button_unchecked, color: C.sage, size: 28),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, style: body(16, c: C.forest, w: FontWeight.w800)),
                  Text(p.visited && p.visitedOn != null ? 'Visited ${fmtDate(DateTime.parse(p.visitedOn!))}' : 'Not visited yet', style: body(13)),
                ])),
                EditDelete(
                    onEdit: () => _placeEditor(t, p),
                    onDelete: () async {
                      if (await confirmDelete(context, p.name)) {
                        TripStore.i.removePlace(p);
                        _snackUndo('Deleted "${p.name}"', () => TripStore.i.addPlace(p));
                      }
                    }),
              ])),
        ),
    ]);
  }

  // ---------------- details ----------------
  Widget _details(Trip t) {
    final b = TripStore.i.bookingById(t.bookingId);
    Widget row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 110, child: Text(k, style: body(14))),
          Expanded(child: Text(v, style: body(15, c: C.forest, w: FontWeight.w700))),
        ]));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Box(
          child: Column(children: [
        row('Destination', t.destination),
        row('Type', t.type),
        row('Dates', rangeText(t.start, t.end)),
        row('Length', '${t.days} day${t.days == 1 ? '' : 's'}'),
        row('Travellers', '${t.travellers}'),
        row('Budget', t.budget > 0 ? money(t.budget) : 'Not set'),
        row('Notes', t.notes.isEmpty ? 'None' : t.notes),
      ])),
      const SizedBox(height: 16),
      if (b != null)
        Box(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: b.id))),
            child: Row(children: [
              const Icon(Icons.confirmation_number_outlined, color: C.sage, size: 28),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Booked with Roam', style: body(16, c: C.forest, w: FontWeight.w800)),
                Text('Ref ${b.reference}  ·  tap to see the booking', style: body(13)),
              ])),
              const Icon(Icons.chevron_right, color: C.muted),
            ]))
      else
        Text(t.source == 'app' ? 'The booking for this trip was removed.' : 'This trip was added manually.', style: body(14)),
    ]);
  }

  // ---------------- build ----------------
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: TripStore.i,
        builder: (_, __) {
          final t = TripStore.i.tripById(widget.tripId);
          if (t == null) {
            return Scaffold(backgroundColor: C.cream, body: const SafeArea(child: EmptyState(Icons.luggage_outlined, 'Trip not found', 'It may have been deleted.')));
          }
          final spent = TripStore.i.spentFor(t.id);
          return Scaffold(
            backgroundColor: C.cream,
            floatingActionButton: tab == 3
                ? null
                : FloatingActionButton.extended(
                    onPressed: () => tab == 0 ? _stopEditor(t) : (tab == 1 ? _expenseEditor(t) : _placeEditor(t)),
                    backgroundColor: C.forest, foregroundColor: C.cream,
                    icon: const Icon(Icons.add),
                    label: Text(['Add stop', 'Add expense', 'Add place'][tab], style: const TextStyle(fontWeight: FontWeight.w800))),
            body: SafeArea(
              child: ListView(padding: const EdgeInsets.fromLTRB(22, 14, 22, 100), children: [
                Row(children: [
                  const BackDot(),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t.name, style: head(22), maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(t.destination, style: body(14)),
                  ])),
                  EditDelete(
                      onEdit: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddTripScreen(trip: t))),
                      onDelete: () async {
                        if (await confirmDelete(context, t.name)) {
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          TripStore.i.deleteTrip(t);
                        }
                      }),
                ]),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3F6355), C.forest])),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Expanded(child: Text(rangeText(t.start, t.end), style: body(15, c: C.cream, w: FontWeight.w700))),
                      statusTag(t.status),
                    ]),
                    const SizedBox(height: 6),
                    Text('${t.days} day${t.days == 1 ? '' : 's'}  ·  ${t.travellers} traveller${t.travellers == 1 ? '' : 's'}  ·  ${t.countdown}', style: body(13, c: const Color(0xFFD5DDD6))),
                    if (t.budget > 0) ...[
                      const SizedBox(height: 14),
                      Bar(spent / t.budget, color: spent > t.budget ? C.rust : C.sky, track: const Color(0xFF586F66)),
                      const SizedBox(height: 6),
                      Text('${money(spent)} of ${money(t.budget)} spent', style: body(13, c: C.cream)),
                    ],
                  ]),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: C.line)),
                  child: Row(children: [
                    for (var i = 0; i < tabNames.length; i++)
                      Expanded(
                          child: Tap(
                        radius: 26,
                        onTap: () => setState(() => tab = i),
                        child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(color: tab == i ? C.forest : Colors.transparent, borderRadius: BorderRadius.circular(26)),
                            child: Center(child: Text(tabNames[i], style: body(13, c: tab == i ? C.cream : C.muted, w: tab == i ? FontWeight.w800 : FontWeight.w400)))),
                      )),
                  ]),
                ),
                const SizedBox(height: 16),
                if (tab == 0) _itinerary(t),
                if (tab == 1) _budget(t),
                if (tab == 2) _places(t),
                if (tab == 3) _details(t),
              ]),
            ),
          );
        },
      );
}
