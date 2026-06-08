import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final ImagePicker _picker = ImagePicker();

  // ─── PICK IMAGE ────────────────────────────────────────────────────────────

  /// Pick image from gallery
  static Future<File?> pickFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  /// Pick image from camera
  static Future<File?> pickFromCamera() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  // ─── UPLOAD PRODUCT IMAGE ──────────────────────────────────────────────────

  /// Upload product image — returns download URL
  static Future<String> uploadProductImage(
    File imageFile, {
    String? productId,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Belum login.');

    final fileName =
        productId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _storage.ref('products/$uid/$fileName.jpg');

    final task = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await task.ref.getDownloadURL();
  }

  /// Upload donation item image — returns download URL
  static Future<String> uploadDonationImage(File imageFile) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Belum login.');

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _storage.ref('donations/$uid/$fileName.jpg');

    final task = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await task.ref.getDownloadURL();
  }

  /// Upload avatar/profile photo — returns download URL
  static Future<String> uploadAvatar(File imageFile) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Belum login.');

    final ref = _storage.ref('avatars/$uid/profile.jpg');
    final task = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await task.ref.getDownloadURL();
  }

  /// Delete file from Storage by URL
  static Future<void> deleteByUrl(String url) async {
    if (url.isEmpty) return;
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {
      // Ignore if file doesn't exist
    }
  }
}
