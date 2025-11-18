---
mode: agent
---

# Command Resource for `qlt query generate new-query`

## Purpose

Use this prompt to guide the execution of `qlt query generate new-query` to generate new CodeQL queries with associated tests and pack structures.

## Primary use of `qlt query generate new-query`

The `qlt query generate new-query` generates the scaffolding for a single, new CodeQL query for some supported `--language`.

This repository expects you to use `--pack custom` or `--pack example` for any new query, regardless of `--language` value.

```bash
qlt query generate new-query --base languages/ --language <language> --pack <custom> --query-name <QueryBasename>
```

Where `<language>` is the programming language to be analyzed by the query and can be one of:

- `actions`
- `cpp`
- `csharp`
- `go`
- `java`
- `javascript`
- `python`
- `ruby`

## Description

Generates a new CodeQL query and associated tests, with optional automatic creation of query packs. Provides scaffolding for different query types and handles proper directory structure organization.

## Key Options

### Required Arguments

- `--query-name <QueryBasename>` - **Required** Name of the query (without .ql extension)
- `--language <lang>` - **Required** Target language: c, cpp, csharp, go, java, javascript, python, ruby
- `--pack <pack>` - **Required** Name of the query pack to place this query in

### Query Configuration

- `--query-kind <kind>` - Type of query to generate:
  - `problem` (default): Standard problem query
  - `path-problem`: Path-problem query for dataflow analysis
- `--scope <scope>` - Optional scope for the query

### Generation Control

- `--create-query-pack` - Create new query pack if none exists (default: True)
- `--create-tests` - Create unit test for this query (default: True)
- `--overwrite-existing` - Overwrite existing files if they exist (default: False)

### Repository Configuration

- `--base <base>` - Base directory from which to generate the pack, query and unit test files

## Generated File Structure

```
languages/<language>/<pack>/
├── src/
│   ├── qlpack.yml                # Query pack configuration
│   └── <QueryBasename>/             # Query source directory for <QueryBasename>
│       ├── <QueryBasename>.ql       # Query file for <QueryBasename>
│       └── <QueryBasename>.md       # Query documentation for <QueryBasename>
└── test/
    ├── qlpack.yml                # Test pack configuration
    └── <QueryBasename>/             # Test directory for <QueryBasename>
        ├── <QueryBasename>.<ext>    # Test code source file with <ext> matching target language file extension
        ├── <QueryBasename>.expected # Expected results for test run of <QueryBasename>
        └── <QueryBasename>.qlref    # Test reference file for <QueryBasename>
```

## Common Usage Patterns

### Generate basic security query

```bash
qlt query generate new-query \
  --base languages/ \
  --query-name=MyExampleQuery1 \
  --language=java \
  --pack=custom \
  --query-kind=problem
```

### Generate dataflow query

```bash
qlt query generate new-query \
  --base languages/ \
  --language=javascript \
  --pack=custom \
  --query-kind=path-problem \
  --query-name=MyExampleQuery2
```

### Overwrite existing query

```bash
qlt query generate new-query \
  --base languages/ \
  --language=csharp \
  --pack=custom \
  --overwrite-existing=true \
  --query-name=MyExistingQuery1
```

### Skip test generation

```bash
qlt query generate new-query \
  --base languages/ \
  --language=go \
  --pack=custom \
  --query-name=simple-query \
  --create-tests=false \
  --overwrite-existing=true
```

## When to Use

- Creating new CodeQL queries from scratch
- Setting up query development environments
- Standardizing query and test structure across projects
- Rapid prototyping of security or quality analyses
- Educational purposes for learning CodeQL development

## Expected Outputs

- Generated query file with appropriate template
- Test directory structure with test files
- Query pack configuration (if created)
- Progress messages showing generation status

## Query Templates

### Problem Query Template

- Basic structure with imports
- Select statement for problem reporting
- Placeholder predicates for customization
- Standard metadata annotations

### Path-Problem Query Template

- Dataflow analysis imports
- Source and sink definitions
- `@kind path-problem` query structure
- Flow configuration boilerplate

## Related Commands

- [`qlt query run install-packs`](./qlt_query_run_install-packs.prompt.md) - Install dependencies for generated queries
- [`qlt test run execute-unit-tests`](./qlt_test_run_execute-unit-tests.prompt.md) - Run tests for generated queries
- [`codeql query compile`](../codeql/codeql_query_compile.prompt.md) - Compile generated queries
