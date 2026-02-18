import 'package:bcrypt/bcrypt.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../config/database.dart';
import '../models/user.dart';
import '../utils/jwt_utils.dart';
import '../utils/validators.dart';

/// Authentication service handling all auth-related business logic
class AuthService {
  /// Register a new user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    // Validate inputs
    if (!Validators.isValidEmail(email)) {
      return {'success': false, 'message': 'Invalid email format'};
    }

    if (!Validators.isStrongPassword(password)) {
      return {
        'success': false,
        'message': Validators.getPasswordStrengthMessage(password)
      };
    }

    if (!Validators.isValidName(name)) {
      return {'success': false, 'message': 'Invalid name'};
    }

    // Check if user already exists
    final existingUser = await Database.users.findOne(
      where.eq('email', email.toLowerCase()),
    );

    if (existingUser != null) {
      return {'success': false, 'message': 'Email already registered'};
    }

    // Hash password
    final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

    // Create user
    final user = User(
      id: ObjectId(),
      email: email.toLowerCase(),
      passwordHash: passwordHash,
      name: name,
      roles: ['user'], // Default role
      emailVerified: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Insert into database
    await Database.users.insertOne(user.toJson());

    return {
      'success': true,
      'message': 'User registered successfully',
      'user': user.toSafeJson(),
    };
  }

  /// Login user and generate tokens
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // Find user by email
    final userDoc = await Database.users.findOne(
      where.eq('email', email.toLowerCase()),
    );

    if (userDoc == null) {
      return {'success': false, 'message': 'Invalid credentials'};
    }

    final user = User.fromJson(userDoc);

    // Verify password
    final isPasswordValid = BCrypt.checkpw(password, user.passwordHash);
    if (!isPasswordValid) {
      return {'success': false, 'message': 'Invalid credentials'};
    }

    // Generate tokens
    final accessToken = JwtUtils.generateAccessToken(user);
    final refreshToken = JwtUtils.generateRefreshToken(user);

    // Store refresh token in database
    await Database.users.updateOne(
      where.eq('_id', user.id),
      modify.set('refreshToken', refreshToken).set('updatedAt', DateTime.now().toIso8601String()),
    );

    return {
      'success': true,
      'message': 'Login successful',
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toSafeJson(),
    };
  }

  /// Refresh access token using refresh token
  static Future<Map<String, dynamic>> refreshAccessToken(String refreshToken) async {
    // Verify refresh token
    final payload = JwtUtils.verifyRefreshToken(refreshToken);
    if (payload == null) {
      return {'success': false, 'message': 'Invalid or expired refresh token'};
    }

    final userId = payload['userId'] as String;

    // Find user
    final userDoc = await Database.users.findOne(
      where.eq('_id', ObjectId.fromHexString(userId)),
    );

    if (userDoc == null) {
      return {'success': false, 'message': 'User not found'};
    }

    final user = User.fromJson(userDoc);

    // Check if refresh token matches stored token
    if (user.refreshToken != refreshToken) {
      return {'success': false, 'message': 'Invalid refresh token'};
    }

    // Generate new access token
    final newAccessToken = JwtUtils.generateAccessToken(user);

    return {
      'success': true,
      'message': 'Token refreshed successfully',
      'accessToken': newAccessToken,
    };
  }

  /// Logout user (invalidate refresh token)
  static Future<Map<String, dynamic>> logout(String userId) async {
    await Database.users.updateOne(
      where.eq('_id', ObjectId.fromHexString(userId)),
      modify.unset('refreshToken').set('updatedAt', DateTime.now().toIso8601String()),
    );

    return {
      'success': true,
      'message': 'Logout successful',
    };
  }

  /// Get user by ID
  static Future<User?> getUserById(String userId) async {
    final userDoc = await Database.users.findOne(
      where.eq('_id', ObjectId.fromHexString(userId)),
    );

    if (userDoc == null) return null;
    return User.fromJson(userDoc);
  }

  /// Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? name,
  }) async {
    final updates = modify.set('updatedAt', DateTime.now().toIso8601String());

    if (name != null && Validators.isValidName(name)) {
      updates.set('name', name);
    }

    await Database.users.updateOne(
      where.eq('_id', ObjectId.fromHexString(userId)),
      updates,
    );

    final user = await getUserById(userId);

    return {
      'success': true,
      'message': 'Profile updated successfully',
      'user': user?.toSafeJson(),
    };
  }

  /// Change password
  static Future<Map<String, dynamic>> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    // Get user
    final user = await getUserById(userId);
    if (user == null) {
      return {'success': false, 'message': 'User not found'};
    }

    // Verify current password
    final isPasswordValid = BCrypt.checkpw(currentPassword, user.passwordHash);
    if (!isPasswordValid) {
      return {'success': false, 'message': 'Current password is incorrect'};
    }

    // Validate new password
    if (!Validators.isStrongPassword(newPassword)) {
      return {
        'success': false,
        'message': Validators.getPasswordStrengthMessage(newPassword)
      };
    }

    // Hash new password
    final newPasswordHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());

    // Update password and invalidate refresh token (force re-login)
    await Database.users.updateOne(
      where.eq('_id', user.id),
      modify
          .set('passwordHash', newPasswordHash)
          .unset('refreshToken')
          .set('updatedAt', DateTime.now().toIso8601String()),
    );

    return {
      'success': true,
      'message': 'Password changed successfully. Please login again.',
    };
  }
}
