import 'package:flutter/material.dart';
import '../core.dart';
import '../models/models.dart';
import '../services/trip_store.dart';
import 'trip_detail_screen.dart';

/// Full details of a booking made inside Roam.
class BookingDetailScreen extends StatelessWidget {
  final String bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});

  Widget _row(String k, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 110, child: Text(k, style: body(14))),
        Expanded(child: Text(v, style: body(15, c: C.forest, w: FontWeight.w700))),
      ]));

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: TripStore.i,
        builder: (_, __) {
          final b = TripStore.i.bookingById(bookingId);
          if (b == null) return const SubPage('Booking', child: EmptyState(Icons.confirmation_number_outlined, 'Booking not found', 'It may have been removed.'));
          final trip = TripStore.i.tripById(b.tripId);
          return SubPage('Booking details',
              sub: 'Ref ${b.reference}',
              bottom: trip == null
                  ? null
                  : SizedBox(
                      width: double.infinity,
                      child: Btn('View trip details', () => Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailScreen(tripId: trip.id))), icon: Icons.luggage_outlined)),
              child: ListView(padding: const EdgeInsets.symmetric(horizontal: 22), children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3F6355), C.forest])),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Expanded(child: Text(b.place, style: head(26, c: C.cream))),
                      statusTag(b.status),
                    ]),
                    const SizedBox(height: 6),
                    Text(b.end == null ? fmtDate(b.start, year: true) : rangeText(b.start, b.end!), style: body(15, c: C.cream, w: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(b.timeline, style: body(13, c: const Color(0xFFD5DDD6))),
                  ]),
                ),
                const SizedBox(height: 18),
                Text('Booking', style: head(20)),
                const SizedBox(height: 8),
                Box(
                    child: Column(children: [
                  _row('Place', b.place),
                  _row('Trip dates', b.end == null ? fmtDate(b.start, year: true) : rangeText(b.start, b.end!)),
                  _row('Booked on', '${fmtWeekday(b.createdAt)}, ${fmtDate(b.createdAt, year: true)}'),
                  _row('Booked at', fmtClock(b.createdAt)),
                  _row('Travellers', '${b.travellers}'),
                  _row('Payment', b.payment.isEmpty ? '-' : b.payment),
                  _row('Amount', money(b.amount)),
                ])),
                const SizedBox(height: 18),
                Text('Facilities included', style: head(20)),
                const SizedBox(height: 8),
                Box(
                    child: Column(children: [
                  for (final f in b.facilities)
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Icon(Icons.check_circle_outline, size: 20, color: C.sage),
                          const SizedBox(width: 10),
                          Expanded(child: Text(f, style: body(15, c: C.forest))),
                        ])),
                  if (b.facilities.isEmpty) Text('No facilities listed.', style: body(14)),
                ])),
                if (trip == null)
                  Padding(padding: const EdgeInsets.only(top: 14), child: Text('The trip linked to this booking was deleted.', style: body(14))),
                const SizedBox(height: 16),
              ]));
        },
      );
}
