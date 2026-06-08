import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/section_title.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _categories = ['Semua', 'Plastik', 'Kayu', 'Kaca', 'Kain', 'Logam'];
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  final Set<String> _favorites = {};
  int _cartCount = 0;

  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _error;

  bool get _isLoggedIn => FirebaseAuth.instance.currentUser != null;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final products = await FirestoreService.getProducts(
        material: _selectedCategory,
        search: _searchQuery,
      );
      if (mounted) setState(() => _products = products);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onCategoryChanged(String category) {
    setState(() => _selectedCategory = category);
    _loadProducts();
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchQuery == query) _loadProducts();
    });
  }

  void _toggleFavorite(String id) => setState(() {
        _favorites.contains(id) ? _favorites.remove(id) : _favorites.add(id);
      });

  void _addToCart() => setState(() => _cartCount++);

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: Icon(
              _isLoggedIn ? Icons.account_circle : Icons.login,
              color: Colors.white,
            ),
            onPressed: () {
              if (_isLoggedIn) {
                Navigator.pushNamed(context, '/profile').then((_) => setState(() {}));
              } else {
                Navigator.pushNamed(context, '/login').then((_) => setState(() {}));
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        color: const Color(0xFF2E7D32),
        child: CustomScrollView(
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
                                Text(
                                  _isLoggedIn
                                      ? 'Halo, ${FirebaseAuth.instance.currentUser?.displayName?.split(' ')[0] ?? ''} 👋'
                                      : 'Halo, Kolektor! 👋',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Temukan karya upcycle\nterbaik hari ini',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.eco,
                                          color: Colors.white, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_products.length} produk tersedia',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.recycling,
                              size: 80, color: Colors.white24),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Search
                    TextField(
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Cari produk upcycle...',
                        prefixIcon:
                            const Icon(Icons.search, color: Color(0xFF2E7D32)),
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
                    // Category chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories
                            .map((c) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => _onCategoryChanged(c),
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
                        title: _isLoading
                            ? 'Memuat produk...'
                            : _products.isEmpty
                                ? 'Tidak ada produk'
                                : 'Produk Unggulan (${_products.length})'),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFF2E7D32))),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text('Error: $_error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProducts,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32)),
                        child: const Text('Coba Lagi',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              )
            else if (_products.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isEmpty
                            ? 'Belum ada produk di kategori ini'
                            : 'Tidak ada produk "$_searchQuery"',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if (_isLoggedIn)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                                    context, '/manage-products')
                                .then((_) => _loadProducts()),
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('Tambah Produk Pertama',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final p = _products[index];
                      final pMap = p.toWidgetMap();
                      return ProductCard(
                        product: pMap,
                        isFavorite: _favorites.contains(p.id),
                        onFavoriteToggle: () => _toggleFavorite(p.id),
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/detail',
                            arguments: {
                              ...pMap,
                              'isFavorite': _favorites.contains(p.id),
                              'onAddToCart': _addToCart,
                            },
                          );
                          if (!mounted) return;
                          setState(() {}); // refresh login state
                          if (result is Map) {
                            final id = result['id'] as String?;
                            final fav = result['isFavorite'] as bool?;
                            if (id != null && fav != null) {
                              setState(() {
                                fav ? _favorites.add(id) : _favorites.remove(id);
                              });
                            }
                          }
                          _loadProducts();
                        },
                      );
                    },
                    childCount: _products.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_isLoggedIn) {
            Navigator.pushNamed(context, '/upload').then((_) => _loadProducts());
          } else {
            Navigator.pushNamed(context, '/login')
                .then((_) => setState(() {}));
          }
        },
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.add_photo_alternate, color: Colors.white),
        label: const Text('Donasi Barang', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showNotifDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Notifikasi'),
        content: _isLoggedIn
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading:
                        Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                    title: Text('Cek email untuk notifikasi pesanan'),
                    subtitle: Text('Email dikirim otomatis via EmailJS'),
                  ),
                ],
              )
            : const Text('Login untuk melihat notifikasi pesanan kamu.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup')),
          if (!_isLoggedIn)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login')
                    .then((_) => setState(() {}));
              },
              child: const Text('Login', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  void _showCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.shopping_cart, color: Color(0xFF2E7D32)),
          SizedBox(width: 8),
          Text('Keranjang'),
        ]),
        content: _cartCount == 0
            ? const Text('Keranjang masih kosong.')
            : Text(
                '$_cartCount produk di keranjang.\nLihat detail pesanan di Profil → Pesanan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
          if (_cartCount > 0 && _isLoggedIn)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
              child: const Text('Lihat Pesanan',
                  style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
