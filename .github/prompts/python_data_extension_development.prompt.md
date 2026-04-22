---
mode: agent
---

# Python Data Extension

For general CodeQL data extension model development guidance, see [Common Data Extension Development](./data_extensions_development.prompt.md).
If you need to write a custom CodeQL query instead of a data extension, see [Common Query Development](./query_development.prompt.md).

## Python-Specific Documentation

### Python Documentation

- [Customizing Library Models for Python](https://codeql.github.com/docs/codeql-language-guides/customizing-library-models-for-python/)
  - Can also be found at [Customizing Library Models for Python Docs](https://github.com/github/codeql/blob/main/docs/codeql/codeql-language-guides/customizing-library-models-for-python.rst)

- [Using API graphs in Python](https://codeql.github.com/docs/codeql-language-guides/using-api-graphs-in-python/) - the access paths input to the extension tuple are powered by API graphs

### API Graphs

- [python/ql/lib/semmle/python/frameworks/data/ModelsAsData.qll](https://github.com/github/codeql/blob/main/python/ql/lib/semmle/python/frameworks/data/ModelsAsData.qll) for python imports ApiGraphModels and ApiGraphs
  - [python/ql/lib/semmle/python/frameworks/data/internal/ApiGraphModels.qll](https://github.com/github/codeql/blob/main/python/ql/lib/semmle/python/frameworks/data/internal/ApiGraphModels.qll) dealing with flow models specified in extensible predicates.
    - [python/ql/lib/semmle/python/frameworks/data/internal/ApiGraphModelsSpecific.qll](https://github.com/github/codeql/blob/main/python/ql/lib/semmle/python/frameworks/data/internal/ApiGraphModelsSpecific.qll) handles the Python-specific Member[x] tokens by calling node.getMember(x) on the API graph

Ex query that could test out the API Graphs for the given database to ensure a proper path is built:

```codeql
import python
import semmle.python.ApiGraphs

from API::CallNode call
where
    call = API::moduleImport("re").getMember("compile").getACall() and
    call.getParameter(0, "pattern") =
        API::moduleImport("argparse")
            .getMember("ArgumentParser")
            .getReturn()
            .getMember("parse_args")
            .getMember(_)
select call
```

The parsing works as follows:

1. `AccessPathSyntax.qll` tokenizes the path "Member[sql].Member[connect].ReturnValue.Member[cursor].ReturnValue.Member[execute].Argument[0]" into individual tokens:

- Member[sql]
- Member[connect]
- ReturnValue
- Member[cursor]
- ReturnValue
- Member[execute]
- Argument[0]

2. `ApiGraphModels.qll` uses getNodeFromPath() to recursively resolve each token starting from the "databricks" type
3. `ApiGraphModelsSpecific.qll` handles the Python-specific Member[x] tokens by calling node.getMember(x) on the API graph

### Sample Model

Given this sample snippet (that would need to be a full piece of code to test this codeql extension)

```python
from flask import Flask, request
import databricks.sql as dbsql

app = Flask(__name__)

@app.get("/q")
def q():
    s = request.args["s"]  # remote user input
    query = "SELECT * FROM users WHERE name='" + s + "'"  # user controls SQL text

    with dbsql.connect(server_hostname="HOST", http_path="HTTP_PATH", access_token="TOKEN") as conn:
        with conn.cursor() as cursor:
            cursor.execute(query)  # sink we want to model with the data extension
            return str(cursor.fetchall())
```

This is a sample model that extends the `sql-injection` sinkModel to find instances of `cursor.execute()` as vulnerable.

`databricks.model.yml`

```yaml
extensions:
  - addsTo:
      pack: codeql/python-all
      extensible: sourceModel
    data: []

  - addsTo:
      pack: codeql/python-all
      extensible: sinkModel
    data:
      # Using API graphs modeling works:
      - [
          'databricks',
          'Member[sql].Member[connect].ReturnValue.Member[cursor].ReturnValue.Member[execute].Argument[0]',
          'sql-injection'
        ]
  - addsTo:
      pack: codeql/python-all
      extensible: summaryModel
    data: []

  - addsTo:
      pack: codeql/python-all
      extensible: barrierModel
    data: []

  - addsTo:
      pack: codeql/python-all
      extensible: barrierGuardModel
    data: []

  - addsTo:
      pack: codeql/python-all
      extensible: neutralModel
    data: []

  - addsTo:
      pack: codeql/python-all
      extensible: typeModel
    data: []
```

### Example: Barrier Using `html.escape`

The `html.escape` function HTML-escapes a string, preventing HTML injection (XSS) attacks.

```python
import html
escaped = html.escape(unknown) # Safe for XSS
```

```yaml
extensions:
  - addsTo:
      pack: codeql/python-all
      extensible: barrierModel
    data:
      - ['html', 'Member[escape].ReturnValue', 'html-injection']
```

Note: The `type` `"html"` starts at the `html` module import. The `path` navigates to the return value of `escape`. The `kind` `"html-injection"` must match the sink kind used by XSS queries.

### Example: Barrier Guard Using Django URL Validation

The `url_has_allowed_host_and_scheme` function from Django validates that a URL is safe for redirects.

```python
if url_has_allowed_host_and_scheme(url, allowed_hosts=...):
    redirect(url)  # Safe
```

```yaml
extensions:
  - addsTo:
      pack: codeql/python-all
      extensible: barrierGuardModel
    data:
      - [
          'django',
          'Member[utils].Member[http].Member[url_has_allowed_host_and_scheme].Argument[0,url:]',
          'true',
          'url-redirection'
        ]
```

Note: The `acceptingValue` `"true"` means the barrier applies when the function returns true. `Argument[0,url:]` matches either the first positional argument or the keyword argument `url`.

### Additional References

- **[Python Reference](./python_query_development.prompt.md)** - Python query development
