import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/section_title.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _categories = ['Semua', 'Plastik', 'Kayu', 'Kaca', 'Kain'];
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  final Set<String> _favorites = {};
  int _cartCount = 0;

  static const _allProducts = [
    {
      'id': '1',
      'name': 'Lampu Botol Kaca',
      'price': 85000,
      'material': 'Kaca',
      'rating': 4.8,
      'crafter': 'Budi Santoso',
      'crafterCity': 'Yogyakarta',
      'description': 'Lampu hias unik dari botol kaca bekas wine yang dimodifikasi dengan lampu LED warm white. Cocok untuk dekorasi ruang tamu atau kafe.',
      'bgColor': 0xFF1565C0,
      'iconType': 'bottle',
    },
    {
      'id': '2',
      'name': 'Pot Kayu Palet',
      'price': 120000,
      'material': 'Kayu',
      'rating': 4.6,
      'crafter': 'Sari Dewi',
      'crafterCity': 'Bandung',
      'description': 'Pot tanaman dari palet kayu bekas yang diamplas halus dan dicat dengan cat ramah lingkungan. Ideal untuk tanaman hias indoor.',
      'bgColor': 0xFF5D4037,
      'iconType': 'wood',
    },
    {
      'id': '3',
      'name': 'Tas Plastik Anyam',
      'price': 65000,
      'material': 'Plastik',
      'rating': 4.5,
      'crafter': 'Rina Wati',
      'crafterCity': 'Surabaya',
      'description': 'Tas belanja dari kantong plastik bekas yang dianyam dengan teknik khusus. Kuat, tahan air, dan ramah lingkungan.',
      'bgColor': 0xFF6A1B9A,
      'iconType': 'bag',
    },
    {
      'id': '4',
      'name': 'Bantal Kain Perca',
      'price': 45000,
      'material': 'Kain',
      'rating': 4.7,
      'crafter': 'Ani Susanti',
      'crafterCity': 'Solo',
      'description': 'Bantal dekoratif dari kain perca batik bekas yang dijahit dengan motif patchwork. Setiap bantal memiliki motif unik.',
      'bgColor': 0xFFAD1457,
      'iconType': 'pillow',
    },
    {
      'id': '5',
      'name': 'Rak Pipa PVC',
      'price': 150000,
      'material': 'Plastik',
      'rating': 4.4,
      'crafter': 'Doni Pratama',
      'crafterCity': 'Jakarta',
      'description': 'Rak dinding minimalis dari pipa PVC bekas yang dicat dan disusun secara kreatif. Cocok untuk display buku atau tanaman.',
      'bgColor': 0xFF00695C,
      'iconType': 'shelf',
    },
    {
      'id': '6',
      'name': 'Cermin Kayu Drift',
      'price': 200000,
      'material': 'Kayu',
      'rating': 4.9,
      'crafter': 'Maya Putri',
      'crafterCity': 'Bali',
      'description': 'Cermin dengan bingkai dari kayu apung (driftwood) yang ditemukan di pantai. Setiap produk memiliki bentuk alami yang berbeda.',
      'bgColor': 0xFF4E342E,
      'iconType': 'mirror',
    },
    {
      'id': '7',
      'name': 'Vas Botol Kaca',
      'price': 55000,
      'material': 'Kaca',
      'rating': 4.3,
      'crafter': 'Hendra Wijaya',
      'crafterCity': 'Semarang',
      'description': 'Vas bunga cantik dari botol kaca bekas yang didekorasi dengan tali rami dan cat warna-warni.',
      'bgColor': 0xFF0277BD,
      'iconType': 'vase',
    },
    {
      'id': '8',
      'name': 'Kursi Kayu Palet',
      'price': 350000,
      'material': 'Kayu',
      'rating': 4.8,
      'crafter': 'Bambang Susilo',
      'crafterCity': 'Malang',
      'description': 'Kursi santai dari palet kayu bekas yang didesain ergonomis dan difinishing dengan pernis anti-air.',
      'bgColor': 0xFF3E2723,
      'iconType': 'chair',
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    return _allProducts.where((p) {
      final matchCat = _selectedCategory == 'Semua' || p['material'] == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          (p['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

  void _toggleFavorite(String id) => setState(() {
        _favorites.contains(id) ? _favorites.remove(id) : _favorites.add(id);
      });

  void _addToCart() => setState(() => _cartCount++);

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text('RecycleMate',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.bell, color: Colors.white, size: 20),
            onPressed: () => _showNotifDialog(context),
          ),
          Stack(
            children: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.cartShopping,
                    color: Colors.white, size: 20),
                onPressed: () => _showCartDialog(context),
              ),
              if (_cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Text('$_cartCount',
                        style: const TextStyle(color: Colors.white, fontSize: 9)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Halo, Kolektor! 👋',
                                  style: TextStyle(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 4),
                              const Text('Temukan karya upcycle\nterbaik hari ini',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(20)),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.eco, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text('120 kg sampah terselamatkan',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.recycling, size: 80, color: Colors.white24),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Cari produk upcycle...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Category filter
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories
                          .map((c) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedCategory = c),
                                  child: CategoryChip(
                                      label: c,
                                      isSelected: _selectedCategory == c),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionTitle(
                      title: filtered.isEmpty
                          ? 'Tidak ada produk'
                          : 'Produk Unggulan (${filtered.length})'),
                ],
              ),
            ),
          ),
          filtered.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Icon(Icons.search_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text('Tidak ada produk "$_searchQuery"',
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final p = filtered[index];
                        return ProductCard(
                          product: p,
                          isFavorite: _favorites.contains(p['id']),
                          onFavoriteToggle: () =>
                              _toggleFavorite(p['id'] as String),
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/detail',
                              arguments: {
                                ...p,
                                'isFavorite': _favorites.contains(p['id']),
                                'onAddToCart': _addToCart,
                              },
                            );
                            if (!mounted) return;
                            if (result is Map) {
                              final id = result['id'] as String?;
                              final fav = result['isFavorite'] as bool?;
                              if (id != null && fav != null) {
                                setState(() {
                                  fav
                                      ? _favorites.add(id)
                                      : _favorites.remove(id);
                                });
                              }
                            }
                          },
                        );
                      },
                      childCount: filtered.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/upload'),
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.add_photo_alternate, color: Colors.white),
        label: const Text('Donasi Barang',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showNotifDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Notifikasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ListTile(
              leading: Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
              title: Text('Donasi kamu diterima pengrajin!'),
              subtitle: Text('2 jam lalu'),
            ),
            ListTile(
              leading: Icon(Icons.local_offer, color: Colors.orange),
              title: Text('Promo: Diskon 20% produk Kayu'),
              subtitle: Text('Hari ini'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'))
        ],
      ),
    );
  }

  void _showCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.shopping_cart, color: Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            const Text('Keranjang'),
          ],
        ),
        content: _cartCount == 0
            ? const Text('Keranjang masih kosong.')
            : Text('$_cartCount produk di keranjang.\nLanjutkan ke pembayaran?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup')),
          if (_cartCount > 0)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32)),
              onPressed: () {
                setState(() => _cartCount = 0);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Pesanan berhasil dibuat!'),
                  backgroundColor: Color(0xFF2E7D32),
                ));
              },
              child: const Text('Checkout', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
