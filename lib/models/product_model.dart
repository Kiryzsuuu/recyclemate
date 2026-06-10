import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final int price;
  final String material;
  final double rating;
  final int ratingCount;
  final String crafterName;
  final String crafterCity;
  final String crafterId;
  final String description;
  final int bgColor;
  final String iconType;
  final String imageUrl;
  final int stock;
  final bool isActive;
  final String sellerRole;  // 'penumpul' | 'pengepul' | 'pengrajin' | 'distributor'
  final String productType; // 'waste' | 'material' | 'handcraft' | 'retail'
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.material,
    this.rating = 0,
    this.ratingCount = 0,
    required this.crafterName,
    this.crafterCity = '',
    this.crafterId = '',
    required this.description,
    this.bgColor = 0xFF2E7D32,
    this.iconType = 'generic',
    this.imageUrl = '',
    this.stock = 1,
    this.isActive = true,
    this.sellerRole = 'pengrajin',
    this.productType = 'handcraft',
    this.createdAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toInt(),
      material: data['material'] ?? 'Lainnya',
      rating: (data['rating'] ?? 0.0).toDouble(),
      ratingCount: (data['ratingCount'] ?? 0).toInt(),
      crafterName: data['crafterName'] ?? '',
      crafterCity: data['crafterCity'] ?? '',
      crafterId: data['crafterId'] ?? '',
      description: data['description'] ?? '',
      bgColor: (data['bgColor'] ?? 0xFF2E7D32).toInt(),
      iconType: data['iconType'] ?? 'generic',
      imageUrl: data['imageUrl'] ?? '',
      stock: (data['stock'] ?? 0).toInt(),
      isActive: data['isActive'] ?? true,
      sellerRole: data['sellerRole'] ?? 'pengrajin',
      productType: data['productType'] ?? 'handcraft',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'price': price,
        'material': material,
        'description': description,
        'bgColor': bgColor,
        'iconType': iconType,
        'imageUrl': imageUrl,
        'stock': stock,
        'isActive': isActive,
        'rating': rating,
        'ratingCount': ratingCount,
        'crafterName': crafterName,
        'crafterCity': crafterCity,
        'crafterId': crafterId,
        'sellerRole': sellerRole,
        'productType': productType,
        'createdAt': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> toWidgetMap() => {
        'id': id,
        'name': name,
        'price': price,
        'material': material,
        'rating': rating,
        'crafter': crafterName,
        'crafterCity': crafterCity,
        'description': description,
        'bgColor': bgColor,
        'iconType': iconType,
        'imageUrl': imageUrl,
        'stock': stock,
        'productId': id,
        'sellerRole': sellerRole,
        'productType': productType,
      };

  String get productTypeLabel {
    switch (productType) {
      case 'waste':     return 'Sampah / Limbah';
      case 'material':  return 'Bahan Baku';
      case 'retail':    return 'Produk Retail';
      default:          return 'Produk Kerajinan';
    }
  }

  String get sellerRoleLabel {
    switch (sellerRole) {
      case 'penumpul':    return 'Penumpul';
      case 'pengepul':    return 'Pengepul';
      case 'distributor': return 'Distributor';
      case 'crafter':
      case 'pengrajin':   return 'Pengrajin';
      default:            return sellerRole;
    }
  }
}
