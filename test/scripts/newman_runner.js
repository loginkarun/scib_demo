#!/usr/bin/env node

/**
 * Newman Test Runner Configuration
 * Advanced Newman runner with custom reporting and test management
 */

const newman = require('newman');
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuration
const config = {
    baseDir: path.resolve(__dirname, '..'),
    collection: path.resolve(__dirname, '../postman/collection.json'),
    environment: path.resolve(__dirname, '../postman/environment.json'),
    reportsDir: path.resolve(__dirname, '../reports'),
    dataDir: path.resolve(__dirname, '../data'),
    timeout: 10000,
    iterations: 1,
    verbose: false,
    bail: false,
    color: 'on',
    reporters: ['cli', 'html', 'json'],
    timestamp: new Date().toISOString().replace(/[:.]/g, '-').slice(0, -5)
};

// Command line argument parsing
const args = process.argv.slice(2);
let environment = 'local';
let folder = null;
let iterations = 1;
let timeout = 10000;
let verbose = false;
let bail = false;
let reporters = ['cli', 'html', 'json'];

// Parse arguments
for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
        case '-e':
        case '--environment':
            environment = args[++i];
            break;
        case '-f':
        case '--folder':
            folder = args[++i];
            break;
        case '-i':
        case '--iterations':
            iterations = parseInt(args[++i]);
            break;
        case '-t':
        case '--timeout':
            timeout = parseInt(args[++i]);
            break;
        case '-v':
        case '--verbose':
            verbose = true;
            break;
        case '-b':
        case '--bail':
            bail = true;
            break;
        case '-r':
        case '--reporters':
            reporters = args[++i].split(',');
            break;
        case '-h':
        case '--help':
            showHelp();
            process.exit(0);
            break;
        default:
            console.error(`Unknown argument: ${args[i]}`);
            showHelp();
            process.exit(1);
    }
}

// Help function
function showHelp() {
    console.log(`
Newman Test Runner

Usage: node newman_runner.js [options]

Options:
  -e, --environment <env>     Environment (local, staging, prod) [default: local]
  -f, --folder <folder>       Run specific folder only
  -i, --iterations <num>      Number of iterations [default: 1]
  -t, --timeout <ms>          Request timeout in milliseconds [default: 10000]
  -v, --verbose               Enable verbose output
  -b, --bail                  Stop on first failure
  -r, --reporters <list>      Comma-separated list of reporters [default: cli,html,json]
  -h, --help                  Show this help

Examples:
  node newman_runner.js
  node newman_runner.js -e staging -f "User Management" -v
  node newman_runner.js -i 5 -t 5000 -r cli,json
`);
}

// Utility functions
function ensureDirectoryExists(dir) {
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
}

function checkPrerequisites() {
    console.log('🔍 Checking prerequisites...');
    
    // Check if collection file exists
    if (!fs.existsSync(config.collection)) {
        console.error(`❌ Collection file not found: ${config.collection}`);
        process.exit(1);
    }
    
    // Check if environment file exists
    if (!fs.existsSync(config.environment)) {
        console.error(`❌ Environment file not found: ${config.environment}`);
        process.exit(1);
    }
    
    // Ensure reports directory exists
    ensureDirectoryExists(config.reportsDir);
    
    console.log('✅ Prerequisites check passed');
}

function checkApiHealth() {
    console.log('🏥 Checking API health...');
    
    try {
        // Read environment file to get base URL
        const envData = JSON.parse(fs.readFileSync(config.environment, 'utf8'));
        const baseUrlVar = envData.values.find(v => v.key === 'base_url');
        
        if (baseUrlVar) {
            const baseUrl = baseUrlVar.value;
            console.log(`🌐 API Base URL: ${baseUrl}`);
            
            try {
                // Try to ping the API
                execSync(`curl -s --max-time 5 "${baseUrl}/actuator/health" > /dev/null`, { stdio: 'ignore' });
                console.log('✅ API is healthy');
            } catch (error) {
                try {
                    execSync(`curl -s --max-time 5 "${baseUrl}" > /dev/null`, { stdio: 'ignore' });
                    console.log('✅ API is reachable');
                } catch (error) {
                    console.log('⚠️  Warning: API may not be reachable');
                }
            }
        }
    } catch (error) {
        console.log('⚠️  Warning: Could not check API health');
    }
}

function buildNewmanOptions() {
    const options = {
        collection: config.collection,
        environment: config.environment,
        timeout: timeout,
        timeoutRequest: timeout,
        timeoutScript: timeout,
        iterationCount: iterations,
        bail: bail,
        color: config.color,
        reporters: [],
        reporter: {}
    };
    
    // Add folder filter if specified
    if (folder) {
        options.folder = folder;
    }
    
    // Configure reporters
    reporters.forEach(reporter => {
        options.reporters.push(reporter);
        
        switch (reporter) {
            case 'html':
                options.reporter.html = {
                    export: path.join(config.reportsDir, `newman-report-${config.timestamp}.html`),
                    template: null // Use default template
                };
                break;
            case 'json':
                options.reporter.json = {
                    export: path.join(config.reportsDir, `newman-report-${config.timestamp}.json`)
                };
                break;
            case 'junit':
                options.reporter.junit = {
                    export: path.join(config.reportsDir, `newman-report-${config.timestamp}.xml`)
                };
                break;
            case 'cli':
                options.reporter.cli = {
                    verbose: verbose,
                    silent: false,
                    noAssertions: false,
                    noSummary: false,
                    noFailures: false,
                    noConsole: false
                };
                break;
        }
    });
    
    return options;
}

