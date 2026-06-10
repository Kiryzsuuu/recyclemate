import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);

    // Guard: redirect if not admin
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profile = await FirebaseAuthService.getProfile();
      if (profile == null || profile.role != 'admin') {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text('Panel Admin',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Pengguna'),
            Tab(text: 'Produk'),
            Tab(text: 'Pesanan'),
            Tab(text: 'Pengaturan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _DashboardTab(),
          _UsersTab(),
          _ProductsTab(),
          _OrdersTab(),
          _SettingsTab(),
        ],
      ),
    );
  }
}

// ─── DASHBOARD TAB ────────────────────────────────────────────────────────────

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  Map<String, int> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final stats = await FirestoreService.getAdminStats();
      if (mounted) setState(() => _stats = stats);
    } catch (e) {
      debugPrint('Dashboard stats error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Statistik Sistem',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _statCard('Pengguna', _stats['users'] ?? 0,
                  Icons.people_outline, Colors.blue),
              _statCard('Produk Aktif', _stats['products'] ?? 0,
                  Icons.inventory_2_outlined, Colors.green),
              _statCard('Total Pesanan', _stats['orders'] ?? 0,
                  Icons.shopping_bag_outlined, Colors.orange),
              _statCard('Donasi', _stats['donations'] ?? 0,
                  Icons.volunteer_activism_outlined, Colors.purple),
            ],
          ),
          const SizedBox(height: 24),
          Text('Aksi Cepat',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _quickAction(
            icon: Icons.person_add_outlined,
            label: 'Lihat Semua Pengguna',
            onTap: () {},
          ),
          _quickAction(
            icon: Icons.store_outlined,
            label: 'Moderasi Produk',
            onTap: () {},
          ),
          _quickAction(
            icon: Icons.settings_outlined,
            label: 'Atur Tampilan Aplikasi',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, int value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text('$value',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ),
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _quickAction(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return ListTile(
      tileColor: Colors.white,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: const Color(0xFF2E7D32)),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

// ─── USERS TAB ────────────────────────────────────────────────────────────────

class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  static const _allRoles = [
    'pembeli', 'penumpul', 'pengepul', 'pengrajin', 'distributor', 'admin'
  ];

  static const _roleLabels = {
    'pembeli': 'Pembeli',
    'buyer': 'Pembeli',
    'penumpul': 'Penumpul',
    'pengepul': 'Pengepul',
    'pengrajin': 'Pengrajin',
    'crafter': 'Pengrajin',
    'distributor': 'Distributor',
    'admin': 'Admin',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final users = await FirestoreService.getAllUsers();
      users.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
      if (mounted) setState(() => _users = users);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeRole(String userId, String currentRole) async {
    final newRole = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ubah Role Pengguna'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _allRoles.map((r) {
            final selected = r == currentRole;
            return ListTile(
              leading: Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? const Color(0xFF2E7D32) : Colors.grey,
              ),
              title: Text(_roleLabels[r] ?? r),
              selected: selected,
              selectedTileColor: const Color(0xFFE8F5E9),
              onTap: () => Navigator.pop(context, r),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
        ],
      ),
    );

    if (newRole != null && newRole != currentRole) {
      try {
        await FirestoreService.updateUserRole(userId, newRole);
        _load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Role berhasil diubah'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(e.toString().replaceAll('Exception: ', '')),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (_, i) {
          final u = _users[i];
          final role = u['role'] ?? 'pembeli';
          final name = u['name'] ?? 'Tanpa Nama';
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF2E7D32),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(u['email'] ?? '',
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 12)),
              trailing: GestureDetector(
                onTap: () => _changeRole(u['id'], role),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _roleColor(role).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _roleColor(role)),
                  ),
                  child: Text(
                    _roleLabels[role] ?? role,
                    style: TextStyle(
                        color: _roleColor(role),
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':       return Colors.red;
      case 'pengrajin':
      case 'crafter':     return Colors.green;
      case 'pengepul':    return Colors.blue;
      case 'penumpul':    return Colors.teal;
      case 'distributor': return Colors.orange;
      default:            return Colors.purple;
    }
  }
}

// ─── PRODUCTS TAB ─────────────────────────────────────────────────────────────

class _ProductsTab extends StatefulWidget {
  const _ProductsTab();

