import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String ownerEmail;
  final String storeName;
  final String storeType; // penumpul | pengepul | pengrajin | distributor
  final String description;
  final String city;
  final String phone;
  final String logoUrl;
  final bool isActive;
  final double rating;
  final int productCount;
  final DateTime? createdAt;

  StoreModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
    required this.storeName,
    required this.storeType,
    this.description = '',
    this.city = '',
    this.phone = '',
    this.logoUrl = '',
    this.isActive = true,
    this.rating = 0,
    this.productCount = 0,
    this.createdAt,
  });

  factory StoreModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return StoreModel(
      id: doc.id,
      ownerId: d['ownerId'] ?? '',
      ownerName: d['ownerName'] ?? '',
      ownerEmail: d['ownerEmail'] ?? '',
      storeName: d['storeName'] ?? '',
      storeType: d['storeType'] ?? 'pengrajin',
      description: d['description'] ?? '',
      city: d['city'] ?? '',
      phone: d['phone'] ?? '',
      logoUrl: d['logoUrl'] ?? '',
      isActive: d['isActive'] ?? true,
      rating: (d['rating'] ?? 0.0).toDouble(),
      productCount: (d['productCount'] ?? 0).toInt(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'ownerId': ownerId,
        'ownerName': ownerName,
        'ownerEmail': ownerEmail,
        'storeName': storeName,
        'storeType': storeType,
        'description': description,
        'city': city,
        'phone': phone,
        'logoUrl': logoUrl,
        'isActive': isActive,
        'rating': rating,
        'productCount': productCount,
        'createdAt': FieldValue.serverTimestamp(),
      };

  String get storeTypeLabel {
    switch (storeType) {
      case 'penumpul':    return 'Penumpul Barang';
      case 'pengepul':    return 'Pengepul';
      case 'distributor': return 'Distributor';
      default:            return 'Pengrajin';
    }
  }

  String get storeTypeEmoji {
    switch (storeType) {
      case 'penumpul':    return '🗑️';
      case 'pengepul':    return '♻️';
      case 'distributor': return '🚚';
      default:            return '🛠️';
    }
  }

  String get storeTypeColor {
    switch (storeType) {
      case 'penumpul':    return 'teal';
      case 'pengepul':    return 'blue';
      case 'distributor': return 'orange';
      default:            return 'green';
    }
  }

  String get productTypeForRole {
    switch (storeType) {
      case 'penumpul':    return 'waste';
      case 'pengepul':    return 'material';
      case 'distributor': return 'retail';
      default:            return 'handcraft';
    }
  }
}
