---
mode: 'agent'
---

# Command Resource for `codeql pack install`

The `codeql pack install` command is used to install library dependencies declared in a CodeQL pack.

## Primary use of `codeql pack install`

The following is an example use of the command for installing dependencies in the current directory:

```bash
codeql pack install
```

## Alternative uses of `codeql pack install`

The `codeql pack install` command can also target specific directories and control dependency resolution:

```bash
# Install dependencies for a specific pack directory
codeql pack install ./my-pack/

# Update dependencies to latest compatible versions
codeql pack install --update

# Force update to latest versions
codeql pack install --update --force
```

## Help for `codeql pack install`

Run `codeql pack install -h` for more information.
Run `codeql pack install -h -vv` for much more information.

## Commands commonly run **BEFORE** `codeql pack install`

- [`codeql pack ls`](./codeql_pack_ls.prompt.md) - List available CodeQL packs

## Commands commonly run **AFTER** `codeql pack install`

- [`codeql query compile`](./codeql_query_compile.prompt.md) - Compile queries using installed dependencies
- [`codeql query run`](./codeql_query_run.prompt.md) - Run queries with installed library dependencies
- [`codeql database analyze`](./codeql_database_analyze.prompt.md) - Analyze databases with installed query packs
