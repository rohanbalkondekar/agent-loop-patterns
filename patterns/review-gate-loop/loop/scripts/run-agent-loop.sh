#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_NAME="$(basename "${ROOT_DIR}")"
DEFAULT_LOG_ROOT="$(cd "${ROOT_DIR}/.." && pwd)/_loop-runs/${REPO_NAME}"
LOOP_LOG_ROOT_WAS_SET="${LOOP_LOG_ROOT+x}"
LOG_ROOT="${LOOP_LOG_ROOT:-${DEFAULT_LOG_ROOT}}"
STATE_DIR="${LOG_ROOT}/state"
LATEST_HANDOFF_FILE="${STATE_DIR}/latest-handoff.md"
FIXER_CODEX_SANDBOX_MODE="${FIXER_CODEX_SANDBOX_MODE:-${CODEX_SANDBOX_MODE:-workspace-write}}"
VALIDATOR_CODEX_SANDBOX_MODE="${VALIDATOR_CODEX_SANDBOX_MODE:-read-only}"
CODEX_ADD_GIT_ROOT="${CODEX_ADD_GIT_ROOT:-true}"
CODEX_MODEL="${CODEX_MODEL:-gpt-5.5}"
CODEX_REASONING_EFFORT="${CODEX_REASONING_EFFORT:-xhigh}"
CODEX_PROFILE="${CODEX_PROFILE:-}"
LOOP_COUNT=3
PREPARE_ONLY=false
LOOP_POLL_INTERVAL_SECS="${LOOP_POLL_INTERVAL_SECS:-5}"
LOOP_ATTEMPT_IDLE_TIMEOUT_SECS="${LOOP_ATTEMPT_IDLE_TIMEOUT_SECS:-1200}"
LOOP_ATTEMPT_WALL_TIMEOUT_SECS="${LOOP_ATTEMPT_WALL_TIMEOUT_SECS:-3600}"

ACTION_FILE_REL="docs/agent-loops/loop-action.md"
QUEUE_FILE_REL="docs/agent-loops/loop-queue.md"
LEDGER_FILE_REL="docs/agent-loops/loop-ledger.md"
VALIDATION_FILE_REL="docs/agent-loops/loop-validation.md"
FIX_TEMPLATE_REL="docs/agent-loops/prompts/fix-agent.md"
VALIDATOR_TEMPLATE_REL="docs/agent-loops/prompts/validator-agent.md"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/run-agent-loop.sh [loop-count] [--prepare-only]

Environment:
  LOOP_LOG_ROOT=/path/to/logs
  CODEX_MODEL=gpt-5.5
  CODEX_REASONING_EFFORT=xhigh
  CODEX_PROFILE=name-from-codex-config
  CODEX_ADD_GIT_ROOT=true
  FIXER_CODEX_SANDBOX_MODE=workspace-write
  VALIDATOR_CODEX_SANDBOX_MODE=read-only
  LOOP_ATTEMPT_IDLE_TIMEOUT_SECS=1200
  LOOP_ATTEMPT_WALL_TIMEOUT_SECS=3600
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prepare-only) PREPARE_ONLY=true ;;
    -h|--help) usage; exit 0 ;;
    *)
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        LOOP_COUNT="$1"
      else
        echo "Unknown argument: $1" >&2
        usage >&2
        exit 1
      fi
      ;;
  esac
  shift
done

if ! [[ "${LOOP_COUNT}" =~ ^[0-9]+$ ]] || [[ "${LOOP_COUNT}" -lt 1 ]]; then
  echo "Loop count must be a positive integer." >&2
  exit 1
fi

