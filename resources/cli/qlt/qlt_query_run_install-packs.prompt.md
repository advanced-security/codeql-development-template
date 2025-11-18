---
mode: 'agent'
---

# QLT Query Run Install-Packs Command

## Purpose

Use this prompt to guide the execution of `qlt query run install-packs` to install all CodeQL packs within a repository structure.

## Command Synopsis

```bash
qlt query run install-packs [options]
```

## Description

Installs CodeQL packs within the repository structure. This command automates the installation of dependencies across multiple language directories and pack structures, making it easier to set up complete development environments.

## Key Options

### Repository Configuration

- `--base <base>` - Base path to find the query repository (default: current directory)
- `--automation-type <actions>` - Automation type configuration (required, default: actions)

### Development Options

- `--development` - Enable development mode with special QLT features (required, default: False)
- `--use-bundle` - Use custom CodeQL bundle instead of distribution versions (required, default: False)

### Help

- `-?, -h, --help` - Show help and usage information

## How It Works

### Repository Structure Discovery

1. Scans the base directory for CodeQL pack structures
2. Identifies all qlpack.yml files across language directories
3. Resolves dependencies for each discovered pack
4. Installs dependencies in appropriate locations

### Language Support

Works with standard CodeQL language directories:

- `languages/actions/`
- `languages/cpp/`
- `languages/csharp/`
- `languages/go/`
- `languages/java/`
- `languages/javascript/`
- `languages/python/`
- `languages/ruby/`
- `languages/swift/`

## Common Usage Patterns

### Install all packs in current repository

```bash
qlt query run install-packs --automation-type=actions --development=false --use-bundle=false
```

### Install packs with custom base directory

```bash
qlt query run install-packs --base=/path/to/repo --automation-type=actions --development=false --use-bundle=false
```

### Development mode installation

```bash
qlt query run install-packs --automation-type=actions --development=true --use-bundle=false
```

### Using custom CodeQL bundle

```bash
qlt query run install-packs --automation-type=actions --development=false --use-bundle=true
```

## When to Use

- Setting up new development environments with multiple language packs
- Installing dependencies after cloning a multi-language CodeQL repository
- Bulk dependency management across multiple query packs
- CI/CD pipeline setup for comprehensive testing environments
- Preparing repositories for bulk query compilation and testing

## Expected Outputs

- Installation progress for each discovered pack
- Dependency resolution logs
- Created or updated lock files across language directories
- Error messages for failed installations or missing dependencies

## Repository Impact

### Before Installation

```
languages/
├── java/
│   ├── custom/
│   │   └── my-pack/
│   │       └── qlpack.yml
│   └── example/
│       └── another-pack/
│           └── qlpack.yml
└── python/
    └── custom/
        └── my-pack/
            └── qlpack.yml
```

### After Installation

```
languages/
├── java/
│   ├── custom/
│   │   └── my-pack/
│   │       ├── qlpack.yml
│   │       └── codeql-pack.lock.yml
│   └── example/
│       └── another-pack/
│           ├── qlpack.yml
│           └── codeql-pack.lock.yml
└── python/
    └── custom/
        └── my-pack/
            ├── qlpack.yml
            └── codeql-pack.lock.yml
```

## Related Commands

- [`qlt query generate new-query`](./qlt_query_generate_new-query.prompt.md) - Generate new queries after installing dependencies
- [`qlt test run execute-unit-tests`](./qlt_test_run_execute-unit-tests.prompt.md) - Run tests after pack installation
- [`codeql pack install`](../codeql/codeql_pack_install.prompt.md) - Install individual pack dependencies
