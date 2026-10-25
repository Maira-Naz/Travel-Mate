import 'package:flutter/material.dart';
import '../core.dart';
import '../models/models.dart';
import '../services/place_service.dart';
import '../services/trip_store.dart';
import 'add_trip_screen.dart';
import 'alerts_screen.dart';
import 'all_destinations_screen.dart';
import 'map_screen.dart';
import 'trip_detail_screen.dart';
import 'visited_screen.dart';
import 'weather_screen.dart';

// ---------------- HOME ----------------
class Home extends StatelessWidget {
  const Home({super.key});
  void _open(BuildContext c, Widget w) => Navigator.push(c, MaterialPageRoute(builder: (_) => w));

  /// Schedule / Budget / Visited work on your current trip (ongoing, else next upcoming).
  void _openTrip(BuildContext c, int tab) {
    final t = TripStore.i.active;
    if (t == null) {
      showDialog(
          context: c,
          builder: (ctx) => AlertDialog(
                title: const Text('No trips yet'),
                content: const Text('Add your first trip to use the schedule, budget and places-to-visit tools.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Not now')),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _open(c, const AddTripScreen());
                      },
                      child: const Text('Add a trip')),
                ],
              ));
      return;
    }
    _open(c, tab == 2 ? VisitedScreen(tripId: t.id) : TripDetailScreen(tripId: t.id, tab: tab));
  }

  Widget _tripCard(BuildContext context) => AnimatedBuilder(
        animation: TripStore.i,
        builder: (_, __) {
          final t = TripStore.i.active;
          return Tap(
            radius: 28,
            onTap: () => t == null ? _open(context, const AddTripScreen()) : _open(context, TripDetailScreen(tripId: t.id)),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3F6355), C.forest])),
              child: Row(children: [
                Expanded(
                    child: t == null
                        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Plan your first trip', style: head(24, c: C.cream)),
                            const SizedBox(height: 4),
                            Text('Add a family or university trip and track its days and expenses.', style: body(14, c: const Color(0xFFD5DDD6))),
                          ])
                        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(t.status == 'Completed' ? 'Your last trip' : (t.status == 'Ongoing' ? 'Your trip now' : 'Your next trip'), style: body(14, c: const Color(0xFFD5DDD6))),
                            const SizedBox(height: 4),
                            Text(t.name, style: head(24, c: C.cream), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text('${rangeText(t.start, t.end)}  ·  ${t.countdown}', style: body(14, c: C.cream, w: FontWeight.w600)),
                          ])),
                const SizedBox(width: 12),
                Container(
                    width: 48, height: 48,
                    decoration: const BoxDecoration(color: C.sky, shape: BoxShape.circle),
                    child: Icon(t == null ? Icons.add : Icons.arrow_forward, color: C.forest)),
              ]),
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final tiles = <List<dynamic>>[
      ['Schedule', Icons.calendar_month_outlined, C.sage, () => _openTrip(context, 0)],
      ['Weather', Icons.wb_sunny_outlined, C.sage, () => _open(context, const WeatherScreen())],
      ['Map', Icons.place_outlined, C.sage, () => _open(context, const MapScreen())],
      ['Budget', Icons.account_balance_wallet_outlined, C.sage, () => _openTrip(context, 1)],
      ['Visited', Icons.check_circle_outline, C.sage, () => _openTrip(context, 2)],
      ['Alerts', Icons.warning_amber_rounded, C.rust, () => _open(context, const AlertsScreen())],
    ];
    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(22), children: [
        Row(children: [
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Good evening', style: body(16)),
            Text('Where to next?', style: head(32)),
          ])),
          Tap(radius: 30, onTap: () => TabNav.index.value = 3, child: const Avatar(radius: 28, fontSize: 22)),
        ]),
        const SizedBox(height: 18),
        Tap(
          radius: 26,
          onTap: () => _open(context, const AllDestinationsScreen()),
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26), border: Border.all(color: C.line)),
            child: Row(children: [
              const Icon(Icons.search, color: C.sage),
              const SizedBox(width: 10),
              Text('Search places', style: body(16)),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        _tripCard(context),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: 3, shrinkWrap: true, crossAxisSpacing: 12, mainAxisSpacing: 12,
          childAspectRatio: 1.15, physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final t in tiles)
              Box(
                  onTap: t[3] as VoidCallback,
                  padding: EdgeInsets.zero,
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(t[1] as IconData, color: t[2] as Color, size: 30),
                    const SizedBox(height: 8),
                    Text(t[0] as String, style: body(15, c: C.forest)),
                  ])),
          ],
        ),
        const SizedBox(height: 26),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Popular destinations', style: head(22)),
          Tap(
              radius: 14,
              onTap: () => _open(context, const AllDestinationsScreen()),
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text('See all', style: body(16, c: const Color(0xFF356A8A), w: FontWeight.w700)))),
        ]),
        const SizedBox(height: 10),
        ValueListenableBuilder<List<Place>>(
          valueListenable: PlaceService.remote,
          builder: (_, __, ___) => SizedBox(
            height: 260,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final p in PlaceService.all) Padding(padding: const EdgeInsets.only(right: 14), child: DestinationCard(p, width: 250)),
            ]),
          ),
        ),
      ]),
    );
  }
}
