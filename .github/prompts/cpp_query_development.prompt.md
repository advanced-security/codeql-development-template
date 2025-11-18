---
mode: agent
---

# C++ Query Development

This prompt provides guidance for developing CodeQL queries targeting C++ code. For common query development patterns and best practices, see [query_development.prompt.md](query_development.prompt.md).

## Language-Specific Guidelines

### C++ CodeQL Libraries

- Import `cpp` for C++ AST nodes and predicates
- Common imports: `Stmt`, `Expr`, `Function`, `Class`, `Type`, `Variable`
- Use `DataFlow` and `TaintTracking` for data flow analysis
- Import `semmle.code.cpp.security` for security-related predicates

### C++ AST Navigation

- **Functions**: `TopLevelFunction`, `MemberFunction`, `Constructor`, `Destructor`
- **Operators**: `CopyAssignmentOperator`, `MoveAssignmentOperator`
- **Statements**: `BlockStmt`, `DeclStmt`, `ExprStmt`, `ReturnStmt`
- **Expressions**: `FunctionCall`, `VariableAccess`, `AssignExpr`, `Literal`
- **Declarations**: `VariableDeclarationEntry`, `Parameter`
- **Types**: `IntType`, `VoidType`, `PointerType`, `LValueReferenceType`, `RValueReferenceType`
- **Control Flow**: Function entry points via `getEntryPoint()`
- **Value Categories**: `prvalue`, `lvalue` for expression value categories

### C++ Memory Management

- Track `new`/`delete` pairs for memory leaks
- Check `malloc`/`free` usage patterns
- Analyze smart pointer usage: `unique_ptr`, `shared_ptr`, `weak_ptr`
- RAII patterns and resource management
- Stack vs heap allocation patterns

### Common C++ Patterns

- **Function calls**: `call.getTarget().hasName("functionName")`
- **Method calls**: `call.getTarget().(MemberFunction).hasName("method")`
- **Class inheritance**: `derived.getABaseClass() = base`
- **Template instantiations**: Use `TemplateInstantiation` and related predicates
- **Operator overloading**: Check for overloaded operators
- **Virtual function calls**: Track polymorphic dispatch
- **Exception handling**: `ThrowStmt`, `TryStmt`, `CatchBlock`

### Data Flow in C++

#### Basic Data Flow

- Use `DataFlow::Node` for nodes in the data flow graph
- `TaintTracking::Configuration` for taint analysis
- Handle pointer aliasing and reference semantics
- Track through function parameters and return values
- Consider const-correctness in flow analysis

#### Advanced Data Flow Patterns

**Local vs Global Data Flow:**

```ql
// Local data flow within function scope
DataFlow::localFlow(source, sink)
DataFlow::localExprFlow(expr1, expr2)

// Global data flow across function boundaries
module GlobalConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { ... }
  predicate isSink(DataFlow::Node sink) { ... }
  predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) { ... }
}
module GlobalFlow = DataFlow::Make<GlobalConfig>;
```

**Flow-State for Tracking Validation Context:**

```ql
// Define flow states using algebraic data types
newtype TValidationState =
  TUnvalidated() or
  TValidated(TypeValidationCall call)

// Stateful data flow configuration
module StatefulConfig implements DataFlow::StateConfigSig {
  class FlowState = TValidationState;

  predicate isSource(DataFlow::Node source, FlowState state) { ... }
  predicate isSink(DataFlow::Node sink, FlowState state) { ... }
  predicate isAdditionalFlowStep(DataFlow::Node node1, FlowState state1,
                                DataFlow::Node node2, FlowState state2) { ... }
  predicate isBarrier(DataFlow::Node node, FlowState state) { ... }
}
module StatefulFlow = DataFlow::MakeWithState<StatefulConfig>;
```

**Multiple Data Flow Configurations:**

```ql
// Separate configs for different aspects
module InputFlow = DataFlow::Make<InputFlowConfig>;
module TypeValidationFlow = DataFlow::Make<TypeValidationConfig>;

// Avoid non-monotonic recursion by careful sink definition
predicate typeValidationGuard(GuardCondition guard, Expr other, BasicBlock block) {
  // Use TypeValidationFlow::hasFlowToExpr() to validate flow
  TypeValidationFlow::hasFlowToExpr(other) and
  guard.ensuresEq(_, other, 0, block, true)
}
```

### C++ Security Patterns

#### Basic Security Vulnerabilities

- **Buffer overflows**: Array bounds checking, string operations
- **Use after free**: Pointer usage after deallocation
- **Double free**: Multiple deallocations of same memory
- **Null pointer dereference**: Unguarded pointer usage
- **Integer overflows**: Arithmetic operations on integers
- **Format string vulnerabilities**: `printf` family functions
- **Race conditions**: Multi-threading without proper synchronization
- **Injection attacks**: Command injection, SQL injection through C++ APIs

#### Advanced Security Analysis Patterns

**Guard Condition Analysis for Type Validation:**

```ql
// Model type validation checks with macro calls
class TypeValidationCall extends FunctionCall {
  TypeValidationCall() { this.getTarget().hasName("VALIDATE_TYPE") }

  int getExpectedType(int index) {
    result = this.getArgument(index).getValue().toInt()
  }
}

// Guard conditions ensuring type safety
predicate typeValidationGuard(GuardCondition guard, TypeValidationCall call,
                             Expr other, BasicBlock block) {
  exists(Expr dest |
    DataFlow::localExprFlow(call, dest) and
    guard.ensuresEq(dest, other, 0, block, true)
  )
}
```

