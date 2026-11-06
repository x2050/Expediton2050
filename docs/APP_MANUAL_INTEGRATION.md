# 09 — Add the Manual to the Flutter App (Offline)

## Goal

Bundle the Markdown manuals into the APK so the operator can read them without internet. This guide describes the integration work; it does not claim that a manual reader is already implemented.

## 1. Copy files

Copy the contents of `assets/manual/` into the Flutter project's `assets/manual/` directory. Keep the canonical editable copies in `docs/`.

## 2. Declare assets

Add the following under the existing `flutter:` section in `pubspec.yaml` (merge with existing declarations; do not create a second `flutter:` key):

```yaml
flutter:
  assets:
    - assets/manual/
```

If the project already declares assets, add this directory to the existing list.

## 3. Choose a Markdown renderer

Select and pin a maintained Flutter Markdown renderer compatible with the project's Flutter/Dart version. Review its licence and accessibility behavior. Run `flutter pub get`.

## 4. Build a manual index

Create an index containing:
- title;
- chapter ID;
- asset path;
- short description;
- reading order.

Keep the index in source control. Do not build paths from arbitrary user input.

## 5. Add a Manual screen

Recommended UI:
- searchable chapter list;
- chapter reader with headings and code blocks;
- copy-command action;
- previous/next chapter navigation;
- offline indicator;
- version and last-updated label.

The reader should load bundled assets using Flutter's asset bundle, not fetch a web page.

## 6. Verify offline behavior

1. Install the APK.
2. Enable airplane mode.
3. Open the Manual screen.
4. Open every chapter.
5. Confirm diagrams/images (if bundled) render.
6. Copy a command and verify it is complete.
7. Force-close and reopen the app.
8. Confirm the manual remains available.

## 7. Keep documentation synchronized

When a chapter changes:
- update `docs/`;
- update the offline copy in `assets/manual/`;
- update the version/date;
- run a link and asset-path check;
- rebuild and test the APK.

## 8. Important limitation

Bundling Markdown files does not itself create a reader screen. A Flutter UI, asset declaration and Markdown renderer must be implemented and tested before the manual is genuinely accessible inside the app.
