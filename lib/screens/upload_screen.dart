import 'dart:io';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/email_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/category_chip.dart';
import '../widgets/section_title.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  int _quantity = 1;
  String _selectedMaterial = 'Plastik';
  bool _isSubmitted = false;
  bool _isLoading = false;
  File? _pickedImage;

  static const _materials = ['Plastik', 'Kayu', 'Kaca', 'Kain', 'Logam', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    // Redirect to login if not authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!FirebaseAuthService.isLoggedIn) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Perlu Login'),
            content: const Text(
                'Kamu harus login untuk mendonasikan barang.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32)),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Login',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSourceType source) async {
    final file = source == ImageSourceType.gallery
        ? await StorageService.pickFromGallery()
        : await StorageService.pickFromCamera();
    if (file != null) setState(() => _pickedImage = file);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!FirebaseAuthService.isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Upload image if selected
      String imageUrl = '';
      if (_pickedImage != null) {
        imageUrl = await StorageService.uploadDonationImage(_pickedImage!);
      }

      // Submit to Firestore
      final donation = await FirestoreService.createDonation(
        itemName: _nameController.text.trim(),
        description: _descController.text.trim(),
        material: _selectedMaterial,
        quantity: _quantity,
        imageUrl: imageUrl,
      );

      // Send confirmation email (non-blocking)
      EmailService.sendDonationConfirmation(
        donorName: donation.donorName,
        donorEmail: donation.donorEmail,
        itemName: donation.itemName,
        material: donation.material,
        quantity: donation.quantity,
      );

      if (mounted) setState(() => _isSubmitted = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text('Donasi Barang Bekas',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSubmitted ? _buildSuccessView() : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo picker area
            GestureDetector(
              onTap: _showImageSourceSheet,
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFF2E7D32),
                      style: BorderStyle.solid),
                ),
                child: _pickedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_pickedImage!, fit: BoxFit.cover),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(12)),
                                child: const Text('Ganti Foto',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 48, color: Color(0xFF2E7D32)),
                          SizedBox(height: 8),
                          Text('Tap untuk upload foto',
                              style: TextStyle(color: Color(0xFF2E7D32))),
                          Text('JPG, PNG max 5MB (opsional)',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            const SectionTitle(title: 'Informasi Barang'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration(
                  'Nama Barang', 'Contoh: Botol kaca bekas'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Nama barang wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: _inputDecoration(
                  'Deskripsi', 'Ceritakan kondisi barang...'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Deskripsi wajib diisi' : null,
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'Jenis Material'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _materials
                  .map((m) => GestureDetector(
                        onTap: () =>
                            setState(() => _selectedMaterial = m),
                        child: CategoryChip(
                          label: m,
                          isSelected: _selectedMaterial == m,
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            const SectionTitle(title: 'Jumlah Barang'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text('Jumlah unit yang didonasikan',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: const Color(0xFF2E7D32),
                      ),
                      Container(
                        width: 40,
                        alignment: Alignment.center,
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _quantity++),
                        icon: const Icon(Icons.add_circle_outline),
                        color: const Color(0xFF2E7D32),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFF2E7D32)))
                : CustomButton(
                    label: 'Kirim Donasi', onPressed: _submit),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pilih Sumber Foto',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSourceType.gallery);
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeri'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSourceType.camera);
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamera'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 100, color: Color(0xFF2E7D32)),
            const SizedBox(height: 24),
            const Text('Donasi Berhasil Dikirim!',
                style:
                    TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              '$_quantity unit ${_nameController.text} ($_selectedMaterial) akan segera '
              'dihubungkan ke pengrajin terdekat.\n\n'
              'Konfirmasi dikirim ke emailmu.',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: Colors.grey, height: 1.6),
            ),
            const SizedBox(height: 32),
            CustomButton(
              label: 'Kembali ke Beranda',
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/home'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/profile'),
              child: const Text('Lihat riwayat donasiku',
                  style: TextStyle(color: Color(0xFF2E7D32))),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E7D32)),
      ),
    );
  }
}

enum ImageSourceType { gallery, camera }
