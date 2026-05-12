import 'package:cloud_firestore/cloud_firestore.dart';

class AuthUserModel {
  AuthUserModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  final String id;
  final int userId;
  final String name;
  final String email;
  final String password;
  final String role;

  factory AuthUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};
    return AuthUserModel(
      id: document.id,
      userId: _toInt(data['userId']) ?? 0,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      password: (data['password'] as String?) ?? '',
      role: (data['role'] as String?) ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'usernameKey': name.toLowerCase(),
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }
}
