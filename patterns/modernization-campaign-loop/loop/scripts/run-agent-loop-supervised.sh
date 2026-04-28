#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_NAME="$(basename "${ROOT_DIR}")"
DEFAULT_LOG_ROOT="$(cd "${ROOT_DIR}/.." && pwd)/_loop-runs/${REPO_NAME}"
LOG_ROOT="${LOOP_LOG_ROOT:-${DEFAULT_LOG_ROOT}}"
RUNNER="${ROOT_DIR}/scripts/run-agent-loop.sh"
TARGET_LOOPS="${1:-25}"
STALE_SECONDS="${STALE_SECONDS:-1800}"
CHECK_INTERVAL_SECONDS="${CHECK_INTERVAL_SECONDS:-300}"
REST_INTERVAL_SECONDS="${REST_INTERVAL_SECONDS:-900}"
SUPERVISOR_LOG="${SUPERVISOR_LOG:-${LOG_ROOT}/supervisor.log}"

mkdir -p "${LOG_ROOT}"

timestamp() { date -Iseconds; }
log() { printf '%s %s\n' "$(timestamp)" "$*" | tee -a "${SUPERVISOR_LOG}"; }

kill_process_tree() {
  local pid="$1" child
  while IFS= read -r child; do
    [[ -n "${child}" ]] || continue
    kill_process_tree "${child}"
  done < <(pgrep -P "${pid}" 2>/dev/null || true)
  kill -TERM "${pid}" 2>/dev/null || true
}

latest_run_dir() {
  find "${LOG_ROOT}" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | sort | tail -1 || true
}

latest_activity_age_seconds() {
  local run_dir="$1"
  python3 - "$run_dir" <<'PY'
import os, sys, time
root = sys.argv[1]
latest = None
if os.path.isdir(root):
    for dirpath, _, files in os.walk(root):
        for name in files:
            path = os.path.join(dirpath, name)
            try:
                m = os.path.getmtime(path)
            except FileNotFoundError:
                continue
            latest = m if latest is None or m > latest else latest
print("") if latest is None else print(int(time.time() - latest))
PY
}

latest_stop_reason() {
  local run_dir="$1" summary="${run_dir}/summary.txt"
  [[ -f "${summary}" ]] || return 0
  grep '^stop_reason=' "${summary}" | tail -1 | cut -d= -f2- || true
}

if ! [[ "${TARGET_LOOPS}" =~ ^[0-9]+$ ]] || [[ "${TARGET_LOOPS}" -lt 1 ]]; then
  echo "Usage: $0 [positive-loop-count]" >&2
  exit 1
fi

while true; do
  latest="$(latest_run_dir)"
  reason=""
  [[ -n "${latest}" ]] && reason="$(latest_stop_reason "${latest}")"
  if [[ "${reason}" == "completed_requested_loops" ]]; then
    log "latest run completed normally run_dir=${latest}; exiting supervisor"
    exit 0
  fi

  log "starting agent loop batch target_loops=${TARGET_LOOPS}"
  "${RUNNER}" "${TARGET_LOOPS}" &
  runner_pid=$!

  while kill -0 "${runner_pid}" 2>/dev/null; do
    run_dir="$(latest_run_dir)"
    if [[ -n "${run_dir}" ]]; then
      age="$(latest_activity_age_seconds "${run_dir}")"
      if [[ -n "${age}" ]] && (( age >= STALE_SECONDS )); then
        log "detected stale run run_dir=${run_dir} age_seconds=${age}; killing runner"
        kill_process_tree "${runner_pid}"
        wait "${runner_pid}" 2>/dev/null || true
        break
      fi
    fi
    sleep "${CHECK_INTERVAL_SECONDS}"
  done

  wait "${runner_pid}" 2>/dev/null || true
  log "sleeping before restart seconds=${REST_INTERVAL_SECONDS}"
  sleep "${REST_INTERVAL_SECONDS}"
done
