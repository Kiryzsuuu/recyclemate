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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  _ensureAdminAccount(); // non-blocking, one-time setup
  runApp(const RecycleMateApp());
}

/// One-time admin account creation — runs only if flag not set in Firestore.
Future<void> _ensureAdminAccount() async {
  const adminEmail = 'maskiryz23@gmail.com';
  const adminPassword = 'opet123';

  try {
    final db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    // Check if already set up
    final setupDoc = await db.collection('app_config').doc('setup').get();
    if (setupDoc.data()?['adminCreated'] == true) {
      // Enforce admin role (in case it was changed accidentally)
      final q = await db
          .collection('users')
          .where('email', isEqualTo: adminEmail)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty && q.docs.first.data()['role'] != 'admin') {
        await q.docs.first.reference.update({'role': 'admin'});
      }
      return;
    }

    // Create or sign in admin
    UserCredential? cred;
    try {
      cred = await auth.createUserWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
      await cred.user!.updateDisplayName('Admin RecycleMate');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        cred = await auth.signInWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
      } else {
        debugPrint('Admin setup error: ${e.code}');
        return;
      }
    }

    // Write admin Firestore profile
    await db.collection('users').doc(cred.user!.uid).set({
      'name': 'Admin RecycleMate',
      'email': adminEmail,
      'role': 'admin',
      'city': 'Jakarta',
      'phone': '',
      'bio': 'Administrator sistem RecycleMate',
      'avatar': '',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Default site settings
    await db.collection('app_config').doc('site_settings').set({
      'bannerTitle': 'Temukan karya upcycle terbaik hari ini',
      'bannerSubtitle': 'Bersama kurangi sampah, ciptakan karya bernilai',
      'statText': '120 kg sampah terselamatkan',
      'promoText': '',
      'maintenanceMode': false,
      'allowNewRegistrations': true,
    }, SetOptions(merge: true));

    // Mark done
    await db.collection('app_config').doc('setup').set(
      {'adminCreated': true, 'createdAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );

    debugPrint('✅ Admin account ready: $adminEmail');
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
