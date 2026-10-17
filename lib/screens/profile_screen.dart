import 'package:flutter/material.dart';
import '../core.dart';
import '../services/app_state.dart';
import '../services/auth.dart';
import 'welcome_screen.dart';
import 'edit_profile_screen.dart';
import 'saved_places_screen.dart';
import 'notifications_screen.dart';
import 'help_screen.dart';
import 'language_screen.dart';

// ---------------- PROFILE ----------------
class Profile extends StatelessWidget {
  const Profile({super.key});
  void _open(BuildContext c, Widget w) => Navigator.push(c, MaterialPageRoute(builder: (_) => w));

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Log out?'),
              content: const Text('You will need to log in again to open your trips.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: C.rust), child: const Text('Log out')),
              ],
            ));
    if (ok != true) return;
    await Auth.logout();
    TabNav.index.value = 0;
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Welcome()), (_) => false);
    }
  }

  Widget _row(BuildContext c, IconData icon, String title, VoidCallback onTap, {Widget? trailing, bool last = false}) => Column(children: [
        Tap(
            radius: 0,
            onTap: onTap,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Row(children: [
                  Icon(icon, color: C.sage, size: 24),
                  const SizedBox(width: 14),
                  Expanded(child: Text(title, style: body(17, c: C.forest))),
                  if (trailing != null) trailing,
                  const Icon(Icons.chevron_right, color: C.muted),
                ]))),
        if (!last) const Divider(height: 1, color: C.line),
      ]);

  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(padding: const EdgeInsets.all(22), children: [
          const SizedBox(height: 10),
          const Center(child: Avatar(radius: 52, fontSize: 52)),
          const SizedBox(height: 14),
          ValueListenableBuilder<String>(valueListenable: UserStore.name, builder: (_, v, __) => Center(child: Text(v, style: head(28)))),
          ValueListenableBuilder<String>(valueListenable: UserStore.email, builder: (_, v, __) => Center(child: Text(v, style: body(16)))),
          const SizedBox(height: 12),
          Center(
              child: OutlinedButton.icon(
                  onPressed: () => _open(context, const EditProfileScreen()),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit profile'),
                  style: OutlinedButton.styleFrom(foregroundColor: C.forest, side: const BorderSide(color: C.forest, width: 1.4), shape: const StadiumBorder()).copyWith(overlayColor: appOverlay))),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Box(onTap: () => TabNav.index.value = 1, child: SizedBox(width: double.infinity, child: Column(children: [Text('3', style: head(28)), Text('Trips', style: body(13))]))))),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ValueListenableBuilder<List<String>>(
                        valueListenable: AppState.saved,
                        builder: (_, s, __) => Box(onTap: () => _open(context, const SavedPlacesScreen()), child: SizedBox(width: double.infinity, child: Column(children: [Text('${s.length}', style: head(28)), Text('Saved places', style: body(13))])))))),
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Box(onTap: () => TabNav.index.value = 2, child: SizedBox(width: double.infinity, child: Column(children: [Text('2', style: head(28)), Text('Bookings', style: body(13))]))))),
          ]),
          const SizedBox(height: 18),
          Box(
              padding: EdgeInsets.zero,
              child: Column(children: [
                _row(context, Icons.credit_card, 'My bookings', () => TabNav.index.value = 2),
                _row(context, Icons.favorite_border, 'Saved places', () => _open(context, const SavedPlacesScreen())),
                _row(context, Icons.notifications_none, 'Notifications', () => _open(context, const NotificationsScreen())),
                ValueListenableBuilder<String>(
                    valueListenable: AppState.language,
                    builder: (_, l, __) => _row(context, Icons.language, 'Language', () => _open(context, const LanguageScreen()),
                        trailing: Padding(padding: const EdgeInsets.only(right: 6), child: Text(l, style: body(14))))),
                _row(context, Icons.help_outline, 'Help and support', () => _open(context, const HelpScreen()), last: true),
              ])),
          const SizedBox(height: 18),
          Btn('Log out', () => _logout(context), fg: const Color(0xFF356A8A), outlined: true),
          const SizedBox(height: 10),
        ]),
      );
}
