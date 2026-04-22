---
name: publish-model-pack
description: Publish an existing CodeQL model pack to GitHub Container Registry (GHCR) with `codeql pack create` / `codeql pack publish`, and configure it for org-wide use under Code Scanning Default Setup. Use when a user asks to "publish a model pack", "push a model pack to GHCR", "release a new version of <pack>", "add a model pack to Default Setup", or "make my custom data extensions apply across the organization".
---

# Publish a CodeQL Model Pack

This skill describes the procedure for shipping an existing CodeQL model pack — built with the [`create-model-pack`](../create-model-pack/SKILL.md) skill or already present under `languages/<language>/custom/src/` — to GHCR and wiring it into org-wide Code Scanning Default Setup.

This is the right skill **only when the consumers must include other repositories** in your organization. If the data extensions are needed only by one repository, prefer the `.github/codeql/extensions/` shortcut described in the [`create-model-pack`](../create-model-pack/SKILL.md) skill — no publish step is required.

## When to use this skill

Trigger this skill when the user wants to:

- Push a new or updated model pack to GHCR.
- Release a new semver version of an existing model pack.
- Configure an org so Default Setup automatically picks up a custom model pack.
- Diagnose why a published model pack is not being applied during Code Scanning analyses.

## Prerequisites

- The model pack already exists locally and has at least one valid `.model.yml`. If not, run the [`create-model-pack`](../create-model-pack/SKILL.md) skill first.
- The `codeql` CLI is available and authenticated to GHCR. On agent runners, the standard `GITHUB_TOKEN` (with `packages: write`) is sufficient; locally you may need `gh auth login` or a PAT exported as `CODEQL_REGISTRIES_AUTH` / `GITHUB_TOKEN`.
- You have write access (`packages: write`) to the GHCR namespace named in the pack's `name` field (e.g. `<org>/<language>-<pack-name>`).
- For the org-wide configuration step, you must have organization-owner or "Manage Code Security settings" permission for the target org.

## Procedure

### 1. Verify `qlpack.yml` is publish-ready

Open the pack's `qlpack.yml` (typically `languages/<language>/custom/src/qlpack.yml`) and confirm:

```yaml
name: <org>/<language>-<pack-name> # must match the GHCR org/repo namespace you can publish to
version: 1.0.0 # semver — see step 5 for version bumps
library: true # model packs are always libraries
extensionTargets:
  codeql/<language>-all: '*' # or a tighter range like ^1.0.0
dataExtensions:
  - models/**/*.yml # glob must actually match your .model.yml files
```

Sanity checks:

- `name` is fully qualified (`<scope>/<pack>`); the scope must be a GHCR namespace you can push to.
- `version` is a valid semver string and is **strictly greater** than the latest version already on GHCR (publishing the same version will fail).
- `extensionTargets` references the upstream pack the extensions extend (`codeql/<language>-all`). The version range determines which CodeQL releases the pack is compatible with.
- `dataExtensions` glob resolves to the expected file list — confirm with:

```bash
ls -1 $(dirname <path-to-qlpack.yml>)/models/**/*.yml
```

### 2. Build the pack with `codeql pack create`

From the directory containing `qlpack.yml`:

```bash
codeql pack create \
    --output=/tmp/codeql-pack-out \
    .
```

- The output directory will contain a versioned subtree (`<scope>/<pack>/<version>/`) ready for upload.
- `codeql pack create` will fail fast on malformed `.model.yml` rows or unresolved `extensionTargets`. Fix any reported errors before proceeding. Run `codeql pack create -h -vv` for full help.

### 3. Publish to GHCR with `codeql pack publish`

```bash
codeql pack publish .
```

- `codeql pack publish` re-runs the build then pushes the resulting OCI artifact to `ghcr.io/<scope>/<pack>:<version>` (and updates the `latest` tag).
- Authentication: ensure `GITHUB_TOKEN` (or a PAT with `write:packages`) is exported. On a workflow runner, set `permissions: { packages: write }` on the job. Run `codeql pack publish -h -vv` for full help.
- Confirm the push by either checking the package under `https://github.com/orgs/<scope>/packages` or running:

```bash
codeql pack download <scope>/<pack>@<version>
```

