import 'package:flutter/material.dart';

class C {
  static const cream = Color(0xFFF6EDDA);
  static const forest = Color(0xFF2F4A43);
  static const sage = Color(0xFF6E927F);
  static const sky = Color(0xFF7BA7BC);
  static const rust = Color(0xFFC4472E);
  static const muted = Color(0xFF5E7068);
  static const line = Color(0xFFE8DEC8);
}

TextStyle head(double s, {Color c = C.forest}) =>
    TextStyle(fontFamily: 'serif', fontSize: s, fontWeight: FontWeight.w800, color: c);
TextStyle body(double s, {Color c = C.muted, FontWeight w = FontWeight.w400}) =>
    TextStyle(fontSize: s, color: c, fontWeight: w);

class Box extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color color;
  final Color? border;
  final double radius;
  const Box({super.key, required this.child, this.padding = const EdgeInsets.all(16),
      this.onTap, this.color = Colors.white, this.border, this.radius = 22});
  @override
  Widget build(BuildContext context) => Material(
        color: color,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(color: border ?? C.line)),
        child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: onTap,
            child: Padding(padding: padding, child: child)),
      );
}

class Tag extends StatelessWidget {
  final String text;
  final Color bg, fg;
  const Tag(this.text, this.bg, this.fg, {super.key});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: body(13, c: fg, w: FontWeight.w700)));
}

class PlaceThumb extends StatelessWidget {
  final List<Color> colors;
  final double size;
  const PlaceThumb(this.colors, {super.key, this.size = 62});
  @override
  Widget build(BuildContext context) => Container(
      width: size, height: size,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors)));
}

class Btn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color bg, fg;
  final bool outlined;
  final IconData? icon;
  const Btn(this.label, this.onTap, {super.key, this.bg = C.sky, this.fg = C.forest,
      this.outlined = false, this.icon});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 54,
        child: outlined
            ? OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                    foregroundColor: fg, side: BorderSide(color: fg, width: 1.5),
                    shape: const StadiumBorder()),
                child: Text(label, style: body(16, c: fg, w: FontWeight.w700)))
            : ElevatedButton.icon(
                onPressed: onTap,
                icon: Icon(icon, size: icon == null ? 0 : 20, color: fg),
                style: ElevatedButton.styleFrom(
                    backgroundColor: bg, elevation: 0, shape: const StadiumBorder()),
                label: Text(label, style: body(16, c: fg, w: FontWeight.w700))),
      );
}

class Bar extends StatelessWidget {
  final double v;
  final Color color, track;
  const Bar(this.v, {super.key, this.color = C.sage, this.track = const Color(0xFFEDE3CC)});
  @override
  Widget build(BuildContext context) => ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
          value: v.clamp(0, 1), minHeight: 10, color: color, backgroundColor: track));
}

class BackDot extends StatelessWidget {
  const BackDot({super.key});
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: () => Navigator.maybePop(context),
      customBorder: const CircleBorder(),
      child: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
              color: Colors.white, shape: BoxShape.circle, border: Border.all(color: C.line)),
          child: const Icon(Icons.chevron_left, color: C.forest, size: 28)));
}

/// Standard sub-page: back button + serif title, cream background.
class SubPage extends StatelessWidget {
  final String title;
  final String? sub;
  final Widget child;
  final Widget? bottom;
  const SubPage(this.title, {super.key, this.sub, required this.child, this.bottom});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: C.cream,
        body: SafeArea(
            child: Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 12),
              child: Row(children: [
                const BackDot(),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: head(26)),
                  if (sub != null) Text(sub!, style: body(14)),
                ])),
              ])),
          Expanded(child: child),
          if (bottom != null)
            Padding(padding: const EdgeInsets.fromLTRB(22, 8, 22, 16), child: bottom),
        ])),
      );
}

// ---------------- MOCK DATA (replace with real data later) ----------------
class Place {
  final String name, region, price, about;
  final double rating;
  final List<Color> colors;
  const Place(this.name, this.region, this.price, this.rating, this.colors, this.about);
}

const places = [
  Place('Hunza Valley', 'Gilgit-Baltistan, Pakistan', 'PKR 45,000', 4.8,
      [Color(0xFFCFE3DC), Color(0xFF2F4A43)],
      'A high mountain valley known for terraced fields, old forts and views of Rakaposhi. [Add your own description here]'),
  Place('Swat Valley', 'Khyber Pakhtunkhwa, Pakistan', 'PKR 32,000', 4.6,
      [Color(0xFFBBD3DE), Color(0xFF356A8A)],
      'Green meadows, rivers and old Buddhist heritage in the north.'),
];

const hotels = [
  ['Karimabad Heights Hotel', 'Town centre, fort view', '4.7', 'PKR 14,000'],
  ['Riverside Lodge', 'Near Attabad Lake', '4.5', 'PKR 9,500'],
  ['Eagle View Guest House', 'Budget stay, mountain views', '4.3', 'PKR 5,000'],
];
const activities = [
  ['Baltit Fort tour', '90 minutes, easy'],
  ['Attabad Lake boating', '2 hours, easy'],
  ["Eagle's Nest sunset hike", '3 hours, moderate'],
];
const foods = [
  ['Chapshuro', 'Local meat-filled flatbread', 'PKR 600'],
  ['Walnut cake', 'Baked fresh in the bazaar', 'PKR 400'],
  ['Butter tea', 'Warm drink for cold evenings', 'PKR 200'],
];
const thumbs = [
  [Color(0xFFCFE3DC), Color(0xFF6E927F)],
  [Color(0xFF8FB0BE), Color(0xFF6E927F)],
  [Color(0xFFBBD3DE), Color(0xFF7BA7BC)],
  [Color(0xFFE6BD8A), Color(0xFFC98A4A)],
];
