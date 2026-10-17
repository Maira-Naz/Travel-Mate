import 'dart:io';
import 'package:flutter/material.dart';
import '../core.dart';
import '../services/auth.dart';
import '../services/media.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final name = TextEditingController(text: UserStore.name.value);
  final email = TextEditingController(text: UserStore.email.value);
  String? photo = UserStore.photo.value;
  Map<String, String> err = {};

  Future<void> _pick() async {
    final p = await pickPhoto();
    if (p != null) setState(() => photo = p);
  }

  Future<void> _save() async {
    final n = name.text.trim(), e = email.text.trim();
    final errs = <String, String>{};
    if (n.length < 2) errs['name'] = 'Please enter your name';
    if (!emailRx.hasMatch(e)) errs['email'] = 'Enter a valid email address';
    setState(() => err = errs);
    if (errs.isNotEmpty) return;
    UserStore.name.value = n;
    UserStore.email.value = e;
    UserStore.photo.value = photo;
    await Auth.updateProfile(n, e);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  @override
  Widget build(BuildContext context) => SubPage('Edit profile',
      bottom: SizedBox(width: double.infinity, child: Btn('Save changes', _save)),
      child: ListView(padding: const EdgeInsets.symmetric(horizontal: 22), children: [
        const SizedBox(height: 8),
        Center(
          child: Tap(
            radius: 64,
            onTap: _pick,
            child: Stack(children: [
              CircleAvatar(
                radius: 60, backgroundColor: C.forest,
                backgroundImage: photo != null ? FileImage(File(photo!)) : null,
                child: photo != null
                    ? null
                    : Text(name.text.trim().isEmpty ? 'Y' : name.text.trim()[0].toUpperCase(),
                        style: head(56, c: C.cream)),
              ),
              Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: C.sky, shape: BoxShape.circle, border: Border.all(color: C.cream, width: 3)),
                      child: const Icon(Icons.camera_alt_outlined, color: C.forest, size: 22))),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextButton(onPressed: _pick, child: const Text('Change photo')),
          if (photo != null) ...[
            const SizedBox(width: 28),
            TextButton(onPressed: () => setState(() => photo = null), style: TextButton.styleFrom(foregroundColor: C.rust), child: const Text('Remove photo')),
          ],
        ]),
        const SizedBox(height: 14),
        AppField(name, 'Full name', Icons.badge_outlined, error: err['name'], action: TextInputAction.next, onChanged: (_) => setState(() => err.remove('name'))),
        const SizedBox(height: 14),
        AppField(email, 'Email', Icons.mail_outline, type: TextInputType.emailAddress, error: err['email'], onChanged: (_) => setState(() => err.remove('email'))),
      ]));
}
