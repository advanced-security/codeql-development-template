---
name: 🔍 New CodeQL Query
about: Pull request for creating a new CodeQL query
title: '[NEW QUERY] '
labels:
  - query-create
  - enhancement
---

## 📝 Query Information

- **Language**: <!-- e.g., java, python, javascript -->
- **Query ID**: <!-- Unique identifier -->
- **Category**: <!-- security, performance, maintainability -->
- **Severity**: <!-- error, warning, info -->
- **CWE/CVE** (if applicable): <!-- e.g., CWE-89 -->

## 🎯 Description

### What This Query Detects

<!-- Clear description of the vulnerability or pattern -->

### Example Vulnerable Code

```[language]
// Code that should be flagged
```

### Example Safe Code

```[language]
// Code that should NOT be flagged
```

## 🧪 Testing

- [ ] Positive test cases included
- [ ] Negative test cases included
- [ ] Edge cases covered
- [ ] All tests pass

## 📋 Checklist

- [ ] Query compiles without errors
- [ ] Documentation complete (`.md` and `.qhelp`)
- [ ] Metadata properly set (@name, @id, @kind, etc.)
- [ ] Tests validate query behavior
- [ ] No false positives in test cases

## 🔗 References

<!-- Links to CWE, OWASP, research, or related queries -->

---

**Note**: This query was developed using Test-Driven Development methodology.
