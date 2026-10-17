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
