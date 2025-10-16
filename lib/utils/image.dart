import 'dart:io';

import 'package:image_picker/image_picker.dart';

abstract class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> getFromAlbum() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    return file == null ? null : File(file.path);
  }

  static Future<File?> getByCamera() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    return file == null ? null : File(file.path);
  }
}
