import 'package:flutter/material.dart';
import '../core.dart';
import 'booking_screen.dart';

// ---------------- DESTINATION DETAIL (About / Hotels / Activities / Foods) ----------------
class DestinationScreen extends StatefulWidget {
  final Place place;
  const DestinationScreen(this.place, {super.key});
  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  int tab = 0;
  bool fav = false;
  final added = <int>{};
  static const tabs = ['About', 'Hotels', 'Activities', 'Foods'];

  Widget _tabBody() {
    switch (tab) {
      case 0:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            for (final s in [['Best time', 'Apr to Oct'], ['Duration', '5 days'], ['Altitude', '2,500 m']])
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Box(
                    radius: 18, padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s[0], style: body(12)),
                      const SizedBox(height: 4),
                      Text(s[1], style: body(15, c: C.forest, w: FontWeight.w800)),
                    ])),
              )),
          ]),
          const SizedBox(height: 18),
          Text('About', style: head(22)),
          const SizedBox(height: 6),
          Text(widget.place.about, style: body(16)),
          const SizedBox(height: 16),
          Text('Highlights', style: head(22)),
          const SizedBox(height: 10),
          Row(children: [
            for (final h in ['Baltit\nFort', 'Attabad\nLake', "Eagle's\nNest"])
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Box(radius: 26, child: Text(h, style: body(15, c: C.forest))),
              )),
          ]),
        ]);
      case 1:
        return Column(children: [
          for (var i = 0; i < hotels.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Box(
                  child: Row(children: [
                PlaceThumb(thumbs[i]),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(hotels[i][0], style: body(16, c: C.forest, w: FontWeight.w800)),
                  Text(hotels[i][1], style: body(13)),
                  Text('${hotels[i][2]} rating', style: body(13, c: C.forest)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(hotels[i][3], style: body(15, c: C.forest, w: FontWeight.w800)),
                  Text('per night', style: body(12)),
                ]),
              ])),
            ),
        ]);
      case 2:
        return Column(children: [
          for (var i = 0; i < activities.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Box(
                  child: Row(children: [
                PlaceThumb(thumbs[i]),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(activities[i][0], style: body(16, c: C.forest, w: FontWeight.w800)),
                  Text(activities[i][1], style: body(13)),
                ])),
                OutlinedButton(
                    onPressed: () => setState(() => added.contains(i) ? added.remove(i) : added.add(i)),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: C.forest, side: const BorderSide(color: C.forest, width: 1.5),
                        backgroundColor: added.contains(i) ? const Color(0xFFD9EBDD) : null,
                        shape: const StadiumBorder()),
                    child: Text(added.contains(i) ? 'Added' : 'Add')),
              ])),
            ),
        ]);
      default:
        return Column(children: [
          for (var i = 0; i < foods.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Box(
                  child: Row(children: [
                PlaceThumb(thumbs[(i + 2) % 4]),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(foods[i][0], style: body(16, c: C.forest, w: FontWeight.w800)),
                  Text(foods[i][1], style: body(13)),
                ])),
                Text(foods[i][2], style: body(14, c: C.forest, w: FontWeight.w800)),
              ])),
            ),
        ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.place;
    return Scaffold(
      backgroundColor: C.cream,
      body: Column(children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: p.colors)),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                CircleAvatar(radius: 24, backgroundColor: C.cream,
                    child: IconButton(icon: const Icon(Icons.chevron_left, color: C.forest),
                        onPressed: () => Navigator.pop(context))),
                CircleAvatar(radius: 24, backgroundColor: C.cream,
                    child: IconButton(
                        icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: C.forest),
                        onPressed: () => setState(() => fav = !fav))),
              ]),
            ),
          ),
        ),
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -30),
            child: Container(
              decoration: const BoxDecoration(
                  color: C.cream,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(34))),
              child: ListView(padding: const EdgeInsets.fromLTRB(22, 24, 22, 20), children: [
                Row(children: [
                  Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.name, style: head(32)),
                    Text(p.region, style: body(15)),
                  ])),
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [
                        const Icon(Icons.star, color: C.sky, size: 18),
                        const SizedBox(width: 6),
                        Text('${p.rating}', style: body(16, c: C.forest, w: FontWeight.w800)),
                      ])),
                ]),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: C.line)),
                  child: Row(children: [
                    for (var i = 0; i < tabs.length; i++)
                      Expanded(
                          child: GestureDetector(
                        onTap: () => setState(() => tab = i),
                        child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                                color: tab == i ? C.forest : Colors.transparent,
                                borderRadius: BorderRadius.circular(26)),
                            child: Center(
                                child: Text(tabs[i],
                                    style: body(14, c: tab == i ? C.cream : C.muted,
                                        w: tab == i ? FontWeight.w800 : FontWeight.w400)))),
                      )),
                  ]),
                ),
                const SizedBox(height: 16),
                _tabBody(),
              ]),
            ),
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('From', style: body(14)),
              Text(p.price, style: body(22, c: C.forest, w: FontWeight.w800)),
            ]),
            const SizedBox(width: 24),
            Expanded(
                child: Btn('Book this trip', () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => BookingScreen(p))))),
          ]),
        ),
      ]),
    );
  }
}
