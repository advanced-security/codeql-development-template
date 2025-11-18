---
mode: 'agent'
---

# Command Resource for `codeql test run`

The `codeql test run` command is used to run unit tests for CodeQL queries against test databases.

## Primary use of `codeql test run`

The following is an example use of the command for running tests in a directory:

```bash
# Run unit tests for the query contained in the specified query directory.
# Keep the databases created during the test run for later inspection, such as printing ASTs for test code source files.
# Use `--show-extractor-output` to help debug the extraction phase of the test run.
codeql test run \
    --format=text \
    --keep-databases \
    --show-extractor-output \
    -- languages/<language>/<pack-basename>/src/<QueryBasename>/
```

## Alternative uses of `codeql test run`

The `codeql test run` command supports many arguments and, accordingly, can be run in many different ways. Some common arguments and alternative command patterns include:

```bash
# Run unit tests by pointing at the query (.ql) file, with `--threads=0` set so that
# the tests use one thread per core on the machine.
codeql test run \
    --format=text \
    --keep-databases \
    --show-extractor-output \
    --threads=0 \
    --verbosity=progress+ \
    -- languages/<language>/<pack-basename>/src/<QueryBasename>/<QueryBasename>.ql
```

```bash
# Run tests, with verbose output, for the specified test directory. We pretty much
# always want to `--keep-databases` as this helps with test driven `ql` development.
codeql test run \
    --format=json \
    --keep-databases \
    --show-extractor-output \
    --verbose \
    -- languages/<language>/<pack-basename>/test/<QueryBasename>/
```

```bash
# Run tests with quiet output, while using the .qlref file to reference the query
# under test. Use the `--learn` flag to avoid failing the tests if actual results
# differ from expected and, instead, just copy the `<QueryBasename>.actual` results
# to the `<QueryBasename>.expected` file. Avoids having to wait for tests to fail
# before running `codeql test accept`. Useful when you know you want to update the
# expected results with whatever results the test run actually produces.
codeql test run \
    --format=betterjson \
    --keep-databases \
    --learn \
    --show-extractor-output \
    --quiet \
    -- languages/<language>/<pack-basename>/test/<QueryBasename>/<QueryBasename>.qlref
```

## Help for `codeql test run`

Run `codeql test run -h` for more information.
Run `codeql test run -h -vv` for much more information.

## Commands commonly run **BEFORE** `codeql test run`

- [`codeql pack install`](./codeql_pack_install.prompt.md) - Install library dependencies declared in a CodeQL pack.
- [`codeql query format`](./codeql_query_format.prompt.md) - Ensure correct formatting of `ql` code (in .ql and/or .qll files) as changes are made. The formatting checks can also be useful as a lightweight (pre-compilation) verification step.
- [`codeql query compile`](./codeql_query_compile.prompt.md) - Ensure the query can be compiled before attempting a test run of the query.
- [`codeql resolve tests`](./codeql_resolve_tests.prompt.md) - Find CodeQL unit tests under a specific directory.
- [`codeql test extract`](./codeql_test_extract.prompt.md) - Extract a database from test code source files **WITHOUT** running unit tests. Allows for running queries against the test database, such as a "PrintAST" query that can print an AST graph for any test code source file (in the test database).

## Commands commonly run **AFTER** `codeql test run`

- [`codeql test accept`](./codeql_test_accept.prompt.md) - Accept test results as expected output.
- [`codeql test run`](./codeql_test_run.prompt.md) - Run unit tests (again) after changing the query and/or test command arguments.
