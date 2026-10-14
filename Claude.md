Claude.md

GitHub Copilot Chat Assistant

Purpose

This document explains how to prepare and run Free Claude Code (FCC) locally so that your local Claude CLI ("claude" binary) can use FCC models and free providers every time you open the Claude CLI.

Important license note

This repository is licensed AGPL-3.0-only. Running FCC locally for your own personal use does not require you to publish anything. If you distribute a CLI or operate FCC as a network service accessible to others, AGPL-3.0 requires you to provide the complete corresponding source under the same license. See the PRD at PRD/PRODUCT_REQUIREMENTS.md for legal and product constraints.

Quick summary (one-liners)

- One-time: run ./scripts/prepare_claude.sh or ./scripts/install.sh from this repo to install FCC and dependencies.
- Autostart: enable the systemd unit (user) so fcc-server starts on login: systemctl --user enable --now fcc-server.service
- Start agent: fcc-server (background) then fcc-claude to run the Claude agent locally.

Prerequisites

- Linux, macOS, or Windows Subsystem for Linux
- Python 3.14+ on PATH
- curl and sh (POSIX) or PowerShell on Windows
- Enough disk space and network access to download dependencies and models

One-time install (recommended, idempotent)

POSIX (macOS / Linux):

1. From repo root, run:

   chmod +x scripts/prepare_claude.sh && ./scripts/prepare_claude.sh

   The script will try to use the repo's local installer (scripts/install.sh) if present; otherwise it falls back to the upstream official installer. It performs an idempotent install and verifies fcc-server/fcc-claude are installed.

Windows (PowerShell):

1. Open PowerShell as your user and run the equivalent installer from the repository or upstream installer. See README.md for the official PowerShell command.

Start and use (every session)

1. Start the server (if not already running):

   fcc-server &

   or enable the systemd user service (Linux):

   systemctl --user enable --now fcc-server.service

2. Run the Claude agent in your terminal:

   fcc-claude

   This launches the local Claude Code agent configured to use your configured FCC models.

Configure a free provider (example: OpenRouter free)

1. Open Admin UI (the server log prints the Admin URL) and add a provider under Providers → Cloud providers or Custom providers.
2. Example environment variables for OpenRouter free provider (example only):

   export OPENROUTER_API_KEY="<your-openrouter-key>"
   export MODEL="open_router/openrouter/free"

3. Save and click Apply in Admin UI. The server automatically uses the selected model for clients.

Automation / "tell Claude to prepare everything"

To let your Claude agent prepare this environment automatically when you say a short command, do the following:

1. Add the prepare script to the machine (scripts/prepare_claude.sh). It is idempotent and can be run multiple times.
2. From your Claude agent prompt or automation, call the local shell to run the script (for example, use a terminal runner or a tiny wrapper that executes it).

Security & privacy

- Keep the server local and protected. If you enable Proxy Authentication in Admin, set a strong bearer token.
- Do not expose the server on public networks unless you accept the AGPL obligations and secure access.

Troubleshooting

- Check server logs and status:

  fcc-doctor
  journalctl --user -u fcc-server.service -n 200
  ps aux | grep fcc-server

- Verify CLI versions:

  fcc-server --version
  fcc-claude --version

Smoke tests

Run project smoke tests locally to validate functionality (some checks are opt-in):

  export FCC_LIVE_SMOKE=1
  uv run pytest smoke -n 0 -s --tb=short

PRD path

The Product Requirements Document is at: PRD/PRODUCT_REQUIREMENTS.md

Files added

- scripts/prepare_claude.sh: idempotent installer and starter
- systemd/fcc-server.service: sample user service to autostart fcc-server on Linux (user)
- PRD/PRODUCT_REQUIREMENTS.md: product requirements, constraints, and acceptance criteria

If you want me to also add a launchd plist for macOS or a Windows service file, tell me and I will add them.
