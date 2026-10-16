import 'package:flutter/material.dart';
import '../core.dart';

// ---------------- BOOKINGS TAB ----------------
class Bookings extends StatelessWidget {
  const Bookings({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(padding: const EdgeInsets.all(22), children: [
          Text('Bookings', style: head(30)),
          const SizedBox(height: 16),
          for (final b in [
            ['Hunza Valley, 5 days', '12 Nov to 16 Nov · 2 travellers', 'PKR 90,000', 'Confirmed'],
            ['Swat Valley, 3 days', '2 Dec to 4 Dec · 1 traveller', 'PKR 32,000', 'Pay later'],
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Box(
                  child: Row(children: [
                const PlaceThumb([Color(0xFF6E927F), Color(0xFF2F4A43)]),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(b[0], style: body(17, c: C.forest, w: FontWeight.w700)),
                  Text(b[1], style: body(13)),
                  const SizedBox(height: 6),
                  Text(b[2], style: body(15, c: C.forest, w: FontWeight.w700)),
                ])),
                Tag(b[3], const Color(0xFFD9EBDD), const Color(0xFF2A6B3C)),
              ])),
            ),
        ]),
      );
}
