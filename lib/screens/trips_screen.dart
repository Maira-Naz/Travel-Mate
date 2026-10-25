import 'package:flutter/material.dart';
import '../core.dart';
import '../models/models.dart';
import '../services/trip_store.dart';
import 'add_trip_screen.dart';
import 'trip_detail_screen.dart';

// ---------------- TRIPS TAB ----------------
class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  Widget _card(BuildContext context, Trip t) {
    final spent = TripStore.i.spentFor(t.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Box(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailScreen(tripId: t.id))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              PlaceThumb(thumbs[t.destination.length % 4], size: 56),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.name, style: body(17, c: C.forest, w: FontWeight.w800)),
                Text('${t.destination}  ·  ${t.days} day${t.days == 1 ? '' : 's'}', style: body(13)),
                Text(rangeText(t.start, t.end), style: body(13)),
              ])),
              const Icon(Icons.chevron_right, color: C.muted),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 6, children: [
              statusTag(t.status),
              Tag(t.source == 'app' ? 'Booked with Roam' : t.type, const Color(0xFFE3EEE7), C.forest),
            ]),
            if (t.budget > 0) ...[
              const SizedBox(height: 12),
              Bar(spent / t.budget, color: spent > t.budget ? C.rust : C.sage),
              const SizedBox(height: 6),
              Text('${money(spent)} of ${money(t.budget)} spent', style: body(13)),
            ],
          ])),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: TripStore.i,
        builder: (_, __) {
          final all = TripStore.i.trips;
          final current = all.where((t) => t.status != 'Completed').toList()..sort((a, b) => a.start.compareTo(b.start));
          final past = all.where((t) => t.status == 'Completed').toList()..sort((a, b) => b.end.compareTo(a.end));
          return Scaffold(
            backgroundColor: C.cream,
            floatingActionButton: FloatingActionButton.extended(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTripScreen())),
                backgroundColor: C.forest, foregroundColor: C.cream,
                icon: const Icon(Icons.add), label: const Text('Add trip', style: TextStyle(fontWeight: FontWeight.w800))),
            body: SafeArea(
              child: ListView(padding: const EdgeInsets.fromLTRB(22, 22, 22, 100), children: [
                Row(children: [
                  BackDot(onTap: () => TabNav.index.value = 0),
                  const SizedBox(width: 14),
                  Text('My trips', style: head(30)),
                ]),
                const SizedBox(height: 18),
                if (all.isEmpty)
                  const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: EmptyState(Icons.luggage_outlined, 'No trips yet', 'Add a family or university trip, or book one in Roam. Then track its days, expenses and places here.')),
                if (current.isNotEmpty) ...[
                  Text('Upcoming and ongoing', style: head(20)),
                  const SizedBox(height: 10),
                  for (final t in current) _card(context, t),
                ],
                if (past.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text('Past trips', style: head(20)),
                  const SizedBox(height: 10),
                  for (final t in past) _card(context, t),
                ],
              ]),
            ),
          );
        },
      );
}
