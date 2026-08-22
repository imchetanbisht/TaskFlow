# TaskFlow — Setup Instructions

## 1. Prerequisites
- Flutter SDK
- Android Studio
- Android SDK
- Android emulator or physical Android device

Verify:

```bash
flutter doctor
```

## 2. Record Versions

```bash
flutter --version
dart --version
```

Fill in:

```text
Flutter: <version>
Dart: <version>
```

## 3. Clone

```bash
git clone <GITHUB_REPOSITORY_URL>
cd TaskFlow
```

## 4. Install Dependencies

```bash
flutter pub get
```

## 5. Verify Mock Asset

The file should be:

```text
assets/mock_data/TaskFlow-MockData.json
```

and registered in `pubspec.yaml`.

## 6. Run

```bash
flutter run
```

## 7. Test

```bash
flutter test
```

Run integration tests using the integration-test configuration included in the repository.

## 8. Release APK

```bash
flutter build apk --release
```

Expected output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## 9. Simulated Error Testing

Document the exact final triggers:

```text
404 / Task Not Found:
<steps>

Timeout:
<steps>

Validation Error:
<steps>

Offline:
<steps>
```

Verify that errors are user-friendly and retryable where appropriate.

## 10. Final Checks

Run:

```bash
flutter pub get
flutter run
flutter test
flutter build apk --release
```

Also verify no secrets, passwords or tokens are committed/logged.
