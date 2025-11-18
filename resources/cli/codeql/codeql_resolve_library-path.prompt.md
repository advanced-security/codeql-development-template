---
mode: 'agent'
---

# Command Resource for `codeql resolve library-path`

The `codeql resolve library-path` command is used to determine the file system paths of installed libraries used in a given CodeQL query.

## Primary use of `codeql resolve library-path`

The following is an example use of the command for a `.ql` query targeting the `cpp` language:

```bash
$ codeql resolve library-path --query languages/cpp/tools/src/PrintAST/PrintAST.ql --format json
{
  "libraryPath" : [
    "/example-path-to/git-base/codeql-development-template/languages/cpp/tools/src",
    "/user/homedir/.codeql/packages/codeql/cpp-all/5.4.1",
    "/user/homedir/.codeql/packages/codeql/dataflow/2.0.13",
    "/user/homedir/.codeql/packages/codeql/mad/1.0.29",
    "/user/homedir/.codeql/packages/codeql/quantum/0.0.7",
    "/user/homedir/.codeql/packages/codeql/rangeanalysis/1.0.29",
    "/user/homedir/.codeql/packages/codeql/ssa/2.0.5",
    "/user/homedir/.codeql/packages/codeql/tutorial/1.0.29",
    "/user/homedir/.codeql/packages/codeql/typeflow/1.0.29",
    "/user/homedir/.codeql/packages/codeql/typetracking/2.0.13",
    "/user/homedir/.codeql/packages/codeql/util/2.0.16",
    "/user/homedir/.codeql/packages/codeql/xml/1.0.29"
  ],
  "dbscheme" : "/user/homedir/.codeql/packages/codeql/cpp-all/5.4.1/semmlecode.cpp.dbscheme",
  "compilationCache" : [
    "/user/homedir/.codeql/compile-cache"
  ],
  "relativeName" : "languages-cpp-tools-src/PrintAST/PrintAST.ql",
  "qlPackName" : "languages-cpp-tools-src"
}
```

## Alternative uses of `codeql resolve library-path`

The `codeql resolve library-path` command can also target a directory (instead of a specific query file):

```bash
$ codeql resolve library-path --dir languages/cpp/tools/src/PrintAST/ --format json
{
  "libraryPath" : [
    "/example-path-to/git-base/codeql-development-template/languages/cpp/tools/src",
    "/user/homedir/.codeql/packages/codeql/cpp-all/5.4.1",
    "/user/homedir/.codeql/packages/codeql/dataflow/2.0.13",
    "/user/homedir/.codeql/packages/codeql/mad/1.0.29",
    "/user/homedir/.codeql/packages/codeql/quantum/0.0.7",
    "/user/homedir/.codeql/packages/codeql/rangeanalysis/1.0.29",
    "/user/homedir/.codeql/packages/codeql/ssa/2.0.5",
    "/user/homedir/.codeql/packages/codeql/tutorial/1.0.29",
    "/user/homedir/.codeql/packages/codeql/typeflow/1.0.29",
    "/user/homedir/.codeql/packages/codeql/typetracking/2.0.13",
    "/user/homedir/.codeql/packages/codeql/util/2.0.16",
    "/user/homedir/.codeql/packages/codeql/xml/1.0.29"
  ],
  "dbscheme" : "/user/homedir/.codeql/packages/codeql/cpp-all/5.4.1/semmlecode.cpp.dbscheme",
  "qlPackName" : "languages-cpp-tools-src"
}
```

## Help for `codeql resolve library-path`

Run `codeql resolve library-path --help` for more information.
Run `codeql resolve library-path --help --verbose` for much more information.

## Commands commonly run **BEFORE** `codeql resolve library-path`

- [`codeql pack install`](./codeql_pack_install.prompt.md) - Install library dependencies declared in a CodeQL pack
- [`codeql resolve queries`](./codeql_resolve_queries.prompt.md) - Resolve which queries to compile

## Commands commonly run **AFTER** `codeql resolve library-path`

- [`codeql query compile`](./codeql_query_compile.prompt.md) - Attempts to compile a CodeQL query (internally uses `codeql resolve library-path` to resolve library paths for compilation)
- [`codeql query run`](./codeql_query_run.prompt.md) - Compiles and runs a local CodeQL query against a local CodeQL database
- [`codeql test run`](./codeql_test_run.prompt.md) - Compiles and runs a local CodeQL query against the test database extracted from the unit test code source file(s)
