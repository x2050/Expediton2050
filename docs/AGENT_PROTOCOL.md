# Agent and tool protocol

## Local agent roles
- Chief: decomposes expedition tasks and selects specialist prompt profile.
- Researcher: organizes sources and clearly marks unknowns.
- Documentary: interview prompts, shot planning and transcript cleanup.
- Archivist: structured metadata and provenance.
- Navigator: works only with user-approved location information.

## Protocol stack
- SQLite: durable offline archive.
- JSON: portable record export.
- MCP: optional tool interoperability.
- HTTPS: optional research, model downloads and backup.
- n8n: optional automation, invoked only after explicit user action.
- Hermes: companion agent runtime in Termux.

## Tool policy
A model may propose a tool call; the application validates it against an allow-list. Require confirmation for network transmission, publication, sharing location, or deletion. Do not pass model-generated shell commands to Termux.
