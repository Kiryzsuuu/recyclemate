import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/category_chip.dart';
import '../widgets/custom_button.dart';
import '../widgets/section_title.dart';
import '../widgets/product_illustration.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late bool _isFavorite;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.product['isFavorite'] as bool? ?? false;
  }

  void _toggleFavorite() => setState(() => _isFavorite = !_isFavorite);

  Map<String, dynamic> _popResult() => {
        'id': widget.product['id'],
        'isFavorite': _isFavorite,
      };

  void _beli() {
    final onAddToCart = widget.product['onAddToCart'] as VoidCallback?;
    onAddToCart?.call();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text('Berhasil!'),
          ],
        ),
        content: Text(
          '$_qty x ${widget.product['name']} ditambahkan ke keranjang.\n\n'
          'Total: Rp ${_fmt((widget.product['price'] as int) * _qty)}',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Lanjut Belanja')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32)),
            onPressed: () {
              Navigator.pop(context); // tutup dialog
              Navigator.pop(context, _popResult()); // kembali ke home dengan result
            },
            child: const Text('Ke Keranjang',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _hubungiPengrajin() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xFF2E7D32),
              child: Text(
                (widget.product['crafter'] as String)[0],
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(widget.product['crafter'] as String,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.product['crafterCity'] as String,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Membuka WhatsApp pengrajin...'),
                        backgroundColor: Color(0xFF25D366),
                      ));
                    },
                    icon: const FaIcon(FontAwesomeIcons.whatsapp,
                        color: Color(0xFF25D366), size: 18),
                    label: const Text('WhatsApp',
                        style: TextStyle(color: Color(0xFF25D366))),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF25D366))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Membuka Instagram pengrajin...'),
                        backgroundColor: Color(0xFFE1306C),
                      ));
                    },
                    icon: const FaIcon(FontAwesomeIcons.instagram,
                        color: Color(0xFFE1306C), size: 18),
                    label: const Text('Instagram',
                        style: TextStyle(color: Color(0xFFE1306C))),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE1306C))),
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

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _popResult());
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F8E9),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: const Color(0xFF2E7D32),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context, _popResult()),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProductIllustration(
                      iconType: p['iconType'] as String,
                      bgColor: p['bgColor'] as int,
                      size: 280,
                    ),
                    // Favorite button — hanya IconButton, tanpa GestureDetector luar
                    Positioned(
                      top: 80,
                      right: 16,
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: IconButton(
                          icon: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: _isFavorite
                                ? Colors.red
                                : const Color(0xFF2E7D32),
                          ),
                          onPressed: _toggleFavorite,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: CategoryChip(
                          label: p['material'] as String, isSelected: true),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['name'] as String,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text('${p['rating']}',
                                style:
                                    const TextStyle(fontWeight: FontWeight.w600)),
                            const Text(' (42 ulasan)',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                        Text(
                          'Rp ${_fmt(p['price'] as int)}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Qty selector
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Jumlah',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _qty > 1
                                    ? () => setState(() => _qty--)
                                    : null,
                                icon: const Icon(Icons.remove_circle_outline),
                                color: const Color(0xFF2E7D32),
                              ),
                              Text('$_qty',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              IconButton(
                                onPressed: () => setState(() => _qty++),
                                icon: const Icon(Icons.add_circle_outline),
                                color: const Color(0xFF2E7D32),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SectionTitle(title: 'Tentang Produk'),
                    const SizedBox(height: 8),
                    Text(p['description'] as String,
                        style:
                            const TextStyle(color: Colors.black87, height: 1.6)),
                    const SizedBox(height: 20),
                    const SectionTitle(title: 'Material Digunakan'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CategoryChip(
                            label: p['material'] as String, isSelected: true),
                        const SizedBox(width: 8),
                        const CategoryChip(
                            label: 'Daur Ulang', isSelected: false),
                        const SizedBox(width: 8),
                        const CategoryChip(label: 'Handmade', isSelected: false),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const SectionTitle(title: 'Profil Pengrajin'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: const Color(0xFF2E7D32),
                            child: Text(
                              (p['crafter'] as String)[0],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p['crafter'] as String,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 2),
                                    Text(p['crafterCity'] as String,
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const FaIcon(FontAwesomeIcons.instagram,
                                    size: 18, color: Color(0xFFE1306C)),
                                onPressed: _hubungiPengrajin,
                              ),
                              IconButton(
                                icon: const FaIcon(FontAwesomeIcons.whatsapp,
                                    size: 18, color: Color(0xFF25D366)),
                                onPressed: _hubungiPengrajin,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(label: 'Beli Sekarang', onPressed: _beli),
                    const SizedBox(height: 12),
                    CustomButton(
                      label: 'Hubungi Pengrajin',
                      onPressed: _hubungiPengrajin,
                      isOutlined: true,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int price) => price
      .toString()
      .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
