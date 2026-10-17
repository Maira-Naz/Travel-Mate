import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Pick a photo from the gallery and copy it into the app folder. Returns the saved path.
Future<String?> pickPhoto() async {
  try {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (x == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final dest = '${dir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(x.path).copy(dest);
    return dest;
  } catch (_) {
    return null;
  }
}
