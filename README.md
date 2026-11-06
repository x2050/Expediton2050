# Expedition Aurélio — S25 Ultra Production Starter

A local-first Android documentary field companion built with Flutter.

## Selected deployment
- Phone: Samsung Galaxy S25 Ultra (ARM64)
- App: Flutter Android
- Local model runtime: LiteRT-LM through `flutter_litert_lm`
- Model choices: Gemma 4 E2B + E4B; Qwen3 0.6B lightweight fallback
- Agent runtime: Hermes in Termux, optional companion process
- Interface: expedition journal / cream paper / vermilion / charcoal

## Important build status
This is a source implementation package, **not a compiled APK**. Flutter/Dart SDK and Android SDK are not installed in the build environment used to create this archive. Build the APK on your ThinkPad or another machine with Flutter and Android SDK.

## Build
```bash
# Install Flutter stable and Android Studio/SDK first.
flutter doctor

# From this project directory:
flutter create --platforms=android --org org.expeditionaurelio .
flutter pub get
flutter run

# Release APK:
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Model handling
Model weights are downloaded separately into app-private storage. They are not bundled in the APK. The download manager checks the expected minimum file size before marking a model ready. Review the official Hugging Face model card and license before distribution.

Default choices:
- Gemma 4 E2B: `litert-community/gemma-4-E2B-it-litert-lm` / `gemma-4-E2B-it.litertlm`
- Gemma 4 E4B: `litert-community/gemma-4-E4B-it-litert-lm` / `gemma-4-E4B-it.litertlm`
- Qwen3 0.6B: `litert-community/Qwen3-0.6B` / `Qwen3-0.6B.litertlm`

## Hermes on Termux
Install Termux from its official F-Droid/GitHub distribution, then follow `docs/HERMES_TERMUX.md`. Hermes runs separately from the APK. The app's capture and local archive must work without Hermes.

## Architecture boundaries
- Flutter: user interface and workflows
- SQLite: offline records
- LiteRT-LM: on-device model inference
- Hermes: optional tool-using agent runtime
- MCP: tool interoperability for approved operations
- n8n: optional network automation
- Hugging Face: model distribution only, not inference quota

## Security
No arbitrary shell execution from model output. All tools are allow-listed and validated. Network actions require visible user confirmation. Never upload media automatically. Consent and publication permission are separate.


## Dashboard implementation update

The dashboard now uses a multi-expedition structure:
- mission switcher and create-expedition flow;
- mission-scoped field notes;
- shared Living Memory archive view;
- bottom navigation for Home, Journal, Archive and AI Lab;
- parchment / charcoal / vermilion theme;
- local SQLite schema migration from database version 1 to 2.

### Current functional boundaries

- Field-note creation and local persistence are wired to SQLite.
- Mission records are seeded locally and new missions can be created.
- Interview and camera dashboard actions currently explain that their capture workflows are not yet implemented.
- The AI Lab can download a selected model using the existing model manager. This is not yet a complete inference/chat experience.
- This source has not been compiled or device-tested in this environment because Flutter/Dart SDKs are unavailable here.
