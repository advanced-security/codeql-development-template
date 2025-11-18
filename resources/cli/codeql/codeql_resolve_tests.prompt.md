---
mode: 'agent'
---

# Command Resource for `codeql resolve tests`

The `codeql resolve tests` command is used to find CodeQL unit tests in given directories.

## Primary use of `codeql resolve tests`

The following is an example use of the command for finding all strictly testable queries under the `languages/` directory, which should return a text list of `.qlref` files:

```bash
codeql resolve tests --format=text --strict-test-discovery -- languages/
```

## Alternative uses of `codeql resolve tests`

The `codeql resolve tests` command can be pointed as a query (.ql) file, a query test reference (aka .qlref) file, or a test directory path. Pointing at the query (.ql) file will just resolve the absolute path of that query file, while it is more useful to point at a test directory or a .qlref file with `--strict-test-discovery` set:

```bash
# Resolve tests for a specific .qlref file, using `json` as the output format.
codeql resolve tests --format=json --strict-test-discovery -- \
    languages/<language>/<pack-basename>/test/<QueryBasename>/<QueryBasename>.qlref
```

Which will produce outpout similar to the following:

```json
[
  "/example-path-to/git-base/codeql-development-template/languages/<language>/tools/test/PrintAST/PrintAST.qlref"
]
```

## Help for `codeql resolve tests`

Run `codeql resolve tests -h` for more information.
Run `codeql resolve tests -h -vv` for much more information.

## Commands commonly run **BEFORE** `codeql resolve tests`

- [`codeql pack install`](./codeql_pack_install.prompt.md) - Install library dependencies declared in a CodeQL pack.

## Commands commonly run **AFTER** `codeql resolve tests`

- [`codeql test run`](./codeql_test_run.prompt.md) - Run the resolved tests.
- [`codeql test accept`](./codeql_test_accept.prompt.md) - Accept test results as expected output.
