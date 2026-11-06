# 07 — Troubleshooting and Recovery

## 1. Flutter command not found

Symptoms: `flutter` is not recognized or command not found.  
Actions:
1. Confirm Flutter SDK was extracted/installed.
2. Add its `bin` directory to PATH.
3. Open a new terminal.
4. Run `flutter --version`.
5. Run `flutter doctor -v`.

## 2. Android device not detected

1. Unlock the phone.
2. Confirm USB debugging is enabled.
3. Approve the RSA prompt.
4. Try a known data cable and another USB port.
5. Run `adb devices`.
6. Revoke USB debugging authorizations on the phone and reconnect if necessary.

## 3. Dependency resolution failure

Capture the exact `flutter pub get` error. Check SDK constraints and package versions. Avoid changing multiple dependencies at once. Use `flutter clean` only when stale build output is suspected.

## 4. APK build failure

Run:
```bash
flutter doctor -v
flutter analyze
flutter build apk --release -v
```

Inspect the first meaningful Gradle/Dart error, not only the final “build failed” line. Check Java/Gradle compatibility and Android SDK installation.

## 5. App crashes on launch

- capture `adb logcat`;
- identify the first exception and stack trace;
- check manifest and runtime permissions;
- reproduce after a clean install;
- test without optional AI components to isolate the issue.

## 6. Model download fails

Check:
- connection stability;
- free storage;
- exact model URL and filename;
- server response;
- download cancellation/partial file handling;
- checksum or size validation.

Do not mark a partial file as installed. Retry only after removing or safely resuming the incomplete temporary file.

## 7. Model does not load

Check:
- model format matches runtime;
- package/runtime version;
- device ABI and Android requirements;
- file is complete and readable;
- sufficient available memory;
- other applications consuming memory.

Try the smaller fallback model. Capture the full native error log. Do not repeatedly retry a failing large model without changing the conditions.

## 8. Slow inference or thermal warning

Reduce prompt/context length, use a smaller model, close unnecessary apps, allow the device to cool, and avoid sustained inference while charging in hot conditions. Record measurements before making performance claims.

## 9. Offline features fail

Test the local database independently from network services. Search for code paths that assume an API response before saving. Local capture must save first and sync later.

## 10. Notes disappear

Stop using the device for further writes if data corruption is suspected. Check app storage and backups. Do not uninstall or clear app data before attempting recovery. For database migrations, test against a copy before applying repair steps.

## 11. Hermes unavailable in background

Android battery management may suspend Termux. Check current Android battery settings and Termux's official guidance. Do not rely on a background agent for safety-critical or time-critical operations.

## 12. Diagnostic bundle

When reporting a bug, include:
- app version/commit;
- phone model and Android version;
- steps to reproduce;
- expected vs actual result;
- exact error message;
- relevant redacted logs;
- network/offline state;
- model/runtime version, if applicable.

Remove API keys, personal data, interview content and precise coordinates before sharing logs.
