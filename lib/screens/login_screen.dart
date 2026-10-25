import 'package:flutter/material.dart';
import '../core.dart';
import '../services/auth.dart';
import 'shell_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final id = TextEditingController(), pw = TextEditingController();
  String? error;
  bool busy = false;

  Future<void> _login() async {
    if (!emailRx.hasMatch(id.text.trim()) || pw.text.isEmpty) return setState(() => error = 'Enter your email and password');
    setState(() { busy = true; error = null; });
    final r = await Auth.login(id.text, pw.text);
    if (!mounted) return;
    setState(() => busy = false);
    if (r != null) return setState(() => error = r);
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Shell()), (_) => false);
  }

  Future<void> _forgot() async {
    final c = TextEditingController(text: id.text.trim());
    final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Reset password'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Enter your email and we will send you a reset link.'),
                TextField(controller: c, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
              ]),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Send link')),
              ],
            ));
    if (ok != true) return;
    if (!emailRx.hasMatch(c.text.trim())) return setState(() => error = 'Enter a valid email to reset your password');
    final r = await Auth.resetPassword(c.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r ?? 'If an account exists for that email, a reset link has been sent.')));
  }

  @override
  Widget build(BuildContext context) => SubPage('Welcome back',
      sub: 'Log in to continue your trips',
      bottom: SizedBox(width: double.infinity, child: Btn(busy ? 'Logging in...' : 'Log in', busy ? () {} : _login)),
      child: ListView(padding: const EdgeInsets.symmetric(horizontal: 22), children: [
        const SizedBox(height: 10),
        if (error != null)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFFBE3D7), borderRadius: BorderRadius.circular(18), border: Border.all(color: C.rust)),
            child: Row(children: [
              const Icon(Icons.error_outline, color: Color(0xFF8E2A18)),
              const SizedBox(width: 10),
              Expanded(child: Text(error!, style: body(14, c: const Color(0xFF6E1F12), w: FontWeight.w600))),
            ]),
          ),
        AppField(id, 'Email', Icons.mail_outline, type: TextInputType.emailAddress, action: TextInputAction.next, onChanged: (_) => setState(() => error = null)),
        const SizedBox(height: 14),
        AppField(pw, 'Password', Icons.lock_outline, password: true, onSubmit: (_) => _login(), onChanged: (_) => setState(() => error = null)),
        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _forgot, child: const Text('Forgot password?'))),
        const SizedBox(height: 6),
        Center(
            child: TextButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                child: const Text('New here? Create an account'))),
      ]));
}
