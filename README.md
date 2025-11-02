# Labs Tracker

A 100% offline Flutter app for iOS and Android that tracks lab attendance, sick notes, make-up sessions, and exam eligibility with a glassmorphism design.

![Flutter](https://img.shields.io/badge/Flutter-3.24-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.1+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![CI](https://github.com/Zyrex24/labs-tracker/workflows/Flutter%20CI/badge.svg)

## Features

### Core functionality

- Subject management with required lab counts  
- Lab sessions: schedule regular and make-up sessions  
- Attendance tracking: mark sessions as attended or missed; submit sick notes  
- Sick notes: attach photos/PDFs and auto-create make-up sessions  
- Make-up sessions: schedule and track attendance  
- Exam management: track exam dates and registration status  
- Summary and reports: eligibility status and PDF export  
- Notifications: reminders for upcoming sessions  
- Backup and restore: export/import all data including attachments

### Technical highlights

- 100% offline: no network calls, no analytics, no remote services  
- Clean architecture with repositories, DAOs, and state management  
- Riverpod for state management  
- Drift (SQLite) with migrations and type-safe queries  
- Glassmorphism UI with animated gradients  
- Null safety throughout  
- Production-ready error handling, validation, and user feedback

## Design

The UI uses a glassmorphism style:

- Frosted glass surfaces with backdrop blur  
- Animated gradient backgrounds  
- Translucent cards and chips  
- Smooth transitions and animations  
- Light and dark mode support

## Architecture

```
lib/
├── app/                    # App-level configuration
│   ├── glass/             # Glassmorphism widgets
│   ├── router/            # Navigation
│   └── theme/             # Gradients and glass theme
├── core/                   # Core utilities
│   ├── constants/         # App constants
│   ├── notifications/     # Notification service
│   └── utils/             # Utilities (date, result)
├── data/                   # Data layer
│   ├── db/                # Drift database, tables, DAOs
│   ├── repos/             # Repositories
│   └── storage/           # File service
├── domain/                 # Business logic
│   ├── attendance_state.dart
│   └── attendance_state_machine.dart
├── features/               # Feature modules
│   ├── calendar/          # Calendar view
│   ├── exams/             # Exams management
│   ├── sessions/          # Lab sessions
│   ├── settings/          # App settings
│   ├── sicknotes/         # Sick notes
│   ├── subjects/          # Subjects management
│   └── summary/           # Summary and PDF export
└── main.dart
```

## Dependencies

### Core

- `flutter_hooks`, `hooks_riverpod`  
- `drift`, `sqlite3_flutter_libs`  
- `path_provider`

### Features

- `file_picker`, `image_picker`  
- `flutter_local_notifications`, `timezone`  
- `archive`, `share_plus`  
- `pdf`, `printing`

### Utilities

- `intl`  
- `uuid`

## Getting started

### Prerequisites

- Flutter SDK 3.24 or higher  
- Dart SDK 3.1 or higher  
- Android Studio (SDK and AVD for Android builds)  
- Xcode (macOS only, for iOS builds)

### Installation

1. Clone the repository

   ```bash
   git clone https://github.com/Zyrex24/labs-tracker.git
   cd labs-tracker
   ```

2. Install dependencies

   ```bash
   flutter pub get
   ```

3. Generate Drift code

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. Run the app

   ```bash
   flutter run
   ```

## Building for release

### Android

For local signed builds, see `android/README_SIGNING.md` for keystore setup.

```bash
# Unsigned APK (testing)
flutter build apk --release

# Signed APK (requires key.properties)
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS (macOS only)

See `ios/README_SIGNING.md` for signing setup.

```bash
# Unsigned build
flutter build ipa --no-codesign

# Signed build (requires Xcode configuration)
flutter build ipa --release
```

## Usage

1. Add subjects

   Use the Subjects screen to add name, code, and required lab count.

2. Schedule lab sessions

   In a subject, add regular sessions with date, time, location, and slot.

3. Track attendance

   Sessions become "Due" within the configured window (default ±2 hours).

   Mark as Attended or Missed, or submit a sick note with an attachment.

4. Handle sick notes

   Submitting a sick note auto-creates a make-up session.

   Schedule the make-up date/time and mark it as attended when completed.

5. View summary

   Review eligibility per subject and export a PDF summary.

   Track exam registration status.

6. Backup and restore

   Export creates a ZIP with database JSON and attachments.

   Import restores all data from a ZIP.

## Testing

Run all tests:

```bash
flutter test
```

Run specific tests:

```bash
flutter test test/unit/attendance_state_machine_test.dart
flutter test test/widget/subject_crud_test.dart
```

Coverage includes:

* Unit tests for the state machine and business logic
* Widget tests for main user flows
* DAO tests for database operations

## Platform support

| Platform | Minimum version | Target version |
| -------- | --------------- | -------------- |
| Android  | API 21 (5.0)    | API 34 (14.0)  |
| iOS      | 13.0            | Latest         |

## Privacy

Labs Tracker is offline-only:

* No internet connection required
* No analytics or tracking
* No data sent to external servers
* All data stored locally on the device
* No network permissions in manifests (verified in CI)

## Continuous integration

GitHub Actions builds an unsigned release APK on every push to verify the project compiles:

* Workflow: `.github/workflows/flutter-ci.yml`
* Artifacts are available in the Actions tab after each run
* No signing keys required for CI builds

## Development

### Code generation

When modifying Drift tables or DAOs:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Database migrations

Migrations live in `lib/data/db/app_database.dart`. Example:

```dart
onUpgrade: (Migrator m, int from, int to) async {
  if (from == 1 && to == 2) {
    await m.addColumn(subjects, subjects.colorHex);
  }
}
```

### Adding new features

1. Create a feature folder in `lib/features/`
2. Add screens, widgets, and dialogs
3. Create a repository if needed
4. Add Riverpod providers
5. Wire up navigation

## State machine

Attendance status transitions:

```
not_ready → due → attended
                → missed → sick_pending → sick_submitted → makeup_scheduled → makeup_attended
```

Rules:

* Sessions enter "due" within the configured window (±N hours)
* Sick note submission auto-creates a make-up session
* Eligibility: (attended + makeup_attended) ≥ labs_required

## Customization

### Gradients

Edit `lib/app/theme/gradients.dart`:

```dart
static const primary = LinearGradient(
  colors: [Color(0xFF6A85F1), Color(0xFFB06AB3)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

### Glass theme

Adjust opacity, blur, and radii in `lib/app/theme/glass_theme.dart`:

```dart
static const double opacityElevation1 = 0.12;
static const double blurMedium = 16.0;
static const double radiusLarge = 20.0;
```

## Troubleshooting

### Build runner

```bash
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Database

* Delete app data and reinstall
* Review migration logic in `app_database.dart`

### Notifications

* Ensure permissions are granted in device settings
* Check timezone initialization in `main.dart`

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit changes: `git commit -m "Describe your change"`
4. Push the branch: `git push origin feature/your-feature`
5. Open a pull request

Do not commit signing keys, keystores, or `key.properties`.

Run `dart run build_runner build` after modifying Drift tables.

Ensure CI passes before requesting review.

## Support

For issues or questions, open an issue on GitHub.
