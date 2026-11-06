# Dashboard Implementation Notes

## Product decision

Expedition Aurélio is a multi-expedition command centre. A single Living Memory archive spans multiple missions, while field entries are associated with one mission.

## Implemented in this source revision

- Mission entity and SQLite table.
- Version-1 to version-2 database migration adding `mission_id` to field entries.
- Three seed missions: Northern Thailand, Brazilian Cordel and European Energy.
- Create-expedition dialog.
- Mission selector on dashboard and journal.
- Mission-scoped notes and shared archive list.
- Bottom navigation: Home, Journal, Archive and AI Lab.
- Parchment / charcoal / vermilion Material 3 theme.
- Local field-note creation and persistence.

## Explicitly not implemented yet

- Camera capture workflow.
- Interview/audio recording workflow.
- GPS capture and consent-management UI.
- Local model load/inference/chat screen.
- Full-text archive search and media ingest.
- In-app Markdown manual reader.

Dashboard tiles for camera and interview currently display an explanatory notice instead of pretending to record media.

## First device verification

From the Flutter project root:
```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run
```

Test an existing version-1 database upgrade with a backup/copy before installing over valuable field data. Verify that previous notes are retained and assigned to the default `northern-thailand` mission.

## Acceptance checks

- [ ] App launches with parchment theme.
- [ ] Three starter missions appear.
- [ ] User can create a new mission.
- [ ] Switching mission changes journal entries.
- [ ] New notes save to the selected mission.
- [ ] Notes persist after app restart.
- [ ] Archive displays records across missions.
- [ ] Airplane-mode note creation and browsing work.
- [ ] AI Lab model download state is accurate.
- [ ] Camera/interview notices do not imply capture is implemented.
