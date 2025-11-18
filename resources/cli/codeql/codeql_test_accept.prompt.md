---
mode: 'agent'
---

# Command Resource for `codeql test accept`

The `codeql test accept` command is used to accept new test results as the expected baseline.

## Command Summary

```text
Accept results of failing unit tests.

This is a convenience command that renames the .actual files left by codeql test run for failing tests into .expected, such that future runs on the tests that give the same output will be considered to pass. What it does can also be achieved by ordinary file manipulation, but you may find its syntax more useful for this special case.

The command-line arguments specify one or more tests -- that is, .ql(ref) files -- and the command automatically derives the names of the .actual files from them. Any test that doesn't have an .actual file will be silently ignored, which makes it easy to accept just the results of failing tests from a previous run.
```

## Primary use of `codeql test accept`

The following is an example use of the command for accepting test results from a previous, failing unit test associated with the query referenced via its .qlref file:

```bash
# Accept results for failing tests associated with the query, where the .qlref file acts as on-disk pointer from the test directory to the query (.ql file) under test.
codeql test accept -- languages/<language>/<pack-basename>/test/<QueryBasename>/<QueryBasename>.qlref
```

## Alternative uses of `codeql test accept`

The `codeql test accept` command can also accept specific tests:

```bash
# Accept results for failing tests in a directory.
codeql test accept -- languages/<language>/<pack-basename>/test/<QueryBasename>/

# Accept results for failing tests associated with a .ql file.
codeql test accept -- languages/<language>/<pack-basename>/src/<QueryBasename>/<QueryBasename>.ql
```

## Help for `codeql test accept`

Run `codeql test accept --help` for more information.
Run `codeql test accept --help --verbose` for much more information.

## Commands commonly run **BEFORE** `codeql test accept`

- [`codeql pack install`](./codeql_pack_install.prompt.md) - Install library dependencies declared in the test pack before attempting to run unit tests for any directory under that test pack.
- [`codeql resolve tests`](./codeql_resolve_tests.prompt.md) - Resolve the local filesystem paths of unit tests and/or queries under some base directory.
- [`codeql test run`](./codeql_test_run.prompt.md) - Run tests to determine the `<QueryBasename>.actual` results. The `codeql test accept` command really just copies the `<QueryBasename>.actual` file to `<QueryBasename>.expected` for a given test directory.

## Commands commonly run **AFTER** `codeql test accept`

- [`codeql test run`](./codeql_test_run.prompt.md) - Re-run tests to verify accepted baselines and/or update the query test status from failing to passing.
