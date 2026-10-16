import 'package:flutter/material.dart';
import '../core.dart';

// ---------------- WEATHER ----------------
class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final fc = [['Mon', '15°', 'Sunny'], ['Tue', '12°', 'Rain'], ['Wed', '10°', 'Cloudy'], ['Thu', '13°', 'Sunny']];
    final picks = [
      ['Attabad Lake', 'Calm water, clear views', 'Great pick', const Color(0xFFD9EBDD), const Color(0xFF2A6B3C)],
      ['Baltit Fort', 'Works in any light', 'Good', const Color(0xFFF3E8BF), const Color(0xFF6B5410)],
      ["Eagle's Nest hike", 'Strong wind near the top', 'Skip today', const Color(0xFFF7D9D2), const Color(0xFF8E2A18)],
    ];
    return SubPage('Weather',
        child: ListView(padding: const EdgeInsets.symmetric(horizontal: 22), children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF6B8F7E), Color(0xFF2F4A43)])),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Hunza Valley, today', style: body(16, c: const Color(0xFFD5DDD6))),
                  Text('14°', style: head(72, c: C.cream)),
                  Text('Partly cloudy', style: body(18, c: C.cream)),
                ]),
                const Icon(Icons.wb_cloudy_outlined, size: 70, color: C.cream),
              ]),
              const Divider(color: Colors.white24, height: 28),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                for (final s in [['Humidity', '52%'], ['Wind', '12 km/h'], ['Rain chance', '20%']])
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s[0], style: body(14, c: const Color(0xFFD5DDD6))),
                    Text(s[1], style: body(17, c: C.cream, w: FontWeight.w800)),
                  ]),
              ]),
            ]),
          ),
          const SizedBox(height: 14),
          Row(children: [
            for (final f in fc)
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Box(
                    radius: 22, padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(children: [
                      Text(f[0], style: body(14)),
                      Text(f[1], style: body(18, c: C.forest, w: FontWeight.w800)),
                      Text(f[2], style: body(13)),
                    ])),
              )),
          ]),
          const SizedBox(height: 22),
          Text('Where to go in this weather', style: head(22)),
          const SizedBox(height: 10),
          for (final p in picks)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Box(
                  child: Row(children: [
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p[0] as String, style: body(18, c: C.forest, w: FontWeight.w800)),
                  Text(p[1] as String, style: body(14)),
                ])),
                Tag(p[2] as String, p[3] as Color, p[4] as Color),
              ])),
            ),
        ]));
  }
}
