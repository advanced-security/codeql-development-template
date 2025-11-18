---
mode: agent
---

# CLI Resources Reference

This document summarizes and links to the files in this repository that provide "resources" (i.e. static descriptions) of CLI tools that are pre-installed for workspaces created from this repository. These CLI resource prompts are intended for use by GitHub Copilot (or other agentic LLM) in aid of various tasks in the CodeQL development lifecycle.

## Summary of Pre-Installed CLI Tools

- `codeql` - The primary, low-level CLI tool for working with individual CodeQL databases, packs, queries, and tests.
- `qlt` - A higher-level CLI tool that is useful for tasks such as:
  - Installing different versions of the `codeql` CLI;
  - Performing development tasks for multiple CodeQL packs, queries, and/or tests;
  - Creating the directories and files required for fully setting up a new query along with its packs and tests.

## `codeql` CLI Tool Resources

The `codeql` CLI has many subcommands -- we will not use all of them.
Just pick the subcommands from the list below according to your needs.

- [codeql bqrs decode](../../resources/cli/codeql/codeql_bqrs_decode.prompt.md) - Decode a .bqrs (Binary Query Results Set) file -- the raw output of a query run against a database -- to some human-readable format.
- [codeql bqrs info](../../resources/cli/codeql/codeql_bqrs_info.prompt.md) - Display metadata about binary query result files.
- [codeql database analyze](../../resources/cli/codeql/codeql_database_analyze.prompt.md) - Run queries against CodeQL databases and interpret results.
- [codeql database create](../../resources/cli/codeql/codeql_database_create.prompt.md) - Create CodeQL databases from source code.
- [codeql execute query-server2](../../resources/cli/codeql/codeql_execute_query-server2.prompt.md) - Run a persistent query execution server for IDE integrations and efficient multi-query workflows.
- [codeql generate extensible-predicate-metadata](../../resources/cli/codeql/codeql_generate_extensible-predicate-metadata.prompt.md) - Generate metadata for extensible predicates.
- [codeql generate log-summary](../../resources/cli/codeql/codeql_generate_log-summary.prompt.md) - Create a summary of structured evaluator log files for performance analysis and debugging.
- [codeql generate query-help](../../resources/cli/codeql/codeql_generate_query-help.prompt.md) - Generate help documentation for queries.
- [codeql pack install](../../resources/cli/codeql/codeql_pack_install.prompt.md) - Install CodeQL packs and their (pack) dependencies.
- [codeql pack ls](../../resources/cli/codeql/codeql_pack_ls.prompt.md) - List available CodeQL packs.
- [codeql query compile](../../resources/cli/codeql/codeql_query_compile.prompt.md) - Compile CodeQL queries and check for syntax errors.
- [codeql query format](../../resources/cli/codeql/codeql_query_format.prompt.md) - Format CodeQL query source code.
- [codeql query run](../../resources/cli/codeql/codeql_query_run.prompt.md) - Execute single CodeQL queries against databases.
- [codeql resolve database](../../resources/cli/codeql/codeql_resolve_database.prompt.md) - Resolve database paths and validate database structure.
- [codeql resolve extractor](../../resources/cli/codeql/codeql_resolve_extractor.prompt.md) - Resolve language extractors and their configurations.
- [codeql resolve languages](../../resources/cli/codeql/codeql_resolve_languages.prompt.md) - List supported programming languages and their extractors.
- [codeql resolve library-path](../../resources/cli/codeql/codeql_resolve_library-path.prompt.md) - Resolve library search paths for CodeQL compilation.
- [codeql resolve metadata](../../resources/cli/codeql/codeql_resolve_metadata.prompt.md) - Resolve query metadata and pack information.
- [codeql resolve queries](../../resources/cli/codeql/codeql_resolve_queries.prompt.md) - Find and resolve query files in packs.
- [codeql resolve tests](../../resources/cli/codeql/codeql_resolve_tests.prompt.md) - Discover test files and test suites.
- [codeql test accept](../../resources/cli/codeql/codeql_test_accept.prompt.md) - Accept test results as new expected outcomes.
- [codeql test extract](../../resources/cli/codeql/codeql_test_extract.prompt.md) - Extract test databases from source code.
- [codeql test run](../../resources/cli/codeql/codeql_test_run.prompt.md) - Execute CodeQL query tests and validate results.

## QLT CLI Tool Resources

The `qlt` (CodeQL Development Toolkit) CLI is primarily used for creating the scaffolding for a new query and its packs (if not already created) and unit test setup. For most iterative `ql` development tasks, the `codeql` CLI is usually a better choice as the `qlt` CLI is intended for CI/CD workflows that operate on all the CodeQL queries for some base directory and/or langauge and/or pack. As such, you should only run `qlt` subcommands (other than `qlt query generate new-query`) if you are really extra sure that you want to perform operations that affect much more than just one query, pack, or test.

### Commonly Used `qlt Subcommands

- [qlt query generate new-query](../../resources/cli/qlt/qlt_query_generate_new-query.prompt.md) - Generate the scaffolding for a new CodeQL query, including directories and files for (src & test) packs, the query itself, and unit testing of the query.

### Rarely Used `qlt` Subcommands

- [qlt query run install-packs](../../resources/cli/qlt/qlt_query_run_install-packs.prompt.md) - Install **ALL** packs, for **ALL** languages, found under a given `--base` directory.
- [qlt test run execute-unit-tests](../../resources/cli/qlt/qlt_test_run_execute-unit-tests.prompt.md) - Execute **ALL** unit tests for all queries for a given `--base` directory and/or language.
- [qlt test run validate-unit-tests](../../resources/cli/qlt/qlt_test_run_validate-unit-tests.prompt.md) - Debug / report on the results from the output directory created by running `qlt test run execute-unit-tests`.
