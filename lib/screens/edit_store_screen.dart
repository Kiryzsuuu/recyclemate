import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/store_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class EditStoreScreen extends StatefulWidget {
  final StoreModel store;
  const EditStoreScreen({super.key, required this.store});

  @override
  State<EditStoreScreen> createState() => _EditStoreScreenState();
}

class _EditStoreScreenState extends State<EditStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _phoneCtrl;

  File? _logoFile;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.store.storeName);
    _descCtrl = TextEditingController(text: widget.store.description);
    _cityCtrl = TextEditingController(text: widget.store.city);
    _phoneCtrl = TextEditingController(text: widget.store.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ganti Logo Toko',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final f = await StorageService.pickFromGallery();
                      if (f != null) setState(() => _logoFile = f);
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
                    onPressed: () async {
                      Navigator.pop(context);
                      final f = await StorageService.pickFromCamera();
                      if (f != null) setState(() => _logoFile = f);
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
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      String logoUrl = widget.store.logoUrl;
      if (_logoFile != null) {
        logoUrl = await StorageService.uploadAvatar(_logoFile!);
      }

      await FirestoreService.updateStore(widget.store.id, {
        'storeName': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'logoUrl': logoUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Toko berhasil diperbarui'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        Navigator.pop(context, true); // true = ada perubahan
      }
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
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeEmoji = widget.store.storeTypeEmoji;
    final storeLabel = widget.store.storeTypeLabel;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Text(
          'Edit Toko',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: Text(
              'Simpan',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info jenis toko (read-only)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Text(storeEmoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(storeLabel,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E7D32))),
                        Text('Jenis toko tidak bisa diubah',
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.lock_outline,
                        color: Colors.grey, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Logo
              GestureDetector(
                onTap: _pickLogo,
                child: Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor:
                            const Color(0xFF2E7D32).withValues(alpha: 0.12),
                        backgroundImage: _logoFile != null
                            ? FileImage(_logoFile!)
                            : (widget.store.logoUrl.isNotEmpty
                                ? NetworkImage(widget.store.logoUrl)
                                    as ImageProvider
                                : null),
                        child: (_logoFile == null &&
                                widget.store.logoUrl.isEmpty)
                            ? Text(storeEmoji,
                                style: const TextStyle(fontSize: 36))
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text('Ketuk untuk ganti logo',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              const SizedBox(height: 24),

              // Form fields
              _field(_nameCtrl, 'Nama Toko *', Icons.store_outlined,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nama toko wajib diisi' : null),
              const SizedBox(height: 14),
              _field(_descCtrl, 'Deskripsi Toko', Icons.description_outlined,
                  maxLines: 3),
              const SizedBox(height: 14),
              _field(_cityCtrl, 'Kota / Lokasi', Icons.location_on_outlined),
              const SizedBox(height: 14),
              _field(_phoneCtrl, 'No. WhatsApp / Telepon',
                  Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Simpan Perubahan',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
