import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../core.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final name = TextEditingController(text: UserStore.name.value);
  final email = TextEditingController(text: UserStore.email.value);
  String? photo = UserStore.photo.value;
  String? error;

  Future<void> _pick() async {
    try {
      final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800);
      if (x != null) {
        final dir = await getApplicationDocumentsDirectory();
        final dest = '${dir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await File(x.path).copy(dest);
        setState(() => photo = dest);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the gallery')));
      }
    }
  }

  void _save() {
    final n = name.text.trim(), e = email.text.trim();
    if (n.isEmpty) return setState(() => error = 'Please enter your name');
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e)) {
      return setState(() => error = 'Please enter a valid email');
    }
    UserStore.name.value = n;
    UserStore.email.value = e;
    UserStore.photo.value = photo;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  InputDecoration _dec(String label) => InputDecoration(
      labelText: label, filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: const BorderSide(color: C.line)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: const BorderSide(color: C.line)));

  @override
  Widget build(BuildContext context) => SubPage('Edit profile',
      bottom: SizedBox(width: double.infinity, child: Btn('Save changes', _save)),
      child: ListView(padding: const EdgeInsets.symmetric(horizontal: 22), children: [
        const SizedBox(height: 8),
        Center(
          child: Stack(children: [
            CircleAvatar(
              radius: 60, backgroundColor: C.forest,
              backgroundImage: photo != null ? FileImage(File(photo!)) : null,
              child: photo != null
                  ? null
                  : Text(name.text.trim().isEmpty ? 'Y' : name.text.trim()[0].toUpperCase(),
                      style: const TextStyle(fontFamily: 'serif', color: C.cream, fontSize: 56, fontWeight: FontWeight.w800)),
            ),
            Positioned(
                right: 0, bottom: 0,
                child: InkWell(
                    onTap: _pick,
                    customBorder: const CircleBorder(),
                    child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: C.sky, shape: BoxShape.circle, border: Border.all(color: C.cream, width: 3)),
                        child: const Icon(Icons.camera_alt_outlined, color: C.forest, size: 22)))),
          ]),
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextButton(onPressed: _pick, child: const Text('Change photo')),
          if (photo != null) TextButton(onPressed: () => setState(() => photo = null), child: const Text('Remove')),
        ]),
        const SizedBox(height: 14),
        TextField(controller: name, onChanged: (_) => setState(() => error = null), decoration: _dec('Full name')),
        const SizedBox(height: 14),
        TextField(controller: email, keyboardType: TextInputType.emailAddress, onChanged: (_) => setState(() => error = null), decoration: _dec('Email')),
        if (error != null)
          Padding(padding: const EdgeInsets.only(top: 12, left: 8), child: Text(error!, style: body(14, c: C.rust, w: FontWeight.w700))),
      ]));
}
