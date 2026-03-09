# API Test Cases Documentation

## Overview
This document contains comprehensive test cases for the SpringBoot API endpoints.

## Test Case Format
- **Test Case ID**: Unique identifier
- **Endpoint**: API endpoint being tested
- **Scenario**: Description of the test scenario
- **Preconditions**: Prerequisites for the test
- **Steps**: Detailed test steps
- **Expected Result**: Expected outcome

---

## User Management API Test Cases

### TC001 - Create User (Happy Path)
- **Test Case ID**: TC001
- **Endpoint**: POST /api/users
- **Scenario**: Successfully create a new user with valid data
- **Preconditions**: API is accessible, database is available
- **Steps**:
  1. Send POST request to /api/users
  2. Include valid JSON payload with user details
  3. Verify response status code
  4. Verify response contains user ID
- **Expected Result**: 
  - Status Code: 201 Created
  - Response contains user ID and created timestamp
  - User is stored in database

### TC002 - Create User (Invalid Email)
- **Test Case ID**: TC002
- **Endpoint**: POST /api/users
- **Scenario**: Attempt to create user with invalid email format
- **Preconditions**: API is accessible
- **Steps**:
  1. Send POST request to /api/users
  2. Include JSON payload with invalid email format
  3. Verify response status code
  4. Verify error message
- **Expected Result**:
  - Status Code: 400 Bad Request
  - Response contains validation error message

### TC003 - Get User by ID (Happy Path)
- **Test Case ID**: TC003
- **Endpoint**: GET /api/users/{id}
- **Scenario**: Retrieve existing user by valid ID
- **Preconditions**: User exists in database
- **Steps**:
  1. Send GET request to /api/users/{valid_id}
  2. Verify response status code
  3. Verify response contains user details
- **Expected Result**:
  - Status Code: 200 OK
  - Response contains complete user information

### TC004 - Get User by ID (Not Found)
- **Test Case ID**: TC004
- **Endpoint**: GET /api/users/{id}
- **Scenario**: Attempt to retrieve non-existent user
- **Preconditions**: API is accessible
- **Steps**:
  1. Send GET request to /api/users/{invalid_id}
  2. Verify response status code
  3. Verify error message
- **Expected Result**:
  - Status Code: 404 Not Found
  - Response contains appropriate error message

### TC005 - Update User (Happy Path)
- **Test Case ID**: TC005
- **Endpoint**: PUT /api/users/{id}
- **Scenario**: Successfully update existing user
- **Preconditions**: User exists in database
- **Steps**:
  1. Send PUT request to /api/users/{valid_id}
  2. Include updated user data in JSON payload
  3. Verify response status code
  4. Verify updated fields in response
- **Expected Result**:
  - Status Code: 200 OK
  - Response contains updated user information

### TC006 - Delete User (Happy Path)
- **Test Case ID**: TC006
- **Endpoint**: DELETE /api/users/{id}
- **Scenario**: Successfully delete existing user
- **Preconditions**: User exists in database
- **Steps**:
  1. Send DELETE request to /api/users/{valid_id}
  2. Verify response status code
  3. Attempt to retrieve deleted user
- **Expected Result**:
  - Status Code: 204 No Content
  - Subsequent GET request returns 404

---

## Product Management API Test Cases

### TC007 - Create Product (Happy Path)
- **Test Case ID**: TC007
- **Endpoint**: POST /api/products
- **Scenario**: Successfully create a new product
- **Preconditions**: API is accessible, valid authentication
- **Steps**:
  1. Send POST request to /api/products with auth header
  2. Include valid product JSON payload
  3. Verify response status code
  4. Verify product details in response
- **Expected Result**:
  - Status Code: 201 Created
  - Response contains product ID and details

### TC008 - Get All Products (Happy Path)
- **Test Case ID**: TC008
- **Endpoint**: GET /api/products
- **Scenario**: Retrieve list of all products
- **Preconditions**: Products exist in database
- **Steps**:
  1. Send GET request to /api/products
  2. Verify response status code
  3. Verify response is array of products
- **Expected Result**:
  - Status Code: 200 OK
  - Response contains array of product objects

### TC009 - Get Products with Pagination
- **Test Case ID**: TC009
- **Endpoint**: GET /api/products?page=0&size=10
- **Scenario**: Retrieve paginated list of products
- **Preconditions**: Multiple products exist in database
- **Steps**:
  1. Send GET request with pagination parameters
  2. Verify response status code
  3. Verify pagination metadata
- **Expected Result**:
  - Status Code: 200 OK
  - Response contains paginated results with metadata

---

## Authentication API Test Cases

### TC010 - User Login (Valid Credentials)
- **Test Case ID**: TC010
- **Endpoint**: POST /api/auth/login
- **Scenario**: Successful login with valid credentials
- **Preconditions**: User account exists
- **Steps**:
  1. Send POST request to /api/auth/login
  2. Include valid username and password
  3. Verify response status code
  4. Verify JWT token in response
- **Expected Result**:
  - Status Code: 200 OK
  - Response contains valid JWT token

### TC011 - User Login (Invalid Credentials)
- **Test Case ID**: TC011
- **Endpoint**: POST /api/auth/login
- **Scenario**: Login attempt with invalid credentials
- **Preconditions**: API is accessible
- **Steps**:
  1. Send POST request to /api/auth/login
  2. Include invalid username or password
  3. Verify response status code
  4. Verify error message
