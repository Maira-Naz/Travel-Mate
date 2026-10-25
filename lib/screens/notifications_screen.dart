import 'package:flutter/material.dart';
import '../core.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../services/place_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => SubPage('Notifications',
      child: ListView(padding: const EdgeInsets.symmetric(horizontal: 22), children: [
        ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: PlaceService.inbox,
          builder: (_, items, __) => items.isEmpty
              ? const SizedBox.shrink()
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('New', style: head(22)),
                  const SizedBox(height: 10),
                  for (final n in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Box(
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(Icons.notifications_active_outlined, color: C.sky, size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(n['title'] as String, style: body(16, c: C.forest, w: FontWeight.w800)),
                          Text(n['body'] as String, style: body(14)),
                          Text('${fmtDate(DateTime.parse(n['at'] as String))}, ${fmtClock(DateTime.parse(n['at'] as String))}', style: body(12)),
                        ])),
                      ])),
                    ),
                  const SizedBox(height: 14),
                ]),
        ),
        Text('Recent', style: head(22)),
        const SizedBox(height: 10),
        for (final n in [
          [Icons.warning_amber_rounded, C.rust, 'Moderate landslide risk', 'Heavy rain expected Tuesday near the Karakoram Highway.', '2h ago'],
          [Icons.check_circle_outline, C.sage, 'Booking confirmed', 'Hunza Valley, 12 Nov to 16 Nov, 2 travellers.', 'Yesterday'],
          [Icons.wb_sunny_outlined, C.sky, 'Weather update', 'Sunny on Monday, 15° in Hunza Valley.', '2 days ago'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Box(
                onTap: () {},
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(n[0] as IconData, color: n[1] as Color, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(n[2] as String, style: body(16, c: C.forest, w: FontWeight.w800)),
                    Text(n[3] as String, style: body(14)),
                  ])),
                  Text(n[4] as String, style: body(12)),
                ])),
          ),
        const SizedBox(height: 14),
        Text('Notify me about', style: head(22)),
        const SizedBox(height: 10),
        ValueListenableBuilder<Map<String, bool>>(
          valueListenable: AppState.notifs,
          builder: (_, m, __) => Box(
              padding: EdgeInsets.zero,
              child: Column(children: [
                for (final e in m.entries)
                  SwitchListTile(
                    title: Text(e.key, style: body(16, c: C.forest)),
                    value: e.value,
                    hoverColor: const Color(0x246E927F),
                    onChanged: (v) => AppState.notifs.value = {...m, e.key: v},
                  ),
              ])),
        ),
        const SizedBox(height: 16),
      ]));
}
