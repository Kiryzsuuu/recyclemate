import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class OpenStoreScreen extends StatefulWidget {
  const OpenStoreScreen({super.key});

  @override
  State<OpenStoreScreen> createState() => _OpenStoreScreenState();
}

class _OpenStoreScreenState extends State<OpenStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String _storeType = '';
  File? _logoFile;
  bool _loading = false;
  int _step = 0; // 0 = pilih jenis, 1 = isi detail

  static const _storeTypes = [
    {
      'value': 'penumpul',
      'emoji': '🗑️',
      'label': 'Penumpul Barang',
      'desc': 'Kumpulkan sampah & limbah dari rumah tangga atau industri, jual ke pengepul.',
      'sells': 'Menjual: Sampah & Limbah',
      'target': 'Target pembeli: Pengepul',
      'color': 0xFF00695C,
    },
    {
      'value': 'pengepul',
      'emoji': '♻️',
      'label': 'Pengepul',
      'desc': 'Beli sampah dari penumpul, sortir & olah menjadi bahan baku siap pakai.',
      'sells': 'Menjual: Bahan Baku Daur Ulang',
      'target': 'Target pembeli: Pengrajin',
      'color': 0xFF1565C0,
    },
    {
      'value': 'pengrajin',
      'emoji': '🛠️',
      'label': 'Pengrajin / Crafter',
      'desc': 'Buat produk kerajinan bernilai tinggi dari bahan daur ulang.',
      'sells': 'Menjual: Produk Kerajinan',
      'target': 'Target pembeli: Pembeli & Distributor',
      'color': 0xFF2E7D32,
    },
    {
      'value': 'distributor',
      'emoji': '🚚',
      'label': 'Distributor',
      'desc': 'Distribusikan produk upcycle dari pengrajin ke pasar yang lebih luas.',
      'sells': 'Menjual: Produk Retail',
      'target': 'Target pembeli: Pembeli umum',
      'color': 0xFFE65100,
    },
  ];

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
            const Text('Pilih Logo Toko',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      String logoUrl = '';
      if (_logoFile != null) {
        logoUrl = await StorageService.uploadAvatar(_logoFile!);
      }

      final store = await FirestoreService.openStore(
        storeName: _nameCtrl.text.trim(),
        storeType: _storeType,
        description: _descCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        logoUrl: logoUrl,
      );

      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.store, size: 64, color: Color(0xFF2E7D32)),
                const SizedBox(height: 16),
                Text(
                  'Toko Berhasil Dibuka!',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${store.storeTypeEmoji} ${store.storeName}',
                  style: const TextStyle(
                      color: Color(0xFF2E7D32), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  store.storeTypeLabel,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Selamat! Kamu sekarang bisa mulai menambahkan produk dan berjualan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // tutup dialog
                    Navigator.pushReplacementNamed(context, '/manage-products');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Mulai Kelola Produk',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
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
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Text(
          _step == 0 ? 'Pilih Jenis Toko' : 'Detail Toko',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_step == 1) {
              setState(() => _step = 0);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: _step == 0 ? _buildTypeSelection() : _buildDetailForm(),
    );
  }

  Widget _buildTypeSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🏪 Buka Toko di RecycleMate',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text(
                    'Pilih jenis toko sesuai peran kamu dalam rantai daur ulang',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _badge('Gratis'),
                    const SizedBox(width: 8),
                    _badge('Langsung Aktif'),
                    const SizedBox(width: 8),
                    _badge('Tanpa Batas Produk'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Pilih Jenis Toko:',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Setiap jenis toko memiliki target pasar yang berbeda',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),
          ..._storeTypes.map((t) => _storeTypeCard(t)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _storeTypeCard(Map<String, dynamic> t) {
    final selected = _storeType == t['value'];
    final color = Color(t['color'] as int);

    return GestureDetector(
      onTap: () => setState(() => _storeType = t['value'] as String),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(t['emoji'] as String,
                        style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t['label'] as String,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: selected ? color : Colors.black87)),
                      Text(t['desc'] as String,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle, color: color, size: 24),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _infoChip(Icons.sell_outlined, t['sells'] as String, color),
                const SizedBox(width: 8),
                _infoChip(Icons.people_outline, t['target'] as String, color),
              ],
            ),
            if (selected) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: () => setState(() => _step = 1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Pilih & Lanjutkan →',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailForm() {
    final selected =
        _storeTypes.firstWhere((t) => t['value'] == _storeType);
    final color = Color(selected['color'] as int);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Jenis terpilih
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Text(selected['emoji'] as String,
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(selected['label'] as String,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: color)),
                      Text(selected['sells'] as String,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _step = 0),
                    child: Text('Ganti',
                        style: TextStyle(color: color, fontSize: 12)),
                  ),
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
                      radius: 48,
                      backgroundColor: color.withValues(alpha: 0.12),
                      backgroundImage:
                          _logoFile != null ? FileImage(_logoFile!) : null,
                      child: _logoFile == null
                          ? Text(selected['emoji'] as String,
                              style: const TextStyle(fontSize: 36))
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color,
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
              child: Text('Upload logo toko (opsional)',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            const SizedBox(height: 20),

            // Form fields
            _field(_nameCtrl, 'Nama Toko *', Icons.store_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama toko wajib diisi' : null),
            const SizedBox(height: 12),
            _field(_descCtrl, 'Deskripsi Toko', Icons.description_outlined,
                maxLines: 3),
            const SizedBox(height: 12),
            _field(_cityCtrl, 'Kota / Lokasi', Icons.location_on_outlined),
            const SizedBox(height: 12),
            _field(_phoneCtrl, 'No. WhatsApp / Telepon',
                Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 28),

            // Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Dengan membuka toko, role akun kamu akan berubah sesuai jenis toko yang dipilih. Kamu bisa langsung menambahkan produk setelah toko aktif.',
                      style: TextStyle(color: Colors.black87, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Buka Toko Sekarang',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
              ),
            ),
            const SizedBox(height: 32),
          ],
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

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(label,
                  style: TextStyle(fontSize: 10, color: color),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
