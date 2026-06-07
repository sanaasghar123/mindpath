import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String?> uploadUserProfileImage({
    required String userId,
    required XFile image,
  }) async {
    try {
      final ref = _storage.ref('users/$userId/profile.jpg');
      final uploadTask = await ref.putFile(File(image.path));
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }
}
