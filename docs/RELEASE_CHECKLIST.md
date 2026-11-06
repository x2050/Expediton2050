# 10 — Release and Documentation Verification Checklist

## Source and build
- [ ] Source repository URL and default branch confirmed.
- [ ] App version and commit SHA recorded.
- [ ] `flutter pub get` succeeds.
- [ ] `dart format` has no unexpected changes.
- [ ] `flutter analyze` passes or known warnings are recorded.
- [ ] `flutter test` passes.
- [ ] Debug APK builds.
- [ ] Release APK builds and is signed appropriately.

## Device
- [ ] Installs on Samsung Galaxy S25 Ultra.
- [ ] Launches after clean install.
- [ ] Field entry save/reopen passes.
- [ ] Airplane-mode capture passes.
- [ ] Permission denial paths are safe.
- [ ] Low-storage behavior is tested.

## AI
- [ ] Model source and licence checked.
- [ ] Download interruption handled.
- [ ] Integrity verification implemented.
- [ ] Load, inference and disposal tested.
- [ ] Offline inference passes.
- [ ] Model memory/thermal behavior recorded.
- [ ] Failure does not block field capture.

## Manual
- [ ] GitHub docs included.
- [ ] Offline manual assets included.
- [ ] Flutter manual reader implemented.
- [ ] Manual opens in airplane mode.
- [ ] Commands tested against the current source.
- [ ] Screenshots correspond to current app version.
- [ ] Known limitations are stated.

## Privacy and safety
- [ ] Consent process documented.
- [ ] No secrets in repository or logs.
- [ ] External uploads require user approval.
- [ ] Location sharing is explicit.
- [ ] Delete/export behavior documented.
- [ ] Backup restore tested.

## Release statement

Only call the application release-ready after the relevant checks have passed on a real target device. A source ZIP, documentation package or successful CI workflow definition is not the same thing as a tested APK.
