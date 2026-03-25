#!/usr/bin/env bash
# codex-dispatch.sh — Dispatch or send follow-up tasks to Codex in a tmux pane
#
# Usage:
#   codex-dispatch.sh dispatch --id "<id>" "<task>"   — Open new pane, launch Codex
#   codex-dispatch.sh send --id "<id>" "<task>"        — Send follow-up to existing pane
#
# Prints the log file path to stdout

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGS_DIR="${SKILL_DIR}/logs"
PROJECT_DIR="${PWD}"

# --- Parse arguments ---
COMMAND="${1:-}"
shift || true

AGENT_ID=""
TASK=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --id)
            AGENT_ID="$2"
            shift 2
            ;;
        *)
            TASK="$1"
            shift
            ;;
    esac
done

# --- Validate ---
if [[ -z "${COMMAND}" ]] || [[ -z "${AGENT_ID}" ]] || [[ -z "${TASK}" ]]; then
    echo "ERROR: Command, --id, and task description required" >&2
    echo "Usage:" >&2
    echo "  codex-dispatch.sh dispatch --id \"<id>\" \"<task>\"" >&2
    echo "  codex-dispatch.sh send --id \"<id>\" \"<task>\"" >&2
    exit 1
fi

if [[ -z "${TMUX:-}" ]]; then
    echo "ERROR: Not inside a tmux session" >&2
    exit 1
fi

if ! command -v codex &>/dev/null; then
    echo "ERROR: codex CLI not found on PATH" >&2
    exit 1
fi

# --- State and log files ---
STATE_FILE="${SKILL_DIR}/.codex-pane-${AGENT_ID}"
DATE="$(date +%Y%m%d)"
TIME="$(date +%H%M%S)"
LOG_FILE="${LOGS_DIR}/${DATE}-${AGENT_ID}-${TIME}.md"

mkdir -p "${LOGS_DIR}"

# --- Prompt wrapper ---
build_prompt() {
    local task="$1"
    local log="$2"
    cat <<PROMPT_EOF
${task}

---

IMPORTANT: When you have completed the task (or determined you cannot complete it), write a summary to the following file:

${log}

Use this exact format:

## Task
(one-line description of what was asked)

## Status
success | partial | failed

## Result
(key findings, output, answer, or description of what was built — this is the main content)

## Files Changed
- path/to/file — description of what changed
(write "none" if no files were changed)

## Issues
(any problems encountered, or "none")

<!-- DONE -->

Do NOT skip writing this summary. Do NOT list this summary file in Files Changed. Focus the Result section on the actual task output.
PROMPT_EOF
}

# --- Codex workers window ---
WORKERS_WINDOW="codex-workers"

ensure_workers_window() {
    # Create the codex-workers window if it doesn't exist
    if ! tmux list-windows -F '#{window_name}' | grep -q "^${WORKERS_WINDOW}$"; then
        tmux new-window -d -n "${WORKERS_WINDOW}" -c "${PROJECT_DIR}"
        # The new window starts with one empty pane — we'll use it for the first codex
        echo "new"
    else
        echo "exists"
    fi
}

# --- Commands ---

do_dispatch() {
    # Kill existing pane for this agent ID if any
    if [[ -f "${STATE_FILE}" ]]; then
        local old_pane
        old_pane="$(cat "${STATE_FILE}")"
        tmux kill-pane -t "${old_pane}" 2>/dev/null || true
        rm -f "${STATE_FILE}"
    fi

    # Build prompt and write to temp file
    local prompt_file
    prompt_file="$(mktemp)"
    build_prompt "${TASK}" "${LOG_FILE}" > "${prompt_file}"

    local state_file="${STATE_FILE}"
    local new_pane
    local codex_cmd="codex --full-auto \"\$(cat '${prompt_file}')\" ; rm -f '${prompt_file}'; rm -f '${state_file}'; echo '[Codex finished — press any key to close]'; read -r"

    # Ensure the codex-workers window exists
    local window_status
    window_status="$(ensure_workers_window)"

    if [[ "${window_status}" == "new" ]]; then
        # Window was just created — use its initial empty pane
        local target_pane
        target_pane="$(tmux list-panes -t "${WORKERS_WINDOW}" -F '#{pane_id}' | head -1)"
        tmux send-keys -t "${target_pane}" "cd '${PROJECT_DIR}' && ${codex_cmd}" Enter
        new_pane="${target_pane}"
    else
        # Window already exists — split a pane inside it
        new_pane="$(tmux split-window -t "${WORKERS_WINDOW}" -d -c "${PROJECT_DIR}" -P -F '#{pane_id}' \
            "${codex_cmd}")"
    fi

    # Rebalance all panes in the workers window
    tmux select-layout -t "${WORKERS_WINDOW}" tiled

    # Save the new pane ID to state file
    echo "${new_pane}" > "${STATE_FILE}"

    echo "${LOG_FILE}"
}

do_send() {
    # Check for existing pane
    if [[ ! -f "${STATE_FILE}" ]]; then
        echo "ERROR: No active Codex pane for id '${AGENT_ID}'. Use 'dispatch' first." >&2
        exit 1
    fi

    local pane_id
    pane_id="$(cat "${STATE_FILE}")"

    # Verify pane is still alive (check all windows)
    if ! tmux list-panes -a -F '#{pane_id}' | grep -q "^${pane_id}$"; then
        echo "ERROR: Codex pane ${pane_id} no longer exists. Use 'dispatch' to start a new one." >&2
        rm -f "${STATE_FILE}"
        exit 1
    fi

    # Build full multi-line prompt with log instructions
    local prompt_file
    prompt_file="$(mktemp)"
    build_prompt "${TASK}" "${LOG_FILE}" > "${prompt_file}"

    # Send prompt to Codex input via tmux send-keys (literal mode)
    # Using send-keys -l avoids bracketed-paste issues that prevent submission
    local prompt_text
    prompt_text="$(cat "${prompt_file}")"
    rm -f "${prompt_file}"
    tmux send-keys -t "${pane_id}" -l "${prompt_text}"
    sleep 0.3
    tmux send-keys -t "${pane_id}" Enter

    echo "${LOG_FILE}"
}

# --- Main ---
case "${COMMAND}" in
    dispatch)
        do_dispatch
        ;;
    send)
        do_send
        ;;
    *)
        echo "ERROR: Unknown command '${COMMAND}'. Use 'dispatch' or 'send'." >&2
        exit 1
        ;;
esac
