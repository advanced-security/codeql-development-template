---
mode: agent
---

# CodeQL Query Development

This prompt provides common guidance for developing CodeQL queries across all supported languages, while language-specific prompts reference this common guidance and add language-specific details.

## Core Principles

### Query Quality Criteria

Your generated CodeQL queries will be evaluated on:

1. **QL Code Quality**:
   - **Critical**: Query must compile without errors. Invalid CodeQL queries cannot be run and have negative code quality.
   - **Important**: Minimize warning-level diagnostics (deprecated elements, style guide deviations)
   - **Best Practice**: Follow CodeQL naming conventions and idioms

2. **Query Results Accuracy**:
   - When tested against provided test code, actual results should match expected results
   - Minimize false positives (flagging correct code as problematic)
   - Minimize false negatives (missing actual problems)

3. **Performance**:
   - Use efficient predicates and avoid unnecessary joins
   - Leverage built-in library predicates when available
   - Consider query complexity for large codebases

### CodeQL Query Structure

#### Standard Query Template

```ql
/**
 * @name QueryName
 * @description Brief description of what the query detects
 * @kind problem
 * @problem.severity warning
 * @security-severity 5.0
 * @precision medium
 * @id language/query-id
 * @tags security
 *       maintainability
 */

import language

from ElementType element
where
  // Query logic here
  problematicCondition(element)
select element, "Description of the issue found"
```

#### Query Metadata Guidelines

- `@name`: Human-readable query name
- `@description`: Clear explanation of what patterns are detected
- `@kind`: Usually `problem` for security/quality queries
- `@problem.severity`: `error`, `warning`, or `recommendation`
- `@precision`: `high`, `medium`, or `low` based on false positive rate
- `@id`: Format as `language/category-name` (e.g., `java/sql-injection`)
- `@tags`: Relevant categories (security, correctness, maintainability, etc.)

### Test-Driven Development Workflow

Follow this workflow for reliable query development:

1. **Create New Query Scaffolding**: Use the [qlt query generate new-query](../../resources/cli/qlt/qlt_query_generate_new-query.prompt.md) command to create the initial query structure.
2. **Generate Query Plan**: Define what patterns to detect
3. **Create Test Cases**: Write both compliant and non-compliant code examples
4. **Extract Test Database**: Create minimal CodeQL database from test code
5. **Analyze AST**: Use PrintAST queries to understand code structure
6. **Implement Query**: Write QL code based on AST analysis
7. **Compile and Test**: Ensure query compiles and produces expected results
8. **Iterate**: Refine based on test results and performance

For detailed TDD workflow, see [Test-Driven QL Development](./test_driven_ql_development.prompt.md).

### Workflow Optimization with Query Server

For iterative development workflows involving multiple query executions, consider using the persistent query server:

#### When to Use Query Server vs Individual Commands

**Use `codeql execute query-server2` when:**

- Running multiple queries during development iterations
- Executing PrintAST and other diagnostic queries repeatedly
- Working in an IDE or editor with CodeQL integration
- Need to minimize query execution latency across multiple runs
- Working with template-based queries (contextual queries)

**Use individual `codeql query run` commands when:**

- Running single queries for final validation
- Scripting or automation scenarios
- Simple one-off query execution
- CLI-based workflows without IDE integration

#### Query Server Benefits

The query-server2 provides several performance advantages:

- **Persistent process**: Eliminates startup overhead for multiple executions
- **Shared compilation cache**: Compiled queries and libraries cached across runs
- **Template support**: Efficient handling of contextual queries with variables
- **Quick evaluation**: Rapid evaluation of query fragments during development

For complete query-server2 usage details, see [codeql execute query-server2](../../resources/cli/codeql/codeql_execute_query-server2.prompt.md).

### Common Import Patterns

Most queries will need these imports:

