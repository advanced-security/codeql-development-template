---
mode: 'agent'
---

# Command Resource for `codeql resolve database`

The `codeql resolve database` command is used to report metadata about a CodeQL database.

## Primary use of `codeql resolve database`

The following is an example use of the command for getting metadata about the test database for
an example `<language>` (e.g. `actions`, `cpp`, `csharp, `go`, `java`, `javascript`, `python`, 'ruby`), `<pack-basename>`, and `<QueryBasename>`:

```bash
$ codeql resolve database -- languages/<language>/<pack-basename>/test/<QueryBasename>/<QueryBasename>.testproj
```

## Alternative uses of `codeql resolve database`

The `codeql resolve database` command can also provide different levels of detail:

```bash
# Get metadata about some CodeQL database via its absolute local directory path
codeql resolve database -- /some/other-repo/or-dir/path-to/existing-codeql-database-dir
```

## Help for `codeql resolve database`

Run `codeql resolve database --help` for more information.
Run `codeql resolve database --help --verbose` for much more information.

## Commands commonly run **BEFORE** `codeql resolve database`

- [`codeql database create`](./codeql_database_create.prompt.md) - Create a new CodeQL database
- [`codeql test extract`](./codeql_test_extract.prompt.md) - Create a test CodeQL database from the source code files in the target test directory **WITHOUT** running unit tests.
- [`codeql test run`](./codeql_test_run.prompt.md) - Create a test CodeQL database from the source code files in the target test directory **WHILE** running unit tests.

## Commands commonly run **AFTER** `codeql resolve database`

- [`codeql query run`](./codeql_query_run.prompt.md) - Run queries against the resolved database
- [`codeql database analyze`](./codeql_database_analyze.prompt.md) - Analyze the resolved database
