---
mode: agent
---

# Command Resource for `codeql pack ls`

The `codeql pack ls` command is used to list CodeQL packs under some local directory path.

## Primary use of `codeql pack ls`

The following is an example use of the command for listing packs in the current directory:

```bash
# List CodeQL packs found under the current working directory,
# using the (default) text output format.
codeql pack ls --format=text -- .
```

## Alternative uses of `codeql pack ls`

The `codeql pack ls` command can also target specific directories and output formats:

```bash
# List packs found under the specified absolute directory path,
# using the json output format.
codeql pack ls --format=json -- /absolute/path-to/pack-dir-or-parent
```

```bash
# List packs found under the specified relative directory path,
# using the json output format.
codeql pack ls --format=json -- relative/path-to/pack-dir-or-parent
```

## Help for `codeql pack ls`

```text
List the CodeQL packages rooted at this directory. This directory must contain a qlpack.yml or .codeqlmanifest.json file.


      [<dir>]                The root directory of the package or workspace, defaults to the current working directory. If this parameter points to a directory containing a qlpack.yml,
                               then this operation will run on only that CodeQL package. If this parameter points to a directory containing a codeql-workspace.yml, then this operation
                               will run on all CodeQL packages in the workspace.
Options for configuring which CodeQL packs to apply this command to.
      --format=<fmt>         Select output format, either text (default) or json.
      --groups[=[-]<group>[,[-]<group>...]...]
                             List of CodeQL pack groups to include or exclude from this operation. A qlpack in the given workspace is included if:

                             * It is in at least one of the groups listed without a minus sign (this condition is automatically satisfied if there are no groups listed without a minus
                               sign), and
                             * It is not in any group listed with a minus sign
Common options:
  -h, --help                 Show this help text.
  -v, --verbose              Incrementally increase the number of progress messages printed.
  -q, --quiet                Incrementally decrease the number of progress messages printed.
Some advanced options have been hidden; try --help -v for a fuller view.
```

## Commands commonly run **BEFORE** `codeql pack ls`

- Navigate to a directory containing CodeQL packs or workspaces

## Commands commonly run **AFTER** `codeql pack ls`

- [`codeql pack install`](./codeql_pack_install.prompt.md) - Install dependencies for discovered packs
- [`codeql resolve queries`](./codeql_resolve_queries.prompt.md) - Resolve queries from listed packs
