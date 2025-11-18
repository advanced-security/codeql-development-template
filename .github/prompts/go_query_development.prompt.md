---
mode: agent
---

# Go Query Development

This prompt provides guidance for developing CodeQL queries targeting Go code. For common query development patterns and best practices, see [query_development.prompt.md](query_development.prompt.md).

## Language-Specific Guidelines

### Go CodeQL Libraries

- Import `go` for Go AST nodes and predicates
- Common imports: `Stmt`, `Expr`, `Function`, `Type`, `Package`, `File`
- Use `DataFlow` and `TaintTracking` for tracking data flow through Go programs
- Import `semmle.go.security` for security-related predicates

### Best Practices

- Start syntactic (AST) for structure; switch to data flow graph (DFG) for semantic flow
- Use `hasQualifiedName` for stable matching of stdlib/framework APIs
- Prefer library predicates over string parsing; rely on classes and accessors
- Keep queries specific and cheap first; generalize after validation

### Go AST Navigation

- **File Structure**: `GoFile` for file nodes
- **Functions**: `FuncDecl` for function declarations, `MethodDecl` for methods, `FuncLit` for function literals
- **Types**: `StructTypeExpr`, `ArrayTypeExpr`, `StarExpr` (pointers), `FuncTypeExpr`
- **Statements**: `IfStmt`, `ForStmt`, `SwitchStmt`, `BlockStmt`, `ReturnStmt`, `DefineStmt`, `AssignStmt`, `DeferStmt`, `RangeStmt`, `IncStmt`
- **Expressions**: `CallExpr`, `SelectorExpr`, `IndexExpr`, `AddressExpr`, `EqlExpr`, `LssExpr`, `GtrExpr`, `MulExpr`, `NeqExpr`
- **Literals**: `StringLit`, `IntLit`, `StructLit`, `SliceLit`
- **Declarations**: `ImportDecl`, `TypeDecl`, `FieldDecl`, `ParameterDecl`, `ReceiverDecl`, `ResultVariableDecl`
- **Identifiers**: `Ident` with roles like `FunctionName`, `VariableName`, `TypeName`, `PackageName`, `ConstantName`

### Go Type System

- Use `getType()` to get the type of an expression
- Check interface satisfaction with `implements()`
- Navigate pointer types with `getBaseType()`
- Check for built-in types: `isString()`, `isNumeric()`, etc.

### Common Go Patterns

- **Function calls**: `call.getTarget().hasName("functionName")` where `call` is a `CallExpr`
- **Method calls**: Use `SelectorExpr` for method access, then `CallExpr` for invocation
- **Package imports**: Navigate `ImportDecl` and `ImportSpec` for import analysis
- **Struct operations**: `StructLit` for literals, `FieldDecl` for field declarations
- **Array/slice operations**: `SliceLit`, `ArrayTypeExpr`, `IndexExpr` for array access
- **Assignment operations**: `AssignStmt` and `DefineStmt` for variable assignments
- **Control flow**: `IfStmt`, `ForStmt`, `RangeStmt` for iteration patterns
- **Defer statements**: `DeferStmt` for cleanup patterns
- **Error handling**: Look for patterns with `if err != nil` using comparison expressions

### Data Flow in Go

- Use `DataFlow::Node` for nodes in the data flow graph
- `TaintTracking::Configuration` for taint analysis
- Track through function calls with `allowImplicitRead()`
- Handle Go-specific flow: channels, goroutines, interfaces
- Consider pointer aliasing and escape analysis

### Go Security Patterns

- **Command injection**: `os/exec.Command()`, `os/exec.CommandContext()`
- **SQL injection**: Database query methods with user input
- **Path traversal**: `os.Open()`, `ioutil.ReadFile()` with unsanitized paths
- **Unsafe reflection**: `reflect` package misuse
- **Goroutine leaks**: Unbounded goroutine creation
- **Race conditions**: Shared memory access without synchronization
- **Improper error handling**: Ignored errors, information leakage
- **Unsafe pointer operations**: `unsafe` package usage
- **Cryptographic issues**: Weak random number generation, deprecated crypto

### Go Runtime Considerations

- **Error handling**: Check for proper error checking patterns
- **Context usage**: Verify context propagation in concurrent code
- **Resource cleanup**: Ensure proper use of `defer` statements
- **Type assertions**: Check for unsafe type assertions without ok checks
- **Nil pointer dereference**: Check for nil checks before dereference
- **Slice bounds**: Check for slice out-of-bounds access
- **Channel operations**: Deadlocks, channel leaks, nil channel operations
- **Interface{} usage**: Type safety with empty interfaces

### Go-Specific TDD Considerations

- **Go Module Setup**: Test databases require a `go.mod` file in the test directory for proper extraction
- **QLT Limitations**: The QLT scaffolding tool doesn't support Go; create directory structure manually
- **Test File Structure**: Follow pattern: `test/{QueryName}/{QueryName}.go`, `{QueryName}.expected`, `{QueryName}.qlref`
- **qlref Paths**: Use simple paths like `QueryName/QueryName.ql` in .qlref files, not relative paths with `..`
- **Search Paths**: Include `--search-path=path/to/src` when running tests to resolve query references
- **Expected Results**: Include full location info: `| file.go:line:col:line:col | element | message |`

### Go Standard Library Patterns

- **HTTP handlers**: `http.HandlerFunc`, `http.Handler` interface
- **JSON operations**: `json.Marshal()`, `json.Unmarshal()`
- **File operations**: `os` package, `io/ioutil` patterns
- **String operations**: `strings` package functions
- **Time operations**: `time` package, duration handling
- **Crypto operations**: `crypto/*` package usage

## Language-Specific Development Resources

- [Go AST Classes](../../languages/go/tools/dev/go_ast.prompt.md) - Comprehensive AST navigation guide
- [Go Security Query Guide](../../languages/go/tools/dev/go_security_query_guide.prompt.md) - Security patterns and vulnerability detection
- [Go Data Flow Analysis](../../languages/go/tools/dev/go_dataflow.prompt.md) - Local and global data flow tracking
- [Go Library Modeling](../../languages/go/tools/dev/go_library_modeling.prompt.md) - Customizing library models with YAML
- [Go Basic Query Examples](../../languages/go/tools/dev/go_basic_queries.prompt.md) - Practical query examples and patterns

## CLI References

- [qlt query generate new-query](../../resources/cli/qlt/qlt_query_generate_new-query.prompt.md) - Generate scaffolding for a new CodeQL query with packs and tests
- [codeql query format](../../resources/cli/codeql/codeql_query_format.prompt.md)
- [codeql query compile](../../resources/cli/codeql/codeql_query_compile.prompt.md)
- [codeql query run](../../resources/cli/codeql/codeql_query_run.prompt.md)
- [codeql test run](../../resources/cli/codeql/codeql_test_run.prompt.md)
