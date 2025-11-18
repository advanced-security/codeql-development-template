---
mode: 'agent'
---

# Command Resource for `codeql resolve queries`

The `codeql resolve queries` command is used to resolve the file paths of CodeQL queries on the local system. Query paths can be resolved for any existing (or installed):

- directory
- query
- suite
- pack

## Primary use of `codeql resolve queries`

The following is an example use of the `codeql resolve queries` command when targeting a directory:

```bash
codeql resolve queries --format=bylanguage -- languages/
```

Which will produce output similar to the following:

```json
{
  "byLanguage": {
    "cpp": {
      "/example-path-to/git-base/codeql-development-template/languages/cpp/tools/src/PrintAST/PrintAST.ql": {}
    }
  },
  "noDeclaredLanguage": {},
  "multipleDeclaredLanguages": {}
}
```

## Alternative uses of `codeql resolve queries`

The `codeql resolve queries` command can also resolve the local file paths of queries from installed query packs.

To resolve the queries from the core query query-pack for a given supported `<language>` value, run:

```bash
codeql resolve queries --format=json -- codeql/<language>-queries
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

## Help for `codeql resolve queries`

Run `codeql resolve queries -h` for more information.
Run `codeql resolve queries -h -vv` for much more information.

## Command commonly run **BEFORE** `codeql resolve queries`

- [`codeql pack ls`](./codeql_pack_ls.prompt.md) - List the CodeQL packs under some local directory path
- [`codeql pack install`](./codeql_pack_install.prompt.md) - Install library dependencies declared in a CodeQL pack

## Commands commonly run **AFTER** `codeql resolve queries`

- [`codeql resolve library-path`](./codeql_resolve_library-path.prompt.md) - Resolve the local paths of CodeQL library dependencies for a given directory or query path
- [`codeql resolve metadata`](./codeql_resolve_metadata.prompt.md) - Extract metadata from a given, local query path
- [`codeql resolve tests`](./codeql_resolve_tests.prompt.md) - Find QL unit tests in given, local directories
- [`codeql query run`](./codeql_query_run.prompt.md) - Compiles and runs a local CodeQL query against a local CodeQL database
- [`codeql test run`](./codeql_test_run.prompt.md) - Compiles and runs a local CodeQL query against the test database extracted from the unit test code source file(s)
