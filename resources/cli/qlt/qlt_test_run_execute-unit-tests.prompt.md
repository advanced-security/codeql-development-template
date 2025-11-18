---
mode: 'agent'
---

# QLT Test Run Execute-Unit-Tests Command

## Purpose

Use this prompt to guide the execution of `qlt test run execute-unit-tests` to run unit tests for CodeQL queries within a repository structure.

## Command Synopsis

```bash
qlt test run execute-unit-tests [options]
```

## Description

Runs unit tests within a repository based on the current configuration. Executes tests in parallel for specified languages and generates intermediate output files for validation.

## Key Options

### Required Configuration

- `--num-threads <num-threads>` - **Required** Number of threads for test execution (default: 4, don't exceed physical cores)
- `--work-dir <work-dir>` - **Required** Directory for intermediate execution output files (default: temp directory)
- `--language <lang>` - **Required** Language to run tests for: c, cpp, csharp, go, java, javascript, python, ruby
- `--runner-os <runner-os>` - **Required** Operating system label for test execution

### CodeQL Configuration

- `--codeql-args <codeql-args>` - Extra arguments to pass to CodeQL CLI

### Repository Configuration

- `--base <base>` - Base path to find the query repository (default: current directory)
- `--automation-type <actions>` - Automation type configuration (required, default: actions)

### Development Options

- `--development` - Enable development mode with special QLT features (required, default: False)
- `--use-bundle` - Use custom CodeQL bundle instead of distribution versions (required, default: False)

## How It Works

### Test Discovery

1. Scans the specified language directory for test structures
2. Identifies all test directories with expected results
3. Discovers queries associated with each test
4. Creates execution plan for parallel testing

### Test Execution

1. Compiles queries for testing
2. Creates test databases from source files
3. Executes queries against test databases
4. Compares results with expected outputs
5. Generates execution reports in work directory

## Common Usage Patterns

### Run Java tests with default settings

```bash
qlt test run execute-unit-tests \
  --num-threads=4 \
  --work-dir=/tmp/test-results \
  --language=java \
  --runner-os=linux \
  --automation-type=actions \
  --development=false \
  --use-bundle=false
```

### High-performance test execution

```bash
qlt test run execute-unit-tests \
  --num-threads=8 \
  --work-dir=/tmp/test-results \
  --language=javascript \
  --runner-os=ubuntu-latest \
  --automation-type=actions \
  --development=false \
  --use-bundle=false
```

### With custom CodeQL arguments

```bash
qlt test run execute-unit-tests \
  --num-threads=4 \
  --work-dir=/tmp/test-results \
  --language=python \
  --runner-os=macos-latest \
  --codeql-args="--ram=8192 --threads=2" \
  --automation-type=actions \
  --development=false \
  --use-bundle=false
```

### Development mode testing

```bash
qlt test run execute-unit-tests \
  --num-threads=2 \
  --work-dir=/tmp/test-results \
  --language=csharp \
  --runner-os=windows-latest \
  --automation-type=actions \
  --development=true \
  --use-bundle=false
```

## When to Use

- CI/CD pipeline quality gates for CodeQL queries
- Bulk testing of multiple queries in a language
- Parallel execution for faster test completion
- Automated validation before deployment
- Development workflow verification

## Expected Outputs

### Work Directory Structure

```
work-dir/
├── test-results/
│   ├── <language>/
│   │   ├── execution-log.txt
│   │   ├── test-summary.json
│   │   └── individual-results/
│   │       ├── query1-results.json
│   │       └── query2-results.json
│   └── metadata/
│       ├── execution-metadata.json
│       └── timing-information.json
```

### Console Output

- Test discovery progress
- Parallel execution status
- Pass/fail counts per query
- Overall execution summary
- Performance timing information

### Success Indicators

- Exit code 0 for all tests passing
- Generated result files in work directory
- Summary statistics of test execution

### Failure Indicators

- Exit code 1 for test failures
- Failed test details in result files
- Error logs for compilation or execution issues

## Performance Considerations

### Thread Count Optimization

- Use physical CPU cores count
- Don't exceed system memory limits
- Consider I/O bound operations for disk-intensive tests

### Memory Management

- Large test suites may require additional CodeQL RAM arguments
- Monitor work directory disk usage
- Clean up intermediate files after validation

## Related Commands

- [`qlt test run validate-unit-tests`](./qlt_test_run_validate-unit-tests.prompt.md) - Validate execution results
- [`qlt query run install-packs`](./qlt_query_run_install-packs.prompt.md) - Install dependencies before testing
- [`codeql test run`](../codeql/codeql_test_run.prompt.md) - Individual query testing