**Union Type Safety Analysis:**

```ql
// Detect unsafe union field access
class UnionAccess extends FieldAccess {
  UnionAccess() {
    this.getQualifier().getType().stripType() instanceof Union
  }

  predicate isUnsafeAccess() {
    // Check if proper type validation exists
    not exists(TypeValidationCall call, GuardCondition guard |
      typeValidationGuard(guard, call, _, this.getBasicBlock()) and
      // Match expected type with actual field access
      matchesExpectedType(call, this)
    )
  }
}
```

**Inter-procedural Validation Analysis:**

```ql
// Track validation across function boundaries
predicate typeValidationGuardOrIndirect(GuardCondition guard, TypeValidationCall call,
                                       Expr other, BasicBlock block) {
  typeValidationGuard(guard, call, other, block)
  or
  exists(FunctionCall fc |
    fc.getBasicBlock() = block and
    typeValidationGuardOrIndirect(guard, call, other,
      fc.getTarget().getACallToThisFunction().getBasicBlock())
  )
}
```

**Missing Flow Step Detection:**

```ql
// Use partial flow for debugging missing edges
import DataFlow::Impl::FlowExploration as FlowExploration
import FlowExploration::PartialPathGraph

// Additional flow steps for custom patterns
predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
  // Model return value flow for wrapper functions
  exists(FunctionCall call |
    call.getTarget().hasName("lock_input") and
    call.getArgument(0) = node1.asExpr() and
    call = node2.asExpr()
  )
}
```

### C++ Standard Library Patterns

- **STL containers**: `vector`, `string`, `map`, `set` operations
- **Iterators**: Iterator usage and invalidation
- **Algorithms**: `std::find`, `std::sort`, lambda expressions
- **Smart pointers**: Modern C++ memory management
- **Threading**: `std::thread`, `std::mutex`, `std::atomic`
- **I/O streams**: `iostream`, file operations

### C++ Language Features

- **Templates**: Template metaprogramming, SFINAE
- **Lambda expressions**: Capture lists, return type deduction
- **Move semantics**: `std::move`, rvalue references
- **Constexpr**: Compile-time evaluation
- **Auto type deduction**: Modern C++ type inference

## Advanced Analysis Techniques

### Data Flow Debugging

**Using Partial Flow for Missing Edges:**

```ql
// Import partial flow exploration
import DataFlow::Impl::FlowExploration as FlowExploration
import FlowExploration::PartialPathGraph

// Use in query to debug missing flow paths
from FlowExploration::PartialPathNode source, FlowExploration::PartialPathNode sink
where FlowExploration::hasPartialFlow(source, sink, _)
select source, sink, "Partial flow from source to sink"
```

**Path-Sensitive vs Path-Insensitive Analysis:**

```ql
// Path-sensitive: Use flow-state to track validation context
// Path-insensitive: Simple guard condition checks may miss cases

// Path-sensitive with barriers
predicate isBarrier(DataFlow::Node node, FlowState state) {
  exists(TypeValidationCall call |
    typeValidationGuard(_, call, _, node.asExpr().getBasicBlock()) and
    (
      state instanceof UnvalidatedState or
      state.(ValidatedState).getCall() != call
    )
  )
}
```

### Control Flow Analysis

**Entry Point Modeling:**

```ql
// Model functions that aren't called internally
class EntryPointFunction extends Function {
  EntryPointFunction() {
    this.hasName(["EP_example", "EP_main"]) or
    // Heuristic: functions with specific signatures not called internally
    (
      this.getNumberOfParameters() = 3 and
      this.getParameter(0).getType().toString().matches("%input%") and
      not exists(FunctionCall call | call.getTarget() = this)
    )
  }

  Parameter getInputParameter() { result = this.getParameter(0) }
  Parameter getInputTypesParameter() { result = this.getParameter(1) }
}
```

**Complex Guard Conditions:**

```ql
// Handle macro-based type validation
class MacroTypeValidation extends Expr {
  MacroTypeValidation() {
    // Match DYN_INPUT_TYPE(type1, type2) patterns
    this.toString().regexpMatch("DYN_INPUT_TYPE\\s*\\(.*\\)")
  }

  int getTypeForIndex(int index) {
    // Extract type constants from macro arguments
    exists(Expr arg |
      arg = this.getChild(index) and
      result = arg.getValue().toInt()
    )
  }
}
```

## Language-Specific Development Resources

For detailed C++ analysis patterns and implementation guides:

- [C++ AST Reference](../../languages/cpp/tools/dev/cpp_ast.prompt.md) - Comprehensive C++ AST node patterns and navigation
- [C++ Security Query Guide](../../languages/cpp/tools/dev/cpp_security_query_guide.prompt.md) - Advanced security analysis patterns including flow-state, union type safety, and debugging techniques

## CLI References

- [qlt query generate new-query](../../resources/cli/qlt/qlt_query_generate_new-query.prompt.md) - Generate scaffolding for a new CodeQL query with packs and tests
- [codeql query format](../../resources/cli/codeql/codeql_query_format.prompt.md)
- [codeql query compile](../../resources/cli/codeql/codeql_query_compile.prompt.md)
- [codeql query run](../../resources/cli/codeql/codeql_query_run.prompt.md)
- [codeql test run](../../resources/cli/codeql/codeql_test_run.prompt.md)
