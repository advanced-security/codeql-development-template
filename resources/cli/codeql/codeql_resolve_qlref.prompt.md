---
mode: 'agent'
---

# Command Resource for `codeql resolve qlref`

The `codeql resolve qlref` command is used to dereference a .qlref file to return a .ql one.

The CLI command accepts a .qlref file and returns the .ql file that it points to.

This is useful because the entire contents of a typical `.qlref` file will just be a single file path, relative to the directory of the query-pack for the referenced query, where the `codeql resolve qlref` command does the work of resolving library paths plus the pack-relative path to yield a single, absolute file path of the referenced query.

## Primary use of `codeql resolve qlref`

The following is an example use of the `codeql resolve qlref` command when targeting a `.qlref` file:

```bash
codeql resolve qlref -- languages/<language>/tools/PrintAST/PrintAST.qlref
```

Which should return output similar to the following

```json
{
  "resolvedPath": "/example-path-to/git-base/codeql-development-template/languages/<language>/tools/src/PrintAST/PrintAST.ql",
  "resolvedPostprocessingPaths": []
}
```

## Alternative uses of `codeql resolve qlref`

The `codeql resolve qlref` command can also resolve the local file paths of queries from installed query packs.

To resolve the queries from the core query query-pack for a given supported `<language>` value, run:

```bash
codeql resolve qlref --format=json -- codeql/<language>-queries
```

The following query-packs should be pre-installed in any workspace created for this repository, but you can (re)install them using the `codeql pack install` command:

- `codeql/actions-queries`
- `codeql/cpp-queries`
- `codeql/csharp-queries`
- `codeql/go-queries`
- `codeql/java-queries`
- `codeql/javascript-queries`
- `codeql/python-queries`
- `codeql/ruby-queries`

## Help for `codeql resolve qlref`

Run `codeql resolve qlref -h` for more information.
Run `codeql resolve qlref -h -vv` for much more information.

## Command commonly run **BEFORE** `codeql resolve qlref`

- [`codeql resolve tests`](./codeql_resolve_tests.prompt.md) - Find QL unit tests in given, local directories

## Commands commonly run **AFTER** `codeql resolve qlref`

- [`codeql query run`](./codeql_query_run.prompt.md) - Compiles and runs a local CodeQL query against a local CodeQL database
- [`codeql test run`](./codeql_test_run.prompt.md) - Compiles and runs a local CodeQL query against the test database extracted from the unit test code source file(s)
