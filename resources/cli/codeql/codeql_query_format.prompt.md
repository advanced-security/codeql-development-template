---
mode: 'agent'
---

# Command Resource for `codeql query format`

The `codeql query format` command is used to automatically format CodeQL source code files.

## Primary use of `codeql query format`

The following is an example use of the command for formatting a query file:

```bash
# Format the ExampleQuery.ql file in the current working directory.
codeql query format -i -- ExampleQuery.ql
```

## Alternative uses of `codeql query format`

The `codeql query format` command can also format multiple files and directories:

```bash
# Format all files .ql and/or .qll files in-place (i.e. `-i`) in the
# `relative/path-to/some/queries/` directory.
codeql query format -i -- relative/path-to/some/queries/*.ql*
```

```bash
# Format all queries found in the `queries/` directory. The `--in-place` flag
# is the long version of the `-i` flag.
codeql query format --in-place -- queries/*.ql
```

```bash
# Only check formatting for all queries found in the `queries/` directory.
codeql query format --check-only -- queries/*.ql
```

## Help for `codeql query format`

```text
Usage: codeql query format [OPTIONS] -- [<file>...]
Autoformat QL source code.

      [<file>...]            One or more .ql or .qll source files to autoformat. A dash can be specified to read from standard input.
  -o, --output=<file>        Write the formatted QL code to this file instead of the standard output stream. Must not be given if there is more than one input.
  -i, --[no-]in-place        Overwrite each input file with a formatted version of its content.
      --[no-]check-only      Instead of writing output, exit with status 1 if any input files differ from their correct formatting. A message telling which files differed will be printed
                               to standard error unless you also give -qq.
  -b, --backup=<ext>         When writing a file that already exists, rename the existing file to a backup by appending this extension to its name. If the backup file already exists, it
                               will be silently deleted.
      --no-syntax-errors     If an input file is not syntactically correct QL, pretend that it is already correctly formatted. (Usually such a file causes the command to terminate with
                               an error message).
Common options:
  -h, --help                 Show this help text.
  -v, --verbose              Incrementally increase the number of progress messages printed.
  -q, --quiet                Incrementally decrease the number of progress messages printed.
Some advanced options have been hidden; try --help -v for a fuller view.
```

## Commands commonly run **BEFORE** `codeql query format`

- Edit or create CodeQL query (`.ql`) and/or library (`.qll`) files.

## Commands commonly run **AFTER** `codeql query format`

- [`codeql query compile`](./codeql_query_compile.prompt.md) - Compile the query once formatting has been validated / enforced.
- [`codeql query run`](./codeql_query_run.prompt.md) - Run the formatted query against an existing, local CodeQL database.
- [`codeql test run`](./codeql_test_run.prompt.md) - Run unit tests for the formatted query.
