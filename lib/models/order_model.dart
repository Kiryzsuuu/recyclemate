import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String buyerId;
  final String buyerName;
  final String buyerEmail;
  final String productId;
  final String productName;
  final int productPrice;
  final int quantity;
  final int totalPrice;
  final String crafterName;
  final String crafterId;
  final String status;
  final String shippingAddress;
  final String notes;
  final String refundReason;
  final DateTime? createdAt;
  final DateTime? refundRequestedAt;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.buyerEmail,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.totalPrice,
    required this.crafterName,
    this.crafterId = '',
    this.status = 'pending',
    this.shippingAddress = '',
    this.notes = '',
    this.refundReason = '',
    this.createdAt,
    this.refundRequestedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      buyerId: data['buyerId'] ?? '',
      buyerName: data['buyerName'] ?? '',
      buyerEmail: data['buyerEmail'] ?? '',
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productPrice: (data['productPrice'] ?? 0).toInt(),
      quantity: (data['quantity'] ?? 1).toInt(),
      totalPrice: (data['totalPrice'] ?? 0).toInt(),
      crafterName: data['crafterName'] ?? '',
      crafterId: data['crafterId'] ?? '',
      status: data['status'] ?? 'pending',
      shippingAddress: data['shippingAddress'] ?? '',
      notes: data['notes'] ?? '',
      refundReason: data['refundReason'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      refundRequestedAt: (data['refundRequestedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'buyerId': buyerId,
        'buyerName': buyerName,
        'buyerEmail': buyerEmail,
        'productId': productId,
        'productName': productName,
        'productPrice': productPrice,
        'quantity': quantity,
        'totalPrice': totalPrice,
        'crafterName': crafterName,
        'crafterId': crafterId,
        'status': status,
        'shippingAddress': shippingAddress,
        'notes': notes,
        'refundReason': '',
        'createdAt': FieldValue.serverTimestamp(),
      };

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Menunggu';
      case 'paid': return 'Dibayar';
      case 'shipped': return 'Dikirim';
      case 'completed': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      case 'refund_requested': return 'Refund Diminta';
      case 'refunded': return 'Dikembalikan';
      default: return status;
    }
  }

  bool get canRefund => ['paid', 'shipped'].contains(status);
  bool get isRefundPending => status == 'refund_requested';
}
