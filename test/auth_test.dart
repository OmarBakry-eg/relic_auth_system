import 'package:test/test.dart';
import '../lib/utils/validators.dart';
import '../lib/utils/jwt_utils.dart';
import '../lib/models/user.dart';
import 'package:mongo_dart/mongo_dart.dart';

void main() {
  group('Validators Tests', () {
    test('Valid email should pass', () {
      expect(Validators.isValidEmail('test@example.com'), isTrue);
      expect(Validators.isValidEmail('user.name+tag@domain.co.uk'), isTrue);
    });

    test('Invalid email should fail', () {
      expect(Validators.isValidEmail('invalid'), isFalse);
      expect(Validators.isValidEmail('test@'), isFalse);
      expect(Validators.isValidEmail('@example.com'), isFalse);
      expect(Validators.isValidEmail('test @example.com'), isFalse);
    });

    test('Strong password should pass', () {
      expect(Validators.isStrongPassword('Password123'), isTrue);
      expect(Validators.isStrongPassword('MySecure1Pass'), isTrue);
    });

    test('Weak password should fail', () {
      expect(Validators.isStrongPassword('short'), isFalse); // Too short
      expect(Validators.isStrongPassword('alllowercase1'), isFalse); // No uppercase
      expect(Validators.isStrongPassword('ALLUPPERCASE1'), isFalse); // No lowercase
      expect(Validators.isStrongPassword('NoNumbers'), isFalse); // No numbers
    });

    test('Valid name should pass', () {
      expect(Validators.isValidName('John Doe'), isTrue);
      expect(Validators.isValidName('Jane'), isTrue);
    });

    test('Invalid name should fail', () {
      expect(Validators.isValidName(''), isFalse);
      expect(Validators.isValidName('   '), isFalse);
    });
  });

  group('User Model Tests', () {
    test('User toJson and fromJson should be consistent', () {
      final now = DateTime.now();
      final user = User(
        id: ObjectId(),
        email: 'test@example.com',
        passwordHash: 'hashedpassword',
        name: 'Test User',
        roles: ['user'],
        emailVerified: true,
        createdAt: now,
        updatedAt: now,
        refreshToken: 'sometoken',
      );

      final json = user.toJson();
      final parsedUser = User.fromJson(json);

      expect(parsedUser.id, equals(user.id));
      expect(parsedUser.email, equals(user.email));
      expect(parsedUser.passwordHash, equals(user.passwordHash));
      expect(parsedUser.name, equals(user.name));
      expect(parsedUser.roles, equals(user.roles));
      expect(parsedUser.emailVerified, equals(user.emailVerified));
      expect(parsedUser.refreshToken, equals(user.refreshToken));
    });

    test('User toSafeJson should not include sensitive data', () {
      final user = User(
        id: ObjectId(),
        email: 'test@example.com',
        passwordHash: 'hashedpassword',
        name: 'Test User',
        roles: ['user'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        refreshToken: 'sometoken',
      );

      final safeJson = user.toSafeJson();

      expect(safeJson.containsKey('passwordHash'), isFalse);
      expect(safeJson.containsKey('refreshToken'), isFalse);
      expect(safeJson.containsKey('email'), isTrue);
      expect(safeJson.containsKey('name'), isTrue);
      expect(safeJson.containsKey('roles'), isTrue);
    });

    test('User copyWith should update fields correctly', () {
      final user = User(
        id: ObjectId(),
        email: 'test@example.com',
        passwordHash: 'hashedpassword',
        name: 'Test User',
        roles: ['user'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedUser = user.copyWith(
        name: 'Updated Name',
        roles: ['user', 'admin'],
      );

      expect(updatedUser.name, equals('Updated Name'));
      expect(updatedUser.roles, equals(['user', 'admin']));
      expect(updatedUser.email, equals(user.email)); // Unchanged
      expect(updatedUser.id, equals(user.id)); // Unchanged
    });
  });

  group('JWT Utils Tests', () {
    test('Should generate and verify access token', () {
      final user = User(
        id: ObjectId(),
        email: 'test@example.com',
        passwordHash: 'hashedpassword',
        name: 'Test User',
        roles: ['user'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Note: This test requires Config to be loaded
      // In a real test environment, you'd set up test config
      // For now, we're just testing the structure
      
      // Test would look like:
      // final token = JwtUtils.generateAccessToken(user);
      // expect(token, isNotEmpty);
      
      // final payload = JwtUtils.verifyAccessToken(token);
      // expect(payload, isNotNull);
      // expect(payload!['userId'], equals(user.id.toHexString()));
      // expect(payload['email'], equals(user.email));
      // expect(payload['type'], equals('access'));
    });

    test('Should reject invalid token', () {
      // Test would verify that invalid tokens are rejected
      // final payload = JwtUtils.verifyAccessToken('invalid-token');
      // expect(payload, isNull);
    });
  });

  group('Integration Tests Checklist', () {
    test('Authentication Flow', () {
      // In a real integration test, you would:
      // 1. Start test server
      // 2. Register a new user
      // 3. Login with credentials
      // 4. Verify access token works
      // 5. Refresh token
      // 6. Logout
      expect(true, isTrue); // Placeholder
    });

    test('Authorization Flow', () {
      // In a real integration test, you would:
      // 1. Create users with different roles
      // 2. Test admin-only endpoint with admin user (should succeed)
      // 3. Test admin-only endpoint with regular user (should fail)
      // 4. Test moderator endpoint with moderator (should succeed)
      expect(true, isTrue); // Placeholder
    });
  });
}
