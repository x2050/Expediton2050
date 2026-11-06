# 03 — Developer Guide

## 1. Architecture overview

Recommended logical layers:

- Presentation: Flutter screens and widgets.
- Domain: field-entry models and use cases.
- Data: SQLite/local files/repositories.
- AI: LiteRT runtime, model manager, prompt and agent routing.
- Integrations: optional network clients, sync, MCP and automation.
- Platform: Android permissions, storage and lifecycle.

Keep the offline capture path independent from remote services. The app should still create and retrieve field entries when the network is unavailable.

## 2. Repository orientation

Typical project structure:
```text
lib/
  main.dart
  app.dart
  screens/
  domain/
  data/
  ai/
android/
  app/
assets/
docs/
```

Read `pubspec.yaml` first. It declares package dependencies and bundled assets. Confirm every referenced file exists before running the app.

## 3. Development loop

1. Create a Git branch for one focused change.
2. Make the smallest useful change.
3. Format:
   ```bash
   dart format .
   ```
4. Analyze:
   ```bash
   flutter analyze
   ```
5. Run tests:
   ```bash
   flutter test
   ```
6. Run on a real device:
   ```bash
   flutter run
   ```
7. Record what was tested and any limitations.
8. Commit with a descriptive message.

## 4. Data model principles

A field record should have:
- stable unique ID;
- title and body;
- created/updated timestamps;
- tags;
- optional location;
- consent/usage restrictions;
- links to original media;
- provenance and source identifiers.

Use migrations when changing SQLite schema. Never silently drop user data during an upgrade. Test migrations using a copy of representative data.

## 5. File storage

Prefer app-private storage for internal working files. Use Android's supported document/photo pickers for user-selected content. Avoid broad storage permissions unless there is a documented requirement. Keep original media immutable; create derivatives for compression, transcription or editing.

## 6. Runtime and lifecycle

AI models consume significant memory. Load only the model needed for the current task. Dispose of conversations and engine resources when leaving the AI workflow or when the app is under memory pressure. Handle app backgrounding, interruptions and process recreation. Never assume Android will keep a background process alive indefinitely.

## 7. LiteRT integration boundary

The current project scaffold includes a LiteRT service concept. Before relying on it:
1. Pin the package version in `pubspec.yaml`.
2. Read that version's official API documentation.
3. Confirm Android ABI, minimum SDK and model format compatibility.
4. Implement model initialization and error handling.
5. Add a visible loading state and cancellation path.
6. Add a test prompt and verify output on the S25 Ultra.
7. Test disposal and repeated model switching.
8. Record measured load time, memory pressure, battery and temperature.

Treat sample API calls as version-sensitive. Do not copy an API signature from a different plugin version without checking.

## 8. Error handling

Use typed application errors where possible:
- model not downloaded;
- unsupported model;
- insufficient storage;
- insufficient memory;
- corrupt/incomplete download;
- permission denied;
- database unavailable;
- network unavailable;
- cancelled operation.

Present plain-language recovery steps to the user and keep technical details in diagnostic logs. Do not log interview contents, credentials or sensitive location data by default.

## 9. Security

- Store secrets in secure platform storage or a server-side secret manager.
- Never commit API keys, signing keys or personal tokens.
- Use HTTPS for network transfers.
- Ask before uploading, publishing, sharing location or deleting data.
- Apply least-privilege permissions.
- Keep consent and usage restrictions attached to media and derived assets.
- Provide a clear export and deletion policy.

## 10. Testing strategy

Unit tests:
- field-entry validation;
- repository operations;
- serialization;
- agent permission decisions.

Integration tests:
- create/save/reopen an entry;
- import media;
- interrupted model download;
- model load and dispose;
- offline capture;
- backup and restore.

Device tests:
- S25 Ultra;
- airplane mode;
- low storage;
- app background/foreground;
- thermal load after repeated inference;
- Android permission denial and later re-approval.

## 11. Pull request checklist

- [ ] One focused change.
- [ ] Formatting and analysis pass.
- [ ] Tests added or updated.
- [ ] No secrets or personal data.
- [ ] Offline path remains functional.
- [ ] Documentation updated.
- [ ] Real-device verification stated honestly.
