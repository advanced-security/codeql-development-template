---
mode: 'agent'
---

# Command Resource for `codeql database create`

The `codeql database create` command is used to create CodeQL databases from source code repositories. This can take a long time, depending upon the size of the codebase from which the data(base) is to be extracted.

## Primary use of `codeql database create`

The following is an example use of the command for creating a database from a Java project:

```bash
$ codeql database create --language=java --source-root=/path/to/project mydb
```

## Alternative uses of `codeql database create`

The `codeql database create` command can also be used with different language and build configurations:

```bash
# Multiple languages
$ codeql database create --language=java,javascript --source-root=. mydb

# With custom build command for compiled languages
$ codeql database create --language=cpp --command="make all" mydb

# Auto-build mode
$ codeql database create --language=java --build-mode=autobuild mydb
```

## Help for `codeql database create`

Run `codeql database create --help` for more information.
Run `codeql database create --help --verbose` for much more information.

## Commands commonly run **BEFORE** `codeql database create`

- [`codeql resolve extractor`](./codeql_resolve_extractor.prompt.md) - Resolve which extractor to use for a language

## Commands commonly run **AFTER** `codeql database create`

- [`codeql database analyze`](./codeql_database_analyze.prompt.md) - Analyze the created database with queries
- [`codeql query run`](./codeql_query_run.prompt.md) - Run individual queries against the database
- [`codeql resolve database`](./codeql_resolve_database.prompt.md) - Resolve the paths of created databases

## Command Synopsis

```bash
codeql database create [OPTIONS] -- <database>
```

## Description

Create a CodeQL database by analyzing source code. The database creation process extracts semantic information from source code, enabling subsequent query analysis. Supports multiple programming languages and build modes.

## Key Options

### Required Arguments

- `<database>` - **Mandatory** Path where the new database will be created

### Language and Build Configuration

- `--language=<lang>[,<lang>...]` - Programming languages to analyze (auto-detected from GitHub repos if omitted with GITHUB_TOKEN)
- `--build-mode=<mode>` - Build mode for database creation:
  - `none`: No building required (C#, Java, JavaScript/TypeScript, Python, Ruby)
  - `autobuild`: Automatic build detection (C/C++, C#, Go, Java/Kotlin, Swift)
  - `manual`: Manual build command (C/C++, C#, Go, Java/Kotlin, Swift)

### Source Code Configuration

- `-s, --source-root=<dir>` - Root source code directory (default: current directory)
- `-c, --command=<command>` - Build command for compiled languages

### Performance Options

- `-j, --threads=<num>` - Threads for import operation (default: 1, 0 = cores, -N = leave N cores)
- `-M, --ram=<MB>` - Memory for import operation

### Advanced Database Options

- `--no-cleanup` - **Advanced** Suppress database cleanup after finalization (debugging)
- `--no-pre-finalize` - **Advanced** Skip pre-finalize script from extractor
- `--[no-]skip-empty` - **Advanced** Warn instead of failing for empty databases
- `--[no-]linkage-aware-import` - **Advanced** Control linkage-aware import (default: enabled)

### Baseline and Coverage

- `--[no-]calculate-baseline` - Calculate baseline information about analyzed code
- `--[no-]sublanguage-file-coverage` - **GitHub.com/GHES 3.12+** Use sub-language file coverage

### Extractor Configuration

- `--search-path=<dir>[:<dir>...]` - Directories containing extractor packs
- `-O, --extractor-option=<name=value>` - Set extractor options
- `--extractor-options-file=<file>` - JSON/YAML file with extractor options

### GitHub Integration

- `-a, --github-auth-stdin` - Accept GitHub Apps token for language auto-detection
- `-g, --github-url=<url>` - GitHub instance URL (auto-detected from checkout)

### Build Customization

- `--working-dir=<dir>` - **Advanced** Directory for build command execution
- `--no-run-unnecessary-builds` - **Advanced** Only run builds when extractors need them
- `--no-tracing` - **Advanced** Don't trace build command
- `--extra-tracing-config=<file>` - **Advanced** Custom tracer configuration

## Language-Specific Build Modes

### No Build Required

```bash
# Python, JavaScript, Ruby
codeql database create --language=python mydb
```

### Auto-build

```bash
# Java, C#, Go with automatic build detection
codeql database create --language=java --build-mode=autobuild mydb
```

### Manual Build

```bash
# C/C++ with custom build command
codeql database create --language=cpp --command="make all" mydb
```

## Common Usage Patterns

### Single language with auto-detection

```bash
codeql database create --language=java --source-root=/path/to/project mydb
```

### Multiple languages

```bash
codeql database create --language=java,javascript --source-root=. mydb
```

### With custom build command

```bash
codeql database create --language=cpp --command="cmake --build build/" mydb
```

### GitHub repository with auto-detection

```bash
# Requires GITHUB_TOKEN environment variable
codeql database create --source-root=/path/to/repo mydb
```

### High-performance configuration

```bash
codeql database create --language=java --threads=8 --ram=16384 mydb
```

### With extractor options

```bash
codeql database create --language=java --extractor-option=java.buildtools.maven.M2_HOME=/usr/local/maven mydb
```

## When to Use

- Analyzing source code repositories for security vulnerabilities
- Setting up databases for custom query development
- CI/CD integration for continuous security analysis
- Research and investigation of codebases
- Preparing data for bulk query analysis

## Expected Outputs

- Complete CodeQL database in specified directory
- Extraction logs and progress information
- Database finalization and cleanup
- Error messages for build or extraction failures

## Database Structure

```
mydb/
├── codeql-database.yml    # Database metadata
├── db-<language>/         # Language-specific data
├── log/                   # Extraction logs
├── working/               # Temporary working files (cleaned up)
└── src.zip               # Source code archive
```

## Related Commands

- [`codeql database analyze`](./codeql_database_analyze.prompt.md) - Analyze created databases
- [`codeql query run`](./codeql_query_run.prompt.md) - Run individual queries against databases
- [`codeql pack install`](./codeql_pack_install.prompt.md) - Install query dependencies before analysis
