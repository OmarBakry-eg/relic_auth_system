# ✅ Context Property Fix - Summary

## What Was Wrong

The original middleware code used an **incorrect API** for Relic's context properties:

```dart
// ❌ INCORRECT (Old Code)
class AuthUserContext extends ContextProperty<Map<String, dynamic>> {
  const AuthUserContext() : super(#authUser);
}
const authUserContext = AuthUserContext();

// Setting value
final requestWithUser = request.withContext(
  authUserContext.withValue(userContext),
);

// Getting value
final userContext = req.context.get(authUserContext);
```

This approach **doesn't exist in Relic** - it was based on a misunderstanding of the API.

## The Correct Way

According to [Relic's documentation](https://docs.dartrelic.dev/reference/context), context properties work like this:

```dart
// ✅ CORRECT (New Code)
final _authUserProperty = ContextProperty<Map<String, dynamic>>('authUser');

// Setting value
_authUserProperty[request] = {
  'userId': payload['userId'],
  'email': payload['email'],
  'roles': payload['roles'],
};

// Getting value (nullable)
final userContext = _authUserProperty[request];

// Getting value (throws if missing)
final userContext = _authUserProperty.get(request);
```

## What Was Fixed

### 1. `lib/middleware/auth_middleware.dart`

**Changed:**
- Created proper context property: `final _authUserProperty = ContextProperty<Map<String, dynamic>>('authUser')`
- Added extension methods for convenient access
- Fixed setting: `_authUserProperty[request] = {...}`
- Fixed reading: `_authUserProperty[request]`

**Added Extension:**
```dart
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
```

### 2. `lib/controllers/auth_controller.dart`

**Changed:**
- Removed: `req.context.get(authUserContext)`
- Added: `req.userId` (using extension)

**Example:**
```dart
// Before
final userContext = req.context.get(authUserContext);
final userId = userContext['userId'] as String;

// After
final userId = req.userId;  // Much cleaner!
```

### 3. `lib/controllers/resource_controller.dart`

**Changed:**
- All handlers updated to use extension methods
- Code is now much cleaner and type-safe

## How to Use Context Properties Now

### In Your Handlers

```dart
Response myHandler(Request req) {
  // Simple access using extensions
  final userId = req.userId;        // String
  final email = req.userEmail;      // String
  final roles = req.userRoles;      // List<String>
  
  // Full context (nullable)
  final user = req.authUser;        // Map<String, dynamic>?
  
  return Response.ok(
    body: Body.fromJson({
      'userId': userId,
      'email': email,
      'roles': roles,
    }),
  );
}
```

### In Your Middleware

```dart
Middleware myMiddleware() {
  return (Handler handler) {
    return (Request request) async {
      // Set value
      _authUserProperty[request] = {
        'userId': '123',
        'email': 'user@example.com',
        'roles': ['user'],
      };
      
      // Pass to handler
      return handler(request);
    };
  };
}
```

## Key Benefits

1. **Type-Safe**: Extension methods provide strong typing
2. **Cleaner Code**: No more `req.context.get(authUserContext)` boilerplate
3. **IDE Support**: Autocomplete works perfectly
4. **Follows Relic Best Practices**: Matches official documentation
5. **Better Error Messages**: Throws clear errors when context is missing

## Testing the Fix

All your existing API calls work exactly the same! The fix is internal:

```bash
# 1. Login to get token
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "Test123"}'

# 2. Use token (works the same as before!)
curl -X GET http://localhost:8080/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## References

- [Relic Context Properties Docs](https://docs.dartrelic.dev/reference/context)
- [ContextProperty Class API](https://pub.dev/documentation/relic/latest/relic/ContextProperty-class.html)
- [Context Property Example](https://github.com/serverpod/relic/blob/main/packages/examples/context/context_property.dart)

## Migration Guide

If you were using the old incorrect code:

```dart
// OLD ❌
final userContext = req.context.get(authUserContext);
final userId = userContext['userId'];

// NEW ✅
final userId = req.userId;
```

That's it! The extension methods handle everything for you.

---

**Version**: 1.1.0  
**Date**: 2026-02-15  
**Status**: ✅ Fixed and tested
