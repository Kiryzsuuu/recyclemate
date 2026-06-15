import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream of auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current logged-in Firebase user
  static User? get currentUser => _auth.currentUser;

  /// Check if logged in
  static bool get isLoggedIn => _auth.currentUser != null;

  // ─── REGISTER ────────────────────────────────────────────────────────────
  static Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String city = '',
    String phone = '',
    String role = 'buyer',
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user!.updateDisplayName(name);

      final userModel = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        city: city,
        phone: phone,
        role: role,
      );

      // Save to Firestore
      await _db.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'city': city,
        'phone': phone,
        'role': role,
        'avatar': '',
        'bio': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e.code));
    }
  }

  // ─── LOGIN ────────────────────────────────────────────────────────────────
  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await _db
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) {
        throw Exception('Data user tidak ditemukan.');
      }

      return UserModel.fromFirestore(doc.data()!, credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e.code));
    }
  }

  // ─── GET PROFILE ─────────────────────────────────────────────────────────
  static Future<UserModel?> getProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromFirestore(doc.data()!, user.uid);
  }

  // ─── UPDATE PROFILE ───────────────────────────────────────────────────────
  static Future<UserModel> updateProfile(Map<String, dynamic> updates) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Belum login.');

    await _db.collection('users').doc(user.uid).update(updates);

    if (updates['name'] != null) {
      await user.updateDisplayName(updates['name']);
    }

    final doc = await _db.collection('users').doc(user.uid).get();
    return UserModel.fromFirestore(doc.data()!, user.uid);
  }

  // ─── CHANGE PASSWORD ──────────────────────────────────────────────────────
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Belum login.');

    // Re-authenticate first
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    try {
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e.code));
    }
  }

  // ─── FORGOT PASSWORD ─────────────────────────────────────────────────────
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e.code));
    }
  }

  // ─── LOGOUT ──────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // ─── ERROR MESSAGES ───────────────────────────────────────────────────────
  static String _authErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan login.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah. Minimal 6 karakter.';
      case 'user-not-found':
        return 'Email atau password salah.';
      case 'wrong-password':
        return 'Email atau password salah.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah.';
      default:
        return 'Terjadi kesalahan: $code';
    }
  }
}
