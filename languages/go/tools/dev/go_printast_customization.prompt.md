---
mode: agent
---

# Go PrintAST Customization

## Issue with Default PrintAST Configuration

The default PrintAST query in `languages/go/tools/src/PrintAST/PrintAST.ql` is hardcoded to only process files named "Example1.go":

```ql
override predicate shouldPrintFile(File file) { file.getBaseName() = "Example1.go" }
```

## Custom PrintAST for TDD Workflow

When developing Go queries with TDD, you'll need to modify the PrintAST configuration to match your test file names. Create a custom PrintAST query or modify the existing one:

```ql
override predicate shouldPrintFile(File file) { 
  file.getBaseName().matches("%.go") // Process all .go files
  // or
  file.getBaseName() = "YourTestFileName.go" // Process specific file
}
```

## Alternative: Simple AST Exploration Query

For TDD development, use a simple query to explore the AST of your test code:

```ql
import go

from AstNode node
where node.getFile().getBaseName().matches("%.go")
select node, node.toString()
```

This allows you to understand the AST structure of your test code for building effective queries.