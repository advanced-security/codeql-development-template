````prompt
---
mode: agent
---

# Command Resource for `codeql execute query-server2`

The `codeql execute query-server2` command is a specialized IDE-oriented query execution server that provides efficient query evaluation through a persistent background process. This command is primarily used by IDE extensions (like VS Code CodeQL extension) to execute multiple queries efficiently without the overhead of starting a new process for each query.

## Primary use of `codeql execute query-server2`

The query-server2 is designed to run as a background daemon process that communicates with IDE clients through standard input/output streams using a special protocol:

```bash
# Start the query server (typically done by IDE extension)
codeql execute query-server2 --threads=4 --timeout=300
```

## Key advantages over `codeql query run`

The query-server2 provides several benefits for interactive development:

- **Persistent process**: Avoids startup overhead for multiple query executions
- **Shared compilation cache**: Compiled queries and library dependencies are cached across runs
- **Template support**: Efficiently handles data extensions and contextual queries
- **Quick evaluation**: Supports rapid evaluation of query fragments during development
- **Protocol-based communication**: Enables sophisticated IDE integrations

## Integration with template-based queries

The query-server2 excels at handling contextual queries that use template variables. IDE extensions use this for features like:

- **Find References**: Pass `selectedSourceFile`, `selectedSourceLine`, `selectedSourceColumn`
- **Print AST**: Pass `selectedSourceFile` to focus on specific files
- **Print CFG**: Pass file and position data for control flow analysis

Template variables are passed through the query-server2 JSON protocol, not via CLI arguments:

```json
{
  "templates": {
    "selectedSourceFile": "src/main/java/Example.java",
    "selectedSourceLine": "42",
    "selectedSourceColumn": "10"
  }
}
```

Example contextual query pattern:
```ql
/**
 * @name Find References
 * @description Find all references to a selected symbol
 * @kind problem
 * @tags ide-contextual-queries/find-references
 */

// External template variables provided by IDE via query-server2 protocol
external string selectedSourceFile();
external string selectedSourceLine();
external string selectedSourceColumn();

// Query logic using the template data...
```

## Quick evaluation support

The query-server2 supports quick evaluation of query fragments through the `quickEvalPosition` parameter in the protocol. This allows IDEs to evaluate specific expressions or predicates within a query file without running the entire query:

```json
{
  "queryPath": "/path/to/query.ql",
  "quickEvalPosition": {
    "line": 15,
    "column": 5
  }
}
```

## Performance optimization features

The query-server2 supports various performance optimizations:

```bash
# Configure threads and memory
codeql execute query-server2 --threads=8 --timeout=600

# Enable tuple counting for performance analysis
codeql execute query-server2 --tuple-counting

# Configure disk cache behavior
codeql execute query-server2 --save-cache --max-disk-cache=4096
```

## Advanced configuration options

### Memory and threading
- `--threads=<num>`: Number of evaluation threads (0 = one per core)
- `--timeout=<seconds>`: Query evaluation timeout
- `--heap-ram=<MB>`: Java heap memory allocation
- `--off-heap-ram=<MB>`: Additional off-heap memory

### Caching and performance
- `--save-cache`: Aggressively cache intermediate results
- `--max-disk-cache=<MB>`: Maximum disk cache size
- `--keep-full-cache`: Don't clean up cache after evaluation
- `--tuple-counting`: Display tuple counts for performance analysis

### Debug and logging
- `--debug`: Include additional debugging information
- `--evaluator-log=<file>`: Output structured performance logs
- `--evaluator-log-minify`: Minimize JSON log size

## Protocol communication

The query-server2 uses a JSON-based protocol over stdin/stdout for communication with IDE clients. The protocol supports:

- Query compilation and execution requests
- Template variable passing for data extensions
- Quick evaluation of query fragments
- Result streaming and formatting
- Error reporting and diagnostics

## When to use query-server2 vs query run

**Use `codeql execute query-server2` when:**
- Building IDE integrations or tools that execute many queries
- Need efficient handling of contextual queries with templates
- Require quick evaluation of query fragments via JSON protocol
- Want to minimize query execution latency in IDE environments

**Use `codeql query run` when:**
- Running single queries from command line
- Following TDD methodology for query development
- Scripting or automation scenarios
- Simple one-off query execution
- Don't need persistent process benefits

**Note**: For command-line TDD workflows, `codeql query run` provides adequate performance with automatic compilation caching. Query server is primarily designed for IDE integration via JSON protocol communication.

## Help for `codeql execute query-server2`

Run `codeql execute query-server2 --help` for more information.
Run `codeql execute query-server2 --help --verbose` for much more information.

## Commands commonly run **BEFORE** `codeql execute query-server2`

- [`codeql database create`](./codeql_database_create.prompt.md) - Create CodeQL databases to query
- [`codeql pack install`](./codeql_pack_install.prompt.md) - Install library dependencies declared in CodeQL packs

## Commands commonly run **AFTER** `codeql execute query-server2`

- [`codeql bqrs decode`](./codeql_bqrs_decode.prompt.md) - Process BQRS results from saved output (when results are saved to files)
- [`codeql bqrs info`](./codeql_bqrs_info.prompt.md) - Get information about BQRS results (when results are saved to files)

## Related commands

- [`codeql query run`](./codeql_query_run.prompt.md) - Execute single CodeQL queries (alternative for simple use cases)
- [`codeql query compile`](./codeql_query_compile.prompt.md) - Compile queries before execution
````