resolve_path() {
  local path="$1"
  if [[ "${path}" = /* ]]; then printf '%s\n' "${path}"; else printf '%s\n' "${ROOT_DIR}/${path}"; fi
}

require_file() {
  local path="$1"
  [[ -f "${path}" ]] || { echo "Required file not found: ${path}" >&2; exit 1; }
}

file_size_bytes() {
  local path="$1"
  [[ -f "${path}" ]] || { printf '0\n'; return; }
  wc -c < "${path}" | tr -d '[:space:]'
}

print_log_delta() {
  local path="$1" start_byte="$2"
  [[ -f "${path}" ]] || return 0
  tail -c +"${start_byte}" "${path}" 2>/dev/null || true
}

kill_process_tree() {
  local pid="$1" child
  while IFS= read -r child; do
    [[ -n "${child}" ]] || continue
    kill_process_tree "${child}"
  done < <(pgrep -P "${pid}" 2>/dev/null || true)
  kill -TERM "${pid}" 2>/dev/null || true
}

run_codex_attempt() {
  local prompt_file="$1" log_file="$2" message_file="$3" label="$4" sandbox_mode="$5"
  local pid start_ts last_progress_ts now current_size printed_size=0
  local -a codex_args
  : > "${log_file}"

  codex_args=(exec -s "${sandbox_mode}" -C "${ROOT_DIR}" -o "${message_file}")
  if [[ -n "${CODEX_MODEL}" ]]; then
    codex_args+=(-m "${CODEX_MODEL}")
  fi
  if [[ -n "${CODEX_REASONING_EFFORT}" ]]; then
    codex_args+=(-c "model_reasoning_effort=\"${CODEX_REASONING_EFFORT}\"")
  fi
  if [[ -n "${CODEX_PROFILE}" ]]; then
    codex_args+=(-p "${CODEX_PROFILE}")
  fi
  if [[ "${CODEX_ADD_GIT_ROOT}" == "true" && -n "${GIT_ROOT:-}" && "${GIT_ROOT}" != "${ROOT_DIR}" ]]; then
    codex_args+=(--add-dir "${GIT_ROOT}")
  fi
  if [[ "${CODEX_ADD_GIT_ROOT}" == "true" && -n "${GIT_METADATA_DIR:-}" ]]; then
    codex_args+=(--add-dir "${GIT_METADATA_DIR}")
  fi
  if [[ "${CODEX_ADD_GIT_ROOT}" == "true" && -n "${GIT_COMMON_DIR:-}" && "${GIT_COMMON_DIR}" != "${GIT_METADATA_DIR:-}" ]]; then
    codex_args+=(--add-dir "${GIT_COMMON_DIR}")
  fi
  codex_args+=(-)

  codex "${codex_args[@]}" < "${prompt_file}" > "${log_file}" 2>&1 &
  pid=$!
  start_ts="$(date +%s)"
  last_progress_ts="${start_ts}"

  while kill -0 "${pid}" 2>/dev/null; do
    sleep "${LOOP_POLL_INTERVAL_SECS}"
    current_size="$(file_size_bytes "${log_file}")"
    if (( current_size > printed_size )); then
      print_log_delta "${log_file}" "$((printed_size + 1))"
      printed_size="${current_size}"
      last_progress_ts="$(date +%s)"
    fi
    now="$(date +%s)"
    if (( now - start_ts >= LOOP_ATTEMPT_WALL_TIMEOUT_SECS )); then
      echo "${label} hit wall timeout." >&2
      kill_process_tree "${pid}"
      wait "${pid}" 2>/dev/null || true
      return 124
    fi
    if (( now - last_progress_ts >= LOOP_ATTEMPT_IDLE_TIMEOUT_SECS )); then
      echo "${label} hit idle timeout." >&2
      kill_process_tree "${pid}"
      wait "${pid}" 2>/dev/null || true
      return 124
    fi
  done

  wait "${pid}"
  local status=$?
  current_size="$(file_size_bytes "${log_file}")"
  if (( current_size > printed_size )); then print_log_delta "${log_file}" "$((printed_size + 1))"; fi
  return "${status}"
}

current_handoff() {
  if [[ -f "${LATEST_HANDOFF_FILE}" ]]; then
    cat "${LATEST_HANDOFF_FILE}"
    return
  fi
  awk '/^## Current Handoff$/ {flag=1; next} /^## / && flag {exit} flag {print}' "${LEDGER_FILE}" || true
}

write_fixer_prompt() {
  local prompt_file="$1" loop_index="$2" total_loops="$3" handoff_text="$4"
  cat > "${prompt_file}" <<EOF
You are running agent loop ${loop_index} of ${total_loops} in ${ROOT_DIR}.

Important path rule:
- Treat ${ROOT_DIR} as the loop root and current working directory.
- Paths in the action, queue, ledger, validation contract, and prompts are relative to this loop root.
- If this loop is installed in a nested directory, do not prefix paths with the nested directory name again.

Read these files first:
- ${ACTION_FILE_REL}
- ${QUEUE_FILE_REL}
- ${LEDGER_FILE_REL}
- ${VALIDATION_FILE_REL}
- ${FIX_TEMPLATE_REL}

Current handoff:
${handoff_text}

Use the fix-agent template exactly. Make one bounded local commit or record a blocker. End with the required FIX_* fields.
EOF
}

write_validator_prompt() {
  local prompt_file="$1" loop_index="$2" total_loops="$3" fixer_message_file="$4"
  cat > "${prompt_file}" <<EOF
You are validating agent loop ${loop_index} of ${total_loops} in ${ROOT_DIR}.

Important path rule:
- Treat ${ROOT_DIR} as the loop root and current working directory.
- Paths in the action, queue, ledger, validation contract, and prompts are relative to this loop root.
- If this loop is installed in a nested directory, do not prefix paths with the nested directory name again.

Read these files first:
- ${ACTION_FILE_REL}
- ${VALIDATION_FILE_REL}
- ${QUEUE_FILE_REL}
- ${LEDGER_FILE_REL}
- ${VALIDATOR_TEMPLATE_REL}

Then inspect the latest commit and the fixer result in:
${fixer_message_file}

Do not edit, stage, or commit. End with the required VALIDATION_* fields.
EOF
}

repo_is_dirty() {
  ! git diff --quiet || ! git diff --cached --quiet || [[ -n "$(git ls-files --others --exclude-standard)" ]]
}

extract_marker() {
  local key="$1" file="$2"
  grep -E "^${key}:" "${file}" | tail -1 | cut -d: -f2- | sed -E 's/^ +//' || true
}

ACTION_FILE="$(resolve_path "${ACTION_FILE_REL}")"
QUEUE_FILE="$(resolve_path "${QUEUE_FILE_REL}")"
LEDGER_FILE="$(resolve_path "${LEDGER_FILE_REL}")"
VALIDATION_FILE="$(resolve_path "${VALIDATION_FILE_REL}")"
FIX_TEMPLATE_FILE="$(resolve_path "${FIX_TEMPLATE_REL}")"
VALIDATOR_TEMPLATE_FILE="$(resolve_path "${VALIDATOR_TEMPLATE_REL}")"

require_file "${ACTION_FILE}"
require_file "${QUEUE_FILE}"
require_file "${LEDGER_FILE}"
require_file "${VALIDATION_FILE}"
require_file "${FIX_TEMPLATE_FILE}"
require_file "${VALIDATOR_TEMPLATE_FILE}"
command -v git >/dev/null 2>&1 || { echo "git is required" >&2; exit 1; }
command -v codex >/dev/null 2>&1 || { echo "codex CLI is required" >&2; exit 1; }

cd "${ROOT_DIR}"
git rev-parse --is-inside-work-tree >/dev/null
GIT_ROOT="$(git rev-parse --show-toplevel)"
GIT_METADATA_DIR_RAW="$(git rev-parse --git-dir)"
if [[ "${GIT_METADATA_DIR_RAW}" = /* ]]; then
  GIT_METADATA_DIR="${GIT_METADATA_DIR_RAW}"
else
  GIT_METADATA_DIR="${GIT_ROOT}/${GIT_METADATA_DIR_RAW}"
fi
GIT_COMMON_DIR_RAW="$(git rev-parse --git-common-dir)"
if [[ "${GIT_COMMON_DIR_RAW}" = /* ]]; then
  GIT_COMMON_DIR="${GIT_COMMON_DIR_RAW}"
else
  GIT_COMMON_DIR="${GIT_METADATA_DIR}/${GIT_COMMON_DIR_RAW}"
fi
if [[ -z "${LOOP_LOG_ROOT_WAS_SET}" && "${GIT_ROOT}" != "${ROOT_DIR}" ]]; then
  LOG_ROOT="$(cd "${GIT_ROOT}/.." && pwd)/_loop-runs/${REPO_NAME}"
  STATE_DIR="${LOG_ROOT}/state"
  LATEST_HANDOFF_FILE="${STATE_DIR}/latest-handoff.md"
fi
mkdir -p "${LOG_ROOT}" "${STATE_DIR}"

if repo_is_dirty; then
  echo "Worktree must be clean before starting the loop." >&2
  git status --short >&2
  exit 1
fi

if [[ "${PREPARE_ONLY}" == true ]]; then
  echo "prepare_only=true"
  echo "repo=${ROOT_DIR}"
  echo "log_root=${LOG_ROOT}"
  echo "codex_model=${CODEX_MODEL:-default}"
  echo "codex_reasoning_effort=${CODEX_REASONING_EFFORT:-default}"
  echo "codex_profile=${CODEX_PROFILE:-default}"
  echo "codex_add_git_root=${CODEX_ADD_GIT_ROOT}"
  echo "fixer_sandbox=${FIXER_CODEX_SANDBOX_MODE}"
  echo "validator_sandbox=${VALIDATOR_CODEX_SANDBOX_MODE}"
  echo "codex=$(command -v codex)"
  exit 0
fi

RUN_DIR="${LOG_ROOT}/$(date +%Y%m%d-%H%M%S)"
mkdir -p "${RUN_DIR}"
cat > "${RUN_DIR}/summary.txt" <<EOF
repo=${ROOT_DIR}
started_at=$(date -Iseconds)
requested_loops=${LOOP_COUNT}
log_root=${LOG_ROOT}
codex_model=${CODEX_MODEL:-default}
codex_reasoning_effort=${CODEX_REASONING_EFFORT:-default}
codex_profile=${CODEX_PROFILE:-default}
EOF

completed=0
for ((loop_index=1; loop_index<=LOOP_COUNT; loop_index++)); do
  echo "=== loop ${loop_index}/${LOOP_COUNT} ==="
  baseline_commit="$(git rev-parse HEAD)"
  handoff_text="$(current_handoff)"

  fixer_prompt="${RUN_DIR}/loop-$(printf '%03d' "${loop_index}")-fixer-prompt.txt"
  fixer_log="${RUN_DIR}/loop-$(printf '%03d' "${loop_index}")-fixer.log"
  fixer_message="${RUN_DIR}/loop-$(printf '%03d' "${loop_index}")-fixer-message.txt"
  validator_prompt="${RUN_DIR}/loop-$(printf '%03d' "${loop_index}")-validator-prompt.txt"
  validator_log="${RUN_DIR}/loop-$(printf '%03d' "${loop_index}")-validator.log"
  validator_message="${RUN_DIR}/loop-$(printf '%03d' "${loop_index}")-validator-message.txt"

  write_fixer_prompt "${fixer_prompt}" "${loop_index}" "${LOOP_COUNT}" "${handoff_text}"
  if ! run_codex_attempt "${fixer_prompt}" "${fixer_log}" "${fixer_message}" "fixer loop ${loop_index}" "${FIXER_CODEX_SANDBOX_MODE}"; then
    echo "stop_reason=fixer_failed" >> "${RUN_DIR}/summary.txt"
    exit 1
  fi

  if repo_is_dirty; then
    echo "Fixer left uncommitted changes. Stop for manual inspection." >&2
    echo "stop_reason=dirty_after_fixer" >> "${RUN_DIR}/summary.txt"
    exit 1
  fi

  new_commit="$(git rev-parse HEAD)"
  if [[ "${new_commit}" == "${baseline_commit}" ]]; then
    echo "No commit produced. Stopping."
    echo "stop_reason=no_commit" >> "${RUN_DIR}/summary.txt"
    exit 0
  fi

  write_validator_prompt "${validator_prompt}" "${loop_index}" "${LOOP_COUNT}" "${fixer_message}"
  if ! run_codex_attempt "${validator_prompt}" "${validator_log}" "${validator_message}" "validator loop ${loop_index}" "${VALIDATOR_CODEX_SANDBOX_MODE}"; then
    echo "stop_reason=validator_exec_failed" >> "${RUN_DIR}/summary.txt"
    exit 1
  fi

  if repo_is_dirty; then
    echo "Validator dirtied the worktree. Stop for manual inspection." >&2
    echo "stop_reason=dirty_after_validator" >> "${RUN_DIR}/summary.txt"
    exit 1
  fi

  validation_result="$(extract_marker VALIDATION_RESULT "${validator_message}")"
  stamp="$(date +%Y%m%d-%H%M%S)-loop-${loop_index}"
  if [[ "${validation_result}" != "passed" ]]; then
    rejected_ref="refs/agent-loop/rejected/${stamp}"
    git update-ref "${rejected_ref}" HEAD
    git reset --hard "${baseline_commit}"
    echo "Validator failed; rejected commit saved at ${rejected_ref}." >&2
    echo "stop_reason=validator_failed" >> "${RUN_DIR}/summary.txt"
    exit 1
  fi

  checkpoint_ref="refs/agent-loop/checkpoints/${stamp}"
  git update-ref "${checkpoint_ref}" HEAD
  cp "${fixer_message}" "${STATE_DIR}/latest-fixer-message.txt"
  cp "${validator_message}" "${STATE_DIR}/latest-validator-message.txt"
  awk '/^FIX_NEXT_STEP:/,/^NEXT_ISSUE:/ {print}' "${fixer_message}" > "${LATEST_HANDOFF_FILE}" || true
  completed=$((completed + 1))
  echo "loop_${loop_index}_commit=$(git rev-parse HEAD)" >> "${RUN_DIR}/summary.txt"
  echo "loop_${loop_index}_checkpoint=${checkpoint_ref}" >> "${RUN_DIR}/summary.txt"
done

echo "completed_loops=${completed}" >> "${RUN_DIR}/summary.txt"
echo "stop_reason=completed_requested_loops" >> "${RUN_DIR}/summary.txt"
echo "Completed ${completed} loop(s). Logs: ${RUN_DIR}"
