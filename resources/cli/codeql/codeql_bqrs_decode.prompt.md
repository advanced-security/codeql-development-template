---
mode: 'agent'
---

# Command Resource for `codeql bqrs decode`

The `codeql bqrs decode` command is used to convert a Binary Query Results Set (BQRS) -- created by a `codeql query run` and output to a `.bqrs` file -- into other (i.e. human readable) formats.

## Primary use of `codeql bqrs decode`

The following is an example use of the command for decoding BQRS results to JSON:

```bash
# Decode to standard output (default) when no `--output` file is specified.
codeql bqrs decode --format=json -- /absolute/path-to/results.bqrs
```

## Alternative uses of `codeql bqrs decode`

The `codeql bqrs decode` command can also output in different formats:

```bash
# Decode to `results.json` output file.
codeql bqrs decode --format=json --output=results.json -- relative/path-to/results.bqrs
```

```bash
# Show only columns for url and string entities in the decoded result set
# (i.e. without the internal `id` of each result) output. Assumes that the
# `results.bqrs` file is in the current working directory.
codeql bqrs decode --entities=url,string --format=json -- results.bqrs
```

## Help for `codeql bqrs decode`

```text
Usage: codeql resolve metadata [OPTIONS] -- <file>

Resolve and return the key-value metadata pairs from a query source file.
      <file>                 [Mandatory] Query source file from which to extract metadata.
      --format=json

Common options:
  -h, --help                 Show this help text.
  -v, --verbose              Incrementally increase the number of progress messages printed.
  -q, --quiet                Incrementally decrease the number of progress messages printed.

Some advanced options have been hidden; try --help -v for a fuller view.
```

## Commands commonly run **BEFORE** `codeql bqrs decode`

- [`codeql query run`](./codeql_query_run.prompt.md) - Run queries to generate BQRS files
- [`codeql bqrs info`](./codeql_bqrs_info.prompt.md) - Get information about BQRS files

## Commands commonly run **AFTER** `codeql bqrs decode`

- Analysis and processing of decoded results in external tools or scripts
