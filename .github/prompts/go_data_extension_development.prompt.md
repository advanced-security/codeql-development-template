---
mode: agent
---

# Go Data Extension

For general CodeQL data extension model development guidance, see [Common Data Extension Development](./data_extensions_development.prompt.md).
For general CodeQL query development guidance, see [Common Query Development](./query_development.prompt.md).

## Go-Specific Documentation

### Documentation

- [Customizing Library Models for Go](https://codeql.github.com/docs/codeql-language-guides/customizing-library-models-for-go/)
  - Can also be found at [Customizing Library Models for Go Docs](https://github.com/github/codeql/blob/main/docs/codeql/codeql-language-guides/customizing-library-models-for-go.rst)

### Model Format

Go uses a **MaD (Models as Data)** format with **9-10 column tuples** that identify callables by package path, type, function name, and signature. Same structural pattern as Java/Kotlin and C#.

The pack name is `codeql/go-all`.

#### Extensible predicates

| Predicate | Columns | Purpose |
|---|---|---|
| `sourceModel` | `(package, type, subtypes, name, signature, ext, output, kind, provenance)` | Model sources of tainted data |
| `sinkModel` | `(package, type, subtypes, name, signature, ext, input, kind, provenance)` | Model sinks |
| `summaryModel` | `(package, type, subtypes, name, signature, ext, input, output, kind, provenance)` | Model flow through functions |
| `barrierModel` | `(package, type, subtypes, name, signature, ext, output, kind, provenance)` | Model barriers (sanitizers) that stop taint flow |
| `barrierGuardModel` | `(package, type, subtypes, name, signature, ext, input, acceptingValue, kind, provenance)` | Model barrier guards (validators) that stop taint via conditional checks |
| `neutralModel` | `(package, type, name, signature, kind, provenance)` | Mark functions as having no dataflow impact |

#### Tuple column reference

| Column | Description | Example |
|---|---|---|
| `package` | Go package import path | `"database/sql"`, `"net/http"` |
| `type` | Receiver type name (leave `""` for free functions) | `"DB"`, `""` |
| `subtypes` | Whether model applies to embedded types / interface implementors (`True`/`False`) | `True` |
| `name` | Function or method name, or field name | `"Prepare"`, `"Body"` |
| `signature` | **Always `""` for Go** (Go does not use signature-based overload resolution) | `""` |
| `ext` | Leave empty (`""`) | `""` |
| `input`/`output` | Access path | `"Argument[0]"`, `"ReturnValue"` |
| `kind` | Source/sink/summary kind | `"sql-injection"`, `"taint"` |
| `provenance` | Origin of the model | `"manual"` |

#### Important: Go-specific rules
- **Signature is always `""`** — Go does not have overloaded functions, so the signature column is unused
- **Free functions** have `type` = `""` and `subtypes` = `False`
- **`subtypes: True`** includes embedded types (promoted methods/fields) and interface implementors
- **Field access** is modeled as a source with an empty output access path: `output` = `""`
- **Multiple return values**: use `ReturnValue[0]`, `ReturnValue[1]`, etc.
- **Receiver access path**: use `Argument[receiver]` (not `Argument[this]`)

### Access Paths

| Component | Description |
|---|---|
| `Argument[n]` | Argument at index n (0-based) |
| `Argument[receiver]` | The receiver of a method call (`u` in `u.Hostname()`) |
| `Argument[n1..n2]` | Range of arguments |
| `Argument[*n]` | First indirection (pointer dereference) of argument n |
| `ReturnValue` | Return value (or first return value) |
| `ReturnValue[n]` | The nth return value (0-indexed) |
| `ArrayElement` | Elements of a slice/array |
| `MapKey` | Key of a map |
| `MapValue` | Value of a map |

### Package Versioning

- Go modules with major version > 1 include the version suffix in the import path (e.g., `github.com/example/pkg/v2`)
- **Omit the version suffix** in the `package` column to match **all versions** automatically
- To match only a specific major version, include the suffix: `"github.com/example/pkg/v2"`
- To match only v1 (no suffix), use the `fixed-version:` prefix: `"fixed-version:github.com/example/pkg"`
- For `gopkg.in` packages, the `.v2` suffix is also handled automatically

### Package Grouping

When the same package is available under multiple import paths, use the `packageGrouping` extensible predicate:

```yaml
extensions:
  - addsTo:
      pack: codeql/go
      extensible: packageGrouping
    data:
      - ["glog", "github.com/golang/glog"]
      - ["glog", "gopkg.in/glog"]

  - addsTo:
      pack: codeql/go
      extensible: sinkModel
    data:
      - ["group:glog", "", False, "Info", "", "", "Argument[0]", "log-injection", "manual"]
```

### Sink Kinds

`sql-injection`, `nosql-injection`, `command-injection`, `path-injection`, `url-redirection`, `log-injection`, `request-forgery`, `xpath-injection`

### Sample Model

Given a snippet where `db.Prepare(query)` is a SQL injection sink:

```go
func Tainted(db *sql.DB, name string) {
    stmt, err := db.Prepare("SELECT * FROM users WHERE name = " + name) // sink
}
```

`database_sql.model.yml`

```yaml
extensions:
  - addsTo:
      pack: codeql/go-all
      extensible: sourceModel
    data: []

  - addsTo:
      pack: codeql/go-all
      extensible: sinkModel
    data:
      - ["database/sql", "DB", True, "Prepare", "", "", "Argument[0]", "sql-injection", "manual"]

  - addsTo:
      pack: codeql/go-all
      extensible: summaryModel
    data: []

  - addsTo:
      pack: codeql/go-all
      extensible: barrierModel
    data: []

  - addsTo:
      pack: codeql/go-all
      extensible: barrierGuardModel
    data: []

  - addsTo:
      pack: codeql/go-all
      extensible: neutralModel
    data: []
```

### Example: Source from HTTP Request Field

Model `r.Body` as a remote source (field access with empty output path):

```yaml
extensions:
  - addsTo:
      pack: codeql/go-all
      extensible: sourceModel
    data:
      - ["net/http", "Request", True, "Body", "", "", "", "remote", "manual"]
```

Note: The output column is `""` (empty) because this models a **field access**, not a method call.

### Example: Source from HTTP Method Return

```yaml
extensions:
  - addsTo:
      pack: codeql/go-all
      extensible: sourceModel
    data:
      - ["net/http", "Request", True, "FormValue", "", "", "ReturnValue", "remote", "manual"]
```

### Example: Flow Through `strings.Join`

```yaml
extensions:
  - addsTo:
      pack: codeql/go-all
      extensible: summaryModel
    data:
      - ["strings", "", False, "Join", "", "", "Argument[0..1]", "ReturnValue", "taint", "manual"]
```

Note: `Argument[0..1]` is shorthand for both `Argument[0]` and `Argument[1]`.

### Example: Flow Through Method with Receiver

```yaml
extensions:
  - addsTo:
      pack: codeql/go-all
      extensible: summaryModel
    data:
      - ["net/url", "URL", True, "Hostname", "", "", "Argument[receiver]", "ReturnValue", "taint", "manual"]
```

Note: Go uses `Argument[receiver]` (not `Argument[this]`).

### Example: Flow Through Variadic Function

For variadic parameters `...T`, the parameter is treated as `[]T`. Access elements with nested `ArrayElement`:

```yaml
extensions:
  - addsTo:
      pack: codeql/go-all
      extensible: summaryModel
    data:
       - ["slices", "", False, "Concat", "", "", "Argument[0].ArrayElement.ArrayElement", "ReturnValue.ArrayElement", "value", "manual"]
```

### Example: Barrier Using `Htmlquote`

The `Htmlquote` function from the beego framework HTML-escapes a string, preventing HTML injection attacks. The return value is safe.

```go
func Render(w http.ResponseWriter, r *http.Request) {
    name := r.FormValue("name")
    safe := beego.Htmlquote(name) // safe is HTML-escaped
}
```

```yaml
extensions:
  - addsTo:
      pack: codeql/go-all
      extensible: barrierModel
    data:
      - ["group:beego", "", True, "Htmlquote", "", "", "ReturnValue", "html-injection", "manual"]
```

Note: The `group:` prefix matches multiple package paths that refer to the same package (configured via `packageGrouping`). The `kind` `"html-injection"` must match the sink kind used by XSS queries.

### Example: Barrier Guard Using a Validation Function

A barrier guard models a function returning a boolean indicating whether data is safe. When the function returns the expected value, taint flow is stopped through the guarded branch.

```go
func Query(db *sql.DB, input string) {
    if example.IsSafe(input) { // The check guards the query
        db.Query(input) // Safe
    }
}
```

```yaml
extensions:
  - addsTo:
      pack: codeql/go-all
      extensible: barrierGuardModel
    data:
      - ["example.com/example", "", False, "IsSafe", "", "", "Argument[0]", "true", "sql-injection", "manual"]
```

Note: The `acceptingValue` `"true"` means the barrier applies when `IsSafe` returns true. The `input` `"Argument[0]"` identifies the first argument whose taint flow is blocked.

### Additional References
- **[Go Reference](./go_query_development.prompt.md)** - Go query development
