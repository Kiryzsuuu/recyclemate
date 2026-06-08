import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/product_model.dart';
import '../widgets/category_chip.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  List<ProductModel> _products = [];
  bool _isLoading = true;

  static const _materials = ['Plastik', 'Kayu', 'Kaca', 'Kain', 'Logam', 'Lainnya'];
  static const _iconTypes = ['generic', 'bottle', 'wood', 'bag', 'pillow', 'shelf', 'mirror', 'vase', 'chair'];
  static const _colorOptions = [
    {'label': 'Hijau', 'value': 0xFF2E7D32},
    {'label': 'Biru', 'value': 0xFF1565C0},
    {'label': 'Coklat', 'value': 0xFF5D4037},
    {'label': 'Ungu', 'value': 0xFF6A1B9A},
    {'label': 'Pink', 'value': 0xFFAD1457},
    {'label': 'Teal', 'value': 0xFF00695C},
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await FirestoreService.getMyProducts();
      setState(() => _products = products);
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

  void _showProductForm({ProductModel? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final priceCtrl =
        TextEditingController(text: existing?.price.toString() ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final stockCtrl =
        TextEditingController(text: existing?.stock.toString() ?? '1');
    String material = existing?.material ?? _materials[0];
    String iconType = existing?.iconType ?? _iconTypes[0];
    int bgColor = existing?.bgColor ?? 0xFF2E7D32;
    File? pickedImage;
    bool isUploadingImage = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.92,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F8E9),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      existing == null ? 'Tambah Produk' : 'Edit Produk',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          showModalBottomSheet(
                            context: ctx,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16)),
                            ),
                            builder: (_) => Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Pilih Foto Produk',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            Navigator.pop(ctx);
                                            final f = await StorageService
                                                .pickFromGallery();
                                            if (f != null) {
                                              setModalState(
                                                  () => pickedImage = f);
                                            }
                                          },
                                          icon: const Icon(Icons.photo_library),
                                          label: const Text('Galeri'),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF2E7D32),
                                              foregroundColor: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            Navigator.pop(ctx);
                                            final f = await StorageService
                                                .pickFromCamera();
                                            if (f != null) {
                                              setModalState(
                                                  () => pickedImage = f);
                                            }
                                          },
                                          icon: const Icon(Icons.camera_alt),
                                          label: const Text('Kamera'),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF2E7D32),
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
                        },
                        child: Container(
                          width: double.infinity,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFF2E7D32).withValues(alpha: 0.5)),
                          ),
                          child: pickedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(pickedImage!,
                                          fit: BoxFit.cover),
                                      Positioned(
                                        bottom: 6,
                                        right: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: const Text('Ganti',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11)),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : (existing?.imageUrl.isNotEmpty == true
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(11),
                                      child: Image.network(
                                          existing!.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _photoPlaceholder()),
                                    )
                                  : _photoPlaceholder()),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _formField(nameCtrl, 'Nama Produk', Icons.label_outline),
                      const SizedBox(height: 12),
                      _formField(priceCtrl, 'Harga (Rp)',
                          Icons.attach_money,
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 12),
                      _formField(descCtrl, 'Deskripsi',
                          Icons.description_outlined,
                          maxLines: 3),
                      const SizedBox(height: 12),
                      _formField(stockCtrl, 'Stok',
                          Icons.inventory_2_outlined,
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 16),
                      const Text('Material:',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _materials
                            .map((m) => GestureDetector(
                                  onTap: () =>
                                      setModalState(() => material = m),
                                  child: CategoryChip(
                                      label: m, isSelected: material == m),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Warna Tema:',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _colorOptions.map((c) {
                          final val = c['value'] as int;
                          final selected = bgColor == val;
                          return GestureDetector(
                            onTap: () =>
                                setModalState(() => bgColor = val),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Color(val),
                                shape: BoxShape.circle,
                                border: selected
                                    ? Border.all(
                                        color: Colors.black, width: 3)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Ikon Produk:',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _iconTypes
                            .map((t) => GestureDetector(
                                  onTap: () =>
                                      setModalState(() => iconType = t),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: iconType == t
                                          ? const Color(0xFF2E7D32)
                                          : Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      t,
                                      style: TextStyle(
                                        color: iconType == t
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            final name = nameCtrl.text.trim();
                            final priceStr = priceCtrl.text.trim();
                            final desc = descCtrl.text.trim();
                            final stockStr = stockCtrl.text.trim();

                            if (name.isEmpty ||
                                priceStr.isEmpty ||
                                desc.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Nama, harga, dan deskripsi wajib diisi'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Upload foto jika ada
                            String imageUrl = existing?.imageUrl ?? '';
                            if (pickedImage != null) {
                              setModalState(() => isUploadingImage = true);
                              try {
                                imageUrl = await StorageService.uploadProductImage(
                                  pickedImage!,
                                  productId: existing?.id,
                                );
                              } finally {
                                setModalState(() => isUploadingImage = false);
                              }
                            }

                            final body = {
                              'name': name,
                              'price': int.tryParse(priceStr) ?? 0,
                              'description': desc,
                              'material': material,
                              'bgColor': bgColor,
                              'iconType': iconType,
                              'stock': int.tryParse(stockStr) ?? 1,
                              'imageUrl': imageUrl,
                            };

                            try {
                              if (existing == null) {
                                await FirestoreService.createProduct(body);
                              } else {
                                await FirestoreService.updateProduct(
                                    existing.id, body);
                              }
                              if (mounted) {
                                Navigator.pop(ctx);
                                _loadProducts();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(existing == null
                                        ? 'Produk berhasil ditambahkan!'
                                        : 'Produk berhasil diperbarui!'),
                                    backgroundColor: const Color(0xFF2E7D32),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e
                                        .toString()
                                        .replaceAll('Exception: ', '')),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isUploadingImage
                                ? 'Mengupload foto...'
                                : (existing == null ? 'Tambah Produk' : 'Simpan Perubahan'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteProduct(ProductModel p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Hapus "${p.name}"? Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirestoreService.deleteProduct(p.id);
        _loadProducts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produk berhasil dihapus'),
              backgroundColor: Color(0xFF2E7D32),
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text('Kelola Produk',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadProducts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductForm(),
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : _products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.store_outlined, size: 72, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Belum ada produk',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _showProductForm(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Tambah Produk Pertama',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _products.length,
                  itemBuilder: (_, i) {
                    final p = _products[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Color(p.bgColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.recycling,
                              color: Colors.white, size: 28),
                        ),
                        title: Text(p.name,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${_fmt(p.price)} · Stok: ${p.stock} · ${p.material}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: Color(0xFF2E7D32)),
                              onPressed: () => _showProductForm(existing: p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => _deleteProduct(p),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _formField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
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
      ),
    );
  }

  String _fmt(int price) => 'Rp ${price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      )}';

  Widget _photoPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 40, color: Color(0xFF2E7D32)),
        SizedBox(height: 6),
        Text('Tap untuk tambah foto',
            style: TextStyle(color: Color(0xFF2E7D32), fontSize: 13)),
        Text('Opsional · Max 5MB',
            style: TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
