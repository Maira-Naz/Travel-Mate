import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import '../core.dart';
import 'storage.dart';

/// Local (on-device) account + login session.
/// Passwords are never stored: only a random salt + PBKDF2-HMAC-SHA256 hash.
/// Later this can be swapped for a real backend (Firebase Auth, etc.).
class Auth {
  static const _iter = 10000;
  static const _common = {'password', 'password1', '12345678', 'qwerty123', 'abc12345', 'iloveyou1', '123456789', 'welcome1'};

  static Map<String, dynamic>? get account {
    final j = Store.getJson('account');
    return j == null ? null : Map<String, dynamic>.from(j);
  }

  static bool get loggedIn => Store.getString('logged_in') == '1' && account != null;

  // ---------- password rules ----------
  static String? validatePassword(String p, {String name = '', String email = ''}) {
    if (p.length < 8) return 'Use at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(p) || !RegExp(r'\d').hasMatch(p)) return 'Include at least one letter and one number';
    if (_common.contains(p.toLowerCase())) return 'That password is too common';
    final local = email.split('@').first.toLowerCase();
    if (local.length >= 4 && p.toLowerCase().contains(local)) return 'Do not use your email in the password';
    return null;
  }

  /// 0 (empty) .. 4 (strong)
  static int strength(String p) {
    if (p.isEmpty) return 0;
    var s = 0;
    if (p.length >= 8) s++;
    if (p.length >= 12) s++;
    if (RegExp(r'[a-z]').hasMatch(p) && RegExp(r'[A-Z]').hasMatch(p)) s++;
    if (RegExp(r'\d').hasMatch(p) && RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
    return s.clamp(1, 4);
  }

  // ---------- hashing ----------
  static Uint8List _pbkdf2(String pw, List<int> salt, int iter) {
    final h = Hmac(sha256, utf8.encode(pw));
    var u = h.convert([...salt, 0, 0, 0, 1]).bytes;
    final t = List<int>.from(u);
    for (var i = 1; i < iter; i++) {
      u = h.convert(u).bytes;
      for (var j = 0; j < t.length; j++) {
        t[j] ^= u[j];
      }
    }
    return Uint8List.fromList(t);
  }

  static bool _same(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var d = 0;
    for (var i = 0; i < a.length; i++) {
      d |= a[i] ^ b[i];
    }
    return d == 0;
  }

  // ---------- actions ----------
  static Future<String?> signUp(String name, String email, String pw, String? photo) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final rnd = Random.secure();
    final salt = List<int>.generate(16, (_) => rnd.nextInt(256));
    await Store.setJson('account', {
      'name': name, 'email': email, 'iter': _iter,
      'salt': base64Encode(salt), 'hash': base64Encode(_pbkdf2(pw, salt, _iter)),
    });
    UserStore.name.value = name;
    UserStore.email.value = email;
    UserStore.photo.value = photo;
    await Store.setString('fails', '0');
    await Store.setString('logged_in', '1');
    return null;
  }

  static Future<String?> login(String id, String pw) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final now = DateTime.now().millisecondsSinceEpoch;
    final lock = int.tryParse(Store.getString('lock_until') ?? '') ?? 0;
    if (lock > now) return 'Too many attempts. Try again in ${((lock - now) / 1000).ceil()} seconds.';
    final a = account;
    if (a == null) return 'No account found on this device. Please sign up first.';
    final i = id.trim().toLowerCase();
    final idOk = i == (a['email'] as String).toLowerCase() || i == (a['name'] as String).toLowerCase();
    final h = _pbkdf2(pw, base64Decode(a['salt']), a['iter'] as int); // always hash (same timing)
    if (!idOk || !_same(h, base64Decode(a['hash']))) {
      final fails = (int.tryParse(Store.getString('fails') ?? '') ?? 0) + 1;
      if (fails >= 5) {
        await Store.setString('fails', '0');
        await Store.setString('lock_until', '${now + 30000}');
        return 'Too many attempts. Try again in 30 seconds.';
      }
      await Store.setString('fails', '$fails');
      return 'Incorrect email/username or password.';
    }
    await Store.setString('fails', '0');
    UserStore.name.value = a['name'];
    UserStore.email.value = a['email'];
    await Store.setString('logged_in', '1');
    return null;
  }

  static Future<void> logout() async => Store.setString('logged_in', null);

  static Future<void> updateProfile(String name, String email) async {
    final a = account;
    if (a == null) return;
    a['name'] = name;
    a['email'] = email;
    await Store.setJson('account', a);
  }
}
