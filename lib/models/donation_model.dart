import 'package:cloud_firestore/cloud_firestore.dart';

class DonationModel {
  final String id;
  final String donorId;
  final String donorName;
  final String donorEmail;
  final String itemName;
  final String description;
  final String material;
  final int quantity;
  final String status;
  final String notes;
  final DateTime? createdAt;

  DonationModel({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.donorEmail,
    required this.itemName,
    required this.description,
    required this.material,
    required this.quantity,
    this.status = 'pending',
    this.notes = '',
    this.createdAt,
  });

  factory DonationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DonationModel(
      id: doc.id,
      donorId: data['donorId'] ?? '',
      donorName: data['donorName'] ?? '',
      donorEmail: data['donorEmail'] ?? '',
      itemName: data['itemName'] ?? '',
      description: data['description'] ?? '',
      material: data['material'] ?? '',
      quantity: (data['quantity'] ?? 1).toInt(),
      status: data['status'] ?? 'pending',
      notes: data['notes'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'donorId': donorId,
        'donorName': donorName,
        'donorEmail': donorEmail,
        'itemName': itemName,
        'description': description,
        'material': material,
        'quantity': quantity,
        'status': status,
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
      };

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Menunggu';
      case 'matched': return 'Dicocokkan';
      case 'processing': return 'Diproses';
      case 'completed': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      default: return status;
    }
  }
}
