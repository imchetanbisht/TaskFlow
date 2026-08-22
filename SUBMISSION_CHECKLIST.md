# TaskFlow — Submission Checklist

The assignment requires the following submission artifacts:

## 1. GitHub Repository — REQUIRED
Must contain:
- Complete Flutter source
- README.md
- Tests
- Mock data asset
- Clean, meaningful commit history

## 2. Architecture Document — REQUIRED
`architecture.md` should cover:
- Application architecture
- State management
- Data layer
- Simulated auth
- Local storage
- Error handling
- Navigation
- Key decisions
- Architecture diagram

## 3. README — REQUIRED
Must explain:
- Project/architecture
- Folder structure
- State management
- Mock data
- Error/delay/offline simulation
- Auth/token flow
- Setup/version
- Run/test/build commands
- Error/offline triggers
- Limitations and trade-offs

## 4. Setup Instructions — REQUIRED
`SETUP.md` with:

```bash
flutter pub get
flutter run
flutter test
flutter build apk --release
```

## 5. Test Credentials — REQUIRED
`TEST_CREDENTIALS.md` with:
- Org A Admin
- Org A Member
- Org B Admin
- Org B Member

Credentials must come from `auth_mock`.

## 6. Screen Recording — REQUIRED
5–10 minutes demonstrating:
1. Login
2. Projects
3. Project details
4. Tasks
5. Create/edit task
6. Assignment
7. Status/priority update
8. Simulated error
9. Offline mode
10. Logout
11. Architecture explanation

## 7. Release APK — REQUIRED TO GENERATE

```bash
flutter build apk --release
```

## 8. Automated Tests — REQUIRED
Unit:
- auth/session
- token refresh
- filtering
- validation
- business/state logic

Widget:
- login validation
- task loading/empty/error/success
- status update

Integration:
- login
- project listing
- task listing
- create/update task
- assignment

## Final Checklist

- [ ] GitHub repository
- [ ] Clean meaningful commits
- [ ] README
- [ ] architecture.md
- [ ] SETUP.md
- [ ] TEST_CREDENTIALS.md
- [ ] Mock JSON asset
- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests
- [ ] Error simulation
- [ ] Offline simulation
- [ ] Release APK
- [ ] Screen recording
- [ ] Known limitations
- [ ] No secrets committed
