#!/bin/bash

# Authentication System API Test Script
# This script tests all endpoints of the auth system

API_URL="http://localhost:8080"

echo "🧪 Testing Authentication System API"
echo "===================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test 1: Health Check
echo -e "${BLUE}Test 1: Health Check${NC}"
curl -X GET "$API_URL/" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n" \
  -s | jq '.'
echo ""

# Test 2: Public Info
echo -e "${BLUE}Test 2: Public Info${NC}"
curl -X GET "$API_URL/api/public/info" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n" \
  -s | jq '.'
echo ""

# Test 3: Register User
echo -e "${BLUE}Test 3: Register New User${NC}"
REGISTER_RESPONSE=$(curl -X POST "$API_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "password": "SecurePass123",
    "name": "Test User"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s)
echo "$REGISTER_RESPONSE" | jq '.'
echo ""

# Test 4: Register Admin User (for later tests)
echo -e "${BLUE}Test 4: Register Admin User${NC}"
curl -X POST "$API_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "AdminPass123",
    "name": "Admin User"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s | jq '.'
echo ""

# Test 5: Try to register with existing email (should fail)
echo -e "${BLUE}Test 5: Register Duplicate Email (Should Fail)${NC}"
curl -X POST "$API_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "password": "SecurePass123",
    "name": "Test User 2"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s | jq '.'
echo ""

# Test 6: Try weak password (should fail)
echo -e "${BLUE}Test 6: Register with Weak Password (Should Fail)${NC}"
curl -X POST "$API_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "weak@example.com",
    "password": "weak",
    "name": "Weak User"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s | jq '.'
echo ""

# Test 7: Login
echo -e "${BLUE}Test 7: Login User${NC}"
LOGIN_RESPONSE=$(curl -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "password": "SecurePass123"
  }' \
  -s)

echo "$LOGIN_RESPONSE" | jq '.'
ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.accessToken')
REFRESH_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.refreshToken')
echo -e "${GREEN}Access Token: $ACCESS_TOKEN${NC}"
echo -e "${GREEN}Refresh Token: $REFRESH_TOKEN${NC}"
echo ""

# Test 8: Login with wrong password (should fail)
echo -e "${BLUE}Test 8: Login with Wrong Password (Should Fail)${NC}"
curl -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "password": "WrongPassword123"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s | jq '.'
echo ""

# Test 9: Get Current User (Protected)
echo -e "${BLUE}Test 9: Get Current User Info${NC}"
curl -X GET "$API_URL/auth/me" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -w "\nStatus: %{http_code}\n" \
  -s | jq '.'
echo ""

# Test 10: Try to access protected route without token (should fail)
echo -e "${BLUE}Test 10: Access Protected Route Without Token (Should Fail)${NC}"
curl -X GET "$API_URL/auth/me" \
  -w "\nStatus: %{http_code}\n" \
  -s | jq '.'
echo ""

# Test 11: Access Dashboard
echo -e "${BLUE}Test 11: Access User Dashboard${NC}"
curl -X GET "$API_URL/api/dashboard" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -w "\nStatus: %{http_code}\n" \
  -s | jq '.'
echo ""

# Test 12: Update Profile
echo -e "${BLUE}Test 12: Update User Profile${NC}"
curl -X PUT "$API_URL/auth/profile" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Test User"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s | jq '.'
echo ""

# Test 13: Change Password
echo -e "${BLUE}Test 13: Change Password${NC}"
curl -X PUT "$API_URL/auth/change-password" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "currentPassword": "SecurePass123",
    "newPassword": "NewSecurePass456"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s | jq '.'
echo ""

# Test 14: Try to login with old password (should fail)
echo -e "${BLUE}Test 14: Login with Old Password After Change (Should Fail)${NC}"
curl -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "password": "SecurePass123"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s | jq '.'
echo ""

# Test 15: Login with new password
echo -e "${BLUE}Test 15: Login with New Password${NC}"
LOGIN_RESPONSE2=$(curl -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "password": "NewSecurePass456"
  }' \
  -s)

echo "$LOGIN_RESPONSE2" | jq '.'
ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE2" | jq -r '.accessToken')
REFRESH_TOKEN=$(echo "$LOGIN_RESPONSE2" | jq -r '.refreshToken')
echo ""

# Test 16: Refresh Access Token
echo -e "${BLUE}Test 16: Refresh Access Token${NC}"
REFRESH_RESPONSE=$(curl -X POST "$API_URL/auth/refresh" \
  -H "Content-Type: application/json" \
  -d "{
    \"refreshToken\": \"$REFRESH_TOKEN\"
  }" \
  -s)

echo "$REFRESH_RESPONSE" | jq '.'
NEW_ACCESS_TOKEN=$(echo "$REFRESH_RESPONSE" | jq -r '.accessToken')
echo -e "${GREEN}New Access Token: $NEW_ACCESS_TOKEN${NC}"
echo ""

# Test 17: Use new access token
echo -e "${BLUE}Test 17: Use Refreshed Access Token${NC}"
curl -X GET "$API_URL/auth/me" \
  -H "Authorization: Bearer $NEW_ACCESS_TOKEN" \
  -w "\nStatus: %{http_code}\n" \
  -s | jq '.'
echo ""

# Test 18: Try to access admin endpoint (should fail - no admin role)
echo -e "${BLUE}Test 18: Access Admin Endpoint as Regular User (Should Fail)${NC}"
curl -X GET "$API_URL/api/admin/users" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -w "\nStatus: %{http_code}\n" \
  -s | jq '.'
echo ""

# Test 19: Try to access moderator endpoint (should fail - no moderator role)
echo -e "${BLUE}Test 19: Access Moderator Endpoint as Regular User (Should Fail)${NC}"
curl -X GET "$API_URL/api/moderator/reports" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -w "\nStatus: %{http_code}\n" \
  -s | jq '.'
echo ""

# Test 20: Logout
echo -e "${BLUE}Test 20: Logout User${NC}"
curl -X POST "$API_URL/auth/logout" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -w "\nStatus: %{http_code}\n" \
  -s | jq '.'
echo ""

# Test 21: Try to use token after logout (refresh token should be invalid)
echo -e "${BLUE}Test 21: Try to Refresh After Logout (Should Fail)${NC}"
curl -X POST "$API_URL/auth/refresh" \
  -H "Content-Type: application/json" \
  -d "{
    \"refreshToken\": \"$REFRESH_TOKEN\"
  }" \
  -w "\nStatus: %{http_code}\n" \
  -s | jq '.'
echo ""

echo -e "${GREEN}===================================="
echo -e "✅ All tests completed!"
echo -e "====================================${NC}"
echo ""
echo "Notes:"
echo "- To test admin/moderator endpoints, you need to manually add those roles in MongoDB"
echo "- Run: mongosh auth_db"
echo "- Then: db.users.updateOne({email: 'admin@example.com'}, {\$set: {roles: ['user', 'admin']}})"
