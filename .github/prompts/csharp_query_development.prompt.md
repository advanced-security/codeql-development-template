---
mode: agent
---

# C# Query Development

This prompt provides guidance for developing CodeQL queries targeting C# code. For common query development patterns and best practices, see [query_development.prompt.md](query_development.prompt.md).

## Language-Specific Guidelines

### C# CodeQL Libraries

- Import `csharp` for C# AST nodes and predicates
- Use `dotnet` imports for .NET Framework specific features
- Common imports: `Stmt`, `Expr`, `Method`, `Class`, `Namespace`
- For comprehensive C# AST reference, see [C# AST Nodes](../../languages/cpp/tools/dev/csharp_ast.prompt.md)

### C# AST Navigation

- **Classes**: `Class` for class declarations
- **Methods**: `Method`, `Constructor`, `Getter`, `Setter` for method definitions
- **Properties**: `Property` with `Getter` and `Setter` accessors
- **Fields**: `Field` for field declarations
- **Statements**: `BlockStmt`, `LocalVariableDeclStmt`, `ExprStmt`, `IfStmt`, `ForStmt`, `ForeachStmt`, `WhileStmt`, `DoStmt`, `SwitchStmt`, `TryStmt`, `CaseStmt`
- **Expressions**: `MethodCall`, `PropertyCall`, `FieldAccess`, `LocalVariableAccess`, `ParameterAccess`, `ObjectCreation`, `AssignExpr`, `BinaryExpr` (e.g., `GTExpr`, `LTExpr`, `EQExpr`)
- **Assignment Expressions**: `AssignExpr`, `AssignAddExpr`, `AssignSubExpr`, `AssignMulExpr`, `AssignDivExpr` for compound assignments
- **Declarations**: `LocalVariableDeclAndInitExpr`, `LocalVariableDeclExpr`, `Parameter`
- **Literals**: `StringLiteralUtf16`, `IntLiteral`, `ArrayCreation`
- **Type Access**: `TypeMention`, `TypeAccess` for type references
- **Control Flow**: `ConstCase`, `DefaultCase`, `SpecificCatchClause` for exception handling
- **Modern C# Features**: `TupleExpr` for tuple expressions, `CastExpr` for type casting, `VariablePatternExpr` for pattern matching, `RecursivePatternExpr` and `PositionalPatternExpr` for complex patterns
- **Security Analysis**: Use `DataFlow::Node` and `TaintTracking::Configuration` for security query implementation

### Common C# Patterns

- **Method calls**: `methodCall.getTarget().hasName("methodName")`
- **Type checking**: `expr.getType().hasName("TypeName")`
- **Attribute usage**: `attributable.getAnAttribute().hasName("AttributeName")`
- **Compound assignments**: `AssignAddExpr`, `AssignSubExpr` for `+=`, `-=` operations
- **Variable declarations**: `LocalVariableDeclAndInitExpr` for initialized declarations
- **Tuple operations**: `TupleExpr` for tuple creation and destructuring
- **Pattern matching**: `VariablePatternExpr`, `RecursivePatternExpr`, `PositionalPatternExpr` in switch expressions
- **Type casting**: `CastExpr` for explicit type conversions
- **Local variable access**: `LocalVariableAccess` for local variable usage
- **Parameter access**: `ParameterAccess` for method parameter usage
- **LINQ queries**: Look for `LinqExpression` and related classes
- **Async/await**: Use `AsyncMethod`, `AwaitExpr`
- **Security taint tracking**: Use `TaintTracking::Configuration` for vulnerability detection
- **Data flow analysis**: Use `DataFlow::Node` for tracking data movement

### C# Security Patterns

- SQL injection via Entity Framework or ADO.NET
- XSS in ASP.NET applications
- Insecure deserialization
- Path traversal in file operations
- Authentication and authorization bypasses
- Inappropriate encoding (CWE-838) - wrong encoding for context
- Command injection in System.Diagnostics.Process
- SSRF in HTTP client requests

For comprehensive C# security query implementation guidance, see [C# Security Query Guide](../../languages/csharp/tools/dev/csharp_security_query_guide.prompt.md).

### Modern C# Language Features

- **Tuples**: Use `TupleExpr` for tuple expressions like `(a, b)` or `(x: 1, y: 2)`
- **Pattern Matching**: `VariablePatternExpr` for simple patterns, `RecursivePatternExpr` for property patterns, `PositionalPatternExpr` for positional patterns
- **Switch Expressions**: Enhanced switch with pattern matching capabilities
- **Local Functions**: Nested function definitions within methods
- **Compound Assignment**: `AssignAddExpr`, `AssignSubExpr`, etc. for `+=`, `-=` operations
- **Type Casting**: `CastExpr` for explicit type conversions and safe casting
- **Variable Declarations**: `LocalVariableDeclExpr` vs `LocalVariableDeclAndInitExpr` for different declaration patterns

## CLI References

- [codeql query format](../../resources/cli/codeql/codeql_query_format.prompt.md)
- [codeql query compile](../../resources/cli/codeql/codeql_query_compile.prompt.md)
- [codeql query run](../../resources/cli/codeql/codeql_query_run.prompt.md)
- [codeql database analyze](../../resources/cli/codeql/codeql_database_analyze.prompt.md)
- [codeql database create](../../resources/cli/codeql/codeql_database_create.prompt.md)
