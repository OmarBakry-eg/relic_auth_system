import 'package:mongo_dart/mongo_dart.dart';

/// User model representing a user in the system
class User {
  final ObjectId id;
  final String email;
  final String passwordHash;
  final String name;
  final List<String> roles;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? refreshToken;

  User({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.name,
    required this.roles,
    this.emailVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.refreshToken,
  });

  /// Convert User to JSON for MongoDB storage
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'passwordHash': passwordHash,
      'name': name,
      'roles': roles,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (refreshToken != null) 'refreshToken': refreshToken,
    };
  }

  /// Create User from MongoDB document
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as ObjectId,
      email: json['email'] as String,
      passwordHash: json['passwordHash'] as String,
      name: json['name'] as String,
      roles: List<String>.from(json['roles'] as List),
      emailVerified: json['emailVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      refreshToken: json['refreshToken'] as String?,
    );
  }

  /// Create a safe JSON representation (without sensitive data)
  Map<String, dynamic> toSafeJson() {
    return {
      'id': id.toHexString(),
      'email': email,
      'name': name,
      'roles': roles,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  User copyWith({
    ObjectId? id,
    String? email,
    String? passwordHash,
    String? name,
    List<String>? roles,
    bool? emailVerified,
    DateTime? updatedAt,
    String? refreshToken,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      name: name ?? this.name,
      roles: roles ?? this.roles,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
