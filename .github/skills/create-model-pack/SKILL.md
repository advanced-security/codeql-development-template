---
name: create-model-pack
description: Create or update a CodeQL model pack of `.model.yml` data extension files for an unmodeled (or under-modeled) library or framework, including local repo-scoped extensions under `.github/codeql/extensions/` and reusable model packs under `languages/<language>/custom/src/`. Use when a user asks to "model a library", "add a data extension", "add sources/sinks/summaries/barriers/barrier-guards for <library>", "create a model pack", or wants CodeQL to recognize calls in a third-party package that currently produce no findings.
---

# Create a CodeQL Model Pack

This skill describes the end-to-end procedure for authoring a CodeQL data extension (a `.model.yml` file) and packaging it either as a repo-local extension or as a reusable model pack. It complements the reference documentation in [`.github/prompts/data_extensions_development.prompt.md`](../../prompts/data_extensions_development.prompt.md) and the language-specific data extension prompts (e.g. [`python_data_extension_development.prompt.md`](../../prompts/python_data_extension_development.prompt.md), [`java_data_extension_development.prompt.md`](../../prompts/java_data_extension_development.prompt.md)).

Once the model pack is ready to ship to other repositories or to org-wide Default Setup, follow up with the [`publish-model-pack`](../publish-model-pack/SKILL.md) skill.

## When to use this skill

Trigger this skill when the user wants to:

- Add CodeQL coverage for a library/framework that produces no findings today.
- Add or correct sources, sinks, summaries, barriers (sanitizers), or barrier guards (validators) for a specific package.
- Bootstrap a new `.model.yml` file under `.github/codeql/extensions/` (single-repo) or under `languages/<language>/custom/src/` (reusable pack).

If the user instead wants to write a custom CodeQL `.ql` query, use the query development prompts rather than this skill.

## Prerequisites

