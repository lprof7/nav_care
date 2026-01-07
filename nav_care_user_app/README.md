# Nav Care User App

User-facing mobile app to browse hospitals, doctors, and services, book appointments, and communicate with providers.

## What it does
- Browse hospitals, doctors, services, and service offerings
- Create and view appointments
- Sign in, sign up, and reset password
- Chat and notifications
- Localization (AR/EN/FR)

## What it does not do (currently)
- No internal admin dashboard
- No separate entrypoints per environment (manual switch)

## Requirements
- Flutter 3.4.3+
- Dart SDK >= 3.4.3
- Android Studio / Xcode depending on platform
- Firebase configured (project files included)

## Run locally (Dev)
```bash
flutter pub get
flutter run
```

## Useful commands
```bash
# Run tests
flutter test

# Build Android APK
flutter build apk

# Build iOS
flutter build ios

# Generate freezed/json_serializable

dart run build_runner build --delete-conflicting-outputs
```

## Environments and switching
The environment is loaded in `lib/main.dart`:
```dart
await ConfigLoader.load(AppEnv.development);
```
- To switch to production: replace `AppEnv.development` with `AppEnv.production`.
- Env files: `assets/env/.env.development` and `assets/env/.env.production`.

## Documentation structure
- `docs/overview.md` Architecture overview
- `docs/structure.md` Project structure
- `docs/config.md` Config & environments
- `docs/api.md` API & integrations
- `docs/storage.md` Local storage
- `docs/contributing.md` How to add a new feature
