import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../config/config.dart';
import '../models/user.dart';

/// JWT token utilities for authentication
class JwtUtils {
  /// Generate access token (short-lived, 15 minutes)
  static String generateAccessToken(User user) {
    final jwt = JWT({
      'userId': user.id.toHexString(),
      'email': user.email,
      'roles': user.roles,
      'type': 'access',
    });

    return jwt.sign(
      SecretKey(Config.jwtSecret),
      expiresIn: Duration(minutes: 15),
    );
  }

  /// Generate refresh token (long-lived, 7 days)
  static String generateRefreshToken(User user) {
    final jwt = JWT({
      'userId': user.id.toHexString(),
      'email': user.email,
      'type': 'refresh',
    });

    return jwt.sign(
      SecretKey(Config.jwtRefreshSecret),
      expiresIn: Duration(days: 7),
    );
  }

  /// Verify and decode access token
  static Map<String, dynamic>? verifyAccessToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(Config.jwtSecret));
      final payload = jwt.payload as Map<String, dynamic>;
      
      // Check token type
      if (payload['type'] != 'access') {
        return null;
      }
      
      return payload;
    } on JWTExpiredException {
      print('Token expired');
      return null;
    } on JWTException catch (e) {
      print('JWT verification failed: $e');
      return null;
    }
  }

  /// Verify and decode refresh token
  static Map<String, dynamic>? verifyRefreshToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(Config.jwtRefreshSecret));
      final payload = jwt.payload as Map<String, dynamic>;
      
      // Check token type
      if (payload['type'] != 'refresh') {
        return null;
      }
      
      return payload;
    } on JWTExpiredException {
      print('Refresh token expired');
      return null;
    } on JWTException catch (e) {
      print('JWT verification failed: $e');
      return null;
    }
  }
}
