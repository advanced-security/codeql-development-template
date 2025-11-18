---
mode: agent
---

# Suggested git hooks for this repository

## Suggested `pre-commit` hook

Before committing or pushing changes to this repository, it is recommended to use the equivalent of the following / example `.git/hooks/pre-commit` script to ensure that linting and formatting checks are performed prior to committing changes:

```sh
# Enforce linting and formatting checks before committing changes
if ! npm run tidy:check
then
    echo "'npm run tidy:check' failed. Please fix the problem(s) and try again."
    exit 1
fi

exit 0
```

## Fixing linting and formatting issues with `npm run tidy`

To avoid the hook failing, or to prevent the need for such a hook, the preferred approach is to run the following in order to actually fix linting and formatting issues before attempting to perform a `git commit` for this repository:

```sh
npm run tidy
```
