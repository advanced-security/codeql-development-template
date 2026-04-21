---
mode: agent
---

# JavaScript / TypeScript Data Extension

For general CodeQL data extension model development guidance, see [Common Data Extension Development](./data_extensions_development.prompt.md).
For general CodeQL query development guidance, see [Common Query Development](./query_development.prompt.md).

## JavaScript/TypeScript-Specific Documentation

### Documentation

- [Customizing Library Models for JavaScript](https://codeql.github.com/docs/codeql-language-guides/customizing-library-models-for-javascript/)
  - Can also be found at [Customizing Library Models for JavaScript Docs](https://github.com/github/codeql/blob/main/docs/codeql/codeql-language-guides/customizing-library-models-for-javascript.rst)

### Model Format

JavaScript/TypeScript uses an **API Graph-based** model format with short tuples — similar to Python and Ruby.

The pack name is `codeql/javascript-all`.

#### Extensible predicates

| Predicate | Columns | Purpose |
|---|---|---|
| `sourceModel` | `(type, path, kind)` | Model sources of tainted data |
| `sinkModel` | `(type, path, kind)` | Model sinks where tainted data is used vulnerably |
| `summaryModel` | `(type, path, input, output, kind)` | Model flow through function calls |
| `barrierModel` | `(type, path, kind)` | Model barriers (sanitizers) that stop taint flow |
| `barrierGuardModel` | `(type, path, acceptingValue, kind)` | Model barrier guards (validators) that stop taint via conditional checks |
| `typeModel` | `(type1, type2, path)` | Define type relationships |

#### Type column (first column)

The `type` column identifies a starting point for access path evaluation:
- **NPM package name** (e.g., `"execa"`, `"mysql"`) — matches imports of that package. If the package name has dots, surround with single quotes: `'lodash.escape'`.
- **`"global"`** — matches the global object (window). Use this to access global variables/functions like `eval`, `decodeURIComponent`.
- **Qualified type** `"<package>.<type>"` (e.g., `"mysql.Connection"`) — matches expressions known to be instances of that type (via type annotations or `typeModel` definitions).

### Access Paths

Access paths are `.`-separated, evaluated left to right:

| Component | Description |
|---|---|
| `Member[name]` | Property access with the given name |
| `AnyMember` | Any property regardless of name |
| `Argument[n]` | Argument at index n |
| `Argument[this]` | The receiver of a method call |
| `Parameter[n]` | Parameter at index n |
| `Parameter[this]` | The `this` parameter of a function |
| `ReturnValue` | Return value of a function or call |
| `ArrayElement` | An element of an array |
| `MapValue` | A value of a map object |
| `Awaited` | The value of a resolved promise |
| `Instance` | Instances of a class (including subclasses) |
| `Fuzzy` | All values derived from the current value (approximate, useful for complex libraries) |

**Call site filters** (select a subset of calls matching criteria):

| Component | Description |
|---|---|
| `WithArity[n]` | Calls with exactly n arguments |
| `WithStringArgument[n=value]` | Calls where argument n is string literal `value` |

**Decorator components:**

| Component | Description |
|---|---|
| `DecoratedClass` | A class decorated by the current value |
| `DecoratedParameter` | A parameter decorated by the current value |
| `DecoratedMember` | A method/field/accessor decorated by the current value |

**Middleware component:**

| Component | Description |
|---|---|
| `GuardedRouteHandler` | Route handlers guarded by the current middleware |

**Syntax notes:**
- Multiple operands: `Member[foo,bar]` matches either `foo` or `bar`
- Numeric intervals: `Argument[0..2]` matches arguments 0, 1, or 2
- Last argument: `Argument[N-1]`, second-to-last: `Argument[N-2]`

### Sink Kinds

`code-injection`, `command-injection`, `path-injection`, `sql-injection`, `nosql-injection`, `html-injection`, `request-forgery`, `url-redirection`, `unsafe-deserialization`, `log-injection`

### Threat Models (JS-specific)

In addition to `remote` and `local`, JavaScript supports:
- `database-access-result` — data from database reads
- `view-component-input` — inputs to React/Vue/Angular components (props)

### Sample Model

Given a snippet using the `execa` package:

```javascript
import { shell } from "execa";
shell(cmd); // sink: command injection
```

`execa.model.yml`

```yaml
extensions:
  - addsTo:
      pack: codeql/javascript-all
      extensible: sinkModel
    data:
      - ["execa", "Member[shell].Argument[0]", "command-injection"]
```

### Example: Source from Window Message Events

```yaml
extensions:
  - addsTo:
      pack: codeql/javascript-all
      extensible: sourceModel
    data:
      - ["global", "Member[addEventListener].WithStringArgument[0=message].Argument[1].Parameter[0].Member[data]", "remote"]
```

Note the use of `WithStringArgument[0=message]` to restrict to only `"message"` event listeners.

### Example: Using Fuzzy Models

When a library is complex and precise modeling is difficult, `Fuzzy` approximates all values derived from a package:

```yaml
extensions:
  - addsTo:
      pack: codeql/javascript-all
      extensible: sinkModel
    data:
      - ["mysql", "Fuzzy.Member[query].Argument[0]", "sql-injection"]
```

### Example: typeModel for Untyped Code

When code lacks type annotations, use `typeModel` to define that a function returns an instance of a known type:

```yaml
extensions:
  - addsTo:
      pack: codeql/javascript-all
      extensible: typeModel
    data:
      - ["mysql.Connection", "@example/db", "Member[getConnection].ReturnValue"]
```

### Example: Summary with GuardedRouteHandler

Model a middleware that injects tainted data on `req.data`:

```yaml
extensions:
  - addsTo:
      pack: codeql/javascript-all
      extensible: sourceModel
    data:
      - ["@example/middleware", "Member[injectData].ReturnValue.GuardedRouteHandler.Parameter[0].Member[data]", "remote"]
```

### Example: Barrier Using `encodeURIComponent`

The `encodeURIComponent` function encodes a string for safe use in URLs, preventing HTML injection when the result is used in HTML contexts.

```javascript
let escaped = encodeURIComponent(input); // Safe for XSS
document.body.innerHTML = escaped;
```

```yaml
extensions:
  - addsTo:
      pack: codeql/javascript-all
      extensible: barrierModel
    data:
      - ["global", "Member[encodeURIComponent].ReturnValue", "html-injection"]
```

Note: The `type` `"global"` starts at the global object. The `path` navigates to the return value of `encodeURIComponent`. The `kind` `"html-injection"` must match the sink kind used by XSS queries.

### Example: Barrier Guard Using a Validation Function

A barrier guard models a function that returns a boolean indicating whether data is safe. When the function returns the expected value, taint flow is stopped through the guarded branch.

```javascript
if (isValid(userInput)) { // The check guards the use
  db.query(userInput); // Safe
}
```

```yaml
extensions:
  - addsTo:
      pack: codeql/javascript-all
      extensible: barrierGuardModel
    data:
      - ["my-package", "Member[isValid].Argument[0]", "true", "sql-injection"]
```

Note: The `acceptingValue` `"true"` means the barrier applies when `isValid` returns true. The `path` `"Member[isValid].Argument[0]"` identifies the value being validated (the first argument).

### Additional References
- **[JavaScript Reference](./javascript_query_development.prompt.md)** - JavaScript/TypeScript query development
