---
mode: agent
---

# JavaScript Query Development

For general CodeQL query development guidance, see [Common Query Development](./query_development.prompt.md).

## JavaScript-Specific Guidance

### Core JavaScript Imports

```ql
import javascript
import DataFlow::DataFlow as DataFlow
import DataFlow::TaintTracking as TaintTracking
import semmle.javascript.security.dataflow.SqlInjection
import semmle.javascript.frameworks.Express
import semmle.javascript.frameworks.React
```

### JavaScript AST Elements

### JavaScript AST Navigation

- **Classes**: `ClassDefinition` with `VarDecl` for class names
- **Functions**: `FunctionDeclStmt`, `FunctionExpr`, `ArrowFunctionExpr`
- **Methods**: `MethodDefinition` for class methods, `ClassInitializedMember` for class members
- **Statements**: `BlockStmt`, `DeclStmt`, `ExprStmt`, `IfStmt`, `ForStmt`, `WhileStmt`, `TryStmt`, `ReturnStmt`
- **Expressions**: `MethodCallExpr`, `NewExpr`, `VarRef`, `AssignExpr`, `BinaryExpr`, `UpdateExpr`, `IndexExpr`
- **Declarations**: `VariableDeclarator`, `SimpleParameter` for function parameters
- **Literals**: `Literal`, `ArrayExpr`, `ObjectExpr`, `TemplateLiteral`
- **Property Access**: `DotExpr` for property access, `Label` for property names
- **Control Flow**: `CatchClause` for exception handling, `Property` for object properties

#### Statement Types

- `FunctionDeclStmt` - Function declarations
- `VarDeclStmt` - Variable declarations
- `ExprStmt` - Expression statements
- `IfStmt` - Conditional statements
- `ForStmt` / `WhileStmt` - Loop statements

### JavaScript-Specific Patterns

#### Node.js/Express Framework Detection

```ql
// Express route handlers
predicate isExpressRouteHandler(Function f) {
  exists(MethodCallExpr call |
    call.getReceiver().(VarAccess).getName() = "app" and
    call.getMethodName() in ["get", "post", "put", "delete", "use"] and
    call.getAnArgument() = f
  )
}

// Express middleware pattern
predicate isExpressMiddleware(Function f) {
  f.getNumParameter() = 3 and
  f.getParameter(0).getName() = "req" and
  f.getParameter(1).getName() = "res" and
  f.getParameter(2).getName() = "next"
}
```

#### React Component Detection

```ql
predicate isReactComponent(Function f) {
  exists(ReturnStmt ret |
    ret.getContainer() = f and
    ret.getExpr() instanceof JSXElement
  )
}

predicate isReactHook(CallExpr call) {
  call.getCalleeName().matches("use%")
}
```

#### DOM Manipulation

```ql
predicate isDOMSink(Expr expr) {
  exists(PropAccess pa | pa = expr |
    pa.getPropertyName() in ["innerHTML", "outerHTML", "insertAdjacentHTML"] or
    pa.getBase().(CallExpr).getCalleeName() in ["getElementById", "querySelector"]
  )
}
```

### Common Security Patterns

#### Cross-Site Scripting (XSS)

```ql
class XssConfiguration extends TaintTracking::Configuration {
  XssConfiguration() { this = "XssConfiguration" }

  override predicate isSource(DataFlow::Node source) {
    // HTTP request parameters
    source instanceof Express::RequestInputAccess
  }

  override predicate isSink(DataFlow::Node sink) {
    // DOM manipulation sinks
    isDOMSink(sink.asExpr())
  }
}
```

#### SQL Injection

```ql
predicate isSqlQuery(CallExpr call) {
  exists(string method | method in ["query", "execute", "prepare"] |
    call.getCalleeName() = method and
    call.getReceiver().getType().hasQualifiedName("mysql", "Connection")
  )
}
```

#### Prototype Pollution

```ql
predicate isPrototypePollution(AssignExpr assign) {
  exists(PropAccess pa | pa = assign.getLhs() |
    pa.getPropertyName() = "prototype" or
    pa.getPropertyName() = "__proto__"
  )
}
```

### Framework-Specific Patterns

#### Express.js Patterns

```ql
// Request data sources
DataFlow::SourceNode expressRequestSource() {
  result = DataFlow::parameterNode(any(Express::RouteHandler rh).getRequestParameter())
}

// Response sinks
predicate isExpressResponseSink(DataFlow::Node sink) {
  exists(MethodCallExpr call |
    call.getReceiver().(VarAccess).getName() = "res" and
    call.getMethodName() in ["send", "json", "render"] and
    sink.asExpr() = call.getAnArgument()
  )
}
```

#### React Patterns

```ql
// Dangerous React patterns
predicate isDangerouslySetInnerHTML(JSXElement jsx) {
  jsx.getAnAttribute().getName() = "dangerouslySetInnerHTML"
}

// State updates
predicate isStateUpdate(CallExpr call) {
  call.getCalleeName().matches("set%") and
  exists(CallExpr useState | useState.getCalleeName() = "useState" |
    DataFlow::flow(DataFlow::valueNode(useState), DataFlow::valueNode(call.getReceiver()))
  )
}
```

### Testing Patterns

#### Test Case Structure

```javascript
// NON_COMPLIANT: XSS vulnerability
app.get('/user/:id', (req, res) => {
  const userId = req.params.id
  res.send(`<h1>User: ${userId}</h1>`) // Direct interpolation
})

// COMPLIANT: Proper escaping
app.get('/user/:id', (req, res) => {
  const userId = req.params.id
  res.render('user', { userId }) // Template engine handles escaping
})
```

### JavaScript Query Examples

#### Simple XSS Detection

```ql
/**
 * @name Reflected XSS
 * @description User input flows into HTTP response without sanitization
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision high
 * @id js/reflected-xss
 * @tags security
 *       external/cwe/cwe-079
 */

import javascript
import DataFlow::PathGraph

class ReflectedXssConfiguration extends TaintTracking::Configuration {
  ReflectedXssConfiguration() { this = "ReflectedXssConfiguration" }

  override predicate isSource(DataFlow::Node source) {
    source instanceof RemoteFlowSource
  }

  override predicate isSink(DataFlow::Node sink) {
    sink instanceof XssSink
  }
}

from ReflectedXssConfiguration cfg, DataFlow::PathNode source, DataFlow::PathNode sink
where cfg.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "Cross-site scripting vulnerability due to $@.",
  source.getNode(), "user-provided value"
```

### Performance Considerations

- **Use specific call patterns**: Prefer `MethodCallExpr` over `CallExpr` when targeting method calls
- **Leverage framework libraries**: Use Express, React modules for better precision
- **Consider async patterns**: JavaScript's async nature requires careful data flow analysis
- **Handle dynamic property access**: Account for bracket notation property access

## CLI References

- [qlt query generate new-query](../../resources/cli/qlt/qlt_query_generate_new-query.prompt.md)
- [codeql query format](../../resources/cli/codeql/codeql_query_format.prompt.md)
- [codeql query compile](../../resources/cli/codeql/codeql_query_compile.prompt.md)
- [codeql query run](../../resources/cli/codeql/codeql_query_run.prompt.md)
- [codeql test run](../../resources/cli/codeql/codeql_test_run.prompt.md)
