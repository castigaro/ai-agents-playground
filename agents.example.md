# agents.md

This repository is set up for local collaboration with AI coding tools.
The goal is to make it easy to administer a Debian-based home server over SSH from Windows and to manage Docker workloads safely.

## Project context

- Workspace root: `d:/projects/ai-agents-playground`
- User-facing documentation lives in `docs/how-to`
- The local server is addressed via the SSH alias `codex-home`
- The dedicated SSH key for this workflow is `~/.ssh/id_ed25519_codex`
- The remote login user is `codex`
- The server hostname in the SSH config should be set locally in the user's SSH config
- The n8n service lives under `services/n8n` and is deployed to `/home/codex/ai-agents-playground/services/n8n`

## SSH setup

- Prefer `ssh codex-home` for all Codex-related server access.
- If the alias is not available, fall back to `ssh -i ~/.ssh/id_ed25519_codex codex@<server-hostname-or-ip>`.
- Do not reuse the Git key `id_ed25519` for Codex access.
- Keep `IdentitiesOnly yes` in the SSH config so the Codex key is used explicitly.

## Server access rules

- Treat `codex` as the default non-root admin account.
- Use `sudo` only when a task genuinely requires it.
- Prefer non-destructive commands first.
- If a command fails because of permissions, report the exact command and the missing privilege.
- The `codex` user is already in the `docker` group.

## Docker workflow

- Use `docker compose` inside the target project directory.
- Typical actions are:
  - create or update a project directory
  - add or edit `compose.yml`
  - run `docker compose up -d`
  - inspect status with `docker compose ps`
  - follow logs with `docker compose logs -f`
  - stop with `docker compose down`
- For n8n on this server, use `docker compose` because the server now provides the plugin-based Compose command.

## File and docs conventions

- Keep documentation in German unless a different language is clearly requested.
- Keep instructions short, direct, and practical.
- If you add another setup guide, place it under `docs/how-to`.
- When documenting SSH keys, always name the Codex key explicitly as `id_ed25519_codex`.
- Keep n8n-specific settings in `services/n8n` and use `scripts/deploy-n8n.ps1` to sync them to the server.
- If Context7 is configured in Codex, prefer it for current n8n or library/API documentation before falling back to generic web search.
- For browser-based checks on Windows, prefer the Edge DevTools MCP workflow documented in `docs/how-to/setup-edge-devtools-mcp.md`.
- When setting up or verifying web apps, use the browser MCP workflow first to confirm reachability and page state before making changes.
- If a setup flow asks for a password or other secret, let the user enter it rather than inventing or storing it in the repo.
- For onboarding flows like n8n, it is fine to stop after the account form is reached and let the user finish the password step manually.

## Operating style for future agents

- First inspect the current state before changing anything.
- Prefer small, targeted edits over large rewrites.
- Preserve unrelated user changes.
- If there is ambiguity about hostnames, keys, or permissions, ask before making risky changes.
- Do not overwrite the existing personal or Git SSH key setup.

## Approval mode

- When working inside this repository, prefer to continue without asking for approval on every small file change.
- Treat routine documentation edits, non-destructive code changes, and normal project-file updates as in-scope.
- Use the SSH alias `codex-home` for server work when remote access is needed.
- Ask for confirmation only before risky actions such as destructive file operations, permission changes outside the project, system-level edits, or anything that could affect unrelated services on the server.
- If a task spans multiple files in the same focused change, continue the full set of related edits instead of stopping after each file.
