# 01 — Installation Guide

## 1. Purpose

Set up the development environment, obtain the source, run the Flutter app, and prepare a repeatable Android build. The instructions cover Windows PowerShell and Ubuntu/Linux. Commands are shown separately because shell syntax differs.

## 2. Prerequisites

- A computer with internet access for initial tool installation.
- Git.
- Flutter SDK on the stable channel.
- Android Studio with Android SDK and platform tools.
- VS Code (optional, recommended).
- Samsung Galaxy S25 Ultra and a USB data cable for device testing.
- Adequate free disk space for Android SDKs, build caches and model downloads.

**Keep model files out of the APK.** Download model files separately into app-private storage. This keeps the APK smaller and allows model updates independently.

## 3. Install and verify Git

Windows PowerShell:
```powershell
git --version
```

Ubuntu:
```bash
sudo apt update
sudo apt install -y git
git --version
```

If Git is missing on Windows, install Git for Windows, reopen PowerShell, and retry.

## 4. Install Flutter

Follow the current official Flutter installation instructions for your operating system. Install the stable channel and add the Flutter `bin` directory to PATH.

Verify:
```bash
flutter --version
dart --version
flutter doctor -v
```

Resolve the Android toolchain warnings shown by `flutter doctor -v`. Accept Android SDK licences:
```bash
flutter doctor --android-licenses
```

Do not assume a successful `flutter doctor` means the application itself compiles; it only verifies the local toolchain.

## 5. Install Android Studio and SDK tools

In Android Studio → Settings → Languages & Frameworks → Android SDK:
- install the Android SDK platform required by the project's Gradle configuration;
- install Android SDK Build-Tools;
- install Android SDK Platform-Tools;
- install Android SDK Command-line Tools.

Verify device bridge:
```bash
adb version
```

## 6. Obtain the source

Repository currently associated with this project:
`https://github.com/x2050/Expediton2050`

The repository name contains the spelling `Expediton2050`. Confirm the URL before cloning.

```bash
git clone https://github.com/x2050/Expediton2050.git
cd Expediton2050
```

If using the supplied ZIP instead:
1. Download the source ZIP.
2. Extract it into a normal development folder.
3. Open the extracted project root (the folder containing `pubspec.yaml`).
4. Do not run Flutter commands from a parent folder.

## 7. Resolve Flutter dependencies

From the project root:
```bash
flutter pub get
```

If dependency resolution fails:
```bash
flutter clean
flutter pub get
```

If it still fails, capture the complete error output and check package compatibility and the Flutter/Dart SDK constraints. Do not randomly upgrade all dependencies.

## 8. Connect the S25 Ultra

On the phone:
1. Open Settings → About phone → Software information.
2. Tap Build number seven times to enable Developer options.
3. Open Developer options.
4. Enable USB debugging.
5. Connect the phone using a data-capable USB cable.
6. Approve the computer's RSA debugging prompt.

On the computer:
```bash
adb devices
flutter devices
```

The phone should appear as an authorized device. If it says `unauthorized`, unlock the phone and approve the prompt. If no device appears, try another cable/USB port and set USB mode to file transfer.

## 9. Run the app

```bash
flutter run
```

For verbose diagnostics:
```bash
flutter run -v
```

To list connected devices:
```bash
flutter devices
```

## 10. Build an APK

Debug APK:
```bash
flutter build apk --debug
```

Release APK:
```bash
flutter build apk --release
```

Expected default output:
`build/app/outputs/flutter-apk/app-release.apk`

The actual output path can change if the Gradle configuration or build flavours change. Confirm the file exists before sharing it.

## 11. Install and verify the APK

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

On the phone:
- launch the app;
- grant only permissions required by the feature being tested;
- create a field note;
- force-close and reopen the app;
- confirm the note persists;
- enable airplane mode and repeat the offline note test.

## 12. Release signing

For a public release, configure a private signing key and keep it outside Git. Store secrets in the CI secret manager, not in source code or documentation. Back up the keystore securely. Losing the signing key can prevent seamless updates to an installed Android app.

## 13. First-run acceptance test

- [ ] App launches without crashing.
- [ ] Local field note can be created.
- [ ] Note survives app restart.
- [ ] App works in airplane mode for offline features.
- [ ] Permission prompts appear only when needed.
- [ ] Model download reports progress and handles interruption.
- [ ] Model load is tested separately from download.
- [ ] No API keys, passwords or signing keys are committed.
