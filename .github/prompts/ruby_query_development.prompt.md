---
mode: agent
---

# Ruby Query Development

This prompt provides guidance for developing CodeQL queries targeting Ruby code. For common query development patterns and best practices, see [query_development.prompt.md](query_development.prompt.md).

## Language-Specific Guidelines

### Ruby CodeQL Libraries

- Import `ruby` for Ruby AST nodes and predicates
- Common imports: `Stmt`, `Expr`, `Method`, `Class`, `Module`, `Constant`
- Use `DataFlow` and `TaintTracking` for data flow analysis
- Import `codeql.ruby.security` for security-related predicates

### Ruby AST Navigation

- **Toplevel**: `Toplevel` for file-level structure
- **Classes**: `ClassDeclaration` for class definitions
- **Modules**: `ModuleDeclaration` for module definitions
- **Methods**: `Method`, `SingletonMethod` for method definitions
- **Statements**: `StmtSequence`, `BeginExpr` for statement blocks
- **Expressions**: `MethodCall`, `AssignExpr`, `IfExpr`, `CaseExpr`, `ForExpr`, `WhileExpr`, `TernaryIfExpr`
- **Variable Access**: `LocalVariableAccess`, `InstanceVariableAccess`, `ClassVariableAccess`, `GlobalVariableAccess`
- **Literals**: `StringLiteral`, `IntegerLiteral`, `ArrayLiteral`, `HashLiteral`, `SymbolLiteral`, `RegExpLiteral`
- **Control Flow**: `WhenClause`, `RescueClause` for exception handling, `Pair` for hash key-value pairs
- **Blocks**: `BraceBlock`, `DoBlock` for block expressions
- **Parameters**: `SimpleParameter`, `OptionalParameter` for method parameters

### Ruby Dynamic Features

- **Metaprogramming**: `define_method`, `method_missing`, `eval` family
- **Reflection**: `send`, `respond_to?`, `const_get`, `instance_variable_get`
- **Duck typing**: Dynamic method dispatch patterns
- **Monkey patching**: Class and module reopening
- **DSL patterns**: Domain-specific language constructs

### Common Ruby Patterns

- **Method calls**: `call.getMethodName() = "method_name"`
- **Chained calls**: Navigate through method chains
- **Block usage**: `call.getBlock()` for blocks passed to methods
- **Class inheritance**: `klass.getSuperClass()`
- **Module inclusion**: `include`, `extend`, `prepend` patterns
- **Constants**: `Constant` access and scoping
- **Symbol usage**: `:symbol` literals and conversions

### Data Flow in Ruby

- Use `DataFlow::Node` for nodes in the data flow graph
- `TaintTracking::Configuration` for taint analysis
- Handle Ruby's dynamic dispatch and method resolution
- Track through blocks, procs, and lambdas
- Consider instance variables and class variables in flow

### Ruby Security Patterns

- **Code injection**: `eval`, `instance_eval`, `class_eval` with user input
- **Command injection**: `system`, `exec`, backticks with user input
- **Path traversal**: File operations with unsanitized paths
- **SQL injection**: ActiveRecord and raw SQL with user input
- **XSS**: HTML output without proper escaping
- **YAML/XML deserialization**: Unsafe deserialization of user data
- **Open redirects**: Redirect operations with user-controlled URLs
- **Mass assignment**: Unsafe parameter handling in frameworks

### Ruby on Rails Patterns

- **Controllers**: `ActionController::Base` subclasses
- **Models**: `ActiveRecord::Base` subclasses
- **Views**: ERB templates, helper methods
- **Routes**: Rails routing patterns
- **Callbacks**: `before_action`, `after_action`, model callbacks
- **Strong parameters**: `params.require().permit()` patterns
- **Authentication**: Devise, session handling
- **Authorization**: CanCan, Pundit patterns

### Ruby Standard Library

- **File operations**: `File`, `Dir`, `Pathname` classes
- **String operations**: String interpolation, regex patterns
- **Collections**: `Array`, `Hash`, `Set` operations
- **Enumerable**: `map`, `select`, `reduce` methods
- **Net/HTTP**: Web request patterns
- **JSON/YAML**: Parsing and generation
- **Threading**: `Thread`, `Mutex`, fiber patterns

## CLI References

- [qlt query generate new-query](../../resources/cli/qlt/qlt_query_generate_new-query.prompt.md) - Generate scaffolding for a new CodeQL query with packs and tests
- [codeql query format](../../resources/cli/codeql/codeql_query_format.prompt.md)
- [codeql query compile](../../resources/cli/codeql/codeql_query_compile.prompt.md)
- [codeql query run](../../resources/cli/codeql/codeql_query_run.prompt.md)
- [codeql test run](../../resources/cli/codeql/codeql_test_run.prompt.md)
