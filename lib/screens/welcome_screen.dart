import 'package:flutter/material.dart';
import '../core.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

// ---------------- 1. WELCOME ----------------
class Welcome extends StatelessWidget {
  const Welcome({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Color(0xFF6B8F7E), Color(0xFF2F4A43), Color(0xFF233A34)])),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 40),
                Row(children: [
                  const Icon(Icons.explore_outlined, color: C.cream, size: 38),
                  const SizedBox(width: 10),
                  Text('Roam', style: head(30, c: C.cream)),
                ]),
                Expanded(
                    child: Stack(children: [
                  Positioned(
                      right: -60, top: 60,
                      child: Container(
                          width: 300, height: 300,
                          decoration: const BoxDecoration(color: C.sky, shape: BoxShape.circle))),
                  Positioned(
                      right: 50, top: 100,
                      child: Container(
                          width: 190, height: 190,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white54, width: 2)))),
                ])),
                Text('Plan the trip.\nSkip the tabs.', style: head(44, c: C.cream)),
                const SizedBox(height: 14),
                Text('Discover places, build an itinerary and book stays in one app.',
                    style: body(18, c: const Color(0xFFD5DDD6))),
                const SizedBox(height: 28),
                SizedBox(
                    width: double.infinity,
                    child: Btn('Get started', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())), bg: C.cream, fg: C.forest)),
                const SizedBox(height: 8),
                Center(
                    child: TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                        child: Text('I already have an account',
                            style: body(16, c: const Color(0xFFD5DDD6))))),
              ]),
            ),
          ),
        ),
      );
}
