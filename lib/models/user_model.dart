// lib/models/user_model.dart
class UserModel {
  final int? id;
  final String username;
  final String password;
  final String role; // 'hr_manager' or 'supervisor'
  final String fullName;
  final String email;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.fullName,
    required this.email,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      role: map['role'],
      fullName: map['full_name'],
      email: map['email'],
      createdAt: map['created_at'] is DateTime
          ? map['created_at']
          : DateTime.parse(map['created_at'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'role': role,
      'full_name': fullName,
      'email': email,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
