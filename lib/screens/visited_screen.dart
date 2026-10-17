import 'package:flutter/material.dart';
import '../core.dart';
import '../services/storage.dart';

// ---------------- VISITED / NOT VISITED ----------------
class VisitedScreen extends StatefulWidget {
  const VisitedScreen({super.key});
  @override
  State<VisitedScreen> createState() => _VisitedScreenState();
}

class _VisitedScreenState extends State<VisitedScreen> {
  bool showVisited = true;
  final items = <List<dynamic>>[
    ['Baltit Fort', 'Visited 12 Nov', true], ['Attabad Lake', 'Visited 13 Nov', true],
    ["Eagle's Nest", 'Visited 14 Nov', true], ['Karimabad Bazaar', 'Visited 12 Nov', true],
    ['Passu Cones', 'Not yet', false], ['Khunjerab Pass', 'Not yet', false],
    ['Altit Fort', 'Not yet', false], ['Rakaposhi View Point', 'Not yet', false],
    ['Borith Lake', 'Not yet', false],
  ];
  @override
  void initState() {
    super.initState();
    final saved = Store.getJson('visited_items');
    if (saved != null) {
      items
        ..clear()
        ..addAll((saved as List).map((e) => List<dynamic>.from(e)));
    }
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    Store.setJson('visited_items', items);
  }

  @override
  Widget build(BuildContext context) {
    final vis = items.where((e) => e[2] == true).length;
    final list = items.where((e) => e[2] == showVisited).toList();
    return SubPage('My places',
        child: ListView(padding: const EdgeInsets.symmetric(horizontal: 22), children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: C.line)),
            child: Row(children: [
              for (final v in [true, false])
                Expanded(
                    child: GestureDetector(
                  onTap: () => setState(() => showVisited = v),
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                          color: showVisited == v ? C.forest : Colors.transparent,
                          borderRadius: BorderRadius.circular(28)),
                      child: Center(
                          child: Text(v ? 'Visited ($vis)' : 'Not visited (${items.length - vis})',
                              style: body(16, c: showVisited == v ? C.cream : C.muted, w: FontWeight.w800)))),
                )),
            ]),
          ),
          const SizedBox(height: 14),
          Box(
              child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('$vis of ${items.length} places', style: body(16, c: C.forest, w: FontWeight.w800)),
              Text('${(vis * 100 / items.length).round()}%', style: body(16)),
            ]),
            const SizedBox(height: 10),
            Bar(vis / items.length),
          ])),
          const SizedBox(height: 14),
          for (final e in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Box(
                  onTap: () => setState(() {
                        e[2] = !(e[2] as bool);
                        e[1] = e[2] ? 'Visited today' : 'Not yet';
                      }),
                  child: Row(children: [
                    PlaceThumb(thumbs[items.indexOf(e) % 4], size: 52),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(e[0], style: body(17, c: C.forest, w: FontWeight.w800)),
                      Text(e[1], style: body(14)),
                    ])),
                    Icon(e[2] ? Icons.check_circle_outline : Icons.radio_button_unchecked, color: C.sage, size: 30),
                  ])),
            ),
          Center(
              child: Text(showVisited ? 'Switch to Not visited to see what is left on your list'
                  : 'Tap a place to mark it as visited', style: body(14))),
        ]));
  }
}
