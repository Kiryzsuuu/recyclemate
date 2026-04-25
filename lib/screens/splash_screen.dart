import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const Icon(Icons.recycling, size: 100, color: Colors.white),
                  const SizedBox(height: 24),
                  Text(
                    'RecycleMate',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ubah sampah jadi karya.\nBeli, jual, dan donasikan barang upcycle.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  _OnboardingItem(
                    icon: Icons.handshake_outlined,
                    title: 'Hubungkan Pengrajin & Kolektor',
                    subtitle: 'Platform khusus ekonomi sirkular Indonesia',
                  ),
                  const SizedBox(height: 16),
                  _OnboardingItem(
                    icon: Icons.eco_outlined,
                    title: 'Kurangi Limbah Rumah Tangga',
                    subtitle: 'Setiap barang bekas punya nilai baru',
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    label: 'Mulai Sekarang',
                    onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              Text(subtitle,
                  style: GoogleFonts.poppins(
                      color: Colors.white60, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
