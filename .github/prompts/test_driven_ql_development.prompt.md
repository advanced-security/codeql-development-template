---
mode: agent
---

# Test-Driven Development (TDD) of `ql` Code

## Test-Driven CodeQL Query Development

### Standard TDD Workflow

```bash
# The following new-query example command uses `cpp` as the target language.
# IMPORTANT: QLT currently only supports limited languages: [cpp, javascript]
# For Go, Python, Ruby, Java, C#, Actions - create directory structure manually
# For detailed usage information, see the CLI reference below
qlt query generate new-query \
    --base /some/base-path \
    --language cpp \
    --pack custom \
    --query-name SomeQuery

# For unsupported languages (Go, Python, Ruby, etc), create structure manually:
# mkdir -p /some/base-path/{language}/custom/src/SomeQuery
# mkdir -p /some/base-path/{language}/custom/test/SomeQuery

# Ensure src and test pack dependencies are installed before working on the query.
# Library imports are not valid until src pack dependencies are installed locally.
# NOTE: May fail with network connectivity issues in sandboxed environments
# For detailed usage information, see the CLI reference below
codeql pack install \
    /some/base-path/cpp/custom/src \
    /some/base-path/cpp/custom/test

### Begin generative AI steps for tests ###
# 1. Generate replacement contents for query documentation file.
# 2. Generate replacement contents for test code source file.
# 3. For Go: Create go.mod file in test directory (required for extraction)
# 4. Generate replacement contents for `SomeQuery.expected` test results file.
### End of generative AI steps for tests ###

# Extract a dataset (minimal CodeQL database) from the test code source file,
# which allows for running (e.g. PrintAST) queries against a test database.
# For detailed usage information, see the CLI reference below
codeql test extract \
    --search-path=/some/base-path/cpp/custom \
    -- /some/base-path/cpp/custom/test/SomeQuery/

# Run the PrintAST query against the test database to get the AST
# graph representation of the test code file.
# For detailed usage information, see the CLI reference below
codeql query run \
    --database=/some/base-path/cpp/custom/test/SomeQuery/SomeQuery.testproj \
    --output=/some/base-path/cpp/custom/test/SomeQuery/SomeQuery_PrintAST.bqrs \
    --search-path=/path-to-repo/languages/cpp/core/ \
    -- /path-to-repo/languages/cpp/core/PrintAST/PrintAST.ql

# Decode the PrintAST query results to output a text representation.
# For detailed usage information, see the CLI reference below
codeql bqrs decode \
    --format=text \
    --output=/some/base-path/cpp/custom/test/SomeQuery/SomeQuery_PrintAST.txt \
    -- /some/base-path/cpp/custom/test/SomeQuery/SomeQuery_PrintAST.bqrs

### Begin generative AI steps for query ###
# 1. Generate replacement contents for query file.
# 2. Save the update SomeQuery.ql file.
### End of generative AI steps for query ###

# The query must be compilable before it is runnable (for testing).
# For detailed usage information, see the CLI reference below
codeql query compile \
    --check-only \
    --search-path=/some/base-path/cpp/custom \
    -- /some/base-path/cpp/custom/src/SomeQuery/SomeQuery.ql

# If the query compiles, run the tests to validate that actual test results match expected.
# IMPORTANT: .qlref files must use simple paths (e.g., "SomeQuery/SomeQuery.ql")
# and search-path must include the directory containing the query subdirectory
# For detailed usage information, see the CLI reference below
codeql test run \
    --search-path=/some/base-path/cpp/custom/src \
    -- /some/base-path/cpp/custom/test/SomeQuery/SomeQuery.qlref
```

### Optimized TDD Workflow with Query Server

**Important Note**: The `codeql execute query-server2` command is designed for IDE integration via JSON protocol over stdin/stdout. For command-line TDD workflows, the standard `codeql query run` provides adequate performance with compilation caching.

For iterative development with multiple query executions, the standard workflow benefits from automatic caching:

