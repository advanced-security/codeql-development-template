#!/usr/bin/env bash
set -euo pipefail

## Parse command line arguments
LANGUAGE=""

usage() {
	cat << EOF
Usage: $0 [OPTIONS]

Install CodeQL packs for all packs discovered in the CodeQL workspace.

OPTIONS:
    --language <lang>  Install packs only for the specified language
                       Valid values: actions, cpp, csharp, go, java, javascript,
                       python, ruby
    -h, --help         Show this help message

By default, the script installs packs for all languages in the workspace.
EOF
}

while [[ $# -gt 0 ]]; do
	case $1 in
		--language)
			LANGUAGE="$2"
			shift 2
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "Error: Unknown option $1" >&2
			usage >&2
			exit 1
			;;
	esac
done

## Validate language if provided
VALID_LANGUAGES=("actions" "cpp" "csharp" "go" "java" "javascript" "python" "ruby")
if [[ -n "${LANGUAGE}" ]]; then
	LANGUAGE_VALID=false
	for valid_lang in "${VALID_LANGUAGES[@]}"; do
		if [[ "${LANGUAGE}" = "${valid_lang}" ]]; then
			LANGUAGE_VALID=true
			break
		fi
	done

	if [[ "${LANGUAGE_VALID}" = false ]]; then
		echo "Error: Invalid language '${LANGUAGE}'" >&2
		echo "Valid languages: ${VALID_LANGUAGES[*]}" >&2
		exit 1
	fi
fi

## Get the directory of this script.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
## Get the root directory of the repository.
REPO_ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
## Explicitly set the cwd to the REPO_ROOT_DIR.
cd "${REPO_ROOT_DIR}"

## Verify prerequisites
if ! command -v codeql >/dev/null 2>&1; then
	echo "Error: 'codeql' CLI not found in PATH" >&2
	echo "Install CodeQL CLI: https://github.com/github/codeql-cli-binaries/releases" >&2
	exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
	echo "Error: 'jq' not found in PATH (required for JSON parsing)" >&2
	exit 1
fi

## Define a helper to run a command with exponential-backoff retry.
## Usage: run_with_retry <max_attempts> <initial_delay_seconds> <command> [args...]
run_with_retry() {
	local _max_attempts="$1"
	local _delay="$2"
	shift 2
	local _attempt=1
	while true; do
		if "$@"; then
			return 0
		fi
		if [[ "${_attempt}" -ge "${_max_attempts}" ]]; then
			echo "ERROR: Command failed after ${_max_attempts} attempt(s): $*" >&2
			return 1
		fi
		echo "WARNING: Command failed (attempt ${_attempt}/${_max_attempts}). Retrying in ${_delay}s..." >&2
		sleep "${_delay}"
		_attempt=$((_attempt + 1))
		_delay=$((_delay * 2))
	done
}

## Discover packs using codeql pack ls
echo "INFO: Discovering CodeQL packs in workspace..."
PACK_JSON=$(codeql pack ls --format=json 2>/dev/null)

# codeql pack ls --format=json returns:
# { "packs": { "<path>/qlpack.yml": { "name": "...", "version": "..." }, ... } }
# Extract the directory of each qlpack.yml file.
PACK_DIRS=$(echo "${PACK_JSON}" | jq -r '.packs | keys[] | sub("/qlpack\\.yml$"; "")')

if [[ -z "${PACK_DIRS}" ]]; then
	echo "Error: No CodeQL packs found in workspace" >&2
	echo "Ensure codeql-workspace.yml exists in the repository root." >&2
	exit 1
fi

INSTALL_COUNT=0
SKIP_COUNT=0
FAIL_COUNT=0

while IFS= read -r pack_dir; do
	[[ -z "${pack_dir}" ]] && continue

	# Compute a relative path for display and filtering
	pack_rel="${pack_dir#"${REPO_ROOT_DIR}/"}"

	# Apply language filter if specified
	if [[ -n "${LANGUAGE}" ]]; then
		if [[ "${pack_rel}" != "languages/${LANGUAGE}/"* ]]; then
			SKIP_COUNT=$((SKIP_COUNT + 1))
			continue
		fi
	fi

	echo "INFO: Running 'codeql pack install' for '${pack_rel}'..."
	if run_with_retry 3 10 codeql pack install --no-strict-mode -- "${pack_dir}"; then
		INSTALL_COUNT=$((INSTALL_COUNT + 1))
	else
		FAIL_COUNT=$((FAIL_COUNT + 1))
	fi
done <<< "${PACK_DIRS}"

echo ""
echo "=== Installation Summary ==="
echo "  Installed: ${INSTALL_COUNT}"
echo "  Skipped:   ${SKIP_COUNT}"
echo "  Failed:    ${FAIL_COUNT}"
echo "============================="

if [[ "${FAIL_COUNT}" -gt 0 ]]; then
	exit 1
fi
