import 'package:flutter/material.dart';
import '../core.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext context) => SubPage('Help and support',
      child: ListView(padding: const EdgeInsets.symmetric(horizontal: 22), children: [
        Text('Common questions', style: head(22)),
        const SizedBox(height: 10),
        for (final q in [
          ['How do I add a stop to my trip?', 'Open the Trips tab and tap Add stop. You can set the day and time, and edit or delete it later.'],
          ['How do I track my budget?', 'Go to Home > Budget and tap Add expense. Tap any expense to edit it.'],
          ['How do I mark a place as visited?', 'Use Mark visited on the Map, or tap a place in Home > Visited.'],
          ['Is my data saved?', 'Yes. Your profile, trips, expenses and visited places are saved on this device.'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Box(
                padding: EdgeInsets.zero,
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(q[0], style: body(16, c: C.forest, w: FontWeight.w700)),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedAlignment: Alignment.centerLeft,
                    children: [Text(q[1], style: body(15))],
                  ),
                )),
          ),
        const SizedBox(height: 14),
        Text('Contact us', style: head(22)),
        const SizedBox(height: 10),
        Btn('Email support', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Support email will be added soon'))), icon: Icons.mail_outline),
        const SizedBox(height: 10),
        Btn('Report a problem', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks! Reporting will be added soon'))), outlined: true),
        const SizedBox(height: 16),
      ]));
}
