#!/bin/bash

# SpringBoot API Test Execution Script
# This script runs the complete test suite using Newman

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$(dirname "$BASE_DIR")"
COLLECTION_FILE="$TEST_DIR/postman/collection.json"
ENVIRONMENT_FILE="$TEST_DIR/postman/environment.json"
REPORTS_DIR="$TEST_DIR/reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Default values
ENVIRONMENT="local"
FORMAT="html,json,cli"
TIMEOUT=10000
VERBOSE=false
FOLDER=""
ITERATIONS=1

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  SpringBoot API Test Runner${NC}"
echo -e "${BLUE}========================================${NC}"
echo

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -e, --environment ENV    Environment to test (local, staging, prod) [default: local]"
    echo "  -f, --format FORMAT      Report format (html,json,cli) [default: html,json,cli]"
    echo "  -t, --timeout TIMEOUT    Request timeout in ms [default: 10000]"
    echo "  -v, --verbose            Enable verbose output"
    echo "  -d, --folder FOLDER      Run specific test folder only"
    echo "  -i, --iterations NUM     Number of iterations [default: 1]"
    echo "  -h, --help              Show this help message"
    echo
    echo "Examples:"
    echo "  $0                                    # Run all tests with default settings"
    echo "  $0 -e staging -f html                # Run against staging with HTML report"
    echo "  $0 -d \"User Management\" -v           # Run only User Management tests with verbose output"
    echo "  $0 -i 5 -t 5000                      # Run 5 iterations with 5s timeout"
    echo
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -f|--format)
            FORMAT="$2"
            shift 2
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -d|--folder)
            FOLDER="$2"
            shift 2
            ;;
        -i|--iterations)
            ITERATIONS="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            exit 1
            ;;
    esac
done

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    # Check if Newman is installed
    if ! command -v newman &> /dev/null; then
        echo -e "${RED}Error: Newman is not installed${NC}"
        echo "Please install Newman: npm install -g newman"
        exit 1
    fi
    
    # Check if collection file exists
    if [[ ! -f "$COLLECTION_FILE" ]]; then
        echo -e "${RED}Error: Collection file not found: $COLLECTION_FILE${NC}"
        exit 1
    fi
    
    # Check if environment file exists
    if [[ ! -f "$ENVIRONMENT_FILE" ]]; then
        echo -e "${RED}Error: Environment file not found: $ENVIRONMENT_FILE${NC}"
        exit 1
    fi
    
    # Create reports directory if it doesn't exist
    mkdir -p "$REPORTS_DIR"
    
    echo -e "${GREEN}✓ Prerequisites check passed${NC}"
    echo
}

# Function to check API health
check_api_health() {
    echo -e "${YELLOW}Checking API health...${NC}"
    
    # Extract base URL from environment file
    BASE_URL=$(grep -o '"base_url"[^,]*' "$ENVIRONMENT_FILE" | cut -d'"' -f4)
    
    if [[ -z "$BASE_URL" ]]; then
        echo -e "${YELLOW}Warning: Could not extract base_url from environment file${NC}"
        return 0
    fi
    
    # Try to reach the API
    if curl -s --max-time 5 "$BASE_URL/actuator/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ API is healthy at $BASE_URL${NC}"
    elif curl -s --max-time 5 "$BASE_URL" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ API is reachable at $BASE_URL${NC}"
    else
        echo -e "${YELLOW}Warning: API may not be reachable at $BASE_URL${NC}"
        echo -e "${YELLOW}Tests may fail if the API is not running${NC}"
    fi
    echo
}

# Function to build Newman command
build_newman_command() {
    local cmd="newman run \"$COLLECTION_FILE\""
    
    # Add environment file
    cmd="$cmd -e \"$ENVIRONMENT_FILE\""
    
    # Add timeout
    cmd="$cmd --timeout-request $TIMEOUT"
    
    # Add iterations
    if [[ $ITERATIONS -gt 1 ]]; then
        cmd="$cmd -n $ITERATIONS"
    fi
    
    # Add folder filter
    if [[ -n "$FOLDER" ]]; then
        cmd="$cmd --folder \"$FOLDER\""
    fi
    
    # Add verbose flag
    if [[ "$VERBOSE" == "true" ]]; then
        cmd="$cmd --verbose"
    fi
    
    # Add reporters
    IFS=',' read -ra FORMATS <<< "$FORMAT"
    for format in "${FORMATS[@]}"; do
        format=$(echo "$format" | xargs)  # Trim whitespace
        case $format in
            html)
                cmd="$cmd -r html --reporter-html-export \"$REPORTS_DIR/newman-report-$TIMESTAMP.html\""
                ;;
            json)
                cmd="$cmd -r json --reporter-json-export \"$REPORTS_DIR/newman-report-$TIMESTAMP.json\""
                ;;
            cli)
                cmd="$cmd -r cli"
                ;;
            junit)
                cmd="$cmd -r junit --reporter-junit-export \"$REPORTS_DIR/newman-report-$TIMESTAMP.xml\""
                ;;
        esac
    done
    
    echo "$cmd"
}

# Function to run tests
run_tests() {
    echo -e "${YELLOW}Running API tests...${NC}"
    echo -e "${BLUE}Environment: $ENVIRONMENT${NC}"
    echo -e "${BLUE}Report formats: $FORMAT${NC}"
    echo -e "${BLUE}Timeout: ${TIMEOUT}ms${NC}"
    echo -e "${BLUE}Iterations: $ITERATIONS${NC}"
    if [[ -n "$FOLDER" ]]; then
        echo -e "${BLUE}Folder: $FOLDER${NC}"
    fi
    echo
    
    # Build and execute Newman command
    local newman_cmd
    newman_cmd=$(build_newman_command)
    
    echo -e "${BLUE}Executing: $newman_cmd${NC}"
    echo
    
    # Execute the command
    if eval "$newman_cmd"; then
        echo
        echo -e "${GREEN}✓ Tests completed successfully${NC}"
        return 0
    else
        echo
        echo -e "${RED}✗ Tests failed${NC}"
        return 1
    fi
}

# Function to display results
display_results() {
    echo
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Test Results${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    # List generated reports
    echo -e "${YELLOW}Generated reports:${NC}"
    find "$REPORTS_DIR" -name "newman-report-$TIMESTAMP.*" -type f | while read -r file; do
        echo -e "  ${GREEN}✓${NC} $(basename "$file")"
    done
    
    # Show HTML report location
    local html_report="$REPORTS_DIR/newman-report-$TIMESTAMP.html"
    if [[ -f "$html_report" ]]; then
        echo
        echo -e "${YELLOW}View detailed HTML report:${NC}"
        echo -e "  file://$html_report"
    fi
    
    echo
}

# Function to cleanup on exit
cleanup() {
    echo
    echo -e "${YELLOW}Cleaning up...${NC}"
    # Add any cleanup logic here if needed
}

# Set trap for cleanup
trap cleanup EXIT

# Main execution
main() {
    check_prerequisites
    check_api_health
    
    local start_time
    start_time=$(date +%s)
    
    if run_tests; then
        local end_time
        end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        display_results
        
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}  Test execution completed successfully${NC}"
        echo -e "${GREEN}  Duration: ${duration}s${NC}"
        echo -e "${GREEN}========================================${NC}"
        exit 0
    else
        local end_time
        end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        display_results
        
        echo -e "${RED}========================================${NC}"
        echo -e "${RED}  Test execution failed${NC}"
        echo -e "${RED}  Duration: ${duration}s${NC}"
        echo -e "${RED}========================================${NC}"
        exit 1
    fi
}

# Run main function
main "$@"