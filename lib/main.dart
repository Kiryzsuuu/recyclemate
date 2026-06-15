import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/manage_products_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/open_store_screen.dart';
import 'screens/forgot_password_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  _ensureAdminAccount(); // non-blocking, one-time setup
  runApp(const RecycleMateApp());
}

// Admin email dikonfigurasi di sini — ganti sesuai kebutuhan deployment.
// Jangan commit password ke git; gunakan env var saat production.
const _kAdminEmail = String.fromEnvironment('ADMIN_EMAIL', defaultValue: 'maskiryz23@gmail.com');
const _kAdminPassword = String.fromEnvironment('ADMIN_PASSWORD', defaultValue: 'opet123');

/// One-time admin account creation — runs only if flag not set in Firestore.
Future<void> _ensureAdminAccount() async {
  try {
    final db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    final setupDoc = await db.collection('app_config').doc('setup').get();
    if (setupDoc.data()?['adminCreated'] == true) {
      // Pastikan role admin tidak berubah secara tidak sengaja
      final q = await db
          .collection('users')
          .where('email', isEqualTo: _kAdminEmail)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty && q.docs.first.data()['role'] != 'admin') {
        await q.docs.first.reference.update({'role': 'admin'});
      }
      return;
    }

    UserCredential? cred;
    try {
      cred = await auth.createUserWithEmailAndPassword(
        email: _kAdminEmail,
        password: _kAdminPassword,
      );
      await cred.user!.updateDisplayName('Admin RecycleMate');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        cred = await auth.signInWithEmailAndPassword(
          email: _kAdminEmail,
          password: _kAdminPassword,
        );
      } else {
        debugPrint('Admin setup error: ${e.code}');
        return;
      }
    }

    await db.collection('users').doc(cred.user!.uid).set({
      'name': 'Admin RecycleMate',
      'email': _kAdminEmail,
      'role': 'admin',
      'city': 'Jakarta',
      'phone': '',
      'bio': 'Administrator sistem RecycleMate',
      'avatar': '',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await db.collection('app_config').doc('site_settings').set({
      'bannerTitle': 'Temukan karya upcycle terbaik hari ini',
      'bannerSubtitle': 'Bersama kurangi sampah, ciptakan karya bernilai',
      'statText': '120 kg sampah terselamatkan',
      'promoText': '',
      'maintenanceMode': false,
      'allowNewRegistrations': true,
    }, SetOptions(merge: true));

    await db.collection('app_config').doc('setup').set(
      {'adminCreated': true, 'createdAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );

    debugPrint('Admin account ready: $_kAdminEmail');
    await auth.signOut();
  } catch (e) {
    debugPrint('Admin setup error: $e');
  }
}

class RecycleMateApp extends StatelessWidget {
  const RecycleMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RecycleMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/upload': (context) => const UploadScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/manage-products': (context) => const ManageProductsScreen(),
        '/admin': (context) => const AdminScreen(),
        '/open-store': (context) => const OpenStoreScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final product = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          );
        }
        return null;
      },
    );
  }
}
