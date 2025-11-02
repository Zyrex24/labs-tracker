# Labs Tracker

A 100% offline Flutter app for iOS & Android that tracks lab attendance, sick notes, make-up sessions, and exam eligibility with a beautiful glassmorphism design.

![Flutter](https://img.shields.io/badge/Flutter-3.24-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.1+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![CI](https://github.com/YOUR_USERNAME/labs_tracker/workflows/Flutter%20CI/badge.svg)

## ✨ Features

### Core Functionality
- **📚 Subject Management**: Track multiple subjects with required lab counts
- **📅 Lab Sessions**: Schedule regular and make-up lab sessions
- **✅ Attendance Tracking**: Mark sessions as attended, missed, or submit sick notes
- **🏥 Sick Notes**: Attach photos/PDFs of sick notes and auto-create make-up sessions
- **📝 Make-up Sessions**: Schedule and track make-up lab attendance
- **🎓 Exam Management**: Track exam dates and registration status
- **📊 Summary & Reports**: View eligibility status and export PDF summaries
- **🔔 Notifications**: Get reminders for upcoming lab sessions
- **💾 Backup & Restore**: Export/import all data including attachments

### Technical Highlights
- **100% Offline**: No network calls, no analytics, no remote services
- **Clean Architecture**: Separation of concerns with repositories, DAOs, and state management
- **Riverpod State Management**: Reactive, testable state management
- **Drift (SQLite)**: Local database with migrations and type-safe queries
- **Glassmorphism UI**: Modern, beautiful frosted glass design with animated gradients
- **Null Safety**: Full null safety support
- **Production Ready**: Error handling, validation, and user feedback

## 🎨 Design

The app features a stunning **glassmorphism** design with:
- Frosted glass surfaces with backdrop blur
- Animated gradient backgrounds
- Translucent cards and chips
- Smooth transitions and animations
- Light/dark mode support

## 🏗️ Architecture

```
lib/
├── app/                    # App-level configuration
│   ├── glass/             # Glassmorphism widgets
│   ├── router/            # Navigation
│   └── theme/             # Gradients & glass theme
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
│   └── summary/           # Summary & PDF export
└── main.dart
```

## 📦 Dependencies

### Core
- `flutter_hooks` & `hooks_riverpod` - State management
- `drift` & `sqlite3_flutter_libs` - Local database
- `path_provider` - File storage

### Features
- `file_picker` & `image_picker` - File selection
- `flutter_local_notifications` & `timezone` - Notifications
- `archive` & `share_plus` - Backup/restore
- `pdf` & `printing` - PDF generation

### Utilities
- `intl` - Internationalization
- `uuid` - Unique IDs

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.24 or higher
- Dart SDK 3.1 or higher
- Android Studio (SDK + AVD for Android builds)
- Xcode (Mac only, for iOS builds)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/labs_tracker.git
   cd labs_tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Drift code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Release

#### Android
For local signed builds, see `android/README_SIGNING.md` for keystore setup.

```bash
# Unsigned APK (for testing)
flutter build apk --release

# Signed APK (requires key.properties)
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

#### iOS (Mac only)
See `ios/README_SIGNING.md` for signing setup.

```bash
# Unsigned build
flutter build ipa --no-codesign

# Signed build (requires Xcode configuration)
flutter build ipa --release
```

## 🎯 Usage

### 1. Add Subjects
- Tap the "+" button on the Subjects screen
- Enter subject name, code, and required lab count

### 2. Schedule Lab Sessions
- Navigate to a subject
- Tap "Add Session"
- Set date, time, location, and slot

### 3. Track Attendance
- Sessions become "Due" within the configured window (default ±2 hours)
- Mark as Attended or Missed
- Submit sick notes with photo/PDF attachments

### 4. Handle Sick Notes
- When you submit a sick note, a make-up session is auto-created
- Schedule the make-up session date/time
- Mark the make-up session as attended when complete

### 5. View Summary
- Check eligibility status per subject
- Export PDF summary for records
- View exam registration status

### 6. Backup & Restore
- Export: Creates a ZIP with database JSON and attachments
- Import: Restores all data from a backup ZIP

## 🧪 Testing

### Run all tests
```bash
flutter test
```

### Run specific test files
```bash
flutter test test/unit/attendance_state_machine_test.dart
flutter test test/widget/subject_crud_test.dart
```

### Test Coverage
- Unit tests for state machine and business logic
- Widget tests for key user flows
- DAO tests for database operations

## 📱 Platform Support

| Platform | Minimum Version | Target Version |
|----------|----------------|----------------|
| Android  | API 21 (5.0)   | API 34 (14.0)  |
| iOS      | 13.0           | Latest         |

## 🔒 Privacy

Labs Tracker is **100% offline** and respects your privacy:
- ✅ No internet connection required
- ✅ No analytics or tracking
- ✅ No data sent to external servers
- ✅ All data stored locally on your device
- ✅ No network permissions in manifests (verified in CI)

## 🔄 Continuous Integration

GitHub Actions automatically builds an unsigned release APK on every push to verify the project compiles:
- Workflow: `.github/workflows/flutter-ci.yml`
- Artifacts available in Actions tab after each run
- No signing keys required for CI builds

## 🛠️ Development

### Code Generation
When you modify Drift tables or DAOs, regenerate code:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Database Migrations
Migrations are defined in `lib/data/db/app_database.dart`. Example:
```dart
onUpgrade: (Migrator m, int from, int to) async {
  if (from == 1 && to == 2) {
    await m.addColumn(subjects, subjects.colorHex);
  }
}
```

### Adding New Features
1. Create feature folder in `lib/features/`
2. Add screen, widgets, and dialogs
3. Create repository if needed
4. Add Riverpod providers
5. Wire up navigation

## 📝 State Machine

The app uses a pure state machine for attendance status transitions:

```
not_ready → due → attended
                → missed → sick_pending → sick_submitted → makeup_scheduled → makeup_attended
```

Rules:
- Sessions become "due" within the configured window (±N hours)
- Sick note submission auto-creates a make-up session
- Eligibility = (attended + makeup_attended) >= labs_required

## 🎨 Customization

### Gradients
Edit `lib/app/theme/gradients.dart` to customize background gradients:
```dart
static const primary = LinearGradient(
  colors: [Color(0xFF6A85F1), Color(0xFFB06AB3)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

### Glass Theme
Adjust opacity, blur, and colors in `lib/app/theme/glass_theme.dart`:
```dart
static const double opacityElevation1 = 0.12;
static const double blurMedium = 16.0;
static const double radiusLarge = 20.0;
```

## 🐛 Troubleshooting

### Build Runner Issues
```bash
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Database Issues
- Delete app data and reinstall
- Check migration logic in `app_database.dart`

### Notification Issues
- Ensure permissions are granted in device settings
- Check timezone initialization in `main.dart`

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

**Important:**
- Do NOT commit signing keys, keystores, or `key.properties`
- Run `dart run build_runner build` after modifying Drift tables
- Ensure CI passes before requesting review

## 📧 Support

For issues, questions, or suggestions, please open an issue on GitHub.

---

**Built with ❤️ using Flutter**
