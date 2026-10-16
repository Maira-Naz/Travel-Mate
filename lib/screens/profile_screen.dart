import 'package:flutter/material.dart';
import '../core.dart';
import 'welcome_screen.dart';

// ---------------- PROFILE ----------------
class Profile extends StatelessWidget {
  const Profile({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(padding: const EdgeInsets.all(22), children: [
          const SizedBox(height: 10),
          const Center(
              child: CircleAvatar(radius: 52, backgroundColor: C.forest,
                  child: Text('Y', style: TextStyle(fontFamily: 'serif', color: C.cream, fontSize: 52, fontWeight: FontWeight.w800)))),
          const SizedBox(height: 14),
          Center(child: Text('Your Name', style: head(28))),
          Center(child: Text('you@email.com', style: body(16))),
          const SizedBox(height: 22),
          Row(children: [
            for (final s in [['3', 'Trips'], ['8', 'Saved places'], ['2', 'Bookings']])
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Box(
                    child: Column(children: [
                  Text(s[0], style: head(28)),
                  Text(s[1], style: body(13)),
                ])),
              )),
          ]),
          const SizedBox(height: 18),
          Box(
              padding: EdgeInsets.zero,
              child: Column(children: [
                for (final t in ['My bookings', 'Saved places', 'Notifications', 'Help and support'])
                  ListTile(
                      title: Text(t, style: body(17, c: C.forest)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {}),
              ])),
          const SizedBox(height: 18),
          Btn('Log out', () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const Welcome())),
              fg: const Color(0xFF356A8A), outlined: true),
        ]),
      );
}
