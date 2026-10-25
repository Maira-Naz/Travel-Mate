import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core.dart';
import 'app_state.dart';
import 'place_service.dart';
import 'trip_store.dart';
import 'storage.dart';

/// Firebase Authentication (email + password). Firebase stores the password
/// securely (salted hash) and keeps the user logged in between app launches.
class Auth {
  static final _auth = FirebaseAuth.instance;
  static User? get user => _auth.currentUser;
  static bool get loggedIn => _auth.currentUser != null;
  static bool get emailVerified => _auth.currentUser?.emailVerified ?? false;

  // ---------- password rules (checked before Firebase is called) ----------
  static const _common = {'password', 'password1', '12345678', 'qwerty123', 'abc12345', 'iloveyou1', '123456789', 'welcome1'};

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

  static String _msg(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-login-credentials':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists. Try logging in.';
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'weak-password':
        return 'That password is too weak. Use a stronger one.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes and try again.';
      case 'network-request-failed':
        return 'No internet connection. Check your network and try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'requires-recent-login':
        return 'Please log in again and retry.';
      default:
        return 'Something went wrong (${e.code}).';
    }
  }

  // ---------- session ----------
  static Future<void> startSession(User u) async {
    await Store.loadUser(u.uid);
    UserStore.load(uid: u.uid, displayName: Store.getString('profile_name') ?? u.displayName, email: u.email);
    AppState.load();
    TripStore.i.load();
    PlaceService.load();
  }

  static void _endSession() {
    TripStore.i.reset();
    PlaceService.reset();
    AppState.reset();
    Store.clear();
    UserStore.reset();
    TabNav.index.value = 0;
  }

  // ---------- actions (return null on success, or an error message) ----------
  static Future<String?> signUp(String name, String email, String pw, String? photo) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: pw);
      final u = cred.user!;
      await u.updateDisplayName(name);
      if (photo != null) await Store.localSet('photo_${u.uid}', photo);
      FirebaseFirestore.instance
          .collection('users').doc(u.uid)
          .set({'name': name, 'email': email.trim(), 'createdAt': FieldValue.serverTimestamp()})
          .catchError((_) {});
      u.sendEmailVerification().catchError((_) {});
      await u.reload();
      await startSession(_auth.currentUser!);
      return null;
    } on FirebaseAuthException catch (e) {
      return _msg(e);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  static Future<String?> login(String email, String pw) async {
    try {
      final c = await _auth.signInWithEmailAndPassword(email: email.trim(), password: pw);
      await startSession(c.user!);
      return null;
    } on FirebaseAuthException catch (e) {
      return _msg(e);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
    _endSession();
  }

  static Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      // do not reveal whether an account exists
      if (e.code == 'user-not-found') return null;
      return _msg(e);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  static Future<String?> resendVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return _msg(e);
    }
  }

  static Future<void> refreshUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (_) {}
  }

  /// Works offline: the cloud copy is queued and sent when the phone is online again.
  static Future<void> updateName(String name) async {
    final u = _auth.currentUser;
    if (u == null) return;
    FirebaseFirestore.instance.collection('users').doc(u.uid).set({'name': name}, SetOptions(merge: true)).catchError((_) {});
    try {
      await u.updateDisplayName(name).timeout(const Duration(seconds: 4));
    } catch (_) {}
  }

  /// Permanently deletes the account and all its cloud data (needs the password again).
  static Future<String?> deleteAccount(String pw) async {
    final u = _auth.currentUser;
    if (u == null || u.email == null) return 'Not signed in.';
    try {
      await u.reauthenticateWithCredential(EmailAuthProvider.credential(email: u.email!, password: pw));
      final db = FirebaseFirestore.instance;
      final ref = db.collection('users').doc(u.uid);
      final data = await ref.collection('data').get();
      final batch = db.batch();
      for (final d in data.docs) {
        batch.delete(d.reference);
      }
      batch.delete(ref);
      await batch.commit();
      await Store.localSet('photo_${u.uid}', null);
      await u.delete();
      _endSession();
      return null;
    } on FirebaseAuthException catch (e) {
      return _msg(e);
    } catch (_) {
      return 'Could not delete the account. Please try again.';
    }
  }
}
