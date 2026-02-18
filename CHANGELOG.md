# Changelog

## v1.1.0 - Context Property Fix (2026-02-15)

### Fixed
- **Context Property API**: Updated middleware to use correct Relic `ContextProperty` API
  - Changed from incorrect `ContextProperty` subclass to proper global constant pattern
  - Fixed context access from `request.context.get()` to `property[request]`
  - Added convenient extension methods on `Request` for cleaner access

### Changed
- **auth_middleware.dart**: 
  - Created `_authUserProperty` as `final ContextProperty<Map<String, dynamic>>`
  - Added `AuthUserRequest` extension with helpers: `authUser`, `userId`, `userEmail`, `userRoles`
  - Updated `authMiddleware()` to use `_authUserProperty[request] = {...}`
  - Updated `requireRoles()` to use `_authUserProperty[request]`

- **auth_controller.dart**:
  - Replaced `req.context.get(authUserContext)` with `req.userId` extension
  - Simplified all protected endpoints to use extension methods

- **resource_controller.dart**:
  - Replaced `req.context.get(authUserContext)` with extension methods
  - All handlers now use `req.userId`, `req.userEmail`, `req.userRoles`

### Technical Details

**Before (Incorrect):**
```dart
class AuthUserContext extends ContextProperty<Map<String, dynamic>> {
  const AuthUserContext() : super(#authUser);
}
const authUserContext = AuthUserContext();

// Usage
final userContext = req.context.get(authUserContext);
```

**After (Correct):**
```dart
final _authUserProperty = ContextProperty<Map<String, dynamic>>('authUser');

extension AuthUserRequest on Request {
  String get userId => _authUserProperty.get(this)['userId'] as String;
}

// Usage
_authUserProperty[request] = {...};  // Setting
final userId = req.userId;           // Getting
```

### How to Access User Context Now

Use the convenient extension methods:

```dart
// In any handler with authMiddleware applied:
Response myHandler(Request req) {
  // Get user ID (throws if not authenticated)
  final userId = req.userId;
  
  // Get user email (throws if not authenticated)
  final email = req.userEmail;
  
  // Get user roles (throws if not authenticated)
  final roles = req.userRoles;
  
  // Get full user context (returns null if not authenticated)
  final userContext = req.authUser;
  if (userContext != null) {
    // Access data safely
  }
  
  return Response.ok(...);
}
```

### References
- [Relic Context Properties Documentation](https://docs.dartrelic.dev/reference/context)
- [ContextProperty API](https://pub.dev/documentation/relic/latest/relic/ContextProperty-class.html)

---

## v1.0.0 - Initial Release (2026-02-15)

### Added
- Complete authentication system with JWT
- User registration and login
- Token refresh mechanism
- Role-based access control (RBAC)
- Password management
- Profile updates
- MongoDB integration
- Comprehensive tests
- Full documentation
