#!/usr/bin/env bash
set -euo pipefail

# Replace this with a real benchmark in the target repo.
# Print one PRIMARY_METRIC line for the agent and validator to parse.
printf 'PRIMARY_METRIC test_runtime_ms=%s\n' "${TEST_RUNTIME_MS:-1000}"
