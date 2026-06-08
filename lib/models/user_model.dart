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
    this.role = 'buyer',
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
      role: data['role'] ?? 'buyer',
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
}
