import 'dart:convert';
import 'package:relic/relic.dart';
import '../services/auth_service.dart';
import '../middleware/auth_middleware.dart';
import '../utils/extenstions.dart';

/// Authentication route handlers
class AuthController {
  /// POST /auth/register - Register a new user
  static Future<Response> register(Request req) async {
    try {
      final body = await req.bodyAsJson;

      final email = body['email'] as String?;
      final password = body['password'] as String?;
      final name = body['name'] as String?;

      if (email == null || password == null || name == null) {
        return Response.badRequest(
          body: Body.fromString(jsonEncode({
            'success': false,
            'message': 'Email, password, and name are required',
          })),
        );
      }

      final result = await AuthService.register(
        email: email,
        password: password,
        name: name,
      );

      if (result['success']) {
        return Response(
          201,
          body: Body.fromString(jsonEncode(result)),
        );
      } else {
        return Response.badRequest(
          body: Body.fromString(jsonEncode(result)),
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: Body.fromString(jsonEncode({
          'success': false,
          'message': 'Registration failed: $e',
        })),
      );
    }
  }

  /// POST /auth/login - Login user
  static Future<Response> login(Request req) async {
    try {
      final body = await req.bodyAsJson;

      final email = body['email'] as String?;
      final password = body['password'] as String?;

      if (email == null || password == null) {
        return Response.badRequest(
          body: Body.fromString(jsonEncode({
            'success': false,
            'message': 'Email and password are required',
          })),
        );
      }

      final result = await AuthService.login(
        email: email,
        password: password,
      );

      if (result['success']) {
        return Response.ok(
          body: Body.fromString(jsonEncode(result)),
        );
      } else {
        return Response.unauthorized(
          body: Body.fromString(jsonEncode(result)),
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: Body.fromString(jsonEncode({
          'success': false,
          'message': 'Login failed: $e',
        })),
      );
    }
  }

  /// POST /auth/refresh - Refresh access token
  static Future<Response> refresh(Request req) async {
    try {
      final body = await req.bodyAsJson;

      final refreshToken = body['refreshToken'] as String?;

      if (refreshToken == null) {
        return Response.badRequest(
          body: Body.fromString(jsonEncode({
            'success': false,
            'message': 'Refresh token is required',
          })),
        );
      }

      final result = await AuthService.refreshAccessToken(refreshToken);

      if (result['success']) {
        return Response.ok(
          body: Body.fromString(jsonEncode(result)),
        );
      } else {
        return Response.unauthorized(
          body: Body.fromString(jsonEncode(result)),
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: Body.fromString(jsonEncode({
          'success': false,
          'message': 'Token refresh failed: $e',
        })),
      );
    }
  }

  /// POST /auth/logout - Logout user
  static Future<Response> logout(Request req) async {
    try {
      // Use extension method to get user ID
      final userId = req.userId;
      final result = await AuthService.logout(userId);

      return Response.ok(
        body: Body.fromString(jsonEncode(result)),
      );
    } catch (e) {
      return Response.internalServerError(
        body: Body.fromString(jsonEncode({
          'success': false,
          'message': 'Logout failed: $e',
        })),
      );
    }
  }

  /// GET /auth/me - Get current user info
  static Future<Response> getCurrentUser(Request req) async {
    try {
      // Use extension method to get user ID
      final userId = req.userId;
      final user = await AuthService.getUserById(userId);

      if (user == null) {
        return Response.notFound(
          body: Body.fromString(jsonEncode({
            'success': false,
            'message': 'User not found',
          })),
        );
      }

      return Response.ok(
        body: Body.fromString(jsonEncode({
          'success': true,
          'user': user.toSafeJson(),
        })),
      );
    } catch (e) {
      return Response.internalServerError(
        body: Body.fromString(jsonEncode({
          'success': false,
          'message': 'Failed to get user: $e',
        })),
      );
    }
  }

  /// PUT /auth/profile - Update user profile
  static Future<Response> updateProfile(Request req) async {
    try {
      // Use extension method to get user ID
      final userId = req.userId;
      final body = await req.bodyAsJson;
      final name = body['name'] as String?;

      final result = await AuthService.updateProfile(
        userId: userId,
        name: name,
      );

      return Response.ok(
        body: Body.fromString(jsonEncode(result)),
      );
    } catch (e) {
      return Response.internalServerError(
        body: Body.fromString(jsonEncode({
          'success': false,
          'message': 'Profile update failed: $e',
        })  ),
      );
    }
  }

  /// PUT /auth/change-password - Change password
  static Future<Response> changePassword(Request req) async {
    try {
      // Use extension method to get user ID
      final userId = req.userId;
      final body = await req.bodyAsJson;

      final currentPassword = body['currentPassword'] as String?;
      final newPassword = body['newPassword'] as String?;

      if (currentPassword == null || newPassword == null) {
        return Response.badRequest(
          body: Body.fromString(jsonEncode({
            'success': false,
            'message': 'Current password and new password are required',
          })),
        );
      }

      final result = await AuthService.changePassword(
        userId: userId,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (result['success']) {
        return Response.ok(
          body: Body.fromString(jsonEncode(result)),
        );
      } else {
        return Response.badRequest(
          body: Body.fromString(jsonEncode(result)),
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: Body.fromString(jsonEncode({
          'success': false,
          'message': 'Password change failed: $e',
        })),
      );
    }
  }
}
