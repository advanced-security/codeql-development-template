---
name: 📦 New CodeQL Data Extension
about: Pull request for creating a new CodeQL data extension model
title: '[NEW DATA EXTENSION] '
labels:
  - data-extension-create
  - enhancement
---

## 📝 Data Extension Information

- **Language**: <!-- e.g., java, python, javascript -->
- **Extension Name(s)**: <!-- e.g., databricks-sql.model.yml. Use <library>-<module>.model.yml naming. List all files if multiple modules. -->
- **Extension Types**: <!-- sourceModel, sinkModel, summaryModel, barrierModel, barrierGuardModel, neutralModel, typeModel -->
- **Target Library/Framework**: <!-- e.g., Undertow, Databricks SQL -->
- **Library Modules Covered**: <!-- List the distinct modules/sub-packages modeled, one per model file. e.g., databricks.sql, databricks.sdk -->

## 🎯 Description

### What This Data Extension Models

<!-- Clear description of the library/framework being modeled and what sources, sinks, summaries, barriers (sanitizers), or barrier guards (validators) it adds -->

### Threat Model

<!-- e.g., remote, local (file, commandargs, database, environment, stdin, windows-registry) -->

### Example Vulnerable Code

```[language]
// Code that should be detected with this data extension
```

### Example Safe Code

```[language]
// Code that should NOT be detected
```

## 📦 Extension Details

### Extension YAML

<!-- Provide the data extension YAML content or a summary of the models added -->

```yaml
extensions:
  - addsTo:
      pack: codeql/[language]-all
      extensible: sinkModel
    data:
      # - ["package","Member[...].Argument[0]","sink-kind"]
```

### Access Path Explanation

<!-- Explain the access path(s) used and how they map to the target API -->

## 🧪 Testing

- [ ] Extension YAML resolves without errors
- [ ] Database created with sample code (`codeql database create` or `codeql test extract`)
- [ ] Single query verified with extension applied (`codeql query run --additional-packs=<model-pack-dir>`)
- [ ] Unit tests pass with extension applied (`codeql test run --additional-packs=<model-pack-dir>`)
- [ ] Positive test cases (vulnerable code detected)
- [ ] Negative test cases (safe code not flagged)

## 📋 Checklist

- [ ] Extension YAML is valid and properly formatted
- [ ] Extension placed in correct location (`languages/[language]/custom/src/`)
- [ ] `qlpack.yml` includes `dataExtensions` configuration
- [ ] Access paths verified via API graph queries
- [ ] No false positives in test cases
- [ ] Documentation/comments included in YAML

## 🔗 References

<!-- Links to library/framework docs, CWE, OWASP, or related queries -->

---

**Note**: This data extension was developed following CodeQL Models as Data best practices.