- **Expected Result**:
  - Status Code: 401 Unauthorized
  - Response contains authentication error message

### TC012 - Access Protected Endpoint (Valid Token)
- **Test Case ID**: TC012
- **Endpoint**: GET /api/protected/resource
- **Scenario**: Access protected resource with valid JWT token
- **Preconditions**: Valid JWT token available
- **Steps**:
  1. Send GET request with Authorization header
  2. Include valid Bearer token
  3. Verify response status code
  4. Verify resource data
- **Expected Result**:
  - Status Code: 200 OK
  - Response contains protected resource data

### TC013 - Access Protected Endpoint (No Token)
- **Test Case ID**: TC013
- **Endpoint**: GET /api/protected/resource
- **Scenario**: Attempt to access protected resource without token
- **Preconditions**: API is accessible
- **Steps**:
  1. Send GET request without Authorization header
  2. Verify response status code
  3. Verify error message
- **Expected Result**:
  - Status Code: 401 Unauthorized
  - Response contains authentication required message

---

## Error Handling Test Cases

### TC014 - Invalid JSON Payload
- **Test Case ID**: TC014
- **Endpoint**: POST /api/users
- **Scenario**: Send malformed JSON payload
- **Preconditions**: API is accessible
- **Steps**:
  1. Send POST request with malformed JSON
  2. Verify response status code
  3. Verify error message format
- **Expected Result**:
  - Status Code: 400 Bad Request
  - Response contains JSON parsing error message

### TC015 - Missing Required Fields
- **Test Case ID**: TC015
- **Endpoint**: POST /api/users
- **Scenario**: Send request with missing required fields
- **Preconditions**: API is accessible
- **Steps**:
  1. Send POST request with incomplete data
  2. Verify response status code
  3. Verify validation error details
- **Expected Result**:
  - Status Code: 400 Bad Request
  - Response contains field validation errors

### TC016 - Server Error Handling
- **Test Case ID**: TC016
- **Endpoint**: GET /api/users
- **Scenario**: Simulate server error condition
- **Preconditions**: Database is unavailable
- **Steps**:
  1. Send GET request when database is down
  2. Verify response status code
  3. Verify error message
- **Expected Result**:
  - Status Code: 500 Internal Server Error
  - Response contains generic error message

---

## Performance Test Cases

### TC017 - Load Testing
- **Test Case ID**: TC017
- **Endpoint**: GET /api/products
- **Scenario**: Test API performance under load
- **Preconditions**: API is accessible, test data available
- **Steps**:
  1. Send 100 concurrent requests
  2. Measure response times
  3. Verify all requests succeed
- **Expected Result**:
  - All requests return 200 OK
  - Average response time < 500ms
  - No timeouts or errors

### TC018 - Rate Limiting
- **Test Case ID**: TC018
- **Endpoint**: POST /api/users
- **Scenario**: Test rate limiting functionality
- **Preconditions**: Rate limiting is configured
- **Steps**:
  1. Send requests exceeding rate limit
  2. Verify rate limit response
  3. Wait for rate limit reset
  4. Verify normal operation resumes
- **Expected Result**:
  - Status Code: 429 Too Many Requests
  - Rate limit headers present
  - Normal operation after reset

---

## Integration Test Cases

### TC019 - End-to-End User Journey
- **Test Case ID**: TC019
- **Endpoint**: Multiple endpoints
- **Scenario**: Complete user registration and product purchase flow
- **Preconditions**: API is accessible
- **Steps**:
  1. Register new user (POST /api/users)
  2. Login user (POST /api/auth/login)
  3. Browse products (GET /api/products)
  4. Create order (POST /api/orders)
  5. Verify order (GET /api/orders/{id})
- **Expected Result**:
  - All steps complete successfully
  - Data consistency maintained
  - Proper state transitions

### TC020 - Database Transaction Rollback
- **Test Case ID**: TC020
- **Endpoint**: POST /api/orders
- **Scenario**: Test transaction rollback on failure
- **Preconditions**: Insufficient inventory
- **Steps**:
  1. Attempt to create order with unavailable product
  2. Verify transaction rollback
  3. Verify database state unchanged
- **Expected Result**:
  - Status Code: 400 Bad Request
  - No partial data committed
  - Database remains consistent

---

## Test Execution Summary

### Coverage Areas
- ✅ CRUD Operations
- ✅ Authentication & Authorization
- ✅ Input Validation
- ✅ Error Handling
- ✅ Performance Testing
- ✅ Integration Testing
- ✅ Security Testing

### Test Categories
- **Positive Tests**: 10 test cases
- **Negative Tests**: 8 test cases
- **Performance Tests**: 2 test cases
- **Integration Tests**: 2 test cases

**Total Test Cases**: 20

### Execution Guidelines
1. Execute tests in order of dependency
2. Use test data setup/teardown for each test
3. Maintain test environment isolation
4. Log all test results with timestamps
5. Generate detailed failure reports

### Test Data Requirements
- Valid user test data
- Invalid input test cases
- Product catalog test data
- Authentication credentials
- Performance test datasets

---

*Generated on: $(date)*
*Test Framework Version: 1.0*
*SpringBoot API Testing Suite*