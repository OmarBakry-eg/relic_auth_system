import 'package:mongo_dart/mongo_dart.dart';

/// Database configuration and connection management
class Database {
  static late Db _db;
  static late DbCollection _usersCollection;

  /// Connect to MongoDB
  static Future<void> connect(String uri) async {
    _db = await Db.create(uri);
    await _db.open();
    
    _usersCollection = _db.collection('users');
    
    // Create indexes
    await _createIndexes();
    
    print('✅ Connected to MongoDB');
  }

  /// Create database indexes for performance
  static Future<void> _createIndexes() async {
    // Unique index on email
    await _usersCollection.createIndex(
      key: 'email',
      unique: true,
    );
    
    print('✅ Database indexes created');
  }

  /// Get users collection
  static DbCollection get users => _usersCollection;

  /// Close database connection
  static Future<void> close() async {
    await _db.close();
    print('✅ Database connection closed');
  }
}
