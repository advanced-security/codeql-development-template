---
mode: 'agent'
---

# Command Resource for `codeql bqrs info`

The `codeql bqrs info` command is used to display metadata for a BQRS file.

This command displays an overview of the data contained in the compact binary BQRS file that is the result of executing a query. It shows the names and sizes of each result set (table)
in the BQRS file, and the column types of each result set.

It can also optionally precompute offsets for using the pagination options of `codeql bqrs decode`. This is mainly useful for IDE plugins.

## Primary use of `codeql bqrs info`

The following is an example use of the command for inspecting a BQRS file:

```bash
# Show metadata for a `results.bqrs` file in the current working directory.
# Use the (default) text output format.
codeql bqrs info --format=text -- results.bqrs
```

## Alternative uses of `codeql bqrs info`

```bash
# Show metadata for a `results.bqrs` file in the current working directory.
# Use the JSON output format.
codeql bqrs info --format=json -- relative/path-to/results.bqrs
```

## Help for `codeql bqrs info`

Run `codeql bqrs info -h` for more information.
Run `codeql bqrs info -h -vv` for much more information.

## Commands commonly run **BEFORE** `codeql bqrs info`

- [`codeql query run`](./codeql_query_run.prompt.md) - Run queries to generate BQRS files

## Commands commonly run **AFTER** `codeql bqrs info`

- [`codeql bqrs decode`](./codeql_bqrs_decode.prompt.md) - Convert BQRS files to readable formats
