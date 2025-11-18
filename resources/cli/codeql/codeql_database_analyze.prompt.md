---
mode: 'agent'
---

# Command Resource for `codeql database analyze`

The `codeql database analyze` command is used to analyze CodeQL databases by running multiple queries and outputing a single set of results in a target format.

## Primary use of `codeql database analyze`

The following is an example use of the command for analyzing a database with the `security-extended` set of (open-source) queries for the `java` language:

```bash
codeql database analyze \
    --format=sarif-latest \
    --output=results.sarif \
    -- \
    some/path-to/mydb_dir \
    codeql/java-security-extended
```

## Alternative uses of `codeql database analyze`

The `codeql database analyze` command can also target specific queries or directories:

```bash
# Analyze with specific query pack
codeql database analyze --format=csv --output=results.csv mydb codeql/java-queries
```

## Help for `codeql database analyze`

Run `codeql database analyze --help` for more information.
Run `codeql database analyze --help --verbose` for much more information.

## Commands commonly run **BEFORE** `codeql database analyze`

- [`codeql database create`](./codeql_database_create.prompt.md) - Create a CodeQL database to analyze
- [`codeql resolve queries`](./codeql_resolve_queries.prompt.md) - Resolve which queries to analyze

## Commands commonly run **AFTER** `codeql database analyze`

- [`codeql bqrs decode`](./codeql_bqrs_decode.prompt.md) - Process BQRS results from intermediate output
- [`codeql bqrs info`](./codeql_bqrs_info.prompt.md) - Get information about intermediate BQRS results
