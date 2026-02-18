import 'package:dotenv/dotenv.dart';

/// Application configuration from environment variables
class Config {
  static late String mongoUri;
  static late String jwtSecret;
  static late String jwtRefreshSecret;
  static late int port;

  /// Load configuration from .env file
  static void load() {
    final env = DotEnv()..load();

    mongoUri = env['MONGODB_URI'] ?? 'mongodb://localhost:27017/auth_db';
    jwtSecret = env['JWT_SECRET'] ?? 'default-secret-change-me';
    jwtRefreshSecret = env['JWT_REFRESH_SECRET'] ?? 'default-refresh-secret-change-me';
    port = int.tryParse(env['PORT'] ?? '8080') ?? 8080;

    print('✅ Configuration loaded');
  }
}
