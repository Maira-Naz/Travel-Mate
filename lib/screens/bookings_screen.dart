import 'package:flutter/material.dart';
import '../core.dart';
import '../models/models.dart';
import '../services/trip_store.dart';
import 'add_booking_screen.dart';
import 'booking_detail_screen.dart';

IconData kindIcon(String k) {
  switch (k) {
    case 'Hotel':
      return Icons.hotel_outlined;
    case 'Flight':
      return Icons.flight_outlined;
    case 'Bus':
      return Icons.directions_bus_outlined;
    case 'Train':
      return Icons.train_outlined;
    case 'Car rental':
      return Icons.directions_car_outlined;
    case 'Tour':
      return Icons.tour_outlined;
    default:
      return Icons.bookmark_border;
  }
}

// Bookings tab (also used by Profile > My bookings)
class Bookings extends StatelessWidget {
  const Bookings({super.key});

  /// Booked in Roam: tap opens the full booking and trip details.
  Widget _appCard(BuildContext context, Booking b) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Box(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: b.id))),
            child: Row(children: [
              const PlaceThumb([Color(0xFF6E927F), Color(0xFF2F4A43)]),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b.title, style: body(17, c: C.forest, w: FontWeight.w800)),
                Text(b.end == null ? fmtDate(b.start, year: true) : rangeText(b.start, b.end!), style: body(13)),
                const SizedBox(height: 4),
                Text('${money(b.amount)}  ·  ${b.travellers} traveller${b.travellers == 1 ? '' : 's'}', style: body(14, c: C.forest, w: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6, children: [statusTag(b.status), statusTag(b.timeline)]),
              ])),
              const Icon(Icons.chevron_right, color: C.muted),
            ])),
      );

  /// Booked elsewhere and added by the user: tracking only, not clickable.
  Widget _externalCard(BuildContext context, Booking b) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Box(
            child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: const Color(0xFFE3EEE7), borderRadius: BorderRadius.circular(16)),
                child: Icon(kindIcon(b.kind), color: C.forest)),
            const SizedBox(width: 14),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b.title, style: body(17, c: C.forest, w: FontWeight.w800)),
              Text('${b.kind}  ·  ${b.place}', style: body(13)),
              Text(b.end == null ? fmtDate(b.start, year: true) : rangeText(b.start, b.end!), style: body(13)),
              if (b.amount > 0 || b.reference.isNotEmpty)
                Text([if (b.amount > 0) money(b.amount), if (b.reference.isNotEmpty) 'Ref ${b.reference}'].join('  ·  '), style: body(13, c: C.forest, w: FontWeight.w700)),
            ])),
            statusTag(b.timeline),
          ]),
          const SizedBox(height: 10),
          Align(
              alignment: Alignment.centerRight,
              child: EditDelete(
                  onEdit: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddBookingScreen(booking: b))),
                  onDelete: () async {
                    if (await confirmDelete(context, b.title)) {
                      TripStore.i.removeBooking(b);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(SnackBar(content: Text('Deleted "${b.title}"'), action: SnackBarAction(label: 'Undo', onPressed: () => TripStore.i.addBooking(b))));
                      }
                    }
                  })),
        ])),
      );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: TripStore.i,
        builder: (_, __) {
          final all = [...TripStore.i.bookings]..sort((a, b) => a.start.compareTo(b.start));
          final app = all.where((b) => b.fromApp).toList();
          final ext = all.where((b) => !b.fromApp).toList();
          return Scaffold(
            backgroundColor: C.cream,
            floatingActionButton: FloatingActionButton.extended(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBookingScreen())),
                backgroundColor: C.forest, foregroundColor: C.cream,
                icon: const Icon(Icons.add), label: const Text('Add booking', style: TextStyle(fontWeight: FontWeight.w800))),
            body: SafeArea(
              child: ListView(padding: const EdgeInsets.fromLTRB(22, 22, 22, 100), children: [
                Row(children: [
                  BackDot(onTap: () => TabNav.index.value = 0),
                  const SizedBox(width: 14),
                  Text('My bookings', style: head(30)),
                ]),
                const SizedBox(height: 18),
                Text('Booked with Roam', style: head(20)),
                const SizedBox(height: 4),
                Text('Tap a booking to see its dates, facilities and trip details.', style: body(13)),
                const SizedBox(height: 10),
                if (app.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Text('Nothing booked in Roam yet. Find a destination on Home and tap Book this trip.', style: body(14))),
                for (final b in app) _appCard(context, b),
                const SizedBox(height: 14),
                Text('Added by me', style: head(20)),
                const SizedBox(height: 4),
                Text('Bookings you made elsewhere. Roam only tracks them.', style: body(13)),
                const SizedBox(height: 10),
                if (ext.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Text('Tap Add booking to track a hotel, flight, bus or tour you booked outside Roam.', style: body(14))),
                for (final b in ext) _externalCard(context, b),
              ]),
            ),
          );
        },
      );
}
