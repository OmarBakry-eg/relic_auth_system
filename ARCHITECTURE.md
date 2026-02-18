# 🏗️ Architecture Documentation

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        Client Application                    │
│                  (Web, Mobile, Desktop)                      │
└────────────────┬────────────────────────────────────────────┘
                 │
                 │ HTTP/HTTPS
                 │
┌────────────────▼────────────────────────────────────────────┐
│                     Relic Web Server                         │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Middleware Pipeline                     │  │
│  │  ┌─────────┐  ┌─────────┐  ┌──────────────┐        │  │
│  │  │  CORS   │→ │   Log   │→ │     Auth     │        │  │
│  │  │         │  │ Requests│  │  Middleware  │        │  │
│  │  └─────────┘  └─────────┘  └──────────────┘        │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                  Route Handlers                      │  │
│  │                                                      │  │
│  │  Public Routes:                                      │  │
│  │  • POST /auth/register                              │  │
│  │  • POST /auth/login                                 │  │
│  │  • POST /auth/refresh                               │  │
│  │                                                      │  │
│  │  Protected Routes (Auth Required):                  │  │
│  │  • GET  /auth/me                                    │  │
│  │  • POST /auth/logout                                │  │
│  │  • PUT  /auth/profile                               │  │
│  │  • GET  /api/dashboard                              │  │
│  │                                                      │  │
│  │  Admin Routes (Admin Role):                         │  │
│  │  • GET  /api/admin/users                            │  │
│  │                                                      │  │
│  │  Moderator Routes (Moderator/Admin):                │  │
│  │  • GET  /api/moderator/reports                      │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────┬────────────────────────────────────────────┘
                 │
                 │
┌────────────────▼────────────────────────────────────────────┐
│                   Business Logic Layer                       │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              AuthService                             │  │
│  │  • register()                                        │  │
│  │  • login()                                           │  │
│  │  • refreshAccessToken()                              │  │
│  │  • logout()                                          │  │
│  │  • getUserById()                                     │  │
│  │  • updateProfile()                                   │  │
│  │  • changePassword()                                  │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Utilities                               │  │
│  │  • JwtUtils (token generation/verification)         │  │
│  │  • Validators (input validation)                     │  │
│  │  • BCrypt (password hashing)                         │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────┬────────────────────────────────────────────┘
                 │
                 │
┌────────────────▼────────────────────────────────────────────┐
│                     Database Layer                           │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                  MongoDB                             │  │
│  │                                                      │  │
│  │  Collection: users                                   │  │
│  │  {                                                   │  │
│  │    _id: ObjectId                                     │  │
│  │    email: String (unique, indexed)                   │  │
│  │    passwordHash: String                              │  │
│  │    name: String                                      │  │
│  │    roles: [String]                                   │  │
│  │    emailVerified: Boolean                            │  │
│  │    createdAt: ISODate                                │  │
│  │    updatedAt: ISODate                                │  │
│  │    refreshToken: String (optional)                   │  │
│  │  }                                                   │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Authentication Flow

```
┌──────────┐                                    ┌──────────┐
│  Client  │                                    │  Server  │
└─────┬────┘                                    └────┬─────┘
      │                                              │
      │  1. POST /auth/register                     │
      │  {email, password, name}                    │
      ├─────────────────────────────────────────────>│
      │                                              │
      │                                         2. Validate input
      │                                         3. Hash password
      │                                         4. Save to DB
      │                                              │
      │  5. {success, user}                         │
      │<─────────────────────────────────────────────┤
      │                                              │
      │  6. POST /auth/login                        │
      │  {email, password}                          │
      ├─────────────────────────────────────────────>│
      │                                              │
      │                                         7. Find user
      │                                         8. Verify password
      │                                         9. Generate tokens
      │                                         10. Store refresh token
      │                                              │
      │  11. {accessToken, refreshToken, user}      │
      │<─────────────────────────────────────────────┤
      │                                              │
      │  12. GET /api/dashboard                     │
      │  Authorization: Bearer <accessToken>        │
      ├─────────────────────────────────────────────>│
      │                                              │
      │                                         13. Verify JWT
      │                                         14. Extract user info
      │                                         15. Check permissions
      │                                              │
      │  16. {success, data}                        │
      │<─────────────────────────────────────────────┤
      │                                              │
```

