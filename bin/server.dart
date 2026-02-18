import 'dart:convert';

import 'package:auth_system/config/config.dart';
import 'package:auth_system/config/database.dart';
import 'package:auth_system/controllers/auth_controller.dart';
import 'package:auth_system/controllers/resource_controller.dart';
import 'package:auth_system/middleware/auth_middleware.dart';
import 'package:relic/relic.dart';

void main() async {
  try {
    // Load configuration
    Config.load();

    // Connect to MongoDB
    await Database.connect(Config.mongoUri);

    // Create Relic app
    final app = RelicApp();

    // Apply CORS middleware globally
    app.use('/', corsMiddleware());

    // Apply request logging
    app.use('/', logRequests());

    // ============================================
    // PUBLIC ROUTES (No authentication required)
    // ============================================

    // Health check
    app.get('/', (req) {
      return Response.ok(
        body: Body.fromString(jsonEncode({
          'success': true,
          'message': 'Auth API is running',
          'version': '1.0.0',
          'endpoints': {
            'health': 'GET /',
            'register': 'POST /auth/register',
            'login': 'POST /auth/login',
            'refresh': 'POST /auth/refresh',
            'public': 'GET /api/public/info',
          },
        })),
      );
    });

    // Public info endpoint
    app.get('/api/public/info', ResourceController.getPublicInfo);

    // Auth routes (public)
    app.post('/auth/register', AuthController.register);
    app.post('/auth/login', AuthController.login);
    app.post('/auth/refresh', AuthController.refresh);

    // ============================================
    // PROTECTED ROUTES (Authentication required)
    // ============================================

    // Apply auth middleware to all /auth/* routes (except register, login, refresh)
    app.use('/auth/logout', authMiddleware());
    app.use('/auth/me', authMiddleware());
    app.use('/auth/profile', authMiddleware());
    app.use('/auth/change-password', authMiddleware());

    // Protected auth routes
    app.post('/auth/logout', AuthController.logout);
    app.get('/auth/me', AuthController.getCurrentUser);
    app.put('/auth/profile', AuthController.updateProfile);
    app.put('/auth/change-password', AuthController.changePassword);

    // Apply auth middleware to all /api/* routes (except public)
    app.use('/api/dashboard', authMiddleware());

    // User dashboard (any authenticated user)
    app.get('/api/dashboard', ResourceController.getDashboard);

    // ============================================
    // ROLE-BASED AUTHORIZATION EXAMPLES
    // ============================================

    // Admin-only routes
    app.use('/api/admin/**', authMiddleware());
    app.use('/api/admin/**', requireRoles(['admin']));
    app.get('/api/admin/users', ResourceController.adminGetUsers);

    // Moderator or Admin routes
    app.use('/api/moderator/**', authMiddleware());
    app.use('/api/moderator/**', requireRoles(['moderator', 'admin']));
    app.get('/api/moderator/reports', ResourceController.moderatorGetReports);

    // 404 handler
    app.fallback = respondWith(
      (_) => Response.notFound(
        body: Body.fromString(jsonEncode({
          'success': false,
          'message': 'Endpoint not found',
        })),
      ),
    );

    // Start server
    final RelicServer server = await app.serve(port: Config.port);

    print('\n🚀 Server started successfully!');
    print('📡 Listening on http://localhost:${server.port}');
    print('\n📚 Available endpoints:');
    print('   Public:');
    print('   - GET  /                      (Health check)');
    print('   - GET  /api/public/info       (Public info)');
    print('   - POST /auth/register         (Register user)');
    print('   - POST /auth/login            (Login user)');
    print('   - POST /auth/refresh          (Refresh token)');
    print('\n   Protected (requires authentication):');
    print('   - POST /auth/logout           (Logout user)');
    print('   - GET  /auth/me               (Get current user)');
    print('   - PUT  /auth/profile          (Update profile)');
    print('   - PUT  /auth/change-password  (Change password)');
    print('   - GET  /api/dashboard         (User dashboard)');
    print('\n   Admin only:');
    print('   - GET  /api/admin/users       (Get all users)');
    print('\n   Moderator/Admin:');
    print('   - GET  /api/moderator/reports (Get reports)');
    print('\n✅ Auth system ready!\n');
  } catch (e, stackTrace) {
    print('❌ Failed to start server: $e');
    print(stackTrace);
  }
}
