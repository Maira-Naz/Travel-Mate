import 'dart:io';
import 'package:flutter/material.dart';
import 'services/storage.dart';

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
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(color: border ?? C.line)),
        child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: onTap,
            hoverColor: const Color(0x246E927F),
            splashColor: const Color(0x406E927F),
            highlightColor: const Color(0x2E6E927F),
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
                    shape: const StadiumBorder()).copyWith(overlayColor: appOverlay),
                child: Text(label, style: body(16, c: fg, w: FontWeight.w700)))
            : ElevatedButton.icon(
                onPressed: onTap,
                icon: Icon(icon, size: icon == null ? 0 : 20, color: fg),
                style: ElevatedButton.styleFrom(
                    backgroundColor: bg, elevation: 0, shape: const StadiumBorder()).copyWith(overlayColor: appOverlay),
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
  Place('Skardu', 'Gilgit-Baltistan, Pakistan', 'PKR 52,000', 4.7,
      [Color(0xFFD9E4EA), Color(0xFF3F5E6B)],
      'Gateway to Deosai, Shangrila Lake and the high peaks of the Karakoram.'),
  Place('Naran Kaghan', 'Khyber Pakhtunkhwa, Pakistan', 'PKR 28,000', 4.5,
      [Color(0xFFD8E8D2), Color(0xFF47694F)],
      'Alpine lakes, Lake Saif-ul-Malook and cool green valleys.'),
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

// ---------------- USER PROFILE (shared, editable) ----------------
class UserStore {
  static final name = ValueNotifier<String>('Your Name');
  static final email = ValueNotifier<String>('you@email.com');
  static final photo = ValueNotifier<String?>(null); // local file path

  /// Load saved values and auto-save on every change.
  static void init() {
    name.value = Store.getString('user_name') ?? name.value;
    email.value = Store.getString('user_email') ?? email.value;
    final p = Store.getString('user_photo');
    photo.value = (p != null && File(p).existsSync()) ? p : null;
    name.addListener(() => Store.setString('user_name', name.value));
    email.addListener(() => Store.setString('user_email', email.value));
    photo.addListener(() => Store.setString('user_photo', photo.value));
  }
}

class Avatar extends StatelessWidget {
  final double radius, fontSize;
  const Avatar({super.key, this.radius = 28, this.fontSize = 22});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([UserStore.name, UserStore.photo]),
        builder: (_, __) {
          final path = UserStore.photo.value;
          final n = UserStore.name.value.trim();
          return CircleAvatar(
            radius: radius,
            backgroundColor: C.forest,
            backgroundImage: path != null ? FileImage(File(path)) : null,
            child: path != null
                ? null
                : Text(n.isEmpty ? 'Y' : n[0].toUpperCase(),
                    style: TextStyle(fontFamily: 'serif', color: C.cream, fontSize: fontSize, fontWeight: FontWeight.w800)),
          );
        },
      );
}

// ---------------- INTERACTION HELPERS ----------------
final emailRx = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Hover (desktop) + press (phone) colours used by all buttons, in the app palette.
final appOverlay = WidgetStateProperty.resolveWith<Color?>((s) {
  if (s.contains(WidgetState.pressed)) return const Color(0x382F4A43);
  if (s.contains(WidgetState.hovered)) return const Color(0x1F2F4A43);
  return null;
});

/// Tappable area with hover + pressed feedback. Drop-in replacement for GestureDetector.
class Tap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double radius;
  const Tap({super.key, required this.child, this.onTap, this.radius = 16});
  @override
  State<Tap> createState() => _TapState();
}

class _TapState extends State<Tap> {
  bool hover = false, down = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
        onEnter: (_) => setState(() => hover = true),
        onExit: (_) => setState(() => hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => down = true),
          onTapUp: (_) => setState(() => down = false),
          onTapCancel: () => setState(() => down = false),
          onTap: widget.onTap,
          child: Stack(fit: StackFit.passthrough, children: [
            widget.child,
            Positioned.fill(
                child: IgnorePointer(
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        decoration: BoxDecoration(
                            color: down ? const Color(0x476E927F) : (hover ? const Color(0x266E927F) : Colors.transparent),
                            borderRadius: BorderRadius.circular(widget.radius))))),
          ]),
        ),
      );
}

/// Switch between bottom-nav tabs from anywhere (0 Home, 1 Trips, 2 Bookings, 3 Profile).
class TabNav {
  static final index = ValueNotifier<int>(0);
}

/// Edit and Delete buttons, clearly separated (gap + divider + different colours).
class EditDelete extends StatelessWidget {
  final VoidCallback onEdit, onDelete;
  const EditDelete({super.key, required this.onEdit, required this.onDelete});
  Widget _b(IconData i, Color c, Color bg, String tip, VoidCallback f) => Tooltip(
      message: tip,
      child: Tap(
          radius: 22, onTap: f,
          child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(i, size: 21, color: c))));
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        _b(Icons.edit_outlined, C.forest, const Color(0x266E927F), 'Edit', onEdit),
        Container(margin: const EdgeInsets.symmetric(horizontal: 12), width: 1, height: 30, color: C.line),
        _b(Icons.delete_outline, C.rust, const Color(0x1FC4472E), 'Delete', onDelete),
      ]);
}

Future<bool> confirmDelete(BuildContext context, String what) async =>
    await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Delete this?'),
              content: Text('"$what" will be removed. You can undo right after.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: TextButton.styleFrom(foregroundColor: C.rust),
                    child: const Text('Delete')),
              ],
            )) ??
    false;

/// Rounded text field used by sign up / login. Password fields get a show/hide eye.
class AppField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool password;
  final String? error;
  final TextInputType? type;
  final ValueChanged<String>? onChanged, onSubmit;
  final TextInputAction? action;
  const AppField(this.controller, this.label, this.icon,
      {super.key, this.password = false, this.error, this.type, this.onChanged, this.onSubmit, this.action});
  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  bool hide = true;
  OutlineInputBorder _b(Color c) => OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: BorderSide(color: c, width: 1.4));
  @override
  Widget build(BuildContext context) => TextField(
        controller: widget.controller,
        obscureText: widget.password && hide,
        keyboardType: widget.type,
        textInputAction: widget.action,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmit,
        autocorrect: !widget.password,
        enableSuggestions: !widget.password,
        decoration: InputDecoration(
          labelText: widget.label, errorText: widget.error, filled: true, fillColor: Colors.white,
          prefixIcon: Icon(widget.icon, color: C.sage),
          suffixIcon: widget.password
              ? IconButton(
                  tooltip: hide ? 'Show password' : 'Hide password',
                  icon: Icon(hide ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: C.muted),
                  onPressed: () => setState(() => hide = !hide))
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          border: _b(C.line), enabledBorder: _b(C.line), focusedBorder: _b(C.forest),
          errorBorder: _b(C.rust), focusedErrorBorder: _b(C.rust),
        ),
      );
}
