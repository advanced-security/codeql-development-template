---
mode: agent
---

# Java Query Development

This prompt provides guidance for developing CodeQL queries targeting Java code. For common query development patterns and best practices, see [query_development.prompt.md](query_development.prompt.md).

## Language-Specific Guidelines

### Java CodeQL Libraries

- Import `java` for Java AST nodes and predicates
- Use `semmle.code.java.dataflow.DataFlow` and `semmle.code.java.dataflow.TaintTracking`
- Import `semmle.code.java.frameworks.*` for framework-specific predicates
- Security-specific imports: `semmle.code.java.security.*`

### Java AST Navigation

- **Compilation Units**: `CompilationUnit` for file-level structure
- **Classes**: `Class`, `Interface` for type declarations
- **Methods**: `Method`, `Constructor` for method definitions
- **Statements**: `BlockStmt`, `ExprStmt`, `IfStmt`, `ForStmt`, `EnhancedForStmt`, `WhileStmt`, `TryStmt`, `ReturnStmt`
- **Expressions**: `MethodCall`, `ClassInstanceExpr`, `VarAccess`, `AssignExpr`, `BinaryExpr` (e.g., `GTExpr`, `LTExpr`, `EQExpr`)
- **Declarations**: `LocalVariableDeclStmt`, `FieldDeclaration`, `Parameter`
- **Literals**: `StringLiteral`, `IntegerLiteral`, `ArrayAccess`
- **Type Access**: `TypeAccess` for type references, `ArrayTypeAccess` for array types
- **Control Flow**: `CatchClause` for exception handling, `ThrowStmt` for exceptions

### Common Java Patterns

- **Method calls**: `call` where `call instanceof MethodCall`
- **Field access**: `access` where `access instanceof VarAccess`
- **Object creation**: `creation` where `creation instanceof ClassInstanceExpr`
- **Type checking**: Use `TypeAccess` for type references
- **Exception handling**: `TryStmt` with `CatchClause` blocks
- **Loop patterns**: `ForStmt`, `EnhancedForStmt` for iteration
- **Lambda expressions**: `LambdaExpr` for functional programming

### Data Flow in Java

- Use `DataFlow::Node` for nodes in the data flow graph
- `TaintTracking::Configuration` for taint analysis
- Handle Java-specific features: inheritance, polymorphism, generics
- Track through method calls, field access, and constructor invocations
- Consider static vs instance members in flow analysis

### Java Security Patterns

- **SQL injection**: JDBC query construction with user input
- **XSS**: HTML output without proper escaping
- **XXE**: XML parsing with external entity processing
- **Deserialization**: Unsafe object deserialization
- **Path traversal**: File operations with unsanitized paths
- **LDAP injection**: LDAP query construction with user input
- **Command injection**: Process execution with user input
- **Reflection vulnerabilities**: Dynamic class loading and method invocation

### Java Framework Patterns

- **Spring**: `@Controller`, `@RequestMapping`, `@Service` annotations
- **Servlets**: `HttpServletRequest`, `HttpServletResponse` handling
- **JSF**: Managed beans and view components
- **Struts**: Action classes and form handling
- **JAX-RS**: RESTful web service endpoints
- **JPA/Hibernate**: Entity mapping and query construction

### Java Standard Library

- **Collections**: `List`, `Set`, `Map` operations and iterations
- **I/O operations**: `FileInputStream`, `BufferedReader` usage
- **Networking**: `URL`, `HttpURLConnection` patterns
- **Concurrency**: `Thread`, `ExecutorService`, `Future` usage
- **Reflection**: `Class.forName()`, `Method.invoke()` patterns
- **Serialization**: `ObjectInputStream`, `ObjectOutputStream`
- **Database**: JDBC `Connection`, `PreparedStatement`, `ResultSet`

### Java Language Features

- **Generics**: Type parameter handling and bounds checking
- **Annotations**: Annotation processing and metadata
- **Lambda expressions**: Functional interfaces and method references
- **Streams**: Stream API operations and collectors
- **Optional**: Null-safe value handling
- **Modules**: Java 9+ module system
- **Records**: Data carrier classes (Java 14+)
- **Switch expressions**: Enhanced switch statements (Java 14+)

### Java-Specific Considerations

- **Inheritance**: Method overriding and polymorphic dispatch
- **Encapsulation**: Access modifiers and visibility
- **Static vs instance**: Different behavior for static and instance members
- **Exception hierarchy**: Checked vs unchecked exceptions
- **Autoboxing**: Primitive to wrapper type conversions
- **String interning**: String literal handling
- **Garbage collection**: Object lifecycle and memory management

## CLI References

- [qlt query generate new-query](../../resources/cli/qlt/qlt_query_generate_new-query.prompt.md) - Generate scaffolding for a new CodeQL query with packs and tests
- [codeql query format](../../resources/cli/codeql/codeql_query_format.prompt.md)
- [codeql query compile](../../resources/cli/codeql/codeql_query_compile.prompt.md)
- [codeql query run](../../resources/cli/codeql/codeql_query_run.prompt.md)
- [codeql test run](../../resources/cli/codeql/codeql_test_run.prompt.md)
