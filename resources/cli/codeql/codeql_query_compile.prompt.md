---
mode: 'agent'
---

# Command Resource for `codeql query compile`

The `codeql query compile` command is used to compile CodeQL queries to check for syntax and semantic errors.

## Primary use of `codeql query compile`

The following is an example use of the command for compiling a query:

```bash
# Just check that the QL is valid and print any errors
# Do not actually optimize and store a query plan.
# This can be much faster than a full compilation.
# Use default options for `--format` and `--warnings` arguments.
codeql query compile \
    --check-only \
    --format=text \
    --warnings=show \
    -- languages/<language>/<pack-basename>/src/<QueryBasename>/<QueryBasename>.ql
```

## Alternative uses of `codeql query compile`

The `codeql query compile` command can also supports many options:

```bash
# Just check that the QL is valid and print any errors.
# Use the `json` output format and hide/suppress warning-level compilation messages.
# Don't check embedded query metadata in QLDoc comments for validity.
codeql query compile \
    --check-only \
    --format=json \
    --no-metadata-verification \
    --warnings=hide \
    -- languages/<language>/<pack-basename>/src/<QueryBasename>/<QueryBasename>.ql
```

```bash
# Perform full compilation of the query, even though using `--check-only` would be much faster.
# Use the `json` output format and treat warning-level compilation messages as errors.
codeql query compile \
    --format=json \
    --warnings=error \
    -- languages/<language>/<pack-basename>/src/<QueryBasename>/<QueryBasename>.ql
```

## Help for `codeql query compile`

Run `codeql query compile -h` for more information.
Run `codeql query compile -h -vv` for much more information.

## Commands commonly run **BEFORE** `codeql query compile`

- [`codeql pack install`](./codeql_pack_install.prompt.md) - Install library dependencies declared in a CodeQL pack
- [`codeql resolve library-path`](./codeql_resolve_library-path.prompt.md) - Resolve the local paths of CodeQL library dependencies

## Commands commonly run **AFTER** `codeql query compile`

- [`codeql query run`](./codeql_query_run.prompt.md) - Run the compiled query against a database
- [`codeql query format`](./codeql_query_format.prompt.md) - Format the compiled query source code
