import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/email_service.dart';
import '../services/storage_service.dart';
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
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  String _submittedName = '';

  File? _selectedImage;
  bool _isUploadingImage = false;

  static const _materials = ['Plastik', 'Kayu', 'Kaca', 'Kain', 'Logam', 'Lainnya'];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pilih Foto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _imageSourceButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Galeri',
                    onTap: () async {
                      Navigator.pop(context);
                      final file = await StorageService.pickFromGallery();
                      if (file != null && mounted) {
                        setState(() => _selectedImage = file);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _imageSourceButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'Kamera',
                    onTap: () async {
                      Navigator.pop(context);
                      final file = await StorageService.pickFromCamera();
                      if (file != null && mounted) {
                        setState(() => _selectedImage = file);
                      }
                    },
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

  Widget _imageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: const Color(0xFF2E7D32)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Color(0xFF2E7D32))),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!FirebaseAuthService.isLoggedIn) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Perlu Login'),
            content: const Text('Kamu harus login untuk mengirim donasi.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32)),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('Login', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // Upload foto jika ada
      String imageUrl = '';
      if (_selectedImage != null) {
        setState(() => _isUploadingImage = true);
        imageUrl = await StorageService.uploadDonationImage(_selectedImage!);
        setState(() => _isUploadingImage = false);
      }

      final donation = await FirestoreService.createDonation(
        itemName: _nameController.text.trim(),
        description: _descController.text.trim(),
        material: _selectedMaterial,
        quantity: _quantity,
        imageUrl: imageUrl,
      );

      // Send donation email (non-blocking)
      EmailService.sendDonationConfirmation(
        donorName: donation.donorName,
        donorEmail: donation.donorEmail,
        itemName: donation.itemName,
        material: donation.material,
        quantity: donation.quantity,
      );

      setState(() {
        _submittedName = _nameController.text.trim();
        _isSubmitted = true;
      });
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
      if (mounted) setState(() {
        _isSubmitting = false;
        _isUploadingImage = false;
      });
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
            // ─── Photo Picker ────────────────────────────────────────────
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2E7D32),
                    width: _selectedImage != null ? 2 : 1,
                  ),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_selectedImage!, fit: BoxFit.cover),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text('Ganti foto',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                  ],
                                ),
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
                          Text('Tap untuk upload foto barang',
                              style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w500)),
                          SizedBox(height: 4),
                          Text('JPG, PNG max 5MB',
                              style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── Form Fields ─────────────────────────────────────────────
            const SectionTitle(title: 'Informasi Barang'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Nama Barang', 'Contoh: Botol kaca bekas'),
              validator: (v) => v!.isEmpty ? 'Nama barang wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: _inputDecoration('Deskripsi', 'Ceritakan kondisi barang...'),
              validator: (v) => v!.isEmpty ? 'Deskripsi wajib diisi' : null,
            ),
            const SizedBox(height: 20),

            // ─── Material ─────────────────────────────────────────────────
            const SectionTitle(title: 'Jenis Material'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _materials
                  .map((m) => GestureDetector(
                        onTap: () => setState(() => _selectedMaterial = m),
                        child: CategoryChip(
                            label: m, isSelected: _selectedMaterial == m),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // ─── Quantity ─────────────────────────────────────────────────
            const SectionTitle(title: 'Jumlah Barang'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                        child: Text('$_quantity',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
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

            // ─── Submit ───────────────────────────────────────────────────
            CustomButton(
              label: _isUploadingImage
                  ? 'Mengupload foto...'
                  : _isSubmitting
                      ? 'Mengirim...'
                      : 'Kirim Donasi',
              onPressed: (_isSubmitting || _isUploadingImage) ? () {} : _submit,
            ),
            const SizedBox(height: 24),
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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Terima kasih! $_quantity unit $_submittedName ($_selectedMaterial) '
              'akan segera dihubungkan ke pengrajin terdekat.\n\n'
              '📧 Email konfirmasi telah dikirim ke emailmu.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, height: 1.6),
            ),
            const SizedBox(height: 32),
            CustomButton(
              label: 'Kembali ke Beranda',
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2E7D32)),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Lihat Donasi Saya',
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E7D32)),
      ),
    );
  }
}
