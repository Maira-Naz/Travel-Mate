import 'package:flutter/material.dart';
import '../core.dart';

// ---------------- SAFETY ALERTS (hook the AI model in here later) ----------------
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final risks = [
      ['Landslide', 'Moderate', const Color(0xFFF7D9D2), const Color(0xFF8E2A18)],
      ['Flood', 'Low', const Color(0xFFF3E8BF), const Color(0xFF6B5410)],
      ['Earthquake', 'Very low', const Color(0xFFD9EBDD), const Color(0xFF2A6B3C)],
      ['Heavy snow', 'Very low', const Color(0xFFD9EBDD), const Color(0xFF2A6B3C)],
    ];
    return SubPage('Safety alerts',
        bottom: SizedBox(
            width: double.infinity,
            child: Btn('Emergency contacts', () => showModalBottomSheet(
                context: context,
                builder: (_) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      for (final c in [['Rescue', '1122'], ['Police', '15'], ['Tourist helpline', '1422']])
                        ListTile(
                            leading: const Icon(Icons.call, color: C.rust),
                            title: Text(c[0]), trailing: Text(c[1], style: const TextStyle(fontWeight: FontWeight.w800))),
                    ]))),
                bg: C.rust, fg: Colors.white)),
        child: ListView(padding: const EdgeInsets.symmetric(horizontal: 22), children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: const Color(0xFFFBE3D7), borderRadius: BorderRadius.circular(26),
                border: Border.all(color: C.rust, width: 1.5)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFF8E2A18), size: 40),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Moderate landslide risk, next 48 hours',
                    style: body(19, c: const Color(0xFF6E1F12), w: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Heavy rain expected Tuesday near the Karakoram Highway. Check the road status before you travel.',
                    style: body(15, c: const Color(0xFF6E1F12))),
              ])),
            ]),
          ),
          const SizedBox(height: 22),
          Text('Risk by hazard', style: head(22)),
          const SizedBox(height: 10),
          for (final r in risks)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Box(
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(r[0] as String, style: body(18, c: C.forest, w: FontWeight.w800)),
                Tag(r[1] as String, r[2] as Color, r[3] as Color),
              ])),
            ),
          const SizedBox(height: 12),
          Text('What to do', style: head(22)),
          const SizedBox(height: 10),
          Box(
              child: Text('Avoid steep roads during rain, keep your phone charged and share your route with someone you trust.',
                  style: body(16))),
          const SizedBox(height: 16),
        ]));
  }
}