## Token Refresh Flow

```
┌──────────┐                                    ┌──────────┐
│  Client  │                                    │  Server  │
└─────┬────┘                                    └────┬─────┘
      │                                              │
      │  Access token expires after 15 min          │
      │                                              │
      │  1. POST /api/dashboard                     │
      │  Authorization: Bearer <expired-token>      │
      ├─────────────────────────────────────────────>│
      │                                              │
      │                                         2. Verify token
      │                                         3. Token expired!
      │                                              │
      │  4. {error: "Token expired"}                │
      │<─────────────────────────────────────────────┤
      │                                              │
      │  5. POST /auth/refresh                      │
      │  {refreshToken}                             │
      ├─────────────────────────────────────────────>│
      │                                              │
      │                                         6. Verify refresh token
      │                                         7. Check DB for match
      │                                         8. Generate new access token
      │                                              │
      │  9. {accessToken}                           │
      │<─────────────────────────────────────────────┤
      │                                              │
      │  10. Retry original request                 │
      │  Authorization: Bearer <new-token>          │
      ├─────────────────────────────────────────────>│
      │                                              │
      │  11. {success, data}                        │
      │<─────────────────────────────────────────────┤
```

## Authorization Flow (RBAC)

```
┌──────────┐                                    ┌──────────┐
│  Client  │                                    │  Server  │
│  (User)  │                                    │          │
└─────┬────┘                                    └────┬─────┘
      │                                              │
      │  1. GET /api/admin/users                    │
      │  Authorization: Bearer <user-token>         │
      ├─────────────────────────────────────────────>│
      │                                              │
      │                                         2. Auth Middleware
      │                                            - Verify token ✓
      │                                            - Extract roles: ["user"]
      │                                              │
      │                                         3. Role Middleware
      │                                            - Check required roles: ["admin"]
      │                                            - User has "user" only
      │                                            - Access DENIED ✗
      │                                              │
      │  4. 403 Forbidden                           │
      │  {error: "Insufficient permissions"}        │
      │<─────────────────────────────────────────────┤
      │                                              │

┌──────────┐                                    ┌──────────┐
│  Client  │                                    │  Server  │
│ (Admin)  │                                    │          │
└─────┬────┘                                    └────┬─────┘
      │                                              │
      │  1. GET /api/admin/users                    │
      │  Authorization: Bearer <admin-token>        │
      ├─────────────────────────────────────────────>│
      │                                              │
      │                                         2. Auth Middleware
      │                                            - Verify token ✓
      │                                            - Extract roles: ["user", "admin"]
      │                                              │
      │                                         3. Role Middleware
      │                                            - Check required roles: ["admin"]
      │                                            - User has "admin"
      │                                            - Access GRANTED ✓
      │                                              │
      │  4. 200 OK                                  │
      │  {success: true, users: [...]}              │
      │<─────────────────────────────────────────────┤
```

## Security Layers

```
┌─────────────────────────────────────────────────────────┐
│                    Security Layers                       │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Layer 1: Input Validation                              │
│  • Email format validation                              │
│  • Password strength requirements                       │
│  • Data sanitization                                    │
│                                                          │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Layer 2: Authentication                                │
│  • Password hashing with bcrypt                         │
│  • JWT token generation                                 │
│  • Token expiration (15min access, 7day refresh)        │
│  • Secure token storage                                 │
│                                                          │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Layer 3: Authorization                                 │
│  • Role-based access control (RBAC)                     │
│  • Route-level permissions                              │
│  • Context-based user verification                      │
│                                                          │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Layer 4: Transport Security                            │
│  • CORS middleware                                      │
│  • HTTPS recommended                                    │
│  • Security headers                                     │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Project Structure Deep Dive

```
auth_system/
│
├── bin/
│   └── server.dart              # Entry point - initializes app
│                                 # Sets up routes and middleware
│                                 # Starts HTTP server
│
├── lib/
│   │
│   ├── config/
│   │   ├── config.dart          # Environment variables loader
│   │   │                        # JWT secrets, port, etc.
│   │   │
│   │   └── database.dart        # MongoDB connection manager
│   │                            # Index creation
│   │                            # Collection accessors
│   │
│   ├── models/
│   │   └── user.dart            # User data model
│   │                            # JSON serialization
│   │                            # Safe data transformation
│   │
│   ├── services/
│   │   └── auth_service.dart    # Business logic layer
│   │                            # Register, login, logout
│   │                            # Token management
│   │                            # Profile operations
│   │
│   ├── controllers/
│   │   ├── auth_controller.dart       # HTTP request handlers
│   │   │                              # Input parsing
│   │   │                              # Response formatting
│   │   │
│   │   └── resource_controller.dart   # Protected endpoints
│   │                                  # Demo authorization
│   │
│   ├── middleware/
│   │   └── auth_middleware.dart       # Request interceptors
│   │                                  # JWT verification
│   │                                  # Role checking
│   │                                  # CORS handling
│   │
│   └── utils/
│       ├── jwt_utils.dart       # Token generation/verification
│       │                        # JWT signing and parsing
│       │
│       └── validators.dart      # Input validation
│                                # Email/password/name checks
│
├── test/
│   └── auth_test.dart           # Unit tests
│                                # Service tests
│                                # Model tests
│
├── .env                         # Environment configuration
├── pubspec.yaml                 # Dependencies
├── README.md                    # Full documentation
├── QUICKSTART.md                # Getting started guide
├── ARCHITECTURE.md              # This file
├── test_api.sh                  # API testing script
├── Dockerfile                   # Container image
└── docker-compose.yml           # Multi-container setup
```

## Data Flow

### 1. Registration Flow
```
Client Request
    ↓
