import 'dart:convert';

import 'package:relic/relic.dart';
import '../utils/jwt_utils.dart';
import '../services/auth_service.dart';

/// Context property for authenticated user data
final _authUserProperty = ContextProperty<Map<String, dynamic>>('authUser');

/// Extension to provide convenient access to authenticated user
extension AuthUserRequest on Request {
  /// Get authenticated user data (returns null if not authenticated)
  Map<String, dynamic>? get authUser => _authUserProperty[this];

  /// Get authenticated user ID (throws if not authenticated)
  String get userId => _authUserProperty.get(this)['userId'] as String;

  /// Get authenticated user email (throws if not authenticated)
  String get userEmail => _authUserProperty.get(this)['email'] as String;

  /// Get authenticated user roles (throws if not authenticated)
  List<String> get userRoles =>
      List<String>.from(_authUserProperty.get(this)['roles'] as List);
}

/// Authentication middleware - verifies JWT token
Middleware authMiddleware() {
  return (Handler handler) {
    return (Request request) async {
      // Get Authorization header
      final authHeader = request.headers.authorization;

      if (authHeader == null) {
        return Response.unauthorized(
          body: Body.fromString(jsonEncode({
            'success': false,
            'message': 'Authorization header missing',
          })),
        );
      }

      // Extract token (format: "Bearer <token>")
      final parts = authHeader.headerValue.split(' ');
      if (parts.length != 2 || parts[0] != 'Bearer') {
        return Response.unauthorized(
          body: Body.fromString(jsonEncode({
            'success': false,
            'message': 'Invalid authorization format. Use: Bearer <token>',
          })),
        );
      }

      final token = parts[1];

      // Verify token
      final payload = JwtUtils.verifyAccessToken(token);
      if (payload == null) {
        return Response.unauthorized(
          body: Body.fromString(jsonEncode({
            'success': false,
            'message': 'Invalid or expired token',
          })),
        );
      }

      // Verify user still exists
      final user = await AuthService.getUserById(payload['userId']);
      if (user == null) {
        return Response.unauthorized(
          body: Body.fromString(jsonEncode({
            'success': false,
            'message': 'User not found',
          })),
        );
      }

      // Add user info to request context using the property
      _authUserProperty[request] = {
        'userId': payload['userId'],
        'email': payload['email'],
        'roles': payload['roles'],
      };

      return handler(request);
    };
  };
}

/// Role-based authorization middleware - checks if user has required roles
Middleware requireRoles(List<String> requiredRoles) {
  return (Handler handler) {
    return (Request request) {
      // Get user data from context
      final userContext = _authUserProperty[request];

      if (userContext == null) {
        return Response.forbidden(
          body: Body.fromString(jsonEncode({
            'success': false,
            'message': 'Authentication required',
          })),
        );
      }

      final userRoles = List<String>.from(userContext['roles'] ?? []);

      // Check if user has any of the required roles
      final hasRequiredRole = requiredRoles.any(
        (role) => userRoles.contains(role),
      );

      if (!hasRequiredRole) {
        return Response.forbidden(
          body: Body.fromString(jsonEncode({
            'success': false,
            'message':
                'Insufficient permissions. Required roles: ${requiredRoles.join(", ")}',
          })),
        );
      }

      return handler(request);
    };
  };
}
/// CORS middleware for handling cross-origin requests
Middleware corsMiddleware() {
  return (Handler handler) {
    return (Request request) async {
      // Handle preflight requests
      if (request.method == Method.options) {
        return Response.ok(
          headers: Headers.build((header) {
            header['Access-Control-Allow-Origin'] = ['*'];
            header['Access-Control-Allow-Methods'] = ['GET, POST, PUT, DELETE, PATCH, OPTIONS'];
            header['Access-Control-Allow-Headers'] = ['Content-Type, Authorization'];
            header['Access-Control-Max-Age'] = ['86400'];
          }),
        );
      }

      // Process actual request
      final result = await handler(request);

      // Only add CORS headers to Response results (not Forward)
      if (result is Response) {
        return Response(
          result.statusCode,
          body: result.body,
          headers: Headers.build((header) {
            // Copy all existing headers
            for (final entry in result.headers.entries) {
              header[entry.key] = entry.value;
            }
            // Add/override CORS headers
            header['Access-Control-Allow-Origin'] = ['*'];
            header['Access-Control-Allow-Methods'] = ['GET, POST, PUT, DELETE, PATCH, OPTIONS'];
            header['Access-Control-Allow-Headers'] = ['Content-Type, Authorization'];
          }),
        );
      }

      // Return other result types (like Forward) unchanged
      return result;
    };
  };
}