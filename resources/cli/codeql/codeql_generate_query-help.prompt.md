---
mode: 'agent'
---

# Command Resource for `codeql generate query-help`

The `codeql generate query-help` command is used to get and/or format end-user query help from some `.qhelp`, `.ql`, `.qls` or `.md` file.

## Primary use of `codeql generate query-help`

The primary use case of the `codeql generate query-help` command is to convert from `.qhelp` (XML) files to a more readable `markdown` format:

```bash
codeql generate query-help \
    --format=markdown \
    --output=example/relative-path-to/SomeQuery.md \
    -- example/relative-path-to/SomeQuery.qhelp
```

## Alternative uses of `codeql generate query-help`

The `codeql generate query-help` command can also be used to get the markdown-formatted documentation for a given query (`.ql`) file path:

```bash
codeql generate query-help \
    --format=markdown \
    --output=example/relative-path-to/SomeQuery.md \
    -- example/relative-path-to/SomeQuery.ql
```

## Help for `codeql generate query-help`

Run `codeql generate query-help -h` for more information.
Run `codeql generate query-help -h -vv` for much more information.

## Commands commonly run **BEFORE** `codeql generate query-help`

- Create .qhelp files with query documentation.
- [`codeql resolve queries`](./codeql_resolve_queries.prompt.md) - Resolve queries before generating help.

## Commands commonly run **AFTER** `codeql generate query-help`

- Review and publish generated documentation.
- Update test code and/or expected test results based on the query's documented intent and/or examples.
- [`codeql test run`](./codeql_test_run.prompt.md) - Run the query against its unit tests when test code and expected test results are an accurate reflection of expected test behavior.