function generateSummaryReport(summary) {
    const reportPath = path.join(config.reportsDir, `test-summary-${config.timestamp}.md`);
    
    const report = `# API Test Execution Summary

**Execution Date**: ${new Date().toISOString()}
**Environment**: ${environment}
**Collection**: ${path.basename(config.collection)}
**Total Duration**: ${summary.run.timings.completed - summary.run.timings.started}ms

## Overall Results

| Metric | Count |
|--------|-------|
| Total Requests | ${summary.run.stats.requests.total} |
| Successful Requests | ${summary.run.stats.requests.total - summary.run.stats.requests.failed} |
| Failed Requests | ${summary.run.stats.requests.failed} |
| Total Assertions | ${summary.run.stats.assertions.total} |
| Passed Assertions | ${summary.run.stats.assertions.total - summary.run.stats.assertions.failed} |
| Failed Assertions | ${summary.run.stats.assertions.failed} |
| Skipped Tests | ${summary.run.stats.tests.total - summary.run.stats.tests.pending} |

## Performance Metrics

| Metric | Value |
|--------|-------|
| Average Response Time | ${Math.round(summary.run.timings.responseAverage)}ms |
| Min Response Time | ${summary.run.timings.responseMin}ms |
| Max Response Time | ${summary.run.timings.responseMax}ms |

## Test Results

### Passed Tests
${summary.run.executions.filter(e => e.assertions && e.assertions.every(a => !a.error)).length} tests passed

### Failed Tests
${summary.run.executions.filter(e => e.assertions && e.assertions.some(a => a.error)).map(e => {
    const failedAssertions = e.assertions.filter(a => a.error);
    return `- **${e.item.name}**: ${failedAssertions.map(a => a.error.message).join(', ')}`;
}).join('\n')}

## Execution Details

${summary.run.executions.map(e => {
    const status = e.assertions && e.assertions.some(a => a.error) ? '❌' : '✅';
    const responseTime = e.response ? e.response.responseTime : 'N/A';
    return `${status} **${e.item.name}** (${responseTime}ms)`;
}).join('\n')}

---
*Generated by Newman Test Runner at ${new Date().toISOString()}*
`;
    
    fs.writeFileSync(reportPath, report);
    console.log(`📊 Summary report generated: ${reportPath}`);
}

function runTests() {
    console.log('🚀 Starting API tests...');
    console.log(`📁 Collection: ${config.collection}`);
    console.log(`🌍 Environment: ${config.environment}`);
    console.log(`📊 Reporters: ${reporters.join(', ')}`);
    console.log(`🔄 Iterations: ${iterations}`);
    console.log(`⏱️  Timeout: ${timeout}ms`);
    if (folder) {
        console.log(`📂 Folder: ${folder}`);
    }
    console.log('');
    
    const options = buildNewmanOptions();
    
    return new Promise((resolve, reject) => {
        newman.run(options, (err, summary) => {
            if (err) {
                console.error('❌ Newman run failed:', err);
                reject(err);
                return;
            }
            
            console.log('\n📈 Test execution completed!');
            
            // Generate summary report
            generateSummaryReport(summary);
            
            // Display results
            const stats = summary.run.stats;
            const timings = summary.run.timings;
            
            console.log('\n📊 Results Summary:');
            console.log(`   Requests: ${stats.requests.total - stats.requests.failed}/${stats.requests.total} passed`);
            console.log(`   Assertions: ${stats.assertions.total - stats.assertions.failed}/${stats.assertions.total} passed`);
            console.log(`   Duration: ${timings.completed - timings.started}ms`);
            console.log(`   Average Response Time: ${Math.round(timings.responseAverage)}ms`);
            
            // List generated reports
            console.log('\n📄 Generated Reports:');
            reporters.forEach(reporter => {
                const reportFile = `newman-report-${config.timestamp}.${reporter === 'cli' ? 'txt' : reporter === 'junit' ? 'xml' : reporter}`;
                if (reporter !== 'cli') {
                    const reportPath = path.join(config.reportsDir, reportFile);
                    if (fs.existsSync(reportPath)) {
                        console.log(`   📋 ${reporter.toUpperCase()}: ${reportPath}`);
                    }
                }
            });
            
            // Check for failures
            if (stats.assertions.failed > 0 || stats.requests.failed > 0) {
                console.log('\n❌ Some tests failed!');
                resolve({ success: false, summary });
            } else {
                console.log('\n✅ All tests passed!');
                resolve({ success: true, summary });
            }
        });
    });
}

// Main execution
async function main() {
    console.log('🧪 Newman API Test Runner');
    console.log('=' .repeat(50));
    
    try {
        checkPrerequisites();
        checkApiHealth();
        
        const startTime = Date.now();
        const result = await runTests();
        const endTime = Date.now();
        
        console.log('\n' + '='.repeat(50));
        console.log(`🏁 Test execution ${result.success ? 'completed successfully' : 'failed'}`);
        console.log(`⏱️  Total execution time: ${endTime - startTime}ms`);
        console.log('=' .repeat(50));
        
        process.exit(result.success ? 0 : 1);
        
    } catch (error) {
        console.error('💥 Fatal error:', error.message);
        process.exit(1);
    }
}

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
    console.error('💥 Uncaught exception:', error);
    process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('💥 Unhandled rejection at:', promise, 'reason:', reason);
    process.exit(1);
});

// Run if called directly
if (require.main === module) {
    main();
}

module.exports = {
    config,
    runTests,
    checkPrerequisites,
    checkApiHealth,
    generateSummaryReport
};