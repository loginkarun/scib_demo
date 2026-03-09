# SpringBoot API Testing Framework

This directory contains comprehensive test assets for the SpringBoot API, including test cases, Postman collections, and execution reports.

## Directory Structure

```
test/
├── README.md                    # This file - Testing framework documentation
├── api_test_cases.md           # Comprehensive test case documentation
├── postman/                    # Postman collection and environment files
│   ├── collection.json         # Postman test collection
│   └── environment.json        # Environment variables and configuration
├── reports/                    # Test execution reports and results
│   └── execution_report.md     # Latest test execution report
├── scripts/                    # Test execution and utility scripts
│   ├── run_tests.sh           # Shell script to execute all tests
│   ├── newman_runner.js       # Newman test runner configuration
│   └── test_data_setup.sql    # SQL script for test data setup
└── data/                      # Test data files
    ├── users.json             # Sample user data for testing
    ├── products.json          # Sample product data for testing
    └── test_scenarios.json    # Test scenario configurations
```

## Prerequisites

### Software Requirements
- Node.js (v14 or higher)
- Newman (Postman CLI runner)
- SpringBoot API running on localhost:8080
- PostgreSQL database (or configured database)

### Installation

1. Install Newman globally:
```bash
npm install -g newman
```

2. Install Newman HTML reporter (optional):
```bash
npm install -g newman-reporter-html
```

## Quick Start

### 1. Manual Testing with Postman

1. Import the collection:
   - Open Postman
   - Click "Import" → "Upload Files"
   - Select `postman/collection.json`

2. Import the environment:
   - Click "Import" → "Upload Files"
   - Select `postman/environment.json`

3. Set the environment:
   - Select "SpringBoot API Test Environment" from the environment dropdown

4. Run the collection:
   - Click "Collections" → "SpringBoot API Test Collection"
   - Click "Run" to execute all tests

### 2. Automated Testing with Newman

#### Basic Execution
```bash
# Navigate to test directory
cd test/

# Run all tests
newman run postman/collection.json -e postman/environment.json
```

#### Advanced Execution with Reporting
```bash
# Run tests with HTML report
newman run postman/collection.json \
  -e postman/environment.json \
  -r html \
  --reporter-html-export reports/newman-report.html

# Run tests with JSON report
newman run postman/collection.json \
  -e postman/environment.json \
  -r json \
  --reporter-json-export reports/newman-report.json
```

#### Run Specific Test Folders
```bash
# Run only User Management tests
newman run postman/collection.json \
  -e postman/environment.json \
  --folder "User Management"

# Run only Authentication tests
newman run postman/collection.json \
  -e postman/environment.json \
  --folder "Authentication"
```

## Test Categories

### 1. User Management Tests
- User creation (positive and negative scenarios)
- User retrieval by ID
- User updates
- User deletion
- Input validation testing

### 2. Product Management Tests
- Product creation with authentication
- Product listing (with and without pagination)
- Product search and filtering
- Product updates and deletion

### 3. Authentication Tests
- User login with valid/invalid credentials
- JWT token validation
- Protected endpoint access
- Token expiration handling

### 4. Error Handling Tests
- Invalid JSON payload handling
- Missing required fields validation
- Server error responses
- Rate limiting behavior

### 5. Performance Tests
- Load testing with concurrent requests
- Response time validation
- Rate limiting verification
- Timeout handling

### 6. Integration Tests
- End-to-end user journeys
- Database transaction testing
- Service integration validation
- Data consistency checks

## Environment Configuration

### Environment Variables

The following variables are configured in `postman/environment.json`:

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `base_url` | API base URL | `http://localhost:8080` |
| `auth_token` | JWT authentication token | (populated by login) |
| `user_id` | Test user ID | (populated by user creation) |
| `product_id` | Test product ID | (populated by product creation) |
| `test_username` | Test user email | `testuser@example.com` |
| `test_password` | Test user password | `SecurePass123!` |
| `admin_username` | Admin user email | `admin@example.com` |
| `admin_password` | Admin user password | `AdminPass123!` |

### Customizing Environment

