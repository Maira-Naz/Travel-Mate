import 'package:flutter/material.dart';
import '../core.dart';
import 'home_screen.dart';
import 'itinerary_screen.dart';
import 'bookings_screen.dart';
import 'profile_screen.dart';

// ---------------- SHELL (bottom nav) ----------------
class Shell extends StatelessWidget {
  const Shell({super.key});
  static const tabs = [Home(), ItineraryScreen(embedded: true), Bookings(), Profile()];
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: TabNav.index,
        builder: (_, i, __) => Scaffold(
          body: IndexedStack(index: i, children: tabs),
          bottomNavigationBar: NavigationBar(
            backgroundColor: Colors.white,
            indicatorColor: const Color(0x336E927F),
            selectedIndex: i,
            onDestinationSelected: (v) => TabNav.index.value = v,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: C.forest), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map, color: C.forest), label: 'Trips'),
              NavigationDestination(icon: Icon(Icons.credit_card), selectedIcon: Icon(Icons.credit_card, color: C.forest), label: 'Bookings'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: C.forest), label: 'Profile'),
            ],
          ),
        ),
      );
}