  @override
  State<_ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<_ProductsTab> {
  List<ProductModel> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final products = await FirestoreService.getAllProductsAdmin();
      if (mounted) setState(() => _products = products);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleActive(ProductModel p) async {
    try {
      await FirestoreService.setProductActive(p.id, !p.isActive);
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(p.isActive
                ? '${p.name} dinonaktifkan'
                : '${p.name} diaktifkan'),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _delete(ProductModel p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Hapus "${p.name}" secara permanen?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await FirestoreService.adminDeleteProduct(p.id);
        _load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Produk dihapus'),
                backgroundColor: Color(0xFF2E7D32)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(e.toString().replaceAll('Exception: ', '')),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _products.length,
        itemBuilder: (_, i) {
          final p = _products[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(p.bgColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.recycling,
                    color: Colors.white, size: 24),
              ),
              title: Text(p.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${p.crafterName} · ${p.material}',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                  Text(p.productTypeLabel,
                      style: const TextStyle(
                          color: Color(0xFF2E7D32), fontSize: 11)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: p.isActive,
                    onChanged: (_) => _toggleActive(p),
                    activeTrackColor: const Color(0xFF2E7D32),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
                    onPressed: () => _delete(p),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── ORDERS TAB ───────────────────────────────────────────────────────────────

class _OrdersTab extends StatefulWidget {
  const _OrdersTab();

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  List<OrderModel> _orders = [];
  bool _loading = true;

  static const _statuses = [
    'pending', 'paid', 'shipped', 'completed', 'cancelled', 'refunded'
  ];
  static const _statusLabels = {
    'pending': 'Menunggu',
    'paid': 'Dibayar',
    'shipped': 'Dikirim',
    'completed': 'Selesai',
    'cancelled': 'Dibatalkan',
    'refund_requested': 'Refund Diminta',
    'refunded': 'Dikembalikan',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final orders = await FirestoreService.getAllOrders();
      if (mounted) setState(() => _orders = orders);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeStatus(OrderModel order) async {
    final newStatus = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ubah Status Pesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _statuses.map((s) {
            final selected = s == order.status;
            return ListTile(
              leading: Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? const Color(0xFF2E7D32) : Colors.grey,
              ),
              title: Text(_statusLabels[s] ?? s),
              selected: selected,
              selectedTileColor: const Color(0xFFE8F5E9),
              onTap: () => Navigator.pop(context, s),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
        ],
      ),
    );

    if (newStatus != null && newStatus != order.status) {
      try {
        await FirestoreService.adminUpdateOrderStatus(order.id, newStatus);
        _load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Status pesanan diperbarui'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(e.toString().replaceAll('Exception: ', '')),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
    }
    if (_orders.isEmpty) {
      return const Center(
        child: Text('Belum ada pesanan', style: TextStyle(color: Colors.grey)),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (_, i) {
          final o = _orders[i];
          final statusColors = {
            'pending': Colors.orange,
            'paid': Colors.blue,
            'shipped': Colors.indigo,
            'completed': Colors.green,
            'cancelled': Colors.red,
            'refund_requested': Colors.deepOrange,
            'refunded': Colors.teal,
          };
          final color = statusColors[o.status] ?? Colors.grey;
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(o.productName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      GestureDetector(
                        onTap: () => _changeStatus(o),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: color.withValues(alpha: 0.4)),
                          ),
                          child: Text(o.statusLabel,
                              style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                      'Pembeli: ${o.buyerName} · Pengrajin: ${o.crafterName}',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                  Text(
                      '${o.quantity} unit · Rp ${_fmt(o.totalPrice)}',
                      style: const TextStyle(
                          color: Colors.black87, fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _fmt(int price) => price
      .toString()
      .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}

// ─── SETTINGS TAB ─────────────────────────────────────────────────────────────

class _SettingsTab extends StatefulWidget {
  const _SettingsTab();

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  final _bannerTitleCtrl = TextEditingController();
  final _bannerSubtitleCtrl = TextEditingController();
  final _statTextCtrl = TextEditingController();
  final _promoCtrl = TextEditingController();
  bool _maintenanceMode = false;
  bool _allowRegistrations = true;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _bannerTitleCtrl.dispose();
    _bannerSubtitleCtrl.dispose();
    _statTextCtrl.dispose();
    _promoCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final settings = await FirestoreService.getSiteSettings();
      if (mounted) {
        setState(() {
          _bannerTitleCtrl.text =
              settings['bannerTitle'] ?? '';
          _bannerSubtitleCtrl.text =
              settings['bannerSubtitle'] ?? '';
          _statTextCtrl.text = settings['statText'] ?? '';
          _promoCtrl.text = settings['promoText'] ?? '';
          _maintenanceMode =
              settings['maintenanceMode'] == true;
          _allowRegistrations =
              settings['allowNewRegistrations'] != false;
        });
      }
    } catch (e) {
      debugPrint('Settings load error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirestoreService.updateSiteSettings({
        'bannerTitle': _bannerTitleCtrl.text.trim(),
        'bannerSubtitle': _bannerSubtitleCtrl.text.trim(),
        'statText': _statTextCtrl.text.trim(),
        'promoText': _promoCtrl.text.trim(),
        'maintenanceMode': _maintenanceMode,
        'allowNewRegistrations': _allowRegistrations,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaturan berhasil disimpan!'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pengaturan Tampilan',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _field(_bannerTitleCtrl, 'Judul Banner Utama',
              'Judul yang tampil di beranda'),
          const SizedBox(height: 12),
          _field(_bannerSubtitleCtrl, 'Subjudul Banner',
              'Deskripsi singkat di bawah judul'),
          const SizedBox(height: 12),
          _field(_statTextCtrl, 'Teks Statistik',
              'Contoh: 120 kg sampah terselamatkan'),
          const SizedBox(height: 12),
          _field(_promoCtrl, 'Teks Promo (opsional)',
              'Contoh: Diskon 20% produk Kayu'),
          const SizedBox(height: 24),
          Text('Pengaturan Sistem',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _switchTile(
            'Mode Pemeliharaan',
            'Nonaktifkan akses pengguna sementara',
            _maintenanceMode,
            (v) => setState(() => _maintenanceMode = v),
            Colors.red,
          ),
          const SizedBox(height: 8),
          _switchTile(
            'Izinkan Pendaftaran Baru',
            'Pengguna baru dapat mendaftar',
            _allowRegistrations,
            (v) => setState(() => _allowRegistrations = v),
            Colors.green,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Simpan Pengaturan',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, String hint) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
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
      ),
    );
  }

  Widget _switchTile(String title, String subtitle, bool value,
      ValueChanged<bool> onChanged, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: color,
        activeTrackColor: color.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
