---
mode: agent
---

# Java / Kotlin Data Extension

For general CodeQL data extension model development guidance, see [Common Data Extension Development](./data_extensions_development.prompt.md).
For general CodeQL query development guidance, see [Common Query Development](./query_development.prompt.md).

## Java/Kotlin-Specific Documentation

### Documentation

- [Customizing Library Models for Java and Kotlin](https://codeql.github.com/docs/codeql-language-guides/customizing-library-models-for-java-and-kotlin/)
  - Can also be found at [Customizing Library Models for Java and Kotlin Docs](https://github.com/github/codeql/blob/main/docs/codeql/codeql-language-guides/customizing-library-models-for-java-and-kotlin.rst)

- The VS Code CodeQL model editor provides a guided UI for creating Java/Kotlin models. See [Using the CodeQL model editor](https://docs.github.com/en/code-security/codeql-for-vs-code/using-the-advanced-functionality-of-the-codeql-for-vs-code-extension/using-the-codeql-model-editor).

### Model Format

Java/Kotlin uses a **MaD (Models as Data)** format with **9-10 column tuples** that identify callables by fully qualified package, type, method name, and signature. This is fundamentally different from the API Graph-based format used by Python, Ruby, and JavaScript.

The pack name is `codeql/java-all`.

#### Extensible predicates

| Predicate | Columns | Purpose |
|---|---|---|
| `sourceModel` | `(package, type, subtypes, name, signature, ext, output, kind, provenance)` | Model sources of tainted data |
| `sinkModel` | `(package, type, subtypes, name, signature, ext, input, kind, provenance)` | Model sinks |
| `summaryModel` | `(package, type, subtypes, name, signature, ext, input, output, kind, provenance)` | Model flow through methods |
| `barrierModel` | `(package, type, subtypes, name, signature, ext, output, kind, provenance)` | Model barriers (sanitizers) that stop taint flow |
| `barrierGuardModel` | `(package, type, subtypes, name, signature, ext, input, acceptingValue, kind, provenance)` | Model barrier guards (validators) that stop taint via conditional checks |
| `neutralModel` | `(package, type, name, signature, kind, provenance)` | Mark methods as having no dataflow impact |

#### Tuple column reference

| Column | Description | Example |
|---|---|---|
| `package` | Fully qualified package name | `"java.sql"` |
| `type` | Class or interface name | `"Statement"` |
| `subtypes` | Whether model applies to overrides (`True`/`False`) | `True` |
| `name` | Method name (constructors use the class name) | `"execute"` |
| `signature` | Method parameter type signature | `"(String)"` |
| `ext` | Leave empty (`""`) | `""` |
| `input`/`output` | Access path to the input/output of the flow | `"Argument[0]"`, `"ReturnValue"` |
| `kind` | Source/sink/summary kind | `"sql-injection"`, `"taint"` |
| `provenance` | Origin of the model | `"manual"` |

#### Important: `subtypes` flag
- `True` — the model applies to the method **and all overrides** in subclasses/implementing classes
- `False` — only applies to the exact class specified

#### Important: `signature` column
- Type names must be **fully qualified**: `"(String)"` means `java.lang.String`
- Multiple parameters: `"(String,int)"`
- Generic type parameters must match source: `"Select<TSource,TResult>"`
- Empty `""` matches any signature (use sparingly)

### Access Paths

| Component | Description |
|---|---|
| `Argument[n]` | Argument at index n (0-based) |
| `Argument[this]` | The qualifier/receiver of a method call |
| `Argument[n1..n2]` | Range of arguments |
| `ReturnValue` | Return value of the method |
| `Element` | Elements of a collection |
| `Field[name]` | Named field of a class |
| `Parameter[n]` | Parameter at index n of a callback |
| `MapKey` | Key of a map |
| `MapValue` | Value of a map |

### Sink Kinds

`sql-injection`, `command-injection`, `code-injection`, `path-injection`, `url-redirection`, `log-injection`, `request-forgery`, `xpath-injection`, `ldap-injection`, `jndi-injection`, `template-injection`, `hostname-verification`

### Threat Models (Java-specific)

In addition to `remote` and `local`, Java supports:
- `android` (`android-external-storage-dir`, `contentprovider`) — Android-specific sources
- `reverse-dns` — reverse DNS lookups

### Sample Model

Given a snippet where `stmt.execute(query)` is a SQL injection sink:

```java
public static void taintsink(Connection conn, String query) throws SQLException {
    Statement stmt = conn.createStatement();
    stmt.execute(query); // sink: SQL injection
}
```

`jdbc.model.yml`

```yaml
extensions:
  - addsTo:
      pack: codeql/java-all
      extensible: sourceModel
    data: []

  - addsTo:
      pack: codeql/java-all
      extensible: sinkModel
    data:
      - ["java.sql", "Statement", True, "execute", "(String)", "", "Argument[0]", "sql-injection", "manual"]

  - addsTo:
      pack: codeql/java-all
      extensible: summaryModel
    data: []

  - addsTo:
      pack: codeql/java-all
      extensible: barrierModel
    data: []

  - addsTo:
      pack: codeql/java-all
      extensible: barrierGuardModel
    data: []

  - addsTo:
      pack: codeql/java-all
      extensible: neutralModel
    data: []
```

### Example: Source from Network Socket

```yaml
extensions:
  - addsTo:
      pack: codeql/java-all
      extensible: sourceModel
    data:
      - ["java.net", "Socket", False, "getInputStream", "()", "", "ReturnValue", "remote", "manual"]
```

### Example: Flow Through `String.concat`

```yaml
extensions:
  - addsTo:
      pack: codeql/java-all
      extensible: summaryModel
    data:
      - ["java.lang", "String", False, "concat", "(String)", "", "Argument[this]", "ReturnValue", "taint", "manual"]
      - ["java.lang", "String", False, "concat", "(String)", "", "Argument[0]", "ReturnValue", "taint", "manual"]
```

### Example: Flow Through Higher-Order Method `Stream.map`

```yaml
extensions:
  - addsTo:
      pack: codeql/java-all
      extensible: summaryModel
    data:
      - ["java.util.stream", "Stream", True, "map", "(Function)", "", "Argument[this].Element", "Argument[0].Parameter[0]", "value", "manual"]
      - ["java.util.stream", "Stream", True, "map", "(Function)", "", "Argument[0].ReturnValue", "ReturnValue.Element", "value", "manual"]
```

Note: Two rows are needed — one for flow into the lambda parameter, one for flow from the lambda return to the output stream elements.

### Example: Neutral Model

```yaml
extensions:
  - addsTo:
      pack: codeql/java-all
      extensible: neutralModel
    data:
      - ["java.time", "Instant", "now", "()", "summary", "manual"]
```

### Example: Barrier for Path Injection

The `File.getName()` method returns only the final component of a path, which protects against path injection vulnerabilities.

```java
public static void barrier(File file) {
    String name = file.getName(); // Only the filename, no directory traversal
}
```

```yaml
extensions:
  - addsTo:
      pack: codeql/java-all
      extensible: barrierModel
    data:
      - ["java.io", "File", True, "getName", "()", "", "ReturnValue", "path-injection", "manual"]
```

Note: The `kind` `"path-injection"` must match the sink kind used by path injection queries. `subtypes: True` ensures the model applies to subclasses of `File`.

### Example: Barrier Guard for Request Forgery

The `URI.isAbsolute()` method returns `false` when the URI is relative and therefore safe for request forgery because it cannot redirect to an external server.

```java
public static void barrierguard(URI uri) throws IOException {
    if (!uri.isAbsolute()) { // The check guards the request
        URL url = uri.toURL();
        url.openConnection(); // Safe
    }
}
```

```yaml
extensions:
  - addsTo:
      pack: codeql/java-all
      extensible: barrierGuardModel
    data:
      - ["java.net", "URI", True, "isAbsolute", "()", "", "Argument[this]", "false", "request-forgery", "manual"]
```

Note: The `acceptingValue` `"false"` means the barrier applies when `isAbsolute` returns false (the URI is relative). The `input` `"Argument[this]"` identifies the qualifier (`uri`) whose taint flow is blocked.

### Additional References
- **[Java Reference](./java_query_development.prompt.md)** - Java/Kotlin query development
