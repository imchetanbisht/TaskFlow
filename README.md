# TaskFlow

TaskFlow is a Flutter project-management application built for the TaskFlow technical assignment. It uses the provided `TaskFlow-MockData.json` as a local mock data source; no real backend or REST API is required.

## Features
- Simulated authentication and session check
- Secure mock token storage and simulated refresh
- Organization-scoped projects
- Role-based project authorization
- Project CRUD
- Task CRUD
- Task status/priority updates
- Task assignment/unassignment
- Status, priority, assignee and due-date filters
- Loading, empty and error states
- Simulated errors and offline mode
- Local persistence of loaded project/task data
- Pull-to-refresh
- Unit, widget and integration tests

## Architecture

```text
Presentation
    ↓
State Management
    ↓
Business Logic / Use Cases
    ↓
Repository Interface
    ↓
Repository Implementation
    ↓
Mock Data Source
    ↓
TaskFlow-MockData.json
```

The UI does not read JSON directly. The repository abstraction is designed so the mock source can later be replaced by a real HTTP source.

See `architecture.md` for the complete architecture.

## Folder Structure

```text
lib/
├── core/
├── data/
├── domain/
├── presentation/
└── main.dart

assets/
└── mock_data/
    └── TaskFlow-MockData.json

test/
├── unit/
├── widget/
└── integration_test/
```

## Mock Data

The provided JSON contains:
- organizations
- users
- org_members
- projects
- tasks
- comments
- notifications
- auth_mock

It must be bundled as a Flutter asset and loaded through the data/repository layer.

## Authentication

Credentials are loaded through the data layer. On successful login, mock access/refresh tokens are stored securely. Access-token expiry and a mock refresh flow are demonstrated. Logout clears the session.

Passwords must not be stored and tokens must not be logged.

See `TEST_CREDENTIALS.md`.

## Role-Based Authorization

Supported roles:
- `org_admin`
- `member`

Admin-only actions such as project deletion/member management must be blocked in business logic, not merely hidden from the UI.

## Projects and Tasks

Projects are scoped to the current user's organization. Tasks support CRUD, status/priority updates, assignment/unassignment and filtering.

Assignment must validate that the selected user belongs to the current organization.

## Simulated Errors and Offline Mode

The final implementation must document how to trigger:
- simulated 404/task not found
- simulated timeout
- simulated validation error
- simulated offline mode

Fill the exact UI/debug steps into this README after implementation.

## Setup

See `SETUP.md`.

Required commands:

```bash
flutter pub get
flutter run
flutter test
flutter build apk --release
```

## Flutter / Dart Version

Record the exact final versions:

```text
Flutter: <version>
Dart: <version>
```

## Testing

Minimum required:
- Unit: auth/session, token refresh, filtering, validation, business logic
- Widget: login validation, task loading/empty/error/success, status update
- Integration: login, projects, tasks, create/update task, assignment

## Screen Recording

Create a 5–10 minute recording covering login, projects, tasks, task creation/editing, assignment, status/priority updates, simulated errors, offline mode, logout and a short architecture explanation.

See `SCREEN_RECORDING_SCRIPT.md`.

## Known Limitations

- No real backend/API
- Authentication is simulated
- Data mutations are local/mock
- No production database
- No real-time synchronization

## Submission Checklist

- [ ] GitHub repository
- [ ] Complete Flutter source
- [ ] Mock data asset
- [ ] README
- [ ] Architecture document
- [ ] Setup instructions
- [ ] Test credentials
- [ ] Unit/widget/integration tests
- [ ] Simulated error/offline states
- [ ] Release APK generated
- [ ] Screen recording
- [ ] Known limitations documented
- [ ] No secrets committed
