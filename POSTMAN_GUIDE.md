# 📮 Postman Collection Guide

## Quick Import

1. Open Postman
2. Click **Import** button (top left)
3. Select the `Auth_System_API.postman_collection.json` file
4. Click **Import**

## 🎯 Collection Features

### ✅ What's Included

- **12 API endpoints** organized into folders
- **Automatic token management** - Login automatically saves tokens
- **Pre-configured variables** for baseUrl, accessToken, refreshToken
- **Test scripts** that validate responses
- **Complete documentation** for each endpoint
- **Example flows** showing common usage patterns

### 📁 Folder Structure

```
Auth System API
├── Public Endpoints (2 requests)
│   ├── Health Check
│   └── Public Info
├── Authentication (3 requests)
│   ├── Register User
│   ├── Login (auto-saves tokens)
│   └── Refresh Token (auto-updates token)
├── User Management (4 requests)
│   ├── Get Current User
│   ├── Update Profile
│   ├── Change Password
│   └── Logout (auto-clears tokens)
├── Protected Resources (1 request)
│   └── User Dashboard
├── Admin Endpoints (1 request)
│   └── Get All Users
├── Moderator Endpoints (1 request)
│   └── Get Reports
└── Example Flows
    └── Complete Registration Flow (4 steps with tests)
```

## 🚀 Quick Start

### Step 1: Configure Base URL

The collection uses `http://localhost:8080` by default. To change:

1. Click on the collection name
2. Go to **Variables** tab
3. Update `baseUrl` to your server URL
4. Click **Save**

### Step 2: Register a User

1. Open **Authentication** → **Register User**
2. Click **Send**
3. You should see a 201 response with user details

### Step 3: Login

1. Open **Authentication** → **Login**
2. Click **Send**
3. ✨ The `accessToken` and `refreshToken` are **automatically saved**!

### Step 4: Access Protected Endpoints

1. Open **User Management** → **Get Current User**
2. Click **Send**
3. The saved `accessToken` is automatically used!

## 🔐 Automatic Token Management

The collection includes scripts that automatically:

### On Login
```javascript
// Saves tokens to collection variables
accessToken → {{accessToken}}
refreshToken → {{refreshToken}}
userId → {{userId}}
```

### On Token Refresh
```javascript
// Updates access token
accessToken → new token
```

### On Logout
```javascript
// Clears tokens
accessToken → ""
refreshToken → ""
```

## 📝 Collection Variables

| Variable | Description | Auto-Set |
|----------|-------------|----------|
| `baseUrl` | API server URL | ❌ Manual |
| `accessToken` | JWT access token (15 min) | ✅ On login/refresh |
| `refreshToken` | JWT refresh token (7 days) | ✅ On login |
| `userId` | Current user ID | ✅ On login/register |

### Viewing Variables

1. Click on collection name
2. Go to **Variables** tab
3. See current values

## 🎭 Testing Different Roles

### Regular User (Default)
All users get `user` role by default. Can access:
- All authentication endpoints
- User management endpoints
- Protected resources (dashboard)

### Testing Admin Role

1. **Register/Login** as usual
2. **Open MongoDB** and run:
```javascript
db.users.updateOne(
  { email: "your-email@example.com" },
  { $set: { roles: ["user", "admin"] } }
)
```
3. **Login again** to get new token with admin role
4. **Try admin endpoints** - should work!

### Testing Moderator Role

1. **Update user role** in MongoDB:
```javascript
db.users.updateOne(
  { email: "your-email@example.com" },
  { $set: { roles: ["user", "moderator"] } }
)
```
2. **Login again**
3. **Try moderator endpoints**

## 🧪 Running Tests

### Individual Request Tests

Each request has built-in tests:
1. Send a request
2. Check **Test Results** tab
3. See pass/fail status

### Running Complete Flow

1. Open **Example Flows** → **Complete Registration Flow**
2. Right-click on folder
3. Select **Run folder**
4. Watch all 4 requests execute in sequence!

## 📊 Common Use Cases

### Use Case 1: New User Registration
```
1. Register User
2. Login (tokens saved automatically)
3. Get Current User (uses saved token)
4. Access Dashboard (uses saved token)
```

### Use Case 2: Existing User Login
```
1. Login (tokens saved)
2. Access any protected endpoint
```

### Use Case 3: Token Expired
```
1. Protected endpoint returns 401
2. Use Refresh Token endpoint
3. New access token saved automatically
4. Retry protected endpoint
```

### Use Case 4: Update Profile
```
1. Login
2. Update Profile
3. Get Current User (verify changes)
```

### Use Case 5: Change Password
```
1. Login
2. Change Password
3. Login again (old token invalid)
```

## 🔍 Request Documentation

Each request includes:
- **Description** of what it does
- **Requirements** (auth, roles, etc.)
- **Request body** examples
- **Response** expectations
- **Notes** with important info

## ⚡ Pro Tips

1. **Use Example Flow** - Run the complete flow to test everything at once
2. **Check Console** - See all automatic variable updates
3. **Duplicate Requests** - Create variants for different test scenarios
4. **Use Environments** - Create separate environments for dev/staging/prod
5. **Pre-request Scripts** - Add custom logic before requests
6. **Collection Runner** - Automate testing of multiple requests

## 🐛 Troubleshooting

### "Authorization header missing"
- Make sure you've logged in first
- Check that `accessToken` variable is set
- Verify request has Bearer token auth configured

### "Invalid or expired token"
- Access token expired (15 min lifetime)
- Use **Refresh Token** endpoint
- Or login again

### "Insufficient permissions"
- Your user doesn't have required role
- Update roles in MongoDB
- Login again to get new token

### "User not found" 
- User was deleted from database
- Register a new user

## 📚 Additional Resources

- **README.md** - Complete API documentation
- **QUICKSTART.md** - Server setup guide
- **ARCHITECTURE.md** - System design
- **CONTEXT_FIX.md** - Implementation details

## 🎉 Happy Testing!

You now have a complete Postman collection with:
- ✅ All API endpoints
- ✅ Automatic token management
- ✅ Built-in tests
- ✅ Example flows
- ✅ Complete documentation

Just import and start testing! 🚀
