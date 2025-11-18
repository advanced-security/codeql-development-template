---
mode: agent
---

# Python Query Development

For general CodeQL query development guidance, see [Common Query Development](./query_development.prompt.md).

## Python-Specific Documentation

### Essential References

- **[Python AST Reference](../../languages/python/tools/dev/python_ast.prompt.md)** - Complete guide to Python AST node types
- **[Python Security Query Guide](../../languages/python/tools/dev/python_security_query_guide.prompt.md)** - Comprehensive framework modeling and security query implementation

## Python-Specific Guidance

### Core Python Imports

```ql
import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import semmle.python.security.dataflow.SqlInjection
import semmle.python.ApiGraphs
```

### Python AST Navigation

#### Essential Expression Types

- `Call` - Function/method calls (`func(args)`)
- `Attribute` - Attribute access (`obj.attr`, `module.function`)
- `Subscript` - Subscript operations (`obj[key]`, `list[0]`)
- `Name` - Variable references and identifiers
- `StringLiteral` - String literals (`"hello"`, `'world'`)
- `List` / `Dict` - Collection literals
- `BinOp` / `UnaryExpr` - Operations

#### Essential Statement Types

- `FunctionDef` / `FunctionExpr` / `Function` - Function definitions and objects
- `ClassDef` / `ClassExpr` / `Class` - Class definitions and objects
- `Import` / `ImportFrom` / `ImportExpr` - Import statements
- `Assign` / `AssignStmt` - Assignment statements
- `If` / `For` / `While` - Control flow statements
- `Return` / `ExprStmt` / `Pass` - Other statements

### Modern Python Analysis with ApiGraphs

The `ApiGraphs` library is the preferred method for tracking Python APIs and data flow:

#### Basic API Tracking

```ql
// Track module imports
API::Node flask() { result = API::moduleImport("flask") }

// Track class instantiation
API::Node flaskApp() { result = flask().getMember("Flask").getACall() }

// Track method calls
API::Node route() { result = flaskApp().getMember("route") }
```

#### Data Flow Integration

```ql
// Connect API tracking to data flow analysis
API::Node userInput() {
  result = API::moduleImport("flask").getMember("request").getMember(["args", "form", "json"])
}

// Use in taint tracking configurations
predicate isSource(DataFlow::Node source) {
  source = userInput().getACall()
}
```

### Python-Specific Patterns

#### Flask/Django Web Framework Detection

```ql
// Flask route detection
predicate isFlaskRoute(FunctionDef func) {
  exists(Decorator d | d.getTarget() = func |
    d.getDecorator().(Attribute).getName() = "route" and
    d.getDecorator().(Attribute).getObject().(Name).getId() = "app"
  )
}

// Django view detection
predicate isDjangoView(FunctionDef func) {
  exists(Parameter p | p = func.getAnArg() |
    p.getAnnotation().(Attribute).getName() = "HttpRequest"
  )
}
```

#### SQL Injection Detection

```ql
from Call call
where
  // Database cursor execute methods
  call.getFunc().(Attribute).getName() in ["execute", "executemany"] and
  exists(Expr arg | arg = call.getAnArg() |
    // Check if argument contains string formatting
    arg instanceof BinOp or
    arg instanceof Call
  )
select call, "Potential SQL injection vulnerability"
```

#### API Graph Usage for Flask

```ql
// Track Flask request data
API::Node flaskRequest() {
  result = API::moduleImport("flask").getMember("request")
}

predicate isUserInput(DataFlow::Node node) {
  node = flaskRequest().getMember(["args", "form", "json", "data"]).getACall()
}
```

### Security Query Development

#### Modern Security Query Structure

Follow the three-part pattern documented in the Security Query Guide:

1. **Customizations Module** (`*Customizations.qll`) - Define sources, sinks, sanitizers
2. **Query Module** (`*Query.qll`) - Define flow configuration
3. **Final Query** (`*.ql`) - Implement path-problem query

#### Common Security Patterns

**Path Traversal**

```ql
predicate isPathTraversal(Call call) {
  exists(string funcName | funcName in ["open", "file"] |
    call.getFunc().(Name).getId() = funcName and
    exists(DataFlow::Node source, DataFlow::Node sink |
      isUserInput(source) and
      sink.asExpr() = call.getAnArg() and
      DataFlow::flow(source, sink)
    )
  )
}
```

**Command Injection**

```ql
import semmle.python.security.dataflow.CommandInjection

from CommandInjection::Configuration config, DataFlow::PathNode source, DataFlow::PathNode sink
where config.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "Command injection from $@.", source.getNode(), "user input"
```

### Python Library Specifics

#### Standard Library Patterns

- `os.system()`, `subprocess.call()` - Command execution
- `eval()`, `exec()` - Code evaluation
- `pickle.loads()` - Deserialization
- `sqlite3.execute()` - Database operations

#### Framework Patterns

- **Flask**: `@app.route`, `request.args`, `render_template`
- **Django**: `HttpRequest`, `render`, `Q` objects
- **FastAPI**: `@app.get`, `Depends`, `Request`

### Testing and Development

#### Test Case Structure

```python
# NON_COMPLIANT: Vulnerable pattern
def vulnerable_function(user_input):
    query = "SELECT * FROM users WHERE id = " + user_input  # SQL injection
    cursor.execute(query)

# COMPLIANT: Safe pattern
def safe_function(user_input):
    query = "SELECT * FROM users WHERE id = ?"
    cursor.execute(query, (user_input,))  # Parameterized query
```

#### Inline Test Annotations

```python
def test_function():
    source = get_user_input()  # $ Source
    sink(source)              # $ Alert=source
```

### Complete Security Query Example

#### Simple SQL Injection Query

```ql
/**
 * @name SQL injection in Python
 * @description User input flows into SQL query without sanitization
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/sql-injection
 * @tags security
 *       external/cwe/cwe-089
 */

import python
import semmle.python.security.dataflow.SqlInjection
import DataFlow::PathGraph

from SqlInjection::Configuration config, DataFlow::PathNode source, DataFlow::PathNode sink
where config.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "SQL query built from $@.", source.getNode(), "user-provided value"
```

### Advanced Techniques

#### Framework Modeling

When existing framework support is insufficient, create comprehensive models following the patterns in the Security Query Guide:

- Use `ApiGraphs` for API tracking
- Extend `Concepts` classes for security-relevant operations
- Implement `InstanceTaintStepsHelper` for method chaining
- Use `ModelsAsData` for external API specifications

#### Performance Considerations

- Prefer `ApiGraphs` over string-based matching
- Use specific AST node types rather than generic `Expr`
- Implement efficient predicate logic with proper ordering

## CLI References

- [qlt query generate new-query](../../resources/cli/qlt/qlt_query_generate_new-query.prompt.md) - Generate scaffolding for a new CodeQL query with packs and tests
- [codeql query format](../../resources/cli/codeql/codeql_query_format.prompt.md)
- [codeql query compile](../../resources/cli/codeql/codeql_query_compile.prompt.md)
- [codeql query run](../../resources/cli/codeql/codeql_query_run.prompt.md)
- [codeql test run](../../resources/cli/codeql/codeql_test_run.prompt.md)
