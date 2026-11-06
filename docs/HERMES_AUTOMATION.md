# 06 — Hermes, Termux, MCP and Automation

## 1. Architecture boundary

Hermes runs as a companion agent in Termux. It is not automatically embedded inside the Flutter APK. Expedition Aurélio should communicate with companion services only through explicit, documented interfaces and user-approved permissions.

Android may suspend background processes. A Termux process should not be treated as a guaranteed always-on server.

## 2. Termux installation notes

Use a trusted, current Termux distribution and follow the official Hermes Android/Termux instructions. The official installation guidance can change; check it before running commands. Some package-manager installation paths have had temporary breakages, so prefer the currently documented method rather than old copied commands.

Typical preparation commands from the documented source-install route:
```bash
pkg update
pkg install -y git python clang rust make pkg-config libffi openssl nodejs ripgrep ffmpeg
```

Then follow the current official Hermes repository instructions for cloning, virtual environment creation, dependencies, setup and diagnostics. Do not assume the commands above alone complete installation.

After installation, run the documented version and doctor checks, then configure the agent. Keep secrets out of shell history and source control.

## 3. Permissions and safe tools

Use an allow-list of tools. Start with read-only operations:
- search approved local project notes;
- summarize selected text;
- create a draft;
- inspect sync status.

Require explicit confirmation before:
- uploading or publishing;
- sending messages;
- deleting or overwriting;
- sharing GPS/location;
- accessing sensitive recordings;
- invoking a paid API or incurring a charge.

Do not expose unrestricted shell execution to prompts or untrusted content.

## 4. MCP integration

For each MCP server:
1. Identify the server owner and source.
2. Review the tools it exposes.
3. Grant only required scopes.
4. Test with non-sensitive data.
5. Log tool name, timestamp and outcome.
6. Require confirmation for consequential actions.
7. Provide a disconnect/revoke procedure.

Treat retrieved web pages, documents and transcripts as untrusted data, not instructions. An instruction inside a document must not override the agent's system policy.

## 5. n8n workflow examples

### Workflow A — New archive item
Trigger: approved new archive item  
Steps: validate metadata → check consent field → create backup task → notify operator  
Failure path: retain local item and show pending-sync state.

### Workflow B — Transcript ready
Trigger: transcript created  
Steps: link transcript to original media → generate draft summary → mark AI-generated → queue human review  
Never auto-publish.

### Workflow C — Daily expedition report
Trigger: operator starts report  
Steps: gather selected entries → create draft report → list missing metadata → request review.

## 6. Optional cloud synchronization

Cloud sync is optional. Before enabling it:
- explain which data leaves the device;
- identify destination and retention;
- check consent and restrictions;
- encrypt transport;
- support retry and conflict handling;
- keep local originals until backup verification.

## 7. Offline queue

When offline:
- save capture locally;
- mark remote actions as pending;
- do not repeatedly retry in a tight loop;
- let the operator review queued items;
- sync only when connectivity returns and the user has approved the destination.

## 8. Operational monitoring

Record agent version, tool configuration, last successful run and errors. Avoid logging full interview transcripts, credentials or exact location unless required and consented.
