# Daily Routine

Personal Flutter routine & task manager backed by **your** Google Spreadsheet (and later Google Calendar). v1 scaffold: Schedule / To-Do / Summary tabs, Riverpod, Sheets service seam with a fake offline impl.

## Features (v1)

- **Schedule** — Current Focus banner (now vs weekday template), Mon–Sun weekday editor with energy tags (`low` / `high`)
- **To-Do** — checkable tasks persisted through the Sheets service interface
- **Summary** — day/week incomplete lists + sticky-task nudge stub
- **Stubs** — Calendar busy intervals, FocusOverride % slider placeholder; **no** Live Activity / WidgetKit yet

Editing a weekday template updates that weekday for **all upcoming weeks**, unless a calendar event (or day override) forces a one-day exception.

## Prerequisites

- Flutter SDK 3.13+ (`flutter doctor`)
- Android Studio / Xcode for device or emulator runs
- (Optional for live Sheets) Google Cloud project + OAuth client

## Run (offline UI — default)

The app boots against `FakeSheetsService` and `FakeCalendarService`, so you can explore the UI without Google credentials:

```bash
flutter pub get
flutter run
```

To analyze:

```bash
flutter analyze
flutter test
```

## Google Cloud OAuth (live Sheets)

1. Open [Google Cloud Console](https://console.cloud.google.com/) and create (or select) a project.
2. Enable **Google Sheets API** (and later **Google Calendar API** for v2).
3. Configure **OAuth consent screen** (External or Internal). Add scopes:
   - `https://www.googleapis.com/auth/spreadsheets`
   - (v2) `https://www.googleapis.com/auth/calendar.readonly`
4. Create **OAuth client IDs**:
   - **iOS**: Bundle ID matching `ios/Runner` (default `com.pratikeshsingh.toDoRoutine`)
   - **Android**: package `com.pratikeshsingh.to_do_routine` + SHA-1 of your debug/release keystore
5. Wire client IDs into the Google Sign-In plugin (see [google_sign_in](https://pub.dev/packages/google_sign_in) platform setup).
6. In `lib/providers/service_providers.dart`, swap `FakeSheetsService()` for `GoogleSheetsService(spreadsheetId: '<YOUR_SHEET_ID>')` once sign-in works.

The spreadsheet ID is the long id in the Sheet URL:  
`https://docs.google.com/spreadsheets/d/<SPREADSHEET_ID>/edit`

## Spreadsheet column setup

Create a spreadsheet you own, then two sheets (tabs) with **header row exactly**:

### `RoutineBlocks`

| id | title | weekday | startTime | endTime | themeColor | energyTag |
|----|-------|---------|-----------|---------|------------|-----------|
| blk-1 | Studying AI | 0 | 09:00 | 12:00 | #C47B4A | high |

- `weekday`: `0` = Monday … `6` = Sunday
- `startTime` / `endTime`: `HH:mm` (24h) or minutes from midnight
- `energyTag`: `low` or `high`

### `Tasks`

| id | title | isCompleted | createdAt | recurrenceHint |
|----|-------|-------------|-----------|----------------|
| task-1 | Update resume | false | 2026-11-01T10:00:00.000Z | |

- `isCompleted`: `true` / `false`
- `createdAt`: ISO-8601
- `recurrenceHint`: optional (e.g. `weekly`)

Later sheets (v2): `FocusOverrides`, day overrides as needed.

## Project layout

```
lib/
  app.dart / main.dart
  models/           # RoutineBlock, TaskItem, FocusOverride, BusyInterval
  services/
    sheets/         # SheetsService + Fake + GoogleSheetsService
    calendar/       # CalendarService + Fake (busy seam)
  providers/        # Riverpod
  features/
    shell/          # Tab navigation
    schedule/       # Focus banner + weekday editor
    todo/
    summary/
    focus/          # % slider placeholder
```

## Focus themes (seed / product)

1. Applying jobs — low  
2. Vriendtime app — low  
3. Channel videos — time-consuming  
4. Studying AI — high  
5. AI blogs — high  

## Out of scope (v1)

- Live Activity / home-screen widgets  
- Live Google Calendar sync (interface + fake only)  
- Full focus % planner productization  

## License

Private / personal use unless otherwise noted.