```bash
# Initial setup - same as standard workflow
qlt query generate new-query \
    --base /some/base-path \
    --language cpp \
    --pack custom \
    --query-name SomeQuery

codeql pack install \
    /some/base-path/cpp/custom/src \
    /some/base-path/cpp/custom/test

### Begin generative AI steps for tests (same as standard workflow) ###

# Extract test database (same as standard workflow)
codeql test extract \
    --search-path=/some/base-path/cpp/custom \
    -- /some/base-path/cpp/custom/test/SomeQuery/

# Query execution benefits from automatic compilation caching
# First run: ~35s compilation + 2.5s evaluation
# Subsequent runs: cached compilation + 2.5s evaluation
codeql query run \
    --database=/some/base-path/cpp/custom/test/SomeQuery/SomeQuery.testproj \
    --output=/tmp/results.bqrs \
    --search-path=/some/base-path/cpp/custom/src \
    -- /some/base-path/cpp/custom/src/SomeQuery/SomeQuery.ql

### Begin generative AI steps for query (same as standard workflow) ###

# Final test validation uses the standard test command
codeql test run \
    --search-path=/some/base-path/cpp/custom/src \
    -- /some/base-path/cpp/custom/test/SomeQuery/SomeQuery.qlref
```

**Query Server Use Cases**: The query-server2 is primarily useful for:

- IDE extensions requiring persistent query execution contexts
- Tools needing template variable support for contextual queries
- Applications requiring the JSON protocol for communication

## CLI Command References

The following links provide detailed usage information for each CLI command mentioned in this workflow:

### Primary Commands Used in Test-Driven Development

- [qlt query generate new-query](../../resources/cli/qlt/qlt_query_generate_new-query.prompt.md) - Generate scaffolding for new CodeQL query with packs and tests
- [codeql pack install](../../resources/cli/codeql/codeql_pack_install.prompt.md) - Install CodeQL packs and their dependencies
- [codeql test extract](../../resources/cli/codeql/codeql_test_extract.prompt.md) - Extract test databases from source code
- [codeql query run](../../resources/cli/codeql/codeql_query_run.prompt.md) - Execute single CodeQL queries against databases
- [codeql execute query-server2](../../resources/cli/codeql/codeql_execute_query-server2.prompt.md) - Run persistent query execution server for efficient multi-query workflows
- [codeql bqrs decode](../../resources/cli/codeql/codeql_bqrs_decode.prompt.md) - Decode binary query results to human-readable format
- [codeql query compile](../../resources/cli/codeql/codeql_query_compile.prompt.md) - Compile CodeQL queries and check for syntax errors
- [codeql test run](../../resources/cli/codeql/codeql_test_run.prompt.md) - Execute CodeQL query tests and validate results

### Additional Useful Commands

For reference, here are other commonly used CLI commands in CodeQL query development:

- [codeql bqrs info](../../resources/cli/codeql/codeql_bqrs_info.prompt.md) - Display metadata about binary query result files
- [codeql database analyze](../../resources/cli/codeql/codeql_database_analyze.prompt.md) - Run queries against CodeQL databases and interpret results
- [codeql database create](../../resources/cli/codeql/codeql_database_create.prompt.md) - Create CodeQL databases from source code
- [codeql query format](../../resources/cli/codeql/codeql_query_format.prompt.md) - Format CodeQL query source code
- [codeql test accept](../../resources/cli/codeql/codeql_test_accept.prompt.md) - Accept test results as new expected outcomes
- [qlt query run install-packs](../../resources/cli/qlt/qlt_query_run_install-packs.prompt.md) - Install all packs under a `--base` directory (i.e. for the entire repo). Errors if any pack installation fails.
- [qlt test run execute-unit-tests](../../resources/cli/qlt/qlt_test_run_execute-unit-tests.prompt.md) - Execute all unit tests for queries
- [qlt test run validate-unit-tests](../../resources/cli/qlt/qlt_test_run_validate-unit-tests.prompt.md) - Debug/report on unit test execution results
