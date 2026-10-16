import 'package:flutter/material.dart';
import '../core.dart';
import 'home_screen.dart';
import 'itinerary_screen.dart';
import 'bookings_screen.dart';
import 'profile_screen.dart';

// ---------------- 2. SHELL (bottom nav) ----------------
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;
  @override
  Widget build(BuildContext context) {
    final tabs = [const Home(), const ItineraryScreen(embedded: true), const Bookings(), const Profile()];
    return Scaffold(
      body: IndexedStack(index: i, children: tabs),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
        selectedIndex: i,
        onDestinationSelected: (v) => setState(() => i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: C.forest), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map, color: C.forest), label: 'Trips'),
          NavigationDestination(icon: Icon(Icons.credit_card), selectedIcon: Icon(Icons.credit_card, color: C.forest), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: C.forest), label: 'Profile'),
        ],
      ),
    );
  }
}
