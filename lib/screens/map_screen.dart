import 'package:flutter/material.dart';
import '../core.dart';
import '../services/storage.dart';

// ---------------- MAP (placeholder painter; swap for google_maps_flutter later) ----------------
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int sel = 0, filter = 0;
  static const pts = [Offset(.51, .26), Offset(.31, .36), Offset(.36, .56), Offset(.67, .59), Offset(.88, .44)];
  static const stops = [
    ['Baltit Fort', 'Karimabad, 6 km from you', '15 min drive'],
    ['Karimabad Bazaar', 'Karimabad, 5 km from you', '12 min drive'],
    ['Riverside Lodge', 'Near Attabad Lake, 9 km', '20 min drive'],
    ['Attabad Lake', 'Gojal, 22 km from you', '35 min drive'],
    ["Eagle's Nest", 'Duikar, 14 km from you', '30 min drive'],
  ];
  bool visited(int i) => _visited.contains(i);
  final _visited = <int>{};

  @override
  void initState() {
    super.initState();
    final saved = Store.getJson('map_visited');
    if (saved != null) _visited.addAll(List<int>.from(saved));
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    Store.setJson('map_visited', _visited.toList());
  }

  @override
  Widget build(BuildContext context) {
    final s = stops[sel];
    return Scaffold(
      backgroundColor: const Color(0xFFCADCC8),
      body: LayoutBuilder(builder: (_, box) {
        final w = box.maxWidth, h = box.maxHeight;
        return Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _MapPainter(pts))),
          for (var i = 0; i < pts.length; i++)
            Positioned(
              left: pts[i].dx * w - 22, top: pts[i].dy * h - 22,
              child: Tap(
                radius: 22,
                onTap: () => setState(() => sel = i),
                child: Container(
                  width: 44, height: 44, alignment: Alignment.center,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: visited(i) ? C.forest : (i == sel ? C.sky : C.sage),
                      border: Border.all(color: Colors.white, width: 3)),
                  child: Text('${i + 1}', style: body(17, c: Colors.white, w: FontWeight.w800)),
                ),
              ),
            ),
          Positioned(left: .74 * w - 10, top: .735 * h, child: Container(
              width: 20, height: 20,
              decoration: BoxDecoration(color: const Color(0xFF2F6BE0), shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3)))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(children: [
                Row(children: [
                  const BackDot(),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Container(
                          height: 52, alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26)),
                          child: Text('Hunza Valley', style: body(17, c: C.forest, w: FontWeight.w800))))
                ]),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(spacing: 8, children: [
                    for (var i = 0; i < 4; i++)
                      ChoiceChip(
                        label: Text(['All', 'Stays', 'Food', 'Sights'][i]),
                        selected: filter == i,
                        onSelected: (_) => setState(() => filter = i),
                        selectedColor: C.forest,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(color: filter == i ? C.cream : C.forest, fontWeight: FontWeight.w700),
                        shape: const StadiumBorder(side: BorderSide(color: Colors.transparent)),
                        showCheckmark: false,
                      ),
                  ]),
                ),
              ]),
            ),
          ),
          Positioned(
            left: 16, right: 16, bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(30),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 18)]),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text('${sel + 1}. ${s[0]}', style: head(24))),
                  Tag(s[2], C.cream, C.forest),
                ]),
                Text(s[1], style: body(15)),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: Btn('Get directions', () {})),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Btn(visited(sel) ? 'Visited ✓' : 'Mark visited',
                          () => setState(() => visited(sel) ? _visited.remove(sel) : _visited.add(sel)),
                          outlined: true)),
                ]),
              ]),
            ),
          ),
        ]);
      }),
    );
  }
}

class _MapPainter extends CustomPainter {
  final List<Offset> p;
  _MapPainter(this.p);
  @override
  void paint(Canvas c, Size s) {
    Offset o(Offset f) => Offset(f.dx * s.width, f.dy * s.height);
    c.drawRect(Rect.fromLTWH(0, s.height * .16, s.width, s.height * .72), Paint()..color = const Color(0xFFE8E0CD));
    final river = Path()
      ..moveTo(0, s.height * .42)
      ..quadraticBezierTo(s.width * .3, s.height * .4, s.width * .5, s.height * .48)
      ..quadraticBezierTo(s.width * .75, s.height * .5, s.width, s.height * .46);
    c.drawPath(river, Paint()..color = const Color(0xFFA9C4CC)..style = PaintingStyle.stroke..strokeWidth = 40);
    final road = Paint()..color = Colors.white..strokeWidth = 9..strokeCap = StrokeCap.round;
    for (final e in [[0, 1], [1, 2], [2, 3]]) {
      c.drawLine(o(p[e[0]]), o(p[e[1]]), road);
    }
    c.drawLine(o(p[3]), Offset(s.width * .8, s.height * .83), road);
    c.drawLine(o(p[2]), Offset(0, s.height * .62), road);
    c.drawLine(o(p[3]), Offset(s.width, s.height * .52), road);
  }
  @override
  bool shouldRepaint(_) => false;
}
