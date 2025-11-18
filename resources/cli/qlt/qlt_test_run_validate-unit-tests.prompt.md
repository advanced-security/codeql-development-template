---
mode: 'agent'
---

# QLT Test Run Validate-Unit-Tests Command

## Purpose

Use this prompt to guide the execution of `qlt test run validate-unit-tests` to validate unit test results in a CI/CD-suitable format.

## Command Synopsis

```bash
qlt test run validate-unit-tests [options]
```

## Description

Validates unit test run results in a fashion suitable for use in CI/CD systems. Processes intermediate execution output files and provides formatted results with appropriate exit codes for automation workflows.

## Key Options

### Required Configuration

- `--results-directory <results-directory>` - **Required** Directory containing intermediate execution output files

### Output Control

- `--pretty-print` - **Required** Pretty print test output in compact format (default: False)
  - **Note**: When enabled, does not exit with failure code if tests fail

### Repository Configuration

- `--base <base>` - Base path to find the query repository (default: current directory)
- `--automation-type <actions>` - Automation type configuration (required, default: actions)

### Development Options

- `--development` - Enable development mode with special QLT features (required, default: False)
- `--use-bundle` - Use custom CodeQL bundle instead of distribution versions (required, default: False)

## How It Works

### Result Processing

1. Reads intermediate execution files from results directory
2. Parses test outcomes and execution metadata
3. Aggregates results across all executed tests
4. Formats output for consumption by CI/CD systems

### Exit Code Behavior

- **Standard mode**: Exit code 1 if any tests failed, 0 if all passed
- **Pretty-print mode**: Always exit code 0 (for display purposes only)

## Common Usage Patterns

### Standard CI/CD validation

```bash
qlt test run validate-unit-tests \
  --results-directory=/tmp/test-results \
  --pretty-print=false \
  --automation-type=actions \
  --development=false \
  --use-bundle=false
```

### Human-readable output (for debugging)

```bash
qlt test run validate-unit-tests \
  --results-directory=/tmp/test-results \
  --pretty-print=true \
  --automation-type=actions \
  --development=false \
  --use-bundle=false
```

### Custom results directory

```bash
qlt test run validate-unit-tests \
  --results-directory=/path/to/custom/results \
  --pretty-print=false \
  --automation-type=actions \
  --development=false \
  --use-bundle=false
```

### Development mode validation

```bash
qlt test run validate-unit-tests \
  --results-directory=/tmp/test-results \
  --pretty-print=false \
  --automation-type=actions \
  --development=true \
  --use-bundle=false
```

## Input Directory Structure

### Expected Results Directory

```
results-directory/
├── test-results/
│   ├── <language>/
│   │   ├── execution-log.txt
│   │   ├── test-summary.json
│   │   └── individual-results/
│   │       ├── query1-results.json
│   │       ├── query2-results.json
│   │       └── ...
│   └── metadata/
│       ├── execution-metadata.json
│       └── timing-information.json
└── other-output-files...
```

## Output Formats

### Standard Mode Output

```
Test Validation Summary:
========================
Total Tests: 25
Passed: 23
Failed: 2
Execution Time: 45.2 seconds

Failed Tests:
- languages/java/custom/security/sql-injection: Expected 3 results, got 2
- languages/python/custom/quality/unused-import: Compilation failed

Exit Code: 1
```

### Pretty-Print Mode Output

```
╔══════════════════════════════════════════════════════════════╗
║                    Test Validation Results                   ║
╠══════════════════════════════════════════════════════════════╣
║ Total Tests: 25                                              ║
║ ✅ Passed: 23                                                ║
║ ❌ Failed: 2                                                 ║
║ ⏱️  Execution Time: 45.2 seconds                            ║
╠══════════════════════════════════════════════════════════════╣
║ Failed Test Details:                                         ║
║ • sql-injection: Result count mismatch                      ║
║ • unused-import: Compilation error                          ║
╚══════════════════════════════════════════════════════════════╝

Exit Code: 0 (pretty-print mode)
```

## When to Use

- CI/CD pipeline final validation step
- Automated test result processing
- Quality gate enforcement in development workflows
- Test result aggregation and reporting
- Debugging test execution issues

## CI/CD Integration

### GitHub Actions Example

```yaml
- name: Execute Tests
  run: |
    qlt test run execute-unit-tests \
      --num-threads=4 \
      --work-dir=/tmp/test-results \
      --language=java \
      --runner-os=ubuntu-latest

- name: Validate Results
  run: |
    qlt test run validate-unit-tests \
      --results-directory=/tmp/test-results \
      --pretty-print=false
```

### Jenkins Pipeline Example

```groovy
stage('Validate Tests') {
    steps {
        sh '''
            qlt test run validate-unit-tests \
              --results-directory=${WORKSPACE}/test-results \
              --pretty-print=false
        '''
    }
}
```

## Expected Outcomes

### Success Case

- Exit code 0
- Summary of all passed tests
- Execution timing information
- Clean validation output

### Failure Case

- Exit code 1 (standard mode only)
- List of failed tests with reasons
- Detailed error information
- Suggestions for resolution

## Related Commands

- [`qlt test run execute-unit-tests`](./qlt_test_run_execute-unit-tests.prompt.md) - Generate test results for validation
- [`codeql test run`](../codeql/codeql_test_run.prompt.md) - Individual test execution for debugging
- [`qlt query generate new-query`](./qlt_query_generate_new-query.prompt.md) - Generate queries with proper test structure
