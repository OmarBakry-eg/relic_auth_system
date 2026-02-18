import 'dart:convert';

import 'package:relic/relic.dart';
import '../middleware/auth_middleware.dart';

/// Example protected resource controllers demonstrating authorization
class ResourceController {
  /// GET /api/dashboard - Accessible by all authenticated users
  static Response getDashboard(Request req) {
    // Use extension methods to access user data
    return Response.ok(
      body: Body.fromString(jsonEncode({
        'success': true,
        'message': 'Welcome to your dashboard!',
        'user': {
          'id': req.userId,
          'email': req.userEmail,
          'roles': req.userRoles,
        },
        'data': {
          'stats': {
            'totalUsers': 1250,
            'activeToday': 87,
            'newThisWeek': 43,
          },
        },
      })),
    );
  }

  /// GET /api/admin/users - Admin only endpoint
  static Response adminGetUsers(Request req) {
    // Use extension methods to access user data
    return Response.ok(
      body: Body.fromString(jsonEncode({
        'success': true,
        'message': 'Admin access granted',
        'requestedBy': {
          'id': req.userId,
          'email': req.userEmail,
          'roles': req.userRoles,
        },
        'users': [
          {
            'id': '1',
            'name': 'John Doe',
            'email': 'john@example.com',
            'role': 'user',
          },
          {
            'id': '2',
            'name': 'Jane Smith',
            'email': 'jane@example.com',
            'role': 'admin',
          },
        ],
      })),
    );
  }

  /// GET /api/moderator/reports - Moderator/Admin endpoint
  static Response moderatorGetReports(Request req) {
    // Use extension methods to access user data
    return Response.ok(
      body: Body.fromString(jsonEncode({
        'success': true,
        'message': 'Moderator access granted',
        'requestedBy': {
          'id': req.userId,
          'email': req.userEmail,
          'roles': req.userRoles,
        },
        'reports': [
          {
            'id': 'R1',
            'type': 'spam',
            'status': 'pending',
            'reportedBy': 'user123',
          },
          {
            'id': 'R2',
            'type': 'harassment',
            'status': 'resolved',
            'reportedBy': 'user456',
          },
        ],
      })),
    );
  }

  /// GET /api/public/info - Public endpoint (no auth required)
  static Response getPublicInfo(Request req) {
    return Response.ok(
      body: Body.fromString(jsonEncode({
        'success': true,
        'message': 'This is a public endpoint',
        'data': {
          'apiVersion': '1.0.0',
          'endpoints': {
            'auth': '/auth/*',
            'protected': '/api/*',
            'public': '/api/public/*',
          },
        },
      }),
    ));
  }
}