### 4. Configure org-wide Default Setup

To apply the published model pack to every Default Setup analysis in the org:

1. Navigate to the org settings: **Code security → Global settings → CodeQL analysis** (also accessible via **Security → Advanced Security → Global settings → Expand CodeQL analysis** depending on the UI version).
2. Under **Model packs**, click **Add model pack** and enter `<scope>/<pack>` (optionally pinned to a version range, e.g. `<scope>/<pack>@^1.0.0`).
3. Save. Default Setup will pick up the pack on the next scheduled or push-triggered analysis for repos that target the relevant language.

References:

- [Configure organization-level CodeQL model packs](https://github.blog/changelog/2024-04-16-configure-organization-level-codeql-model-packs-for-github-code-scanning/)
- [Extending CodeQL coverage with model packs in Default Setup](https://docs.github.com/en/code-security/how-tos/find-and-fix-code-vulnerabilities/manage-your-configuration/editing-your-configuration-of-default-setup#extending-codeql-coverage-with-codeql-model-packs-in-default-setup)
- [Configuring Default Setup at scale](https://docs.github.com/en/code-security/how-tos/secure-at-scale/configure-organization-security/configure-specific-tools/configuring-default-setup-for-code-scanning-at-scale)

### 5. Version management

- Use **semver** for `version`. Bump `patch` for additive rows that don't change semantics, `minor` for new model categories or substantial new coverage, `major` for breaking changes (renames, removals, format changes).
- For each release, bump `version` in `qlpack.yml` **before** running `codeql pack publish` — re-publishing the same version fails.
- If the org-level configuration uses a range (e.g. `@^1.0.0` or no pin at all), Default Setup automatically resolves the **latest matching** version on every run; consumers do not need to take any action to receive a new minor/patch release.
- If the org-level configuration is pinned to an exact version, you must update it after each release.

### 6. Validate the published pack is being applied

Pick a repository covered by Default Setup that contains code exercising the new models, then:

1. Trigger a Code Scanning run (push to the default branch or click **Re-run all jobs** on the latest CodeQL workflow).
2. Open the workflow logs for the CodeQL Analyze job and look for log lines confirming the pack was downloaded and its data extensions were loaded — typically lines containing `<scope>/<pack>` and the resolved version, alongside extension counts.
3. Confirm that new alerts attributable to the new sources/sinks/summaries appear in the Code Scanning alerts view (or, if you intentionally added barriers/neutrals, that previously-flagged false-positive alerts are now suppressed).

If the pack does not appear in the logs:

- Re-check that `name` in `qlpack.yml` matches exactly what is configured in the org settings.
- Verify the version range in org settings (or `extensionTargets` in the pack) is satisfiable by what's published.
- Confirm the consumer repo's language is included in the pack's `extensionTargets` (e.g. a `codeql/python-all` extension only fires for Python repos).
- Pull the pack manually with `codeql pack download <scope>/<pack>@<version>` to rule out access/visibility problems.

## Validation checklist

- [ ] `qlpack.yml` `version` strictly greater than the previously published version.
- [ ] `codeql pack create` succeeds with no errors or warnings about unknown rows.
- [ ] `codeql pack publish` reports a successful push and the package is visible under the org's GHCR packages.
- [ ] The pack is listed under the org's Default Setup model packs configuration.
- [ ] A subsequent CodeQL workflow run logs the pack as loaded and surfaces the expected new alerts (or suppressions).

## Related resources

- [`create-model-pack`](../create-model-pack/SKILL.md) — upstream skill that produces the model pack consumed here.
- [`data_extensions_development.prompt.md`](../../prompts/data_extensions_development.prompt.md) — reference for `qlpack.yml` shape (`extensionTargets`, `dataExtensions`) and the workflow context.
- [`codeql pack install`](../../../resources/cli/codeql/codeql_pack_install.prompt.md) — companion CLI reference; for `pack create`, `pack publish`, and `pack download` use `codeql <subcommand> -h -vv`.
- [CodeQL now supports sanitizers and validators in models-as-data](https://github.blog/changelog/2026-04-21-codeql-now-supports-sanitizers-and-validators-in-models-as-data/) — recent capability that may motivate a pack version bump.
