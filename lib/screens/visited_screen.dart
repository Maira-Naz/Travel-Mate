import 'package:flutter/material.dart';
import '../core.dart';
import '../models/models.dart';
import '../services/trip_store.dart';

/// Visited / Not visited places of one trip (opened from the Home "Visited" tile).
class VisitedScreen extends StatefulWidget {
  final String? tripId;
  const VisitedScreen({super.key, this.tripId});
  @override
  State<VisitedScreen> createState() => _VisitedScreenState();
}

class _VisitedScreenState extends State<VisitedScreen> {
  bool showVisited = true;
  late String? tid = widget.tripId ?? TripStore.i.active?.id;

  Future<void> _editor(Trip t, [TripPlace? p]) async {
    final name = TextEditingController(text: p?.name ?? '');
    final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(p == null ? 'Add a place' : 'Edit place'),
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

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: TripStore.i,
        builder: (_, __) {
          final t = TripStore.i.tripById(tid);
          if (t == null) {
            return const SubPage('My places', child: EmptyState(Icons.luggage_outlined, 'No trip selected', 'Add a trip first, then track the places you visit.'));
          }
          final all = TripStore.i.placesFor(t.id);
          final vis = all.where((p) => p.visited).length;
          final list = all.where((p) => p.visited == showVisited).toList();
          return SubPage('My places',
              sub: t.name,
              bottom: SizedBox(width: double.infinity, child: Btn('Add place', () => _editor(t), icon: Icons.add)),
              child: ListView(padding: const EdgeInsets.symmetric(horizontal: 22), children: [
                if (TripStore.i.trips.length > 1) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      for (final x in TripStore.i.trips)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Tap(
                            radius: 20,
                            onTap: () => setState(() => tid = x.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(color: x.id == t.id ? C.forest : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.line)),
                              child: Text(x.name, style: body(13, c: x.id == t.id ? C.cream : C.forest, w: FontWeight.w700)),
                            ),
                          ),
                        ),
                    ]),
                  ),
                  const SizedBox(height: 14),
                ],
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: C.line)),
                  child: Row(children: [
                    for (final v in [true, false])
                      Expanded(
                          child: Tap(
                        radius: 28,
                        onTap: () => setState(() => showVisited = v),
                        child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(color: showVisited == v ? C.forest : Colors.transparent, borderRadius: BorderRadius.circular(28)),
                            child: Center(child: Text(v ? 'Visited ($vis)' : 'Not visited (${all.length - vis})', style: body(16, c: showVisited == v ? C.cream : C.muted, w: FontWeight.w800)))),
                      )),
                  ]),
                ),
                const SizedBox(height: 14),
                Box(
                    child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('$vis of ${all.length} places', style: body(16, c: C.forest, w: FontWeight.w800)),
                    Text(all.isEmpty ? '0%' : '${(vis * 100 / all.length).round()}%', style: body(16)),
                  ]),
                  const SizedBox(height: 10),
                  Bar(all.isEmpty ? 0 : vis / all.length),
                ])),
                const SizedBox(height: 14),
                if (list.isEmpty)
                  Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(child: Text(all.isEmpty ? 'No places yet. Tap Add place.' : (showVisited ? 'Nothing visited yet.' : 'You have visited everything on your list!'), textAlign: TextAlign.center, style: body(15)))),
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
                            Text(p.visited && p.visitedOn != null ? 'Visited ${fmtDate(DateTime.parse(p.visitedOn!))}' : 'Tap to mark as visited', style: body(13)),
                          ])),
                          EditDelete(
                              onEdit: () => _editor(t, p),
                              onDelete: () async {
                                if (await confirmDelete(context, p.name)) {
                                  TripStore.i.removePlace(p);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                      ..clearSnackBars()
                                      ..showSnackBar(SnackBar(content: Text('Deleted "${p.name}"'), action: SnackBarAction(label: 'Undo', onPressed: () => TripStore.i.addPlace(p))));
                                  }
                                }
                              }),
                        ])),
                  ),
                const SizedBox(height: 10),
              ]));
        },
      );
}
