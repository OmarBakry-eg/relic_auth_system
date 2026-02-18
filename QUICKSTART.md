# 🚀 Quick Start Guide

Get your authentication system running in minutes!

## Option 1: Local Development (Fastest)

### Prerequisites
- Dart SDK 3.0+
- MongoDB running locally

### Steps

1. **Install dependencies:**
```bash
dart pub get
```

2. **Start MongoDB:**
```bash
mongod
```

3. **Run the server:**
```bash
dart run bin/server.dart
```

4. **Test it works:**
```bash
curl http://localhost:8080/
```

You should see:
```json
{
  "success": true,
  "message": "Auth API is running",
  "version": "1.0.0"
}
```

## Option 2: Docker (Recommended for Production)

### Prerequisites
- Docker
- Docker Compose

### Steps

1. **Start everything:**
```bash
docker-compose up -d
```

This will:
- Start MongoDB
- Build and run the auth API
- Create a network between them

2. **Check logs:**
```bash
docker-compose logs -f auth_api
```

3. **Test it works:**
```bash
curl http://localhost:8080/
```

## 🧪 Run Tests

### Unit Tests
```bash
dart test
```

### API Tests (requires server running)
```bash
./test_api.sh
```

This will test all 21 scenarios including:
- User registration
- Login/logout
- Token refresh
- Protected routes
- Role-based access
- Password changes

## 📝 First API Call - Register a User

```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@example.com",
    "password": "SecurePass123",
    "name": "Alice Johnson"
  }'
```

Expected response:
```json
{
  "success": true,
  "message": "User registered successfully",
  "user": {
    "id": "65c1f5e8a1b2c3d4e5f6g7h8",
    "email": "alice@example.com",
    "name": "Alice Johnson",
    "roles": ["user"],
    "emailVerified": false,
    "createdAt": "2026-02-11T10:30:00.000Z",
    "updatedAt": "2026-02-11T10:30:00.000Z"
  }
}
```

## 🔑 Login and Get Token

```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@example.com",
    "password": "SecurePass123"
  }'
```

Save the `accessToken` from response!

## 🛡️ Access Protected Route

```bash
curl -X GET http://localhost:8080/api/dashboard \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE"
```

## 👑 Testing Admin Routes

Admin routes require the `admin` role. To test:

1. **Login to MongoDB:**
```bash
mongosh auth_db
```

2. **Add admin role to a user:**
```javascript
db.users.updateOne(
  { email: "alice@example.com" },
  { $set: { roles: ["user", "admin"] } }
)
```

3. **Login again to get new token with admin role:**
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@example.com",
    "password": "SecurePass123"
  }'
```

4. **Access admin endpoint:**
```bash
curl -X GET http://localhost:8080/api/admin/users \
  -H "Authorization: Bearer YOUR_NEW_ACCESS_TOKEN"
```

## 🐛 Troubleshooting

### MongoDB Connection Error
```
Error: Failed to connect to MongoDB
```

**Solution:** Make sure MongoDB is running:
```bash
# Check if MongoDB is running
sudo systemctl status mongod

# Start MongoDB
sudo systemctl start mongod
```

### Port Already in Use
```
Error: Port 8080 already in use
```

**Solution:** Change port in `.env`:
```env
PORT=3000
```

### Dart Not Found
```
bash: dart: command not found
```

**Solution:** Install Dart SDK:
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install dart

# macOS
brew tap dart-lang/dart
brew install dart
```

## 📊 What's Next?

1. **Explore the code** - Check out the well-documented source files
2. **Add features** - Email verification, 2FA, OAuth
3. **Customize** - Modify roles, add new endpoints
4. **Deploy** - Use Docker for production deployment

## 🎯 Common Use Cases

### Use Case 1: Simple Auth for Mobile App
- Use `/auth/register` and `/auth/login`
- Store tokens securely on device
- Use `/auth/refresh` when access token expires

### Use Case 2: Multi-Tenant SaaS
- Add `organizationId` to User model
- Filter data by organization in middleware
- Add organization-based RBAC

### Use Case 3: Admin Dashboard
- Use role-based routes
- Add more admin endpoints
- Implement user management UI

## 💡 Pro Tips

1. **Always use HTTPS in production**
2. **Change JWT secrets before deploying**
3. **Implement rate limiting for auth endpoints**
4. **Add email verification flow**
5. **Monitor failed login attempts**
6. **Set up proper logging**
7. **Use MongoDB Atlas for production database**
8. **Implement refresh token rotation**
9. **Add API versioning (/v1/auth/...)**
10. **Set up CI/CD pipeline**

## 📚 Learn More

- [Relic Documentation](https://docs.dartrelic.dev/)
- [MongoDB Dart Driver](https://pub.dev/packages/mongo_dart)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)

---

Happy coding! 🚀