- The `codeql` CLI is available (preinstalled in this template's environment via [`.github/workflows/copilot-setup-steps.yml`](../../workflows/copilot-setup-steps.yml)).
- A CodeQL database for the target language is available, or sample code from which one can be built with `codeql database create`.
- Familiarity with the two tuple formats:
  - **API Graph format** — Python, Ruby, JavaScript/TypeScript (3–5 columns).
  - **MaD format** — Java/Kotlin, C#, Go, C/C++ (9–10 columns; includes `subtypes` and `provenance`).

See the "Two Model Formats" and "Quick reference" tables in [`data_extensions_development.prompt.md`](../../prompts/data_extensions_development.prompt.md) for the canonical column layouts and examples.

## Procedure

### 1. Identify the target library and language

- Confirm the library name, version, and the CodeQL language it targets (`python`, `ruby`, `javascript`, `java`, `csharp`, `go`, `cpp`, `actions`).
- Confirm whether the language uses **API Graph** or **MaD** tuples — pick the wrong format and the extension will silently fail to load.
- Skim the library's public API surface (docs, type stubs, or source) so you can classify methods in the next step.

### 2. Classify the API surface

For each public method, function, or class on the library, ask:

1. Does it return data from outside the program (network, file, env, stdin)? → **sourceModel** (pick a `kind` in the appropriate threat model — usually `remote`).
2. Does it consume data in a security-sensitive operation (SQL, exec, path, redirect, eval, deserialize)? → **sinkModel** (pick a `kind` matching the vulnerability class, e.g. `sql-injection`, `command-injection`, `path-injection`).
3. Does it pass data through opaque library code (encode, decode, wrap, copy, iterate)? → **summaryModel** with `kind: taint` (derived) or `kind: value` (identity).
4. Does it sanitize data so its output is safe for a specific sink kind? → **barrierModel** (`kind` must match the sink kind it neutralizes).
5. Does it return a boolean indicating whether data is safe? → **barrierGuardModel** with the appropriate `acceptingValue` (`"true"` or `"false"`) and matching `kind`.
6. Is the type a subclass of something already modeled? → **typeModel** (API Graph languages only) or set `subtypes: True` in the MaD tuple.
7. Did the auto-generated model assign a wrong summary? → **neutralModel** to suppress it.

A complete chain of source → (summary\*) → sink is required for end-to-end findings; missing a single hop will cause false negatives.

### 3. Choose the deployment scope

Decide between two paths and the directory layout follows:

- **Single-repo shortcut** — drop `.model.yml` files directly under `.github/codeql/extensions/<pack-name>/` in the consuming repo. **No `qlpack.yml` is required**; Code Scanning auto-loads extensions from this directory. Use this when the models only need to apply to one repo and you do not want to version-publish them.
- **Reusable model pack** — create the files under a pack directory in this template (e.g. `languages/<language>/custom/src/models/`) with a `qlpack.yml` declaring `extensionTargets` and `dataExtensions`. Use this when the models will be consumed by multiple repos or by org-wide Default Setup. Publishing is handled by the [`publish-model-pack`](../publish-model-pack/SKILL.md) skill.

### 4. Author the `.model.yml` file(s)

- Use the naming convention `<library>-<module>.model.yml` (lowercase, hyphen-separated). Split per logical module rather than putting an entire ecosystem in one file — e.g. `databricks-sql.model.yml`, `databricks-sdk.model.yml`.
- Begin each file with the standard header and the extensible predicates that apply, for example:

```yaml
extensions:
  - addsTo:
      pack: codeql/<language>-all
      extensible: sinkModel
    data:
      # API Graph (Python/Ruby/JS): [type, path, kind]
      - ['mylib', 'Member[connect].ReturnValue.Member[execute].Argument[0]', 'sql-injection']
      # MaD (Java/C#/Go/C++): [package, type, subtypes, name, signature, ext, input, kind, provenance]
      # - ['java.sql', 'Statement', true, 'execute', '(String)', '', 'Argument[0]', 'sql-injection', 'manual']
  - addsTo:
      pack: codeql/<language>-all
      extensible: summaryModel
    data: []
```

- Every row must have the exact column count for that extensible predicate — see the "Two Model Formats" tables in [`data_extensions_development.prompt.md`](../../prompts/data_extensions_development.prompt.md). An invalid row will fail the engine.
- Use `provenance: 'manual'` (MaD) for hand-written rows; reserve `'df-generated'` for output of the model generator.

### 5. Configure `qlpack.yml` (model-pack path only)

Skip this step if you chose the `.github/codeql/extensions/` shortcut in step 3.

For a reusable pack (e.g. `languages/<language>/custom/src/qlpack.yml`), add or confirm:

```yaml
name: <org>/<language>-<pack-name>
version: 0.0.1
library: true
extensionTargets:
  codeql/<language>-all: '*'
dataExtensions:
  - models/**/*.yml
```

- `library: true` — model packs are always libraries, never queries.
- `extensionTargets` — names the upstream pack (and version range) the extensions extend.
- `dataExtensions` — a glob that picks up every `.model.yml` you author in step 4.

### 6. Test locally with `codeql query run`

Validate the model pack against a real database before relying on it:

```bash
codeql query run \
    --database=/path/to/db \
    --additional-packs=<path-to-pack-dir> \
    --output=/tmp/results.bqrs \
    -- <path-to-relevant-query>.ql

codeql bqrs decode --format=text /tmp/results.bqrs
```

- For published packs, swap `--additional-packs=<dir>` for `--model-packs=<org>/<pack>@<range>`.
- Pick a query whose sink kind matches what you modeled (e.g. a `sql-injection` query when adding SQL sinks). See [`codeql query run`](../../../resources/cli/codeql/codeql_query_run.prompt.md).

### 7. Run unit tests with `codeql test run`

`codeql test run` does **not** accept `--model-packs`; data extensions are wired in via `qlpack.yml`. The test pack must depend on the model pack, then:

```bash
codeql test run \
    --additional-packs=<path-to-model-pack-dir> \
    --keep-databases \
    --show-extractor-output \
    -- languages/<language>/<pack-basename>/test/<QueryBasename>/
```

Add a small test case under `languages/<language>/custom/test/` (or your project's equivalent) that exercises the new source/sink/summary chain end-to-end and accept its `.expected` output once you have confirmed it is correct. See [`codeql test run`](../../../resources/cli/codeql/codeql_test_run.prompt.md).

### 8. Decide on next steps

- If the `.model.yml` lives under `.github/codeql/extensions/` of the consuming repo, you are done — Code Scanning will load it on the next analysis.
- If you authored a reusable model pack and want it to apply across an organization, continue with the [`publish-model-pack`](../publish-model-pack/SKILL.md) skill.

## Validation checklist

- [ ] Correct tuple format for the language (API Graph vs MaD).
- [ ] Every row has the exact column count for its extensible predicate.
- [ ] Sink/barrier `kind` values match across the chain (e.g. a `sql-injection` barrier must guard a `sql-injection` sink).
- [ ] At least one end-to-end test exercises the new model and produces the expected finding.
- [ ] `qlpack.yml` `dataExtensions` glob actually matches the new files (verify by running `codeql resolve library-path`).
- [ ] No regressions in pre-existing tests under the same pack.

## Related resources

- [`data_extensions_development.prompt.md`](../../prompts/data_extensions_development.prompt.md) — reference for tuple formats, threat models, and access path syntax.
- Language-specific data extension prompts in [`.github/prompts/`](../../prompts/) (one per supported language).
- [`publish-model-pack`](../publish-model-pack/SKILL.md) — follow-up skill for shipping the pack to GHCR and Default Setup.
- [`codeql query run`](../../../resources/cli/codeql/codeql_query_run.prompt.md) and [`codeql test run`](../../../resources/cli/codeql/codeql_test_run.prompt.md) — CLI references used in steps 6 and 7.
