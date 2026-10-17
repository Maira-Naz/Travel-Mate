import 'package:flutter/material.dart';
import '../core.dart';
import 'all_destinations_screen.dart';
import 'weather_screen.dart';
import 'map_screen.dart';
import 'budget_screen.dart';
import 'visited_screen.dart';
import 'alerts_screen.dart';
import 'itinerary_screen.dart';

// ---------------- HOME ----------------
class Home extends StatelessWidget {
  const Home({super.key});
  void _open(BuildContext c, Widget w) => Navigator.push(c, MaterialPageRoute(builder: (_) => w));
  @override
  Widget build(BuildContext context) {
    final tiles = [
      ['Schedule', Icons.calendar_month_outlined, C.sage, const ItineraryScreen()],
      ['Weather', Icons.wb_sunny_outlined, C.sage, const WeatherScreen()],
      ['Map', Icons.place_outlined, C.sage, const MapScreen()],
      ['Budget', Icons.account_balance_wallet_outlined, C.sage, const BudgetScreen()],
      ['Visited', Icons.check_circle_outline, C.sage, const VisitedScreen()],
      ['Alerts', Icons.warning_amber_rounded, C.rust, const AlertsScreen()],
    ];
    // demo trip start date, replace with real trip data later
    final days = DateTime(2026, 11, 12).difference(DateTime.now()).inDays + 1;
    final until = days > 0 ? 'in $days days' : 'happening now';
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
        const SizedBox(height: 22),
        Tap(
          radius: 28,
          onTap: () => TabNav.index.value = 1,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3F6355), C.forest])),
            child: Row(children: [
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Your next trip', style: body(14, c: const Color(0xFFD5DDD6))),
                const SizedBox(height: 4),
                Text('Hunza Valley', style: head(26, c: C.cream)),
                const SizedBox(height: 4),
                Text('12 Nov to 16 Nov  ·  $until', style: body(14, c: C.cream, w: FontWeight.w600)),
              ])),
              Container(
                  width: 48, height: 48,
                  decoration: const BoxDecoration(color: C.sky, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_forward, color: C.forest)),
            ]),
          ),
        ),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: 3, shrinkWrap: true, crossAxisSpacing: 12, mainAxisSpacing: 12,
          childAspectRatio: 1.15, physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final t in tiles)
              Box(
                  onTap: () => _open(context, t[3] as Widget),
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
        SizedBox(
          height: 260,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final p in places)
              Padding(padding: const EdgeInsets.only(right: 14), child: DestinationCard(p, width: 250)),
          ]),
        ),
      ]),
    );
  }
}
