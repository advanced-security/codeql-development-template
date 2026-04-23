# codeql-development-template

> **Lowering the barrier to entry for CodeQL development through natural language and GitHub Copilot**

A GitHub repository template for building custom CodeQL queries with AI assistance. This template provides a structured environment with prompts, instructions, and workflows designed to guide GitHub Copilot Coding Agent through the complete CodeQL development lifecycle.

## Background

This repository template enables developers to create custom CodeQL security queries with minimal CodeQL expertise by leveraging:

- **GitHub Copilot Coding Agent** for automated query development
- **Hierarchical prompt system** that guides AI through CodeQL tasks
- **Test-driven development methodology** for reliable query creation
- **Pre-configured workflows** for setup, testing, and validation

## Requirements

Before using this repository template, ensure your GitHub organization/account has:

- **GitHub Actions** enabled for running CI/CD workflows
- **GitHub Copilot Coding Agent** access for AI-assisted development
- **GitHub Advanced Security** (optional, but recommended)

## Getting Started

### Step 1: Create a New Repository from Template

1. Click the **"Use this template"** button at the top of this repository
2. Choose **"Create a new repository"**
3. Select your GitHub organization or personal account
4. Enter a repository name (e.g., `my-codeql-queries`)
5. Set the repository visibility (internal, private, or public)
6. Click **"Create repository"**

**Note:** The ['copilot-setup-steps' actions workflow](./.github/workflows/copilot-setup-steps.yml) will automatically set up the environment for Copilot Coding Agent (CCA), so local installation is optional and primarily useful for manual development.

### Step 2: Install CodeQL Pack Dependencies

After cloning your new repository, install the CodeQL pack dependencies:

```bash
./scripts/install-codeql-packs.sh
```

This uses `codeql pack ls` to discover all packs in the workspace and runs `codeql pack install` for each one, generating `codeql-pack.lock.yml` files and downloading required dependencies locally. You can target a single language with `--language <lang>` (e.g., `--language java`).

> **Note:** The generated `codeql-pack.lock.yml` files should be committed to your repository to ensure reproducible dependency resolution across your team.

### Step 3: Create an Issue for the CodeQL query or data extension you want to develop

1. **Navigate to Issues** in your new repository
2. **Click "New Issue"**
3. **Select a template:**
   - **"Request new CodeQL Query"** for custom query development
   - **"Request new CodeQL Data Extension"** for modeling an unmodeled library via YAML (models-as-data)
4. **Fill in the template fields** — each template will guide you, but at minimum:
   - **Target language**
   - **Description** of what to detect or which library to model
   - **Library URL** (data extensions) or **Severity level** (queries)
   - **Code Examples** (recommended — helps Copilot generate better results)
5. **Submit the issue**

### Step 4: Assign Issue to `@copilot`

1. **Assign the issue** to `@copilot` (GitHub's Copilot Coding Agent user)
2. **Wait for Copilot** to process the issue and create a Pull Request
3. **Monitor progress** via the `Sessions` and/or comments for the new Pull Request

### Step 5: Review Pull Request created by Copilot Coding Agent

1. **Navigate to the generated Pull Request**
2. **Review the changes:**
   - Query implementation (`.ql` files) or data extensions (`.model.yml` files)
   - Test cases (in `test/` directories)
   - Query documentation (`.md` and `.qhelp` files)
3. **Check CI/CD results:**
   - All tests pass
   - Query compiles successfully
   - Linting and formatting checks pass
4. **Review and approve** the PR
5. **Merge** to incorporate the query into your repository

## 📋 Available Issue Templates

| Template                                                                              | Purpose                                                                                  |
| ------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| [Request new CodeQL Query](.github/ISSUE_TEMPLATE/query-create.yml)                   | Create a new CodeQL query to detect specific code patterns or vulnerabilities            |
| [Update existing CodeQL Query](.github/ISSUE_TEMPLATE/query-update.yml)               | Modify an existing query to improve accuracy or add new detection capabilities           |
| [Request new CodeQL Data Extension](.github/ISSUE_TEMPLATE/data-extension-create.yml) | Create a data extension (models-as-data YAML) to model an unmodeled library or framework |
| [Improve Prompts/Instructions](.github/ISSUE_TEMPLATE/prompt-update.yml)              | Contribute improvements to the AI guidance system                                        |

## Repository Structure

After creating your first query, your repository will contain:

```text
codeql-development-template/
├── .github/
│   ├── instructions/           # Level 2: Language-specific Copilot instructions
│   ├── prompts/               # Level 3: High-level prompt templates
│   ├── ISSUE_TEMPLATE/        # Level 1: Entry points for Copilot workflows
│   └── workflows/             # CI/CD automation for testing and setup
├── languages/
│   └── {language}/            # Per-language development environments
│       ├── custom/            # Your custom queries (generated by Copilot)
│       │   ├── src/          # Query source files (.ql)
│       │   └── test/         # Query test cases
│       ├── example/           # Example queries for reference
│       └── tools/             # Development resources and AST exploration
│           ├── dev/          # Language-specific development guides
│           ├── src/          # PrintAST queries for exploring code structure
│           └── test/         # PrintAST test suites
├── resources/cli/             # CLI command reference documentation
│   ├── codeql/               # CodeQL CLI subcommand guides
│   └── qlt/                  # QLT CLI subcommand guides
└── scripts/                   # Setup and automation scripts
```

## How It Works

This template implements a **hierarchical prompt system** that maximizes GitHub Copilot's effectiveness:

1. **Issue Templates** provide structured input for query and model requirements
2. **Language-Specific Instructions** guide Copilot with relevant context
3. **High-Level Prompts** break down complex CodeQL workflows
4. **Tool-Specific Resources** provide CLI usage examples and patterns
5. **Test-Driven Development** ensures query accuracy through automated testing

The Copilot Coding Agent uses this hierarchy to:

- Understand your query requirements
- Generate appropriate CodeQL logic
- Create comprehensive test cases
- Validate query correctness
- Document the query properly

See [PROMPTS.md](PROMPTS.md) for details on the prompt hierarchy system.

## Supported Languages

CodeQL supports the following languages. This template provides query development and/or data extension (models-as-data) guidance for each:

| Language              | CodeQL Library | Query Development | Model Development |
| --------------------- | -------------- | :---------------: | :---------------: |
| C/C++                 | `cpp`          |        ✅         |        ✅         |
| C#                    | `csharp`       |        ✅         |        ✅         |
| GitHub Actions        | `actions`      |        ✅         |                   |
| Go                    | `go`           |        ✅         |        ✅         |
| Java/Kotlin           | `java`         |        ✅         |        ✅         |
| JavaScript/TypeScript | `javascript`   |        ✅         |        ✅         |
| Python                | `python`       |        ✅         |        ✅         |
| Ruby                  | `ruby`         |        ✅         |        ✅         |
| Rust                  | `rust`         |                   |                   |
| Swift                 | `swift`        |                   |                   |

## License

This repository template is available under the [MIT License](LICENSE).

## Maintainers

This repository template is maintained by the [CODEOWNERS](CODEOWNERS).

## Support

This repository template comes with no expectation or guarantee of support, with more details in the [SUPPORT.md](SUPPORT.md) document.
