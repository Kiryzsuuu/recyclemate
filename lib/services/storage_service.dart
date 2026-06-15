import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class StorageService {
  static final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  static Future<File?> pickFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  // Pick image from camera
  static Future<File?> pickFromCamera() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  // Convert file to base64 string
  static Future<String> toBase64(File file) async {
    final bytes = await file.readAsBytes();
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }

  // Upload product image — returns base64 string
  static Future<String> uploadProductImage(File imageFile, {String? productId}) async {
    return toBase64(imageFile);
  }

  // Upload donation image — returns base64 string
  static Future<String> uploadDonationImage(File imageFile) async {
    return toBase64(imageFile);
  }

  // Upload avatar — returns base64 string
  static Future<String> uploadAvatar(File imageFile) async {
    return toBase64(imageFile);
  }

  // No-op: base64 tidak perlu dihapus
  static Future<void> deleteByUrl(String url) async {}
}
