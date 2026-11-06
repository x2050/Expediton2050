# Build and install on Galaxy S25 Ultra

## Recommended: GitHub Actions
After the source is committed to the `main` branch, GitHub Actions builds the release APK using `.github/workflows/android-apk.yml`.
Open the repository's Actions tab, select the latest successful `Build Android APK` run, and download the `expedition-aurelio-s25-release` artifact.

## Build locally
Install Flutter stable, Android Studio / Android SDK, and Java 17+.

```bash
# Check that the Android toolchain is configured.
flutter doctor

# Generate platform files if this repository has only Dart source.
flutter create --platforms=android --org org.expeditionaurelio .

# Resolve dependencies, analyze, and run on the phone.
flutter pub get
flutter analyze
flutter devices
flutter run

# Build the release APK.
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`.

## Phone setup
1. Settings → About phone → Software information → tap Build number seven times.
2. Developer options → enable USB debugging.
3. Connect phone and authorize the computer.
4. Run `flutter devices`, then `flutter run`.

## Model
Weights are downloaded separately after install. Gemma 4 E2B is approximately 2.46 GB; E4B approximately 3.40 GB. Keep several additional GB free for runtime memory and temporary files. Do not put weights in APK assets.

## Validation checklist
- Cold start in airplane mode.
- Save and reopen field notes offline.
- Download a model on Wi-Fi.
- Load/unload without crashing.
- Test 10-minute inference for thermal and memory pressure.
- Confirm media never uploads without explicit action.
