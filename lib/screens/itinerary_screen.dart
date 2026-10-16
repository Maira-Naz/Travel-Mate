import 'package:flutter/material.dart';
import '../core.dart';

// ---------------- SCHEDULE / ITINERARY ----------------
class ItineraryScreen extends StatefulWidget {
  final bool embedded; // true when used as the "Trips" tab (no back button)
  const ItineraryScreen({super.key, this.embedded = false});
  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  int day = 0;
  final days = <List<List<String>>>[
    [['9:00 AM', 'Drive to Karimabad', 'Check in and rest, about 4 hours'],
     ['1:00 PM', 'Lunch at the bazaar', 'Local walnut cake and tea'],
     ['4:00 PM', 'Baltit Fort', 'Guided visit, 90 minutes']],
    [['10:00 AM', 'Attabad Lake boating', '2 hours, easy']],
    [['3:00 PM', "Eagle's Nest sunset hike", '3 hours, moderate']],
    [],
  ];

  Future<void> _add() async {
    final t = TextEditingController(), time = TextEditingController();
    final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Add stop'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: time, decoration: const InputDecoration(labelText: 'Time e.g. 6:00 PM')),
                TextField(controller: t, decoration: const InputDecoration(labelText: 'Place or activity')),
              ]),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add')),
              ],
            ));
    if (ok == true && t.text.isNotEmpty) {
      setState(() => days[day].add([time.text, t.text, 'Added by you']));
    }
  }

  @override
  Widget build(BuildContext context) {
    final stops = days[day];
    return Scaffold(
      backgroundColor: C.cream,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: _add, backgroundColor: C.sky, foregroundColor: C.forest,
          icon: const Icon(Icons.add), label: const Text('Add stop', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (!widget.embedded) ...[const BackDot(), const SizedBox(width: 14)],
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hunza, 5 days', style: head(26)),
                Text('12 Nov to 16 Nov', style: body(14)),
              ]),
            ]),
            const SizedBox(height: 18),
            Row(children: [
              for (var i = 0; i < 4; i++)
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => day = i),
                    child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                            color: day == i ? C.forest : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: C.line)),
                        child: Center(
                            child: Text('Day ${i + 1}',
                                style: body(15, c: day == i ? C.cream : C.forest,
                                    w: day == i ? FontWeight.w800 : FontWeight.w400)))),
                  ),
                )),
            ]),
            const SizedBox(height: 22),
            Expanded(
              child: stops.isEmpty
                  ? Center(child: Text('Nothing planned yet. Tap Add stop.', style: body(16)))
                  : ListView.builder(
                      itemCount: stops.length,
                      itemBuilder: (_, i) => IntrinsicHeight(
                        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          SizedBox(
                              width: 30,
                              child: Column(children: [
                                Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    width: 14, height: 14,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle, color: i == 0 ? C.sky : C.sage)),
                                if (i != stops.length - 1)
                                  Expanded(child: Container(width: 3, color: const Color(0xFFD9D0B8))),
                              ])),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(stops[i][0], style: body(15)),
                              const SizedBox(height: 6),
                              Box(
                                  child: SizedBox(
                                      width: double.infinity,
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(stops[i][1], style: body(17, c: C.forest, w: FontWeight.w800)),
                                        Text(stops[i][2], style: body(14)),
                                      ]))),
                            ]),
                          )),
                        ]),
                      ),
                    ),
            ),
          ]),
        ),
      ),
    );
  }
}