```ql
import language              // Core language support
import language.DataFlow     // Data flow analysis (if needed)
import language.TaintTracking // Taint tracking (if needed)
import language.security.*   // Security-specific predicates (if available)
```

### Writing Effective Predicates

#### Pattern Matching

```ql
predicate isVulnerablePattern(Expr expr) {
  // Define specific conditions that indicate vulnerability
  expr instanceof SomeVulnerableExpr and
  not expr.hasSecurityMitigation()
}
```

#### Data Flow Analysis

```ql
class VulnerableDataFlow extends DataFlow::Configuration {
  VulnerableDataFlow() { this = "VulnerableDataFlow" }

  override predicate isSource(DataFlow::Node source) {
    // Define sources of untrusted data
  }

  override predicate isSink(DataFlow::Node sink) {
    // Define dangerous sinks
  }
}
```

### Performance Best Practices

- **Use specific types**: Prefer `MethodCall` over `Expr` when possible
- **Early filtering**: Apply most restrictive conditions first
- **Leverage indices**: Use built-in predicates that are optimized
- **Avoid complex joins**: Break down complex conditions into helper predicates
- **Profile queries**: Use `codeql query run` with performance metrics

### Common Pitfalls

1. **Over-broad matching**: Ensure predicates are specific enough
2. **Missing edge cases**: Consider inheritance, overloading, etc.
3. **Performance issues**: Watch for cartesian products in joins
4. **False positives**: Test against real-world codebases
5. **Ignoring data flow**: Many vulnerabilities require tracking data flow

### Debugging Queries

#### Compilation Issues

- Check import statements and library dependencies
- Verify predicate signatures match usage
- Ensure proper scoping of variables

#### Unexpected Results

- Use `select` statements to inspect intermediate results
- Break complex predicates into smaller, testable parts
- Add debug predicates to understand data flow

#### Performance Problems

- Add `pragma[inline]` to small, frequently-used predicates
- Use `pragma[noinline]` for large predicates to control optimization
- Consider using `pragma[nomagic]` to prevent unwanted joins

## CLI References

Essential commands for query development:

### Core Development Commands

- [qlt query generate new-query](../../resources/cli/qlt/qlt_query_generate_new-query.prompt.md) - Generate scaffolding for a new CodeQL query with packs and tests
- [codeql query compile](../../resources/cli/codeql/codeql_query_compile.prompt.md) - Compile and validate query syntax
- [codeql query run](../../resources/cli/codeql/codeql_query_run.prompt.md) - Execute queries against databases
- [codeql execute query-server2](../../resources/cli/codeql/codeql_execute_query-server2.prompt.md) - Run a persistent query execution server for efficient multi-query workflows and IDE integrations
- [codeql query format](../../resources/cli/codeql/codeql_query_format.prompt.md) - Format query source code
- [codeql test run](../../resources/cli/codeql/codeql_test_run.prompt.md) - Execute query test suites
- [codeql test extract](../../resources/cli/codeql/codeql_test_extract.prompt.md) - Create test databases

### Database Operations

- [codeql database create](../../resources/cli/codeql/codeql_database_create.prompt.md) - Create CodeQL databases
- [codeql database analyze](../../resources/cli/codeql/codeql_database_analyze.prompt.md) - Run queries against databases

### Package Management

- [codeql pack install](../../resources/cli/codeql/codeql_pack_install.prompt.md) - Install query dependencies
- [codeql resolve library-path](../../resources/cli/codeql/codeql_resolve_library-path.prompt.md) - Resolve library paths

### Results Analysis

- [codeql bqrs decode](../../resources/cli/codeql/codeql_bqrs_decode.prompt.md) - Convert binary results to text
- [codeql bqrs info](../../resources/cli/codeql/codeql_bqrs_info.prompt.md) - Inspect result metadata

## Related Resources

- [Test-Driven QL Development](./test_driven_ql_development.prompt.md) - Comprehensive TDD workflow
- [Language-specific prompts](.) - Additional guidance for specific languages
