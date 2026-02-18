# Authentication System with [Relic](https://github.com/serverpod/relic) & MongoDB

A complete, production-ready authentication and authorization system built with [Relic](https://github.com/serverpod/relic) (modern Dart web framework) and MongoDB.

## 🎯 Features

### Authentication
- ✅ User Registration with validation
- ✅ User Login with JWT tokens
- ✅ Access Token (15 min expiry) & Refresh Token (7 days)
- ✅ Token Refresh mechanism
- ✅ Secure Password Hashing (bcrypt)
- ✅ Logout functionality

### Authorization
- ✅ Role-Based Access Control (RBAC)
- ✅ JWT Middleware for protected routes
- ✅ Custom role requirements per endpoint
- ✅ User context in requests

### Security
- ✅ Strong password validation
- ✅ Email format validation
- ✅ CORS middleware
- ✅ Secure token storage
- ✅ Password change with verification

### Profile Management
- ✅ Get current user profile
- ✅ Update profile information
- ✅ Change password

## 📁 Project Structure

```
auth_system/
├── bin/
│   └── server.dart              # Main application entry point
├── lib/
│   ├── config/
│   │   ├── config.dart          # Environment configuration
│   │   └── database.dart        # MongoDB connection
│   ├── controllers/
│   │   ├── auth_controller.dart # Auth route handlers
│   │   └── resource_controller.dart # Protected resource handlers
│   ├── middleware/
│   │   └── auth_middleware.dart # JWT auth & RBAC middleware
│   ├── models/
│   │   └── user.dart            # User model
│   ├── services/
│   │   └── auth_service.dart    # Business logic
│   └── utils/
│       ├── jwt_utils.dart       # JWT token utilities
│       └── validators.dart      # Input validation
├── test/
│   └── auth_test.dart           # Unit tests
├── .env                         # Environment variables
└── pubspec.yaml                 # Dependencies

```

## 🚀 Getting Started

### Prerequisites
- Dart SDK 3.0 or newer
- MongoDB (local or MongoDB Atlas)

### Installation

1. **Install dependencies:**
```bash
dart pub get
```

2. **Configure environment variables:**

Edit `.env` file:
```env
MONGODB_URI=mongodb://localhost:27017/auth_db
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_REFRESH_SECRET=your-super-secret-refresh-key-change-this-in-production
PORT=8080
```

3. **Start MongoDB:**

Local:
```bash
mongod
```

Or use MongoDB Atlas cloud database.

4. **Run the server:**
```bash
dart run bin/server.dart
```

The server will start on `http://localhost:8080`

## 📚 API Endpoints

### Public Endpoints (No Authentication Required)

#### Health Check
```http
GET /
```

#### Register User
```http
POST /auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass123",
  "name": "John Doe"
}
```

#### Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass123"
}
```

Response:
```json
{
  "success": true,
  "message": "Login successful",
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "email": "user@example.com",
    "name": "John Doe",
    "roles": ["user"],
    "emailVerified": false,
    "createdAt": "2026-02-11T10:30:00.000Z",
    "updatedAt": "2026-02-11T10:30:00.000Z"
  }
}
```

#### Refresh Token
```http
POST /auth/refresh
Content-Type: application/json

{
  "refreshToken": "eyJhbGc..."
}
```

#### Public Info
```http
GET /api/public/info
```

### Protected Endpoints (Authentication Required)

Include the access token in the Authorization header:
```
Authorization: Bearer <accessToken>
```

#### Get Current User
```http
GET /auth/me
Authorization: Bearer <accessToken>
```

#### Update Profile
```http
PUT /auth/profile
Authorization: Bearer <accessToken>
Content-Type: application/json

{
  "name": "Jane Smith"
}
```

#### Change Password
```http
PUT /auth/change-password
Authorization: Bearer <accessToken>
Content-Type: application/json

{
  "currentPassword": "SecurePass123",
  "newPassword": "NewSecurePass456"
}
```

#### Logout
```http
POST /auth/logout
Authorization: Bearer <accessToken>
```

#### User Dashboard
```http
GET /api/dashboard
Authorization: Bearer <accessToken>
```

### Admin Only Endpoints

Requires `admin` role:

```http
GET /api/admin/users
Authorization: Bearer <accessToken>
```

### Moderator/Admin Endpoints

Requires `moderator` or `admin` role:

```http
GET /api/moderator/reports
Authorization: Bearer <accessToken>
```

## 🔐 Password Requirements

- Minimum 8 characters
- At least 1 uppercase letter
- At least 1 lowercase letter
- At least 1 number

## 🧪 Testing

Run tests:
```bash
dart test
```

## 🎭 Example Usage (cURL)

### 1. Register a new user
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@example.com",
    "password": "SecurePass123",
    "name": "Alice Johnson"
  }'
```

### 2. Login
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@example.com",
    "password": "SecurePass123"
  }'
```

Save the `accessToken` from the response.

### 3. Access protected endpoint
```bash
curl -X GET http://localhost:8080/auth/me \
  -H "Authorization: Bearer <your-access-token>"
```

### 4. Access dashboard
```bash
curl -X GET http://localhost:8080/api/dashboard \
  -H "Authorization: Bearer <your-access-token>"
```

## 🛡️ Security Best Practices

1. **Change default secrets** in `.env` for production
2. **Use HTTPS** in production
3. **Store refresh tokens** securely on client side
4. **Implement rate limiting** for auth endpoints
5. **Add email verification** before allowing login
6. **Implement 2FA** for sensitive operations
7. **Use environment-specific** configurations
8. **Monitor failed login** attempts
9. **Regularly rotate** JWT secrets
10. **Audit user activity** logs

## 🔄 Token Flow

1. User logs in → Receives access token (15 min) + refresh token (7 days)
2. Client stores both tokens securely
3. Client uses access token for API requests
4. When access token expires → Use refresh token to get new access token
5. When refresh token expires → User must login again

## 🎯 Role-Based Access Control (RBAC)

### Default Roles
- `user` - Default role for all registered users
- `moderator` - Can access moderation endpoints
- `admin` - Full access to all endpoints

### Adding Custom Roles

To manually add roles to a user in MongoDB:

```javascript
db.users.updateOne(
  { email: "admin@example.com" },
  { $set: { roles: ["user", "admin"] } }
)
```

### Creating Role-Protected Routes

```dart
// Admin only
app.use('/api/admin/**', authMiddleware());
app.use('/api/admin/**', requireRoles(['admin']));
app.get('/api/admin/users', yourHandler);

// Moderator or Admin
app.use('/api/moderator/**', authMiddleware());
app.use('/api/moderator/**', requireRoles(['moderator', 'admin']));
```

## 📊 Database Schema

### Users Collection

```json
{
  "_id": ObjectId,
  "email": String (unique, indexed),
  "passwordHash": String,
  "name": String,
  "roles": [String],
  "emailVerified": Boolean,
  "createdAt": ISODate,
  "updatedAt": ISODate,
  "refreshToken": String (optional)
}
```

## 🚧 Future Enhancements

- [ ] Email verification
- [ ] Password reset via email
- [ ] Two-Factor Authentication (2FA)
- [ ] OAuth 2.0 social login
- [ ] Session management
- [ ] Rate limiting
- [ ] Account lockout after failed attempts
- [ ] Audit logging
- [ ] API key authentication

## 📝 License

MIT License - feel free to use this in your projects!

## 🤝 Contributing

Contributions welcome! Please feel free to submit a Pull Request.

## 📧 Support

For issues or questions, please open an issue on GitHub.

---

Built with ❤️ using [Relic](https://github.com/serverpod/relic) and MongoDB
