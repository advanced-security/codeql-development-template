---
mode: agent
---

# CodeQL Data Extensions / Models as Data / Model Packs

This prompt provides common guidance for developing CodeQL data extensions across all supported languages, while language-specific prompts reference this common guidance and add language-specific details.

## Product Documentation

- [Extending coverage for a repository](https://docs.github.com/en/code-security/how-tos/scan-code-for-vulnerabilities/manage-your-configuration/editing-your-configuration-of-default-setup#extending-coverage-for-a-repository) - `.github/codeql/extensions directory` for local model pack refrences (does not need a qlpack.yml)
- [Extending coverage for all repositories in an organization](https://docs.github.com/en/code-security/how-tos/scan-code-for-vulnerabilities/manage-your-configuration/editing-your-configuration-of-default-setup#extending-coverage-for-all-repositories-in-an-organization) - publishing model packs and referencing them globally (must be done click button in UI)
- [Creating a CodeQL model pack](https://docs.github.com/en/code-security/tutorials/customize-code-scanning/creating-and-working-with-codeql-packs?versionId=free-pro-team%40latest&productId=code-security&restPage=how-tos%2Cscan-code-for-vulnerabilities%2Cmanage-your-configuration%2Cediting-your-configuration-of-default-setup#creating-a-codeql-model-pack) - publishing a model pack + for dataExtensions via qlpack.yml

## Core Principles
CodeQL analysis can be customized by adding library models in data extension YAML files to recognize libraries and frameworks that are not supported by default.
Model packs can be used to expand code scanning analysis at scale.  Model packs use data extensions, which are implemented as YAML and describe how to add data for new dependencies. When a model pack is specified, the data extensions in that pack will be added to the code scanning analysis automatically.

Generally each language will allow customization of the following extensible prdicates:
- sourceModel -  This is used to model sources of potentially tainted data. The `kind` of the sources defined using this predicate determine which **threat model** they are associated with (e.g., `remote`, `local`, `file`, `commandargs`). Different threat models can be used to customize the sources used in an analysis.
- sinkModel - This is used to model sinks where tainted data maybe used in a way that makes the code vulnerable. The `kind` identifies the vulnerability class (e.g., `sql-injection`, `command-injection`).
- summaryModel -  This is used to model flow through elements. The `kind` is either `taint` (derived value) or `value` (same value).
- neutralModel - This is similar to a summary model but used to model the flow of values that have only a minor impact on the dataflow analysis. Used to override incorrect auto-generated models.
- barrierModel - This is used to model barriers (sanitizers), which are elements that stop the flow of taint for a specified query kind. For example, an HTML-escaping function that prevents cross-site scripting. The `kind` must match the corresponding sink kind (e.g., `sql-injection`, `html-injection`). Available since CodeQL 2.25.2.
- barrierGuardModel - This is used to model barrier guards (validators), which are elements that return a boolean indicating whether data is safe. When the conditional check returns the specified `acceptingValue` (e.g., `"true"` or `"false"`), taint flow is stopped through guarded branches. The `kind` must match the corresponding sink kind. Available since CodeQL 2.25.2.
- typeModel - Only available in **API Graph languages** (Python, Ruby, JavaScript/TypeScript). Defines type relationships so that models for a parent type automatically apply to subtypes. MaD languages (Java/Kotlin, C#, Go, C/C++) handle subtyping via the `subtypes` boolean column in their tuples instead.

### What to Model in a Library

When reviewing a library or framework's documentation/API surface, identify the following categories of methods. All are important — sources, sinks, and summaries work together to form a complete taint-tracking path. Missing any one of them can break the chain and cause false negatives.

#### How to read a library's API for modeling

Given a library's documentation, ask these questions for each public method, function, or class:

1. **Does this method return data from an external source?** (network, filesystem, user input, environment) → **Source**
2. **Does this method consume data in a security-sensitive operation?** (execute SQL, run a shell command, write to a file path, redirect a URL) → **Sink**
3. **Does this method pass data through without CodeQL being able to see the implementation?** (transform, encode, decode, copy, wrap, unwrap, iterate) → **Summary**
4. **Does this method sanitize data so its output is safe for a specific vulnerability type?** (HTML-escape, SQL-escape, path canonicalization, URL encoding) → **Barrier**
5. **Does this method return a boolean indicating whether data is safe to use?** (URL validation, input format checking, allowlist matching) → **Barrier Guard**
6. **Is this type a subclass or variant of another type we've already modeled?** → **Type model**
7. **Has CodeQL's model generator incorrectly flagged this method as having flow?** → **Neutral**

#### Sources (sourceModel)

Sources are methods that return data from outside the application boundary. Without source models, taint tracking has no starting point.

Look for methods that:
- Read from HTTP requests (parameters, headers, body, cookies, URL)
- Read from WebSocket/gRPC/messaging channels
- Read from files, stdin, environment variables, command-line arguments
- Read from databases or caches
- Deserialize external data (JSON, XML, YAML, Protobuf)

The `kind` column determines the threat model category — see the Threat Models section below.

#### Sinks (sinkModel)

Sinks are methods that consume data in a way that can cause a vulnerability if the data is attacker-controlled. Without sink models, CodeQL cannot flag the vulnerability even if tainted data reaches the dangerous call.

Look for methods that:
- Execute SQL or NoSQL queries
- Execute OS commands or shell scripts
- Evaluate code dynamically (eval, template rendering)
- Access filesystem paths
- Redirect users to URLs
- Construct LDAP/XPath/regex queries from input
- Send data over the network (cleartext transmission)
- Deserialize untrusted data into objects

Each sink kind maps to a specific vulnerability class:

| Sink Kind | Vulnerability | Example |
|---|---|---|
| `sql-injection` | SQL Injection (CWE-089) | `cursor.execute(query)` |
| `command-injection` | OS Command Injection (CWE-078) | `subprocess.run(cmd)` |
| `code-injection` | Code Injection (CWE-094) | `eval(expr)` |
| `path-injection` | Path Traversal (CWE-022) | `open(filepath)` |
| `url-redirection` | Open Redirect (CWE-601) | `redirect(url)` |
| `log-injection` | Log Injection (CWE-117) | `logger.info(msg)` |
| `request-forgery` | SSRF (CWE-918) | `fetch(url)` |
| `nosql-injection` | NoSQL Injection | `collection.find(query)` |
| `xpath-injection` | XPath Injection | XPath query construction |
| `ldap-injection` | LDAP Injection | LDAP search filter construction |
| `html-injection` | XSS (CWE-079) | DOM manipulation (JS only) |
| `unsafe-deserialization` | Insecure Deserialization (CWE-502) | Unsafe YAML/pickle parsing (JS only) |
| `remote-sink` | Cleartext Transmission (CWE-319) | Network write (C/C++ only) |

Not all sink kinds are available in all languages — see language-specific prompts for details.

#### Summaries (summaryModel)

Summaries describe how taint propagates **through** a method call. Without summaries, taint tracking loses track of data as it passes through library/framework code, causing false negatives.

Look for methods that:
- Transform data (encode, decode, escape, unescape, serialize, deserialize)
- Copy or wrap data (constructors, builders, factory methods)
- Pass data through collections (add to list, get from map, iterate)
- Concatenate, split, or format strings
- Chain or compose operations (middleware, decorators, pipes)

Two summary kinds:
- `taint` — the output is derived from the input but not necessarily identical (e.g., string concatenation, encoding, parsing). Use this for most cases.
- `value` — the output is the same value or a direct copy (e.g., getter, identity transform, collection element access). Preserves all properties of the original value.

**When to model summaries:** Focus on methods that sit on the path between a source and a sink. If taint already flows end-to-end without a summary, you don't need one.

#### Types (typeModel)

Type models define relationships between types (e.g., "this subclass should inherit all models from its parent"). Useful to avoid duplicating sink/source/summary models across related classes.

**Supported by:** Python, Ruby, JavaScript/TypeScript (API Graph languages only)

**Not available in:** Java/Kotlin, C#, Go, C/C++ — these MaD languages handle subtyping through the `subtypes` boolean column in their source/sink/summary tuples. Setting `subtypes: True` makes the model apply to all overrides and implementations of the specified method.

#### Barriers (barrierModel)

Barriers model sanitizer functions — methods whose output is considered safe for a specific vulnerability type. A barrier stops taint flow at the modeled element. The `kind` value must match the sink kind used by the query where the barrier should take effect (e.g., `sql-injection`, `html-injection`, `path-injection`, `url-redirection`, `request-forgery`).

Look for methods that:
- Escape or encode output for a specific context (HTML-escape, SQL-escape, shell-escape)
- Canonicalize or normalize paths to prevent traversal
- Encode data to prevent injection (URL encoding, base64 for safe contexts)
- Strip or sanitize dangerous characters from input

#### Barrier Guards (barrierGuardModel)

Barrier guards model validator functions — methods that return a boolean indicating whether data is safe to use. When the function returns the expected `acceptingValue` (typically `"true"` or `"false"`), taint flow is stopped through the guarded branch. The `kind` must match the corresponding sink kind.

Look for methods that:
- Validate URLs (e.g., check if relative, check against allowlist)
- Check input format or pattern (e.g., is numeric, matches regex)
- Verify data integrity or safety (e.g., signature validation, allowlist check)
- Return a boolean that gates subsequent security-sensitive operations

#### Neutrals (neutralModel)

Neutral models explicitly mark a method as having no taint flow. Their primary purpose is to **override auto-generated models** — if CodeQL's model generator (`df-generated` provenance) incorrectly assigned a summary to a method, a manual neutral model suppresses it. They also have a minor effect on dataflow dispatch. Generally only needed when curating generated models.

### Threat Models

### Model File Organization

When a library or framework has distinct modules, packages, or sub-libraries, split models into **separate YAML files per module** rather than putting everything in one file. This makes models easier to review, maintain, and test independently.

For example, if modeling the `databricks` ecosystem:

```
models/
  databricks-sql.model.yml      # databricks.sql module (connect, cursor, execute)
  databricks-sdk.model.yml       # databricks SDK client methods
  databricks-connect.model.yml   # databricks-connect Spark session
```

Or for a web framework like Django:

```
models/
  django-http.model.yml          # django.http request/response sources
  django-db.model.yml            # django.db ORM sinks (raw SQL)
  django-shortcuts.model.yml     # django.shortcuts (redirect sinks)
  django-template.model.yml      # django.template (template injection sinks)
```

Naming convention: `<library>-<module>.model.yml` (lowercase, hyphen-separated).

All `.model.yml` files within a model pack are automatically picked up via the `dataExtensions` glob in `qlpack.yml` (e.g., `dataExtensions: models/**/*.yml`).

### Two Model Formats: API Graph vs MaD

CodeQL data extensions use one of two tuple formats depending on the language. Using the wrong format for a language will produce invalid extensions.

#### API Graph format (short tuples)

Used by: **Python**, **Ruby**, **JavaScript/TypeScript**

Tuples identify targets by a **type** string and an **access path** that navigates the API graph. Tuples are compact (3-5 columns).

```yaml
# sinkModel(type, path, kind) — 3 columns
- ["databricks","Member[sql].Member[connect].ReturnValue.Member[cursor].ReturnValue.Member[execute].Argument[0]","sql-injection"]

# summaryModel(type, path, input, output, kind) — 5 columns
- ["global", "Member[decodeURIComponent]", "Argument[0]", "ReturnValue", "taint"]

# barrierModel(type, path, kind) — 3 columns
- ["html", "Member[escape].ReturnValue", "html-injection"]

# barrierGuardModel(type, path, acceptingValue, kind) — 4 columns
- ["my-package", "Member[isValid].Argument[0]", "true", "sql-injection"]
```

- The `type` column is a starting point (package name, class name, or `"global"`)
- The `path` column is a `.`-separated chain of API graph tokens like `Member[x]`, `ReturnValue`, `Argument[n]`, `Parameter[n]`
- API graph paths can be verified by writing a CodeQL query that walks the API graph (see language-specific prompts)

#### MaD (Models as Data) format (long tuples)

Used by: **Java/Kotlin**, **C#**, **Go**, **C/C++**

Tuples identify targets by **fully qualified package/namespace, type, method name, and signature**. Tuples are verbose (9-10 columns).

```yaml
# sinkModel(package, type, subtypes, name, signature, ext, input, kind, provenance) — 9 columns
- ["java.sql", "Statement", True, "execute", "(String)", "", "Argument[0]", "sql-injection", "manual"]

# summaryModel(package, type, subtypes, name, signature, ext, input, output, kind, provenance) — 10 columns
- ["System", "String", False, "Concat", "(System.Object,System.Object)", "", "Argument[0,1]", "ReturnValue", "taint", "manual"]

# barrierModel(package, type, subtypes, name, signature, ext, output, kind, provenance) — 9 columns
- ["java.io", "File", True, "getName", "()", "", "ReturnValue", "path-injection", "manual"]

# barrierGuardModel(package, type, subtypes, name, signature, ext, input, acceptingValue, kind, provenance) — 10 columns
- ["java.net", "URI", True, "isAbsolute", "()", "", "Argument[this]", "false", "request-forgery", "manual"]
```

- The first 5 columns locate the callable: `package`/`namespace`, `type`, `subtypes` (bool), `name`, `signature`
- `subtypes: True` means the model applies to overrides/implementors
- `signature` uses fully qualified type names (Go always uses `""`)
- The `provenance` column (last) should be `"manual"` for hand-written models

#### Quick reference

| | API Graph | MaD |
|---|---|---|
| **Languages** | Python, Ruby, JS/TS | Java/Kotlin, C#, Go, C/C++ |
| **Pack name** | `codeql/<lang>-all` | `codeql/<lang>-all` |
| **Sink columns** | 3 (type, path, kind) | 9 |
| **Summary columns** | 5 | 10 |
| **Barrier columns** | 3 (type, path, kind) | 9 |
| **Barrier guard columns** | 4 (type, path, acceptingValue, kind) | 10 |
| **Target identification** | Access path navigation | Package + type + method + signature |
| **Pointer indirection** | N/A | C/C++ only: `Argument[*n]` |
| **Receiver access** | `Argument[self]` (Ruby/Python) | `Argument[this]` (Java/C#), `Argument[receiver]` (Go) |

For detailed syntax and examples, see the language-specific data extension prompts.

### Threat Models

Threat models control which `sourceModel` entries are active during analysis. The `kind` column of a `sourceModel` determines its threat model category.

#### Default behavior
By default, only the **`remote`** threat model is enabled. This means only sources marked with `kind: "remote"` are active. To include local sources, you must explicitly enable additional threat models via `--threat-model` on the CLI or in the code scanning configuration.

#### Categories

**`remote`** (enabled by default)
- Network requests and responses — HTTP parameters, headers, request bodies, WebSocket messages, API responses
- This is the primary threat model for web-facing applications

**`local`** (must be explicitly enabled)
Represents data from the local system. Subcategories can be enabled/disabled independently:

| Subcategory | Description | Example |
|---|---|---|
| `file` | Local file reads | `open("config.txt").read()` |
| `commandargs` | Command-line arguments | `sys.argv[1]` |
| `database` | Database query results | `cursor.fetchall()` |
| `environment` | Environment variables | `os.environ["KEY"]` |
| `stdin` | Standard input | `input()` |
| `windows-registry` | Windows registry values (C# only) | Registry.GetValue() |

Enable selectively: `--threat-model commandargs --threat-model environment` enables only those two, not all of `local`.

**Language-specific categories:**

| Category | Description | Language |
|---|---|---|
| `android` | External storage reads, ContentProvider params | Java/Kotlin only |
| `reverse-dns` | Reverse DNS lookups | Java only |
| `database-access-result` | Database access results | JavaScript only |
| `file-write` | Opening files in write mode | C# only |
| `view-component-input` | React/Vue/Angular component props | JavaScript/TypeScript only |

#### Choosing a threat model for your source

- Use `"remote"` for any data that arrives over the network — this is the most common and is active by default
- Use specific `local` subcategories (e.g., `"file"`, `"commandargs"`) when modeling local input mechanisms — be precise rather than using the generic `"local"` parent
- When in doubt, use `"remote"` — it provides the broadest default coverage

### Query Quality Criteria

Your generated CodeQL models will be evaluated on:

1. **Code Quality**:
   - **Critical**: Extensions must be formatted without errors. Invalid extensions will fail the engine and have negative code quality.
   - **Important**: Minimize warning-level diagnostics (deprecated elements, style guide deviations)
   - **Best Practice**: Follow CodeQL naming conventions and idioms, provide comments with sensible organizaiton


### Common Pitfalls

1. **Invalid definitions**: yaml models that do not match the defined format and have not been tested to be valid are not well trusted.

### Development

Access paths for data extensions are parsed using [shared/dataflow/codeql/dataflow/internal/AccessPathSyntax.qll](https://github.com/github/codeql/blob/main/shared/dataflow/codeql/dataflow/internal/AccessPathSyntax.qll)

For languages that support API Graphs as the access paths can be most easilly tested by:
1. creating a small codeql database with some sample code that has a full end to end flow for the suspected query
2. writing/executing a sample codeql query using api graphs to verify with 100% certainty that the path to discover the suspected source/sink/summary is verified.

To understand if APIGraphs are used by the language, it is best to evaluate the ModelsAsData.qll for the given language.
- ex: [python/ql/lib/semmle/python/frameworks/data/ModelsAsData.qll](https://github.com/github/codeql/blob/main/python/ql/lib/semmle/python/frameworks/data/ModelsAsData.qll) for python imports ApiGraphModels and ApiGraphs
  - [python/ql/lib/semmle/python/frameworks/data/internal/ApiGraphModels.qll](https://github.com/github/codeql/blob/main/python/ql/lib/semmle/python/frameworks/data/internal/ApiGraphModels.qll) dealing with flow models specified in extensible predicates.
    - [python/ql/lib/semmle/python/frameworks/data/internal/ApiGraphModelsSpecific.qll](https://github.com/github/codeql/blob/main/python/ql/lib/semmle/python/frameworks/data/internal/ApiGraphModelsSpecific.qll) handles the Python-specific Member[x] tokens by calling node.getMember(x) on the API graph



## CLI References

Essential commands for query development:

### Core Development Commands

- [qlt query generate new-query](../../resources/cli/qlt/qlt_query_generate_new-query.prompt.md) - Generate scaffolding for a new CodeQL query with packs and tests
- [codeql query compile](../../resources/cli/codeql/codeql_query_compile.prompt.md) - Compile and validate query syntax
- [codeql query run](../../resources/cli/codeql/codeql_query_run.prompt.md) - Execute queries against databases
- [codeql execute query-server2](../../resources/cli/codeql/codeql_execute_query-server2.prompt.md) - Run a persistent query execution server for efficient multi-query workflows and IDE integrations
- [codeql query format](../../resources/cli/codeql/codeql_query_format.prompt.md) - Format query source code
- [codeql test run](../../resources/cli/codeql/codeql_test_run.prompt.md) - Execute query test suites
- [codeql test extract](../../resources/cli/codeql/codeql_test_extract.prompt.md) - Create test databases

### Database Operations

- [codeql database create](../../resources/cli/codeql/codeql_database_create.prompt.md) - Create CodeQL databases
- [codeql database analyze](../../resources/cli/codeql/codeql_database_analyze.prompt.md) - Run queries against databases

### Package Management

- [codeql pack install](../../resources/cli/codeql/codeql_pack_install.prompt.md) - Install query dependencies
- [codeql resolve library-path](../../resources/cli/codeql/codeql_resolve_library-path.prompt.md) - Resolve library paths

### Results Analysis

- [codeql bqrs decode](../../resources/cli/codeql/codeql_bqrs_decode.prompt.md) - Convert binary results to text
- [codeql bqrs info](../../resources/cli/codeql/codeql_bqrs_info.prompt.md) - Inspect result metadata

### Model Pack / Data Extension Options

During development, you'll typically test data extensions with a **single query** or **unit test** — not `codeql database analyze` (which is for full analysis runs / CI).

#### Running a single query with model packs

Use `codeql query run` with `--model-packs` or `--additional-packs`:

```bash
# Use a published model pack by name against a single query
codeql query run \
    --database=/path/to/db \
    --model-packs=my-org/my-model-pack \
    --output=results.bqrs \
    -- path/to/MyQuery.ql

# Use a local (unpublished) model pack during development
codeql query run \
    --database=/path/to/db \
    --additional-packs=languages/<language>/custom/src \
    --output=results.bqrs \
    -- path/to/MyQuery.ql
```

#### Running unit tests with model packs

`codeql test run` does **not** support `--model-packs`. Instead, data extensions are resolved through `qlpack.yml` configuration:

1. The **model pack** declares `extensionTargets` and `dataExtensions` in its `qlpack.yml`
2. The **test pack** declares a dependency on the model pack in its `qlpack.yml`
3. Use `--additional-packs` to point the test runner at a local (unpublished) model pack:

```bash
codeql test run \
    --additional-packs=languages/<language>/custom/src \
    --keep-databases \
    --show-extractor-output \
    -- languages/<language>/<pack-basename>/test/<QueryBasename>/
```

#### Full option reference

| Option | Available on | Purpose |
|---|---|---|
| `--model-packs=<name@range>` | `codeql query run`, `codeql database analyze` | Reference published model packs by name |
| `--additional-packs=<dir>[;<dir>...]` | `codeql query run`, `codeql test run`, `codeql database analyze` | Search local directories for packs (primary mechanism for local development) |
| `--no-database-extension-packs` | `codeql database analyze` | Omit extensions bundled into the database at creation time |
| `--no-database-threat-models` | `codeql database analyze` | Omit threat model config stored in the database |
| `--threat-model=<name>` | `codeql database analyze` | Enable/disable threat model categories (e.g., `local`, `remote`, `all`) |

## Related Resources

- [Test-Driven QL Development](./test_driven_ql_development.prompt.md) - Comprehensive TDD workflow
- [Language-specific prompts](.) - Additional guidance for specific languages
