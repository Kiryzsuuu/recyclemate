import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String city;
  final String phone;
  final String role;
  final String avatar;
  final String bio;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.city = '',
    this.phone = '',
    this.role = 'pembeli',
    this.avatar = '',
    this.bio = '',
    this.createdAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      city: data['city'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'pembeli',
      avatar: data['avatar'] ?? '',
      bio: data['bio'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'city': city,
        'phone': phone,
        'role': role,
        'avatar': avatar,
        'bio': bio,
      };

  // ─── Role helpers ─────────────────────────────────────────────────────────

  String get roleLabel {
    switch (role) {
      case 'admin':       return 'Admin';
      case 'penumpul':    return 'Penumpul Barang';
      case 'pengepul':    return 'Pengepul';
      case 'pengrajin':
      case 'crafter':     return 'Pengrajin'; // backward compat
      case 'distributor': return 'Distributor';
      case 'pembeli':
      case 'buyer':       return 'Pembeli'; // backward compat
      default:            return 'Pembeli';
    }
  }

  String get roleEmoji {
    switch (role) {
      case 'admin':       return '⚙️';
      case 'penumpul':    return '♻️';
      case 'pengepul':    return '📦';
      case 'pengrajin':
      case 'crafter':     return '🛠️';
      case 'distributor': return '🚚';
      default:            return '🛍️';
    }
  }

  bool get isAdmin => role == 'admin';

  // Roles that can list items for sale
  bool get isSeller => ['penumpul', 'pengepul', 'pengrajin', 'crafter', 'distributor'].contains(role);

  bool get isBuyer => ['pembeli', 'buyer'].contains(role);
}