To test against different environments:

1. Copy `postman/environment.json` to `postman/environment-staging.json`
2. Update the `base_url` and other environment-specific values
3. Run tests with the new environment:

```bash
newman run postman/collection.json -e postman/environment-staging.json
```

## Test Data Management

### Test Data Setup

Before running tests, ensure your database has the required test data:

```bash
# Run test data setup script
psql -d your_database -f scripts/test_data_setup.sql
```

### Test Data Cleanup

After test execution, clean up test data:

```bash
# Run cleanup script
psql -d your_database -f scripts/test_data_cleanup.sql
```

## Continuous Integration

### GitHub Actions Integration

Add this workflow to `.github/workflows/api-tests.yml`:

```yaml
name: API Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  api-tests:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: testdb
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Set up Java
      uses: actions/setup-java@v2
      with:
        java-version: '11'
        distribution: 'temurin'
    
    - name: Start SpringBoot Application
      run: |
        ./mvnw spring-boot:run &
        sleep 30
    
    - name: Set up Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '16'
    
    - name: Install Newman
      run: npm install -g newman newman-reporter-html
    
    - name: Run API Tests
      run: |
        cd test
        newman run postman/collection.json \
          -e postman/environment.json \
          -r html,json \
          --reporter-html-export reports/newman-report.html \
          --reporter-json-export reports/newman-report.json
    
    - name: Upload Test Reports
      uses: actions/upload-artifact@v2
      if: always()
      with:
        name: test-reports
        path: test/reports/
```

## Troubleshooting

### Common Issues

#### 1. Connection Refused Errors
**Problem**: Tests fail with "ECONNREFUSED" errors  
**Solution**: Ensure the SpringBoot application is running on the correct port

```bash
# Check if application is running
curl http://localhost:8080/actuator/health

# If not running, start the application
./mvnw spring-boot:run
```

#### 2. Authentication Failures
**Problem**: Tests fail with 401 Unauthorized errors  
**Solution**: Verify test credentials and ensure login endpoint is working

```bash
# Test login manually
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser@example.com","password":"SecurePass123!"}'
```

#### 3. Database Connection Issues
**Problem**: Tests fail with database-related errors  
**Solution**: Verify database connection and test data setup

```bash
# Check database connectivity
psql -h localhost -U your_user -d your_database -c "SELECT 1;"

# Run test data setup
psql -d your_database -f scripts/test_data_setup.sql
```

#### 4. Timeout Issues
**Problem**: Tests fail with timeout errors  
**Solution**: Increase timeout values or optimize API performance

```bash
# Run with increased timeout
newman run postman/collection.json \
  -e postman/environment.json \
  --timeout-request 10000
```

### Debug Mode

Run tests in debug mode for detailed output:

```bash
newman run postman/collection.json \
  -e postman/environment.json \
  --verbose
```

## Best Practices

### 1. Test Organization
- Group related tests in folders
- Use descriptive test names
- Include both positive and negative test cases
- Maintain test independence

### 2. Data Management
- Use dynamic variables for test data
- Clean up test data after execution
- Avoid hardcoded values in tests
- Use environment-specific configurations

### 3. Assertions
- Validate status codes
- Check response structure
- Verify business logic
- Test error conditions

### 4. Maintenance
- Keep tests updated with API changes
- Review and update test data regularly
- Monitor test execution times
- Document test scenarios clearly

## Contributing

### Adding New Tests

1. Add test case documentation to `api_test_cases.md`
2. Create corresponding Postman requests in the collection
3. Add appropriate assertions and error handling
4. Update environment variables if needed
5. Test locally before committing

### Updating Existing Tests

1. Update test documentation first
2. Modify Postman collection accordingly
3. Verify all related tests still pass
4. Update execution reports if needed

## Support

For questions or issues with the testing framework:

- **Documentation**: Check this README and test case documentation
- **Issues**: Create GitHub issues for bugs or feature requests
- **Contact**: Reach out to the QA team at qa-team@company.com

---

*Last Updated: 2024-01-15*  
*Framework Version: 1.0*  
*Maintained by: QA Engineering Team*