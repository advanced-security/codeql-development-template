---
applyTo: 'languages/*/tools/dev/*.prompt.md'
description: 'Instructions for editing low-level implementation prompts for a given language and use-case.'
---

# `ql_dev_prompts` Instructions

## Purpose of each `languages/<language>/tools/dev/*.prompt.md` file

Each `languages/<language>/tools/dev/<specific_topic>.prompt.md` file provides specialized, technical guidance for CodeQL development targeting a specific programming language and development use-case, including:

- Language-specific AST node classes and their hierarchies for CodeQL query development
- Framework-specific modeling patterns for security analysis and data flow tracking
- Security query implementation guides with concrete examples and code templates
- Data flow and taint tracking patterns tailored to the target language's semantics
- Best practices for modeling libraries, frameworks, and security concepts in the target language

For additional guidance on repository development workflows, refer to the language-specific instruction files in `.github/instructions/` and CLI resource documentation in `resources/cli/`.

## Requirements

ALWAYS do the following when creating or editing any `languages/<language>/tools/dev/*.prompt.md` file:

- ALWAYS add YAML frontmatter with `mode: agent` at the top of the file, with `---` lines before and after the frontmatter
- ALWAYS use valid markdown syntax, with the exception of the YAML frontmatter at the top of the `.prompt.md` file
- ALWAYS demonstrate CodeQL syntax usage with code blocks that start with three backticks followed by `ql` (i.e. "```ql")
- ALWAYS leave an empty line before and after each code block, as well as at the end of the file
- ALWAYS provide relative, markdown-style links to related `languages/<language>/tools/dev/*.prompt.md` files when referencing complementary development topics
- ALWAYS include practical, runnable CodeQL examples that target the specific language being documented
- ALWAYS use relative, markdown-style links to other `*.prompt.md` files in this file rather than duplicating such content, wherever possible

## Constraints

NEVER do the following when creating or editing any `languages/<language>/tools/dev/*.prompt.md` file:

- NEVER nest one code block within another code block
- NEVER use four backticks (````) to denote code blocks
- NEVER add or leave any trailing whitespace on any line
- NEVER assume that what works in CodeQL for one language (e.g. java) will work in CodeQL for another language (e.g. javascript)
- NEVER reference fictional or non-existent CodeQL classes, predicates, or library modules
- NEVER provide examples that would not compile or execute correctly with the CodeQL CLI
- NEVER duplicate content that should be shared across languages (use cross-references instead)
- NEVER include implementation details that are specific to the CodeQL CLI tooling rather than query development
- NEVER make assumptions about CodeQL library versions or capabilities without verifying against the current CodeQL standard library for the target language
