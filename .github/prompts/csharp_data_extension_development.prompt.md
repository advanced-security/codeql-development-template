---
mode: agent
---

# C# Data Extension

For general CodeQL data extension model development guidance, see [Common Data Extension Development](./data_extensions_development.prompt.md).
If you need to write a custom CodeQL query instead of a data extension, see [Common Query Development](./query_development.prompt.md).

## C#-Specific Documentation

### Documentation

- [Customizing Library Models for C#](https://codeql.github.com/docs/codeql-language-guides/customizing-library-models-for-csharp/)
  - Can also be found at [Customizing Library Models for C# Docs](https://github.com/github/codeql/blob/main/docs/codeql/codeql-language-guides/customizing-library-models-for-csharp.rst)

### Model Format

C# uses a **MaD (Models as Data)** format with **9-10 column tuples** that identify callables by fully qualified namespace, type, method name, and signature. This is the same structural pattern as Java/Kotlin and Go.

The pack name is `codeql/csharp-all`.

#### Extensible predicates

| Predicate           | Columns                                                                                      | Purpose                                                                  |
| ------------------- | -------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| `sourceModel`       | `(namespace, type, subtypes, name, signature, ext, output, kind, provenance)`                | Model sources of tainted data                                            |
| `sinkModel`         | `(namespace, type, subtypes, name, signature, ext, input, kind, provenance)`                 | Model sinks                                                              |
| `summaryModel`      | `(namespace, type, subtypes, name, signature, ext, input, output, kind, provenance)`         | Model flow through methods                                               |
| `barrierModel`      | `(namespace, type, subtypes, name, signature, ext, output, kind, provenance)`                | Model barriers (sanitizers) that stop taint flow                         |
| `barrierGuardModel` | `(namespace, type, subtypes, name, signature, ext, input, acceptingValue, kind, provenance)` | Model barrier guards (validators) that stop taint via conditional checks |
| `neutralModel`      | `(namespace, type, name, signature, kind, provenance)`                                       | Mark methods as having no dataflow impact                                |

#### Tuple column reference

| Column           | Description                                                                                     | Example                                                 |
| ---------------- | ----------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| `namespace`      | Fully qualified namespace                                                                       | `"System.Data.SqlClient"`                               |
| `type`           | Class or interface name                                                                         | `"SqlCommand"`                                          |
| `subtypes`       | Whether model applies to overrides (`True`/`False`)                                             | `False`                                                 |
| `name`           | Method/property name. Constructors use the class name. Getters: `get_Name`, Setters: `set_Name` | `"SqlCommand"`, `"get_Now"`                             |
| `signature`      | Fully qualified parameter types in parentheses                                                  | `"(System.String,System.Data.SqlClient.SqlConnection)"` |
| `ext`            | Leave empty (`""`)                                                                              | `""`                                                    |
| `input`/`output` | Access path                                                                                     | `"Argument[0]"`, `"ReturnValue"`                        |
| `kind`           | Source/sink/summary kind                                                                        | `"sql-injection"`, `"taint"`                            |
| `provenance`     | Origin of the model                                                                             | `"manual"`                                              |

#### Important: C#-specific signature rules

- Type names must be **fully qualified**: `System.String`, not `string`
- Generic type parameters must match source code names: `Select<TSource,TResult>`
- Generics in signatures must match: `(System.Collections.Generic.IEnumerable<TSource>,System.Func<TSource,TResult>)`
- Property getters/setters are modeled as `get_PropertyName`/`set_PropertyName`
- Constructors use the class name (e.g., `"SqlCommand"`)

### Access Paths

| Component         | Description                                  |
| ----------------- | -------------------------------------------- |
| `Argument[n]`     | Argument at index n (0-based)                |
| `Argument[this]`  | The qualifier/receiver of a method call      |
| `Argument[n1,n2]` | Shorthand for multiple arguments             |
| `ReturnValue`     | Return value of the method                   |
| `Element`         | Elements of a collection (e.g., IEnumerable) |
| `Parameter[n]`    | Parameter at index n of a delegate/lambda    |
| `Field[name]`     | Named field                                  |
| `Property[name]`  | Named property                               |

### Sink Kinds

`sql-injection`, `command-injection`, `code-injection`, `path-injection`, `url-redirection`, `log-injection`, `request-forgery`, `xpath-injection`, `ldap-injection`

### Threat Models (C#-specific)

In addition to `remote` and `local`, C# supports:

- `file-write` — opening a file in write mode
- `windows-registry` — Windows registry values (C# only)

### Sample Model

Given a snippet where the `SqlCommand` constructor takes a SQL string:

```csharp
public static void TaintSink(SqlConnection conn, string query) {
    SqlCommand command = new SqlCommand(query, conn); // sink: SQL injection
}
```

`sqlclient.model.yml`

```yaml
extensions:
  - addsTo:
      pack: codeql/csharp-all
      extensible: sourceModel
    data: []

  - addsTo:
      pack: codeql/csharp-all
      extensible: sinkModel
    data:
      - [
          'System.Data.SqlClient',
          'SqlCommand',
          False,
          'SqlCommand',
          '(System.String,System.Data.SqlClient.SqlConnection)',
          '',
          'Argument[0]',
          'sql-injection',
          'manual'
        ]

  - addsTo:
      pack: codeql/csharp-all
      extensible: summaryModel
    data: []

  - addsTo:
      pack: codeql/csharp-all
      extensible: barrierModel
    data: []

  - addsTo:
      pack: codeql/csharp-all
      extensible: barrierGuardModel
    data: []

  - addsTo:
      pack: codeql/csharp-all
      extensible: neutralModel
    data: []
```

### Example: Remote Source from Network Stream

```yaml
extensions:
  - addsTo:
      pack: codeql/csharp-all
      extensible: sourceModel
    data:
      - [
          'System.Net.Sockets',
          'TcpClient',
          False,
          'GetStream',
          '()',
          '',
          'ReturnValue',
          'remote',
          'manual'
        ]
```

### Example: Flow Through `String.Concat`

```yaml
extensions:
  - addsTo:
      pack: codeql/csharp-all
      extensible: summaryModel
    data:
      - [
          'System',
          'String',
          False,
          'Concat',
          '(System.Object,System.Object)',
          '',
          'Argument[0,1]',
          'ReturnValue',
          'taint',
          'manual'
        ]
```

Note: `Argument[0,1]` is shorthand for both `Argument[0]` and `Argument[1]`.

### Example: Flow Through `String.Trim` (Instance Method)

```yaml
extensions:
  - addsTo:
      pack: codeql/csharp-all
      extensible: summaryModel
    data:
      - [
          'System',
          'String',
          False,
          'Trim',
          '()',
          '',
          'Argument[this]',
          'ReturnValue',
          'taint',
          'manual'
        ]
```

### Example: Flow Through LINQ `Select` (Higher-Order + Generics)

```yaml
extensions:
  - addsTo:
      pack: codeql/csharp-all
      extensible: summaryModel
    data:
      - [
          'System.Linq',
          'Enumerable',
          False,
          'Select<TSource,TResult>',
          '(System.Collections.Generic.IEnumerable<TSource>,System.Func<TSource,TResult>)',
          '',
          'Argument[0].Element',
          'Argument[1].Parameter[0]',
          'value',
          'manual'
        ]
      - [
          'System.Linq',
          'Enumerable',
          False,
          'Select<TSource,TResult>',
          '(System.Collections.Generic.IEnumerable<TSource>,System.Func<TSource,TResult>)',
          '',
          'Argument[1].ReturnValue',
          'ReturnValue.Element',
          'value',
          'manual'
        ]
```

Note: Two rows model the two-step flow: collection elements into the lambda parameter, then from the lambda return value into the output collection elements. Generic type parameter names must match the source code.

### Example: Neutral Model (Property Getter)

```yaml
extensions:
  - addsTo:
      pack: codeql/csharp-all
      extensible: neutralModel
    data:
      - ['System', 'DateTime', 'get_Now', '()', 'summary', 'manual']
```

### Example: Barrier for URL Redirection

The `RawUrl` property of `HttpRequest` returns the raw URL of the current request, which is safe for URL redirects because it cannot be manipulated by an attacker.

```csharp
public static void TaintBarrier(HttpRequest request) {
    string url = request.RawUrl; // Safe for URL redirects
    Response.Redirect(url); // Not a URL redirection vulnerability
}
```

```yaml
extensions:
  - addsTo:
      pack: codeql/csharp-all
      extensible: barrierModel
    data:
      - [
          'System.Web',
          'HttpRequest',
          False,
          'get_RawUrl',
          '()',
          '',
          'ReturnValue',
          'url-redirection',
          'manual'
        ]
```

Note: Property getters are modeled as `get_PropertyName`. The `kind` `"url-redirection"` must match the sink kind used by URL redirection queries.

### Example: Barrier Guard for URL Validation

The `IsAbsoluteUri` property of `Uri` returns `false` when the URL is relative and therefore safe for URL redirects.

```csharp
public static void TaintBarrierGuard(Uri uri) {
    if (!uri.IsAbsoluteUri) { // The check guards the redirect
        Response.Redirect(uri.ToString()); // Safe
    }
}
```

```yaml
extensions:
  - addsTo:
      pack: codeql/csharp-all
      extensible: barrierGuardModel
    data:
      - [
          'System',
          'Uri',
          False,
          'get_IsAbsoluteUri',
          '()',
          '',
          'Argument[this]',
          'false',
          'url-redirection',
          'manual'
        ]
```

Note: The `acceptingValue` `"false"` means the barrier applies when `IsAbsoluteUri` is false (the URL is relative). The `input` `"Argument[this]"` identifies the qualifier (`uri`) whose taint flow is blocked.

### Additional References

- **[C# Reference](./csharp_query_development.prompt.md)** - C# query development
