---
applyTo: 'resources/cli/**/*.prompt.md'
description: 'High-level instructions for managing tool-level resources (aka prompts) for important CLI commands.'
---

# `resources_cli_prompts` Instructions

## Purpose of each `resources/cli/**/*.prompt.md` file

Each `resources/cli/{codeql,qlt}/<subcommand_with_underscores>.prompt.md` file provides a static description of a specific CLI tool subcommand, including its:

- Generic description and/or purpose of the subcommand
- Primary use of the given subcommand, including example arguments / options
- Alternative and/or advanced uses of the given subcommand, including example arguments / options

For additional guidance on repository development workflows, refer to:

- [CLI Resources](../prompts/cli_resources.prompt.md)
- [Git Hooks](../prompts/git_hooks.prompt.md) - Repository commit and push guidelines

## Requirements

ALWAYS do the following when creating or editing any `resources/cli/**/*.prompt.md` file

- ALWAYS add YAML frontmatter with `mode: agent` at the top of the file, with `---` lines before and after the frontmatter
- ALWAYS use valid markdown syntax, with the exception of the YAML frontmatter at the top of the `.prompt.md` file
- ALWAYS demonstrate the `bash` usage of the 'Primary use of <command>' section with a code block that starts with three backticks followed by `bash` (i.e. "```bash")
- ALWAYS leave an empty line before and after each code block, as well as at the end of the file
- ALWAYS provide relative, markdown-style links to the `resources/cli/**/*.prompt.md` file(s) associated with any CLI tool subcommand(s) mentioned in that `resources/cli/**/*.prompt.md` file
- ALWAYS keep the content concise and to the point, using at most a few command examples / sections
- ALWAYS provide an example of getting more help, and much more help, via the `-h` and `-h -vv` options, respectively
- ALWAYS provide links to commands suggested to run **BEFORE** and **AFTER** running the given command, but only when such commands are relevant and useful

## Constraints

NEVER do the following when creating or editing any `resources/cli/**/*.prompt.md` file:

- NEVER nest one code block within another code block
- NEVER use four backticks (````) to denote code blocks
- NEVER add or leave any trailing whitespace on any line
- NEVER make up or guess any details about the CLI tool subcommand -- use the `-h -vv` options to get verbose help for the subcommand as a means of verifying the resource content is accurate for that subcommand