AuthController.register
    ↓
Validate input (Validators)
    ↓
AuthService.register
    ↓
Hash password (BCrypt)
    ↓
Save to Database (MongoDB)
    ↓
Return success response
```

### 2. Login Flow
```
Client Request
    ↓
AuthController.login
    ↓
AuthService.login
    ↓
Find user in Database
    ↓
Verify password (BCrypt)
    ↓
Generate tokens (JwtUtils)
    ↓
Store refresh token in Database
    ↓
Return tokens + user data
```

### 3. Protected Request Flow
```
Client Request + Token
    ↓
CORS Middleware
    ↓
Log Middleware
    ↓
Auth Middleware
    ├─ Verify JWT (JwtUtils)
    ├─ Extract user info
    └─ Add to request context
    ↓
Role Middleware (if needed)
    ├─ Check user roles
    └─ Verify permissions
    ↓
Route Handler
    ├─ Access user from context
    └─ Execute business logic
    ↓
Return response
```

## Performance Considerations

### Relic Framework Benefits
- **Trie-based routing**: O(segments) lookup time
- **Type safety**: Compile-time checks
- **Zero-copy parsing**: Efficient request handling
- **LRU caching**: Fast repeated lookups

### Database Optimization
- **Indexed email field**: Fast user lookups
- **Connection pooling**: Reuse connections
- **Selective field projection**: Reduce data transfer

### Token Strategy
- **Short-lived access tokens**: 15 minutes
  - Reduces impact of token theft
  - Forces periodic re-validation
  
- **Long-lived refresh tokens**: 7 days
  - Better user experience
  - Stored securely in database
  - Can be revoked instantly

## Scalability

### Horizontal Scaling
```
Load Balancer
    ├─ Server Instance 1
    ├─ Server Instance 2
    └─ Server Instance N
            ↓
    Shared MongoDB
```

### Stateless Design
- No session storage in memory
- All state in JWT or database
- Can add/remove servers freely

### Caching Opportunities
- User data caching
- Role definitions caching
- Public endpoint responses

## Security Best Practices Implemented

✅ Password hashing with bcrypt (salt rounds)
✅ JWT with expiration
✅ Refresh token rotation on use
✅ Input validation and sanitization
✅ CORS protection
✅ Type-safe request handling
✅ Secure password requirements
✅ Token invalidation on logout
✅ Role-based access control
✅ No sensitive data in logs

## Future Enhancements

### High Priority
- [ ] Rate limiting
- [ ] Email verification
- [ ] Password reset via email
- [ ] Account lockout after failed attempts

### Medium Priority
- [ ] Two-factor authentication (2FA)
- [ ] OAuth 2.0 providers (Google, GitHub)
- [ ] Session management
- [ ] Audit logging

### Nice to Have
- [ ] IP-based restrictions
- [ ] Device fingerprinting
- [ ] Anomaly detection
- [ ] GraphQL API option
