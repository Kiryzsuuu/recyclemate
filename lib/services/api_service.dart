import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/donation_model.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;

  // ─── PRODUCTS ─────────────────────────────────────────────────────────────

  /// Get all active products, optionally filtered
  static Future<List<ProductModel>> getProducts({
    String? material,
    String? search,
  }) async {
    Query query = _db
        .collection('products')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (material != null && material != 'Semua') {
      query = query.where('material', isEqualTo: material);
    }

    final snapshot = await query.get();
    var products =
        snapshot.docs.map((d) => ProductModel.fromFirestore(d)).toList();

    // Client-side search filter (Firestore doesn't support full-text natively)
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      products = products
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q))
          .toList();
    }

    return products;
  }

  /// Get a single product
  static Future<ProductModel?> getProduct(String id) async {
    final doc = await _db.collection('products').doc(id).get();
    if (!doc.exists) return null;
    return ProductModel.fromFirestore(doc);
  }

  /// Get products by current crafter (my products)
  static Future<List<ProductModel>> getMyProducts() async {
    if (_uid == null) throw Exception('Belum login.');
    final snapshot = await _db
        .collection('products')
        .where('crafterId', isEqualTo: _uid)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((d) => ProductModel.fromFirestore(d)).toList();
  }

  /// Create a new product
  static Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Belum login.');

    // Get user profile for crafter info
    final userDoc = await _db.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};

    final docData = {
      ...data,
      'crafterId': user.uid,
      'crafterName': userData['name'] ?? user.displayName ?? '',
      'crafterCity': userData['city'] ?? '',
      'isActive': true,
      'rating': 0.0,
      'ratingCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final ref = await _db.collection('products').add(docData);
    final doc = await ref.get();
    return ProductModel.fromFirestore(doc);
  }

  /// Update a product (owner only — enforced by Firestore rules)
  static Future<void> updateProduct(
      String id, Map<String, dynamic> data) async {
    if (_uid == null) throw Exception('Belum login.');
    await _db.collection('products').doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Soft delete a product
  static Future<void> deleteProduct(String id) async {
    if (_uid == null) throw Exception('Belum login.');
    await _db
        .collection('products')
        .doc(id)
        .update({'isActive': false, 'deletedAt': FieldValue.serverTimestamp()});
  }

  // ─── ORDERS ───────────────────────────────────────────────────────────────

  /// Create an order and decrement stock
  static Future<OrderModel> createOrder({
    required String productId,
    required int quantity,
    String shippingAddress = '',
    String notes = '',
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Belum login.');

    // Fetch product
    final productDoc =
        await _db.collection('products').doc(productId).get();
    if (!productDoc.exists) throw Exception('Produk tidak ditemukan.');

    final product = ProductModel.fromFirestore(productDoc);

    if (product.stock < quantity) {
      throw Exception(
          'Stok tidak mencukupi. Tersedia: ${product.stock}');
    }

    // Fetch buyer info
    final userDoc = await _db.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};

    final totalPrice = product.price * quantity;

    final order = OrderModel(
      id: '',
      buyerId: user.uid,
      buyerName: userData['name'] ?? user.displayName ?? '',
      buyerEmail: user.email ?? '',
      productId: productId,
      productName: product.name,
      productPrice: product.price,
      quantity: quantity,
      totalPrice: totalPrice,
      crafterName: product.crafterName,
      crafterId: product.crafterId,
      shippingAddress: shippingAddress,
      notes: notes,
    );

    // Transaction: create order + decrement stock atomically
    final batch = _db.batch();

    final orderRef = _db.collection('orders').doc();
    batch.set(orderRef, order.toFirestore());

    final productRef = _db.collection('products').doc(productId);
    batch.update(productRef, {'stock': FieldValue.increment(-quantity)});

    await batch.commit();

    final orderDoc = await orderRef.get();
    return OrderModel.fromFirestore(orderDoc);
  }

  /// Get orders for current buyer
  static Future<List<OrderModel>> getMyOrders() async {
    if (_uid == null) throw Exception('Belum login.');
    final snapshot = await _db
        .collection('orders')
        .where('buyerId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((d) => OrderModel.fromFirestore(d)).toList();
  }

  /// Get orders for current crafter's products
  static Future<List<OrderModel>> getOrdersAsCrafter() async {
    if (_uid == null) throw Exception('Belum login.');
    final snapshot = await _db
        .collection('orders')
        .where('crafterId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((d) => OrderModel.fromFirestore(d)).toList();
  }

  /// Update order status
  static Future<void> updateOrderStatus(String id, String status) async {
    if (_uid == null) throw Exception('Belum login.');
    await _db.collection('orders').doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Restore stock if cancelled
    if (status == 'cancelled') {
      final orderDoc = await _db.collection('orders').doc(id).get();
      final order = OrderModel.fromFirestore(orderDoc);
      await _db.collection('products').doc(order.productId).update({
        'stock': FieldValue.increment(order.quantity),
      });
    }
  }

  /// Request refund
  static Future<void> requestRefund(String id, {String reason = ''}) async {
    if (_uid == null) throw Exception('Belum login.');
    await _db.collection('orders').doc(id).update({
      'status': 'refund_requested',
      'refundReason': reason,
      'refundRequestedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── DONATIONS ────────────────────────────────────────────────────────────

  /// Create a donation
  static Future<DonationModel> createDonation({
    required String itemName,
    required String description,
    required String material,
    required int quantity,
    String imageUrl = '',
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Belum login.');

    final userDoc = await _db.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};

    final donation = DonationModel(
      id: '',
      donorId: user.uid,
      donorName: userData['name'] ?? user.displayName ?? '',
      donorEmail: user.email ?? '',
      itemName: itemName,
      description: description,
      material: material,
      quantity: quantity,
    );

    final data = {
      ...donation.toFirestore(),
      if (imageUrl.isNotEmpty) 'imageUrl': imageUrl,
    };

    final ref = await _db.collection('donations').add(data);
    final doc = await ref.get();
    return DonationModel.fromFirestore(doc);
  }

  /// Get donations for current user
  static Future<List<DonationModel>> getMyDonations() async {
    if (_uid == null) throw Exception('Belum login.');
    final snapshot = await _db
        .collection('donations')
        .where('donorId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((d) => DonationModel.fromFirestore(d)).toList();
  }

  /// Cancel a donation
  static Future<void> cancelDonation(String id) async {
    if (_uid == null) throw Exception('Belum login.');
    final doc = await _db.collection('donations').doc(id).get();
    final data = doc.data() as Map<String, dynamic>;
    if (data['status'] != 'pending') {
      throw Exception('Donasi yang sudah diproses tidak bisa dibatalkan.');
    }
    await _db
        .collection('donations')
        .doc(id)
        .update({'status': 'cancelled'});
  }

  // ─── ROLE-BASED PRODUCT QUERY ─────────────────────────────────────────────

  /// Get products visible to a specific role (supply chain filter)
  static Stream<List<ProductModel>> getProductsStreamForRole(String? userRole) {
    return _db
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) {
      var all = snap.docs.map((d) => ProductModel.fromFirestore(d)).toList();

      // Sort by createdAt client-side (avoids composite index requirement)
      all.sort((a, b) {
        final at = a.createdAt ?? DateTime(0);
        final bt = b.createdAt ?? DateTime(0);
        return bt.compareTo(at);
      });

      // Role-based visibility filter
      switch (userRole) {
        case 'admin':
          return all; // admin sees everything
        case 'pengepul':
          return all
              .where((p) =>
                  p.productType == 'waste' ||
                  ['handcraft', 'retail'].contains(p.productType))
              .toList();
        case 'pengrajin':
        case 'crafter':
          return all
              .where((p) =>
                  p.productType == 'material' ||
                  ['handcraft', 'retail'].contains(p.productType))
              .toList();
        case 'distributor':
          return all
              .where((p) => ['handcraft', 'retail'].contains(p.productType))
              .toList();
        default: // pembeli, penumpul, buyer, guest
          return all
              .where((p) => ['handcraft', 'retail'].contains(p.productType))
              .toList();
      }
    });
  }

  // ─── ADMIN: USERS ────────────────────────────────────────────────────────

  /// Get all users (admin only)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final snap = await _db.collection('users').get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  /// Update a user's role (admin only)
  static Future<void> updateUserRole(String userId, String role) async {
    await _db.collection('users').doc(userId).update({'role': role});
  }

  /// Deactivate a user (admin only)
  static Future<void> setUserDeactivated(String userId, bool deactivated) async {
    await _db
        .collection('users')
        .doc(userId)
        .update({'isDeactivated': deactivated});
  }

  // ─── ADMIN: PRODUCTS ─────────────────────────────────────────────────────

  /// Get ALL products including inactive (admin only)
  static Future<List<ProductModel>> getAllProductsAdmin() async {
    final snap = await _db
        .collection('products')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => ProductModel.fromFirestore(d)).toList();
  }

  /// Toggle product active status (admin or owner)
  static Future<void> setProductActive(String id, bool isActive) async {
    await _db.collection('products').doc(id).update({'isActive': isActive});
  }

  /// Hard delete a product (admin only)
  static Future<void> adminDeleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }

  // ─── ADMIN: ORDERS ────────────────────────────────────────────────────────

  /// Get ALL orders (admin only)
  static Future<List<OrderModel>> getAllOrders() async {
    final snap = await _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => OrderModel.fromFirestore(d)).toList();
  }

  /// Admin update order status (no ownership check)
  static Future<void> adminUpdateOrderStatus(String id, String status) async {
    await _db.collection('orders').doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (status == 'cancelled') {
      final orderDoc = await _db.collection('orders').doc(id).get();
      final order = OrderModel.fromFirestore(orderDoc);
      await _db.collection('products').doc(order.productId).update({
        'stock': FieldValue.increment(order.quantity),
      });
    }
  }

  // ─── ADMIN: DONATIONS ────────────────────────────────────────────────────

  /// Get ALL donations (admin only)
  static Future<List<DonationModel>> getAllDonations() async {
    final snap = await _db
        .collection('donations')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => DonationModel.fromFirestore(d)).toList();
  }

  /// Admin update donation status
  static Future<void> adminUpdateDonationStatus(String id, String status) async {
    await _db
        .collection('donations')
        .doc(id)
        .update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});
  }

  // ─── SITE SETTINGS ───────────────────────────────────────────────────────

  /// Get site settings (visible to all)
  static Future<Map<String, dynamic>> getSiteSettings() async {
    final doc =
        await _db.collection('app_config').doc('site_settings').get();
    return doc.data() ?? {
      'bannerTitle': 'Temukan karya upcycle terbaik hari ini',
      'bannerSubtitle': 'Bersama kurangi sampah, ciptakan karya bernilai',
      'statText': '120 kg sampah terselamatkan',
      'promoText': '',
      'maintenanceMode': false,
      'allowNewRegistrations': true,
    };
  }

  /// Update site settings (admin only)
  static Future<void> updateSiteSettings(Map<String, dynamic> settings) async {
    await _db.collection('app_config').doc('site_settings').set(
      {...settings, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  // ─── ADMIN: STATS ────────────────────────────────────────────────────────

  /// Get dashboard stats (admin only)
  static Future<Map<String, int>> getAdminStats() async {
    final futures = await Future.wait([
      _db.collection('users').count().get(),
      _db.collection('products').where('isActive', isEqualTo: true).count().get(),
      _db.collection('orders').count().get(),
      _db.collection('donations').count().get(),
    ]);

    return {
      'users': futures[0].count ?? 0,
      'products': futures[1].count ?? 0,
      'orders': futures[2].count ?? 0,
      'donations': futures[3].count ?? 0,
    };
  }
}
