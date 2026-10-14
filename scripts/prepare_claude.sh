#!/usr/bin/env bash
# scripts/prepare_claude.sh
# Idempotent helper to prepare Free Claude Code locally so the Claude CLI can use it.
# Usage: chmod +x scripts/prepare_claude.sh && ./scripts/prepare_claude.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/.."

echo "[prepare_claude] Starting preparation from ${SCRIPT_DIR}"

# Ensure Python 3 is installed
command -v python3 >/dev/null 2>&1 || { echo "python3 not found on PATH. Please install Python 3.14+."; exit 1; }
PYTHON_VER=$(python3 -c 'import sys; print("%d.%d" % (sys.version_info.major, sys.version_info.minor))')
echo "[prepare_claude] Found python version ${PYTHON_VER}"

# Use local installer if present, otherwise use upstream installer
LOCAL_INSTALLER="${REPO_ROOT}/scripts/install.sh"
if [ -f "${LOCAL_INSTALLER}" ]; then
  echo "[prepare_claude] Found local installer at ${LOCAL_INSTALLER}; running it"
  chmod +x "${LOCAL_INSTALLER}"
  "${LOCAL_INSTALLER}"
else
  echo "[prepare_claude] Local installer not found. Falling back to upstream installer."
  echo "[prepare_claude] Running: curl -fsSL https://raw.githubusercontent.com/Alishahryar1/free-claude-code/main/scripts/install.sh | sh"
  curl -fsSL "https://raw.githubusercontent.com/Alishahryar1/free-claude-code/main/scripts/install.sh" | sh
fi

# Verify installation
if command -v fcc-server >/dev/null 2>&1; then
  echo "[prepare_claude] fcc-server is installed"
else
  echo "[prepare_claude] Warning: fcc-server not found on PATH after installer. Check the installer output or add it to PATH."
fi

if command -v fcc-claude >/dev/null 2>&1; then
  echo "[prepare_claude] fcc-claude is installed"
else
  echo "[prepare_claude] Warning: fcc-claude not found on PATH after installer."
fi

# Create default .fcc directory and env file if missing
FCC_DIR="$HOME/.fcc"
ENV_FILE="$FCC_DIR/.env"
if [ ! -d "$FCC_DIR" ]; then
  mkdir -p "$FCC_DIR"
  echo "[prepare_claude] Created $FCC_DIR"
fi
if [ ! -f "$ENV_FILE" ]; then
  cat > "$ENV_FILE" <<EOF
# FCC managed env (created by scripts/prepare_claude.sh)
# Add provider keys here, for example:
# OPENROUTER_API_KEY=your_openrouter_key
# MODEL=open_router/openrouter/free
EOF
  echo "[prepare_claude] Created default env file at $ENV_FILE"
fi

# Start the server if not running (user-level background)
if pgrep -f "fcc-server" >/dev/null 2>&1; then
  echo "[prepare_claude] fcc-server appears to be running"
else
  echo "[prepare_claude] Starting fcc-server in background"
  # Try to run in background and detach
  if command -v fcc-server >/dev/null 2>&1; then
    nohup fcc-server >/dev/null 2>&1 &
    sleep 2
    echo "[prepare_claude] fcc-server started"
  else
    echo "[prepare_claude] fcc-server not available to start; please check installation"
  fi
fi

echo "[prepare_claude] Preparation complete. To run the Claude agent, execute: fcc-claude"
