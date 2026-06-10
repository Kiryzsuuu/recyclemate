import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/email_service.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/donation_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserModel? _user;
  List<OrderModel> _orders = [];
  List<DonationModel> _donations = [];
  bool _isLoading = true;

  bool _isEditing = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _bioCtrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (_isEditing) {
      _nameCtrl.dispose();
      _cityCtrl.dispose();
      _phoneCtrl.dispose();
      _bioCtrl.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = await FirebaseAuthService.getProfile();
      final orders = await FirestoreService.getMyOrders();
      final donations = await FirestoreService.getMyDonations();
      setState(() {
        _user = user;
        _orders = orders;
        _donations = donations;
        _nameCtrl = TextEditingController(text: user?.name ?? '');
        _cityCtrl = TextEditingController(text: user?.city ?? '');
        _phoneCtrl = TextEditingController(text: user?.phone ?? '');
        _bioCtrl = TextEditingController(text: user?.bio ?? '');
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat profil: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    try {
      final updated = await FirebaseAuthService.updateProfile({
        'name': _nameCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
      });
      setState(() {
        _user = updated;
        _isEditing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
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

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseAuthService.logout();
      if (mounted) Navigator.pushReplacementNamed(context, '/');
    }
  }

  Future<void> _requestRefund(OrderModel order) async {
    final reasonCtrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ajukan Refund'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Produk: ${order.productName}'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Alasan refund...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32)),
            onPressed: () => Navigator.pop(context, reasonCtrl.text),
            child: const Text('Ajukan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (reason != null && _user != null) {
      try {
        await FirestoreService.requestRefund(order.id, reason: reason);

        // Send refund email
        EmailService.sendRefundNotification(
          buyerName: _user!.name,
          buyerEmail: _user!.email,
          productName: order.productName,
          totalPrice: order.totalPrice,
          reason: reason,
        );

        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permintaan refund berhasil! Cek email kamu.'),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text('Profil Saya',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => setState(() => _isEditing = false),
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Profil'),
            Tab(text: 'Pesanan'),
            Tab(text: 'Donasi'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildOrdersTab(),
                _buildDonationsTab(),
              ],
            ),
    );
  }

  Widget _buildProfileTab() {
    if (_user == null) return const Center(child: Text('Profil tidak tersedia'));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: const Color(0xFF2E7D32),
            child: Text(
              _user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : '?',
              style: const TextStyle(
                  fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          if (!_isEditing) ...[
            Text(_user!.name,
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text(_user!.email, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_user!.roleEmoji} ${_user!.roleLabel}',
                style: const TextStyle(
                    color: Color(0xFF2E7D32), fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 24),
            _infoCard([
              if (_user!.city.isNotEmpty)
                _infoRow(Icons.location_on_outlined, _user!.city),
              if (_user!.phone.isNotEmpty)
                _infoRow(Icons.phone_outlined, _user!.phone),
              if (_user!.bio.isNotEmpty)
                _infoRow(Icons.info_outline, _user!.bio),
            ]),
          ] else ...[
            const SizedBox(height: 20),
            _editField(_nameCtrl, 'Nama Lengkap', Icons.person_outline),
            const SizedBox(height: 12),
            _editField(_cityCtrl, 'Kota', Icons.location_city_outlined),
            const SizedBox(height: 12),
            _editField(_phoneCtrl, 'No. Telepon', Icons.phone_outlined),
            const SizedBox(height: 12),
            _editField(_bioCtrl, 'Bio / Deskripsi', Icons.info_outline, maxLines: 3),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simpan Perubahan',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (_user!.isAdmin)
            _actionTile(
              icon: Icons.admin_panel_settings,
              label: 'Panel Admin',
              color: Colors.red,
              onTap: () => Navigator.pushNamed(context, '/admin'),
            ),
          if (_user!.isSeller) ...[
            const SizedBox(height: 10),
            _actionTile(
              icon: Icons.store,
              label: 'Kelola Produk Saya',
              color: const Color(0xFF2E7D32),
              onTap: () => Navigator.pushNamed(context, '/manage-products')
                  .then((_) => _loadData()),
            ),
          ],
          if (_user!.isBuyer && !_user!.isAdmin) ...[
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.store_mall_directory,
                    color: Colors.white),
                title: const Text('Buka Toko',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text('Mulai berjualan di RecycleMate',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onTap: () => Navigator.pushNamed(context, '/open-store')
                    .then((_) => _loadData()),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    if (_orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('Belum ada pesanan', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (_, i) => _orderCard(_orders[i]),
    );
  }

  Widget _orderCard(OrderModel order) {
    final statusColors = {
      'pending': Colors.orange,
      'paid': Colors.blue,
      'shipped': Colors.indigo,
      'completed': Colors.green,
      'cancelled': Colors.red,
      'refund_requested': Colors.deepOrange,
      'refunded': Colors.teal,
    };
    final color = statusColors[order.status] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(order.productName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(order.statusLabel,
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Pengrajin: ${order.crafterName}',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Text('${order.quantity} unit × ${_fmt(order.productPrice)}',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${_fmt(order.totalPrice)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                      fontSize: 15),
                ),
                if (order.canRefund)
                  TextButton(
                    onPressed: () => _requestRefund(order),
                    child: const Text('Ajukan Refund',
                        style: TextStyle(color: Colors.orange)),
                  ),
                if (order.isRefundPending)
                  const Text('Refund Diproses...',
                      style:
                          TextStyle(color: Colors.deepOrange, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationsTab() {
    if (_donations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volunteer_activism_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('Belum ada donasi', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _donations.length,
      itemBuilder: (_, i) => _donationCard(_donations[i]),
    );
  }

  Widget _donationCard(DonationModel donation) {
    final statusColors = {
      'pending': Colors.orange,
      'matched': Colors.blue,
      'processing': Colors.indigo,
      'completed': Colors.green,
      'cancelled': Colors.red,
    };
    final color = statusColors[donation.status] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(donation.itemName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(donation.statusLabel,
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Material: ${donation.material} · ${donation.quantity} unit',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            if (donation.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(donation.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87, fontSize: 13)),
            ],
            if (donation.status == 'pending') ...[
              const Divider(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _cancelDonation(donation),
                  child:
                      const Text('Batalkan', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _cancelDonation(DonationModel donation) async {
    try {
      await FirestoreService.cancelDonation(donation.id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donasi berhasil dibatalkan'),
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

  Widget _infoCard(List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _editField(TextEditingController ctrl, String label, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
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

  Widget _actionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      tileColor: Colors.white,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: color),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  String _fmt(int price) => 'Rp ${price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      )}';
}
