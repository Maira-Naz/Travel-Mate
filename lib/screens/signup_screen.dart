import 'dart:io';
import 'package:flutter/material.dart';
import '../core.dart';
import '../services/auth.dart';
import '../services/media.dart';
import 'login_screen.dart';
import 'shell_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final name = TextEditingController(), email = TextEditingController();
  final pw = TextEditingController(), pw2 = TextEditingController();
  String? photo;
  Map<String, String> err = {};
  bool busy = false;

  Future<void> _submit() async {
    final n = name.text.trim(), e = email.text.trim();
    final errs = <String, String>{};
    if (n.length < 2) errs['name'] = 'Please enter your name';
    if (!emailRx.hasMatch(e)) errs['email'] = 'Enter a valid email address';
    final pe = Auth.validatePassword(pw.text, name: n, email: e);
    if (pe != null) errs['pw'] = pe;
    if (pw2.text != pw.text) errs['pw2'] = 'Passwords do not match';
    setState(() => err = errs);
    if (errs.isNotEmpty) return;
    setState(() => busy = true);
    final r = await Auth.signUp(n, e, pw.text, photo);
    if (!mounted) return;
    setState(() => busy = false);
    if (r != null) return setState(() => err = {'email': r});
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Shell()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final s = Auth.strength(pw.text);
    final labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
    final cols = [C.line, C.rust, const Color(0xFFC98A4A), C.sky, C.sage];
    return SubPage('Set up your profile',
        sub: 'Create your account to start planning',
        bottom: SizedBox(width: double.infinity, child: Btn(busy ? 'Creating account...' : 'Create account', busy ? () {} : _submit)),
        child: ListView(padding: const EdgeInsets.symmetric(horizontal: 22), children: [
          const SizedBox(height: 6),
          Center(
            child: Tap(
              radius: 60,
              onTap: () async {
                final p = await pickPhoto();
                if (p != null) setState(() => photo = p);
              },
              child: Stack(children: [
                CircleAvatar(
                  radius: 54, backgroundColor: const Color(0xFFDDE6DD),
                  backgroundImage: photo != null ? FileImage(File(photo!)) : null,
                  child: photo != null ? null : const Icon(Icons.person_outline, size: 54, color: C.sage),
                ),
                Positioned(
                    right: 0, bottom: 0,
                    child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(color: C.sky, shape: BoxShape.circle, border: Border.all(color: C.cream, width: 3)),
                        child: const Icon(Icons.camera_alt_outlined, size: 20, color: C.forest))),
              ]),
            ),
          ),
          const SizedBox(height: 6),
          Center(child: Text(photo == null ? 'Add a profile photo (optional)' : 'Tap the photo to change it', style: body(14))),
          if (photo != null) Center(child: TextButton(onPressed: () => setState(() => photo = null), style: TextButton.styleFrom(foregroundColor: C.rust), child: const Text('Remove photo'))),
          const SizedBox(height: 14),
          AppField(name, 'Full name', Icons.badge_outlined, error: err['name'], action: TextInputAction.next, onChanged: (_) => setState(() => err.remove('name'))),
          const SizedBox(height: 14),
          AppField(email, 'Email', Icons.mail_outline, type: TextInputType.emailAddress, error: err['email'], action: TextInputAction.next, onChanged: (_) => setState(() => err.remove('email'))),
          const SizedBox(height: 14),
          AppField(pw, 'Password', Icons.lock_outline, password: true, error: err['pw'], action: TextInputAction.next, onChanged: (_) => setState(() => err.remove('pw'))),
          const SizedBox(height: 8),
          Row(children: [
            for (var i = 1; i <= 4; i++)
              Expanded(child: Container(height: 6, margin: const EdgeInsets.only(right: 5), decoration: BoxDecoration(color: s >= i ? cols[s] : C.line, borderRadius: BorderRadius.circular(6)))),
            const SizedBox(width: 8),
            SizedBox(width: 52, child: Text(labels[s], style: body(13, c: C.forest, w: FontWeight.w700))),
          ]),
          const SizedBox(height: 4),
          Text('Use 8+ characters with letters and numbers. Longer is stronger.', style: body(12.5)),
          const SizedBox(height: 14),
          AppField(pw2, 'Confirm password', Icons.lock_reset_outlined, password: true, error: err['pw2'], onSubmit: (_) => _submit(), onChanged: (_) => setState(() => err.remove('pw2'))),
          const SizedBox(height: 14),
          Row(children: [
            const Icon(Icons.language, size: 18, color: C.muted),
            const SizedBox(width: 8),
            Text('Language: English (you can change it later in Profile)', style: body(13)),
          ]),
          const SizedBox(height: 10),
          Center(
              child: TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('Already have an account? Log in'))),
          const SizedBox(height: 10),
        ]));
  }
}
