#!/usr/bin/env bash
# Install Crew as a user-level Claude Code subagent.
#
# Two ways to run:
#   1. From a local clone:  ./install.sh
#   2. One-liner from anywhere:
#        curl -fsSL https://raw.githubusercontent.com/sanimesh96/crew/main/install.sh | bash
#
# Non-interactive: overwrites any existing crew agent without prompting.
# Backups: existing files are saved to .bak first.

set -euo pipefail

AGENT_DIR="${HOME}/.claude/agents"
ORGS_DIR="${HOME}/.claude/orgs"
AGENT_FILE="crew.md"
SEED_ORG="content-factory.yaml"

LOCAL_AGENT="agents/${AGENT_FILE}"
LOCAL_ORG="orgs/${SEED_ORG}"
REMOTE_AGENT_URL="https://raw.githubusercontent.com/sanimesh96/crew/main/agents/${AGENT_FILE}"
REMOTE_ORG_URL="https://raw.githubusercontent.com/sanimesh96/crew/main/orgs/${SEED_ORG}"

AGENT_DEST="${AGENT_DIR}/${AGENT_FILE}"
ORG_DEST="${ORGS_DIR}/${SEED_ORG}"

mkdir -p "${AGENT_DIR}" "${ORGS_DIR}"

backup_if_exists() {
  local target="$1"
  if [[ -f "${target}" ]]; then
    cp "${target}" "${target}.bak"
    echo "  Backed up existing ${target} to ${target}.bak"
  fi
}

install_file() {
  local local_src="$1"
  local remote_url="$2"
  local dest="$3"
  local label="$4"

  backup_if_exists "${dest}"

  if [[ -f "${local_src}" ]]; then
    cp "${local_src}" "${dest}"
    echo "  Installed ${label} from local checkout → ${dest}"
  elif command -v curl >/dev/null 2>&1; then
    curl -fsSL "${remote_url}" -o "${dest}"
    echo "  Installed ${label} from GitHub → ${dest}"
  else
    echo "Error: need either a local checkout or curl on PATH to install ${label}." >&2
    exit 1
  fi
}

echo "Installing Crew..."
install_file "${LOCAL_AGENT}" "${REMOTE_AGENT_URL}" "${AGENT_DEST}" "crew agent"
install_file "${LOCAL_ORG}"   "${REMOTE_ORG_URL}"   "${ORG_DEST}"   "content-factory seed org"

cat <<EOF

Crew installed. Restart Claude Code so it picks up the agent.

Try it out:
  • "list crews"
  • "run crew content-factory on the topic: Why subagents beat single agents"
  • "crew create my-new-crew"

Crews live in: ${ORGS_DIR}
Edit a YAML directly to customize roles, prompts, or tools.
EOF
