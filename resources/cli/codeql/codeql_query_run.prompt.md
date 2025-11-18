---
mode: agent
---

# Command Resource for `codeql query run`

The `codeql query run` command is used to execute a single CodeQL query against a database.

## Primary use of `codeql query run`

The following is an example use of the command for running the local `PrintAST.ql` query against an existing database:

```bash
codeql query run \
  --database=relative-path/to-some/<language>-db \
  --external=selectedSourceFile=data_selectedSourceFile.csv \
  --output=results_<language>-db_PrintAST.bqrs \
  --timeout=300 \
  -- languages/<language>/tools/src/PrintAST/PrintAST.ql
```

## Advanced uses of `codeql query run`

### Using external predicates with CSV data

CodeQL queries can accept external data through CSV files for external predicates. This allows you to provide custom data to queries:

```bash
# Provide external predicate data via CSV files
codeql query run \
  --database=/path/to/db \
  --external=myExternalPredicate=data_myExternalPredicate.csv \
  --external=anotherExternalPredicate=data_anotherExternalPredicate.csv \
  --evaluator-log=evaluator-log_<language>-db_SomeQuery.json.txt \
  --evaluator-log-minify \
  --output=results_SomeQuery.bqrs \
  --timeout=300 \
  -- SomeQuery.ql
```

Example CSV file (`data.csv`):

```csv
value1,value2,value3
"string1",123,"string2"
"string3",456,"string4"
```

Example query using external predicates:

```ql
/**
 * @name Query with External Data
 * @description Uses external predicate data from CSV
 * @kind table
 */

// External predicate populated from CSV via --external
external predicate myExternalPredicate(string col1, int col2, string col3);

from string a, int b, string c
where myExternalPredicate(a, b, c)
select a, b, c
```

### Outputting structured evaluator logs via `codeql query run`

The `--evaluator-log` and `--evaluator-log-minify` options can be used with the `codeql query run` command in order to generate detailed logs about (query) evaluator performance and behavior for that specific query run.

From the command help:

```text
--evaluator-log=<file> [Advanced] Output structured logs about evaluator performance to the given
                        file. The format of this log file is subject to change with no notice,
                        but will be a stream of JSON objects separated by either two newline
                        characters (by default) or one if the --evaluator-log-minify option is
                        passed. Please use codeql generate log-summary <file> to produce a more
                        stable summary of this file, and avoid parsing the file directly. The
                        file will be overwritten if it already exists.

--evaluator-log-minify [Advanced] If the --evaluator-log option is passed, also passing this
                        option will minimize the size of the JSON log produced, at the expense
                        of making it much less human readable.
```

## Help for `codeql query run`

Run `codeql query run --help` for more information.
Run `codeql query run --help --verbose` for much more information.

## Commands commonly run **BEFORE** `codeql query run`

- [`codeql database create`](./codeql_database_create.prompt.md) - Create a CodeQL database to query
- [`codeql query compile`](./codeql_query_compile.prompt.md) - Compile queries before running
- [`codeql pack install`](./codeql_pack_install.prompt.md) - Install library dependencies declared in a CodeQL pack

## Commands commonly run **AFTER** `codeql query run`

- [`codeql bqrs decode`](./codeql_bqrs_decode.prompt.md) - Process BQRS results from saved output
- [`codeql bqrs info`](./codeql_bqrs_info.prompt.md) - Get information about BQRS results
