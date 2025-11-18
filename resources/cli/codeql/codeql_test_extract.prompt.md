---
mode: 'agent'
---

# Command Resource for `codeql test extract`

The `codeql test extract` command is used to extract test databases from source code for testing purposes.

## Command Summary

```text
Build a dataset for a test directory.

Build a database for a specified test directory, without actually running any test queries. Outputs the path to the raw QL dataset to execute test queries against.
```

## Primary use of `codeql test extract`

The following is an example use of the command for extracting test databases:

```bash
codeql test extract -- languages/<language>/<pack-basename>/test/
```

## Alternative uses of `codeql test extract`

The `codeql test extract` command can also extract specific tests and control the output:

```bash
# Extract a dataset (and create a database) from the test code source file(s)
# found in the specified (unit test) directory, which also should contain either
# the .ql query file to run or (more commonly) a .qlref file that points to the
# .ql query to be tested.
codeql test extract --

# Extract with threads for performance
codeql test extract --threads=4 test/

# Extract with custom options
codeql test extract --ram=8192 test/
```

## Help for `codeql test extract`

Run `codeql test extract --help` for more information.
Run `codeql test extract --help --verbose` for much more information.

## Commands commonly run **BEFORE** `codeql test extract`

- [`codeql pack install`](./codeql_pack_install.prompt.md) - Install library dependencies declared in the test pack before attempting to extract the test dataset. The test pack also declares the extractor and corresponding database schema to use when creating the test database.
- [`codeql resolve queries`](./codeql_resolve_queries.prompt.md) - Resolve the local filesystem path of a target query (or queries)
- [`codeql resolve tests`](./codeql_resolve_tests.prompt.md) - Find and resolve the local filesystem paths of queries and/or query-tests

## Commands commonly run **AFTER** `codeql test extract`

- [`codeql test run`](./codeql_test_run.prompt.md) - Run tests against extracted databases
- [`codeql query run`](./codeql_query_run.prompt.md) - Run queries against extracted test databases
