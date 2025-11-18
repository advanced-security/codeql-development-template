---
mode: 'agent'
---

# Command Resource for `codeql resolve languages`

The `codeql resolve languages` lists installed CodeQL extractor packs. This is an internal/plumbing command of the `codeql` CLI and, therefore, it is uncommon to directly use the `codeql resolve languages` subcommand.

When run with JSON output selected, the `codeql resolve languages` command can report multiple locations for each extractor pack name. When that happens, it means that the pack has conflicting locations within a single search element, so it cannot actually be resolved. The caller may use the actual locations to format an appropriate error message.

## Primary use of `codeql resolve languages`

The following is an example use of the command for listing available languages:

```bash
codeql resolve languages --format=text
```

## Alternative uses of `codeql resolve languages`

The `codeql resolve languages` command can also provide output in different formats:

```bash
# Output in `json` format
codeql resolve languages --format=json
```

```bash
# Output in `betterjson` format
codeql resolve languages --format=betterjson
```

## Help for `codeql resolve languages`

Run `codeql resolve languages -h` for more information.
Run `codeql resolve languages -h -vv` for much more information.

## Commands commonly run **BEFORE** `codeql resolve languages`

- Check system requirements and CodeQL installation

## Commands commonly run **AFTER** `codeql resolve languages`

- [`codeql resolve queries`](./codeql_resolve_queries.prompt.md) - List available CodeQL queries found on the local filesystem, including queries installed via query pack(s).
