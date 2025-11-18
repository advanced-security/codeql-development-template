---
mode: 'agent'
---

# Command Resource for `codeql resolve metadata`

The `codeql resolve metadata` command is used resolve and return the key-value metadata pairs from a query source file.

## Primary use of `codeql resolve metadata`

The following is an example use of the command for extracting query metadata:

```bash
codeql resolve metadata \
    --format=json \
    -- languages/<language>/<pack-basename>/src/<QueryBasename>/<QueryBasename>.ql
```

## Help for `codeql resolve metadata`

Run `codeql resolve metadata -h` for more information.
Run `codeql resolve metadata -h -vv` for much more information.

## Commands commonly run **BEFORE** `codeql resolve metadata`

- [`codeql resolve queries`](./codeql_resolve_queries.prompt.md) - Resolve query paths before extracting metadata

## Commands commonly run **AFTER** `codeql resolve metadata`

- [`codeql query run`](./codeql_query_run.prompt.md) - Run the query against an existing CodeQL database, which will produce an output .bqrs file containing the Binary Query Results Set (BQRS) from the query run.
- [`codeql test run`](./codeql_test_run.prompt.md) - Run the query against its unit tests after validating query metadata.
