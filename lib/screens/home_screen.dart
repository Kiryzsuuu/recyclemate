import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/section_title.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';

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
  UserModel? _userProfile;

  bool get _isLoggedIn => FirebaseAuth.instance.currentUser != null;
  String? get _userRole => _userProfile?.role;
  bool get _isAdmin => _userProfile?.isAdmin == true;
  bool get _isSeller => _userProfile?.isSeller == true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (!_isLoggedIn) return;
    final profile = await FirebaseAuthService.getProfile();
    if (mounted) setState(() => _userProfile = profile);
  }

  void _onCategoryChanged(String category) =>
      setState(() => _selectedCategory = category);

  void _onSearchChanged(String query) =>
      setState(() => _searchQuery = query);

  void _toggleFavorite(String id) => setState(() {
        _favorites.contains(id) ? _favorites.remove(id) : _favorites.add(id);
      });

  void _addToCart() => setState(() => _cartCount++);

  List<ProductModel> _applyFilters(List<ProductModel> all) {
    var products = all;

    if (_selectedCategory != 'Semua') {
      products = products
          .where((p) => p.material == _selectedCategory)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      products = products
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q))
          .toList();
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text('RecycleMate',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
              tooltip: 'Panel Admin',
              onPressed: () =>
                  Navigator.pushNamed(context, '/admin'),
            ),
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
            onPressed: () async {
              if (_isLoggedIn) {
                await Navigator.pushNamed(context, '/profile');
                _loadUserProfile();
              } else {
                await Navigator.pushNamed(context, '/login');
                _loadUserProfile();
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: FirestoreService.getProductsStreamForRole(_userRole),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(snapshot.error.toString().replaceAll('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final loading = !snapshot.hasData;
          final allProducts = snapshot.data ?? [];
          final products = _applyFilters(allProducts);

          return RefreshIndicator(
            onRefresh: () async => _loadUserProfile(),
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
                                          ? 'Halo, ${_userProfile?.name.split(' ')[0] ?? FirebaseAuth.instance.currentUser?.displayName?.split(' ')[0] ?? ''}!'
                                          : 'Halo, Kolektor!',
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 13),
                                    ),
                                    if (_userProfile != null)
                                      Text(
                                        '${_userProfile!.roleEmoji} ${_userProfile!.roleLabel}',
                                        style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 11),
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
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.eco,
                                              color: Colors.white, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            loading
                                                ? 'Memuat...'
                                                : '${products.length} produk tersedia',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11),
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
                            prefixIcon: const Icon(Icons.search,
                                color: Color(0xFF2E7D32)),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
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
                                            isSelected:
                                                _selectedCategory == c),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        if (!_isLoggedIn) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFF2E7D32), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.account_circle_outlined,
                                    size: 36, color: Color(0xFF2E7D32)),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Masuk untuk mulai belanja',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                      Text('Atau daftar akun baru gratis',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      height: 34,
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pushNamed(
                                                context, '/login')
                                            .then((_) => _loadUserProfile()),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF2E7D32),
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        child: const Text('Masuk',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13)),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      width: 80,
                                      height: 34,
                                      child: OutlinedButton(
                                        onPressed: () => Navigator.pushNamed(
                                                context, '/register')
                                            .then((_) => _loadUserProfile()),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                              color: Color(0xFF2E7D32)),
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        child: const Text('Daftar',
                                            style: TextStyle(
                                                color: Color(0xFF2E7D32),
                                                fontSize: 13)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        SectionTitle(
                            title: loading
                                ? 'Memuat produk...'
                                : products.isEmpty
                                    ? 'Tidak ada produk'
                                    : 'Produk (${products.length})'),
                      ],
                    ),
                  ),
                ),
                if (loading)
                  const SliverFillRemaining(
                    child: Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF2E7D32))),
                  )
                else if (products.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          const Icon(Icons.search_off,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Belum ada produk di kategori ini'
                                : 'Tidak ada produk "$_searchQuery"',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          if (_isSeller)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.pushNamed(
                                    context, '/manage-products'),
                                icon: const Icon(Icons.add, color: Colors.white),
                                label: const Text('Tambah Produk',
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
                          final p = products[index];
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
                        childCount: products.length,
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
          );
        },
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildFab() {
    if (!_isLoggedIn) {
      return const SizedBox.shrink(); // banner di atas sudah cukup
    }

    if (_isSeller) {
      return FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/manage-products'),
        backgroundColor: const Color(0xFF1565C0),
        icon: const Icon(Icons.storefront, color: Colors.white),
        label: const Text('Kelola Produk', style: TextStyle(color: Colors.white)),
      );
    }

    // pembeli — tawarkan buka toko
    return FloatingActionButton.extended(
      onPressed: () =>
          Navigator.pushNamed(context, '/open-store').then((_) => _loadUserProfile()),
      backgroundColor: const Color(0xFF2E7D32),
      icon: const Icon(Icons.store_mall_directory, color: Colors.white),
      label: const Text('Buka Toko', style: TextStyle(color: Colors.white)),
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
                    .then((_) => _loadUserProfile());
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup')),
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
