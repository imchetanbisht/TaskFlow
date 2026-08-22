# TaskFlow — Product Requirements Document (PRD)

## 1. Product Overview

**Product Name:** TaskFlow  
**Platform:** Flutter (Android required, iOS optional)  
**Purpose:** Build a lightweight project management mobile application where users belong to organizations, manage projects, manage tasks, assign work, and view task-related information.

This assignment is focused on **UI, architecture, state management, local data handling, simulated authentication, error handling, offline awareness, and testing**.

There is **no real backend or live API**. The application must use the provided `TaskFlow-MockData.json` as its local mock data source.

---

## 2. Goals

The application should allow users to:

- Log in using provided mock credentials.
- Maintain a simulated authenticated session.
- View projects belonging to their organization.
- Create, edit, and delete projects according to their role.
- View project details and task summaries.
- View, create, edit, and delete tasks.
- Filter tasks by status, priority, assignee, and due-date range.
- Assign and unassign organization members from tasks.
- Change task status and priority.
- Handle loading, empty, success, and error states.
- Simulate offline conditions.
- Store previously loaded data locally.
- Demonstrate simulated token expiry and token refresh.
- Run automated unit, widget, and integration tests.

---

## 3. Scope

### In Scope

- Splash / session check
- Login
- Register
- Home / Dashboard
- Project list
- Project details
- Project CRUD
- Task list
- Task details
- Create / edit task
- Task CRUD
- Task assignment
- User/member listing
- Role-based authorization
- Simulated JWT-style authentication
- Secure token storage
- Local mock JSON data source
- Repository/data layer
- State management
- Loading / empty / error states
- Simulated errors
- Simulated offline mode
- Local persistence of successfully loaded project/task data
- Profile / Settings
- Automated tests
- README and architecture documentation
- Release APK generation

### Out of Scope

- Real backend development
- Real REST API integration
- Firebase as the primary data source
- Backend-as-a-Service
- Real production authentication
- Production database
- Real network synchronization

---

## 4. Users and Roles

TaskFlow supports organization-based users.

### Organization Admin (`org_admin`)

Admin users can:

- View projects in their organization.
- Create projects.
- Edit projects.
- Delete projects.
- Manage organization members.
- Manage tasks according to the application's task permissions.

Destructive/admin actions must be protected in the business-logic layer, not only by hiding UI buttons.

### Organization Member (`member`)

Members can access normal project/task functionality available to them, but must not be able to perform admin-only actions such as project deletion or member management.

The business logic must validate authorization even if an admin screen/action is accessed through a direct navigation/deep link.

---

## 5. Data Source

The application will use one provided JSON asset:

`TaskFlow-MockData.json`

The file contains these top-level collections:

- `organizations`
- `users`
- `org_members`
- `projects`
- `tasks`
- `comments`
- `notifications`
- `auth_mock`

The JSON file must be bundled as a Flutter asset.

The UI must **not read JSON directly**.

Required flow:

```text
UI
 ↓
State Management
 ↓
Business Logic / Use Cases
 ↓
Repository
 ↓
Mock Data Source
 ↓
TaskFlow-MockData.json
```

The repository interface should be designed so that the mock data source can later be replaced by a real HTTP API without changing the presentation layer.

---

## 6. Authentication Requirements

### Screens

- Splash / Session Check
- Login
- Register

### Login

The login screen must:

- Accept the mock credentials.
- Load credentials through the data layer.
- Validate required fields.
- Show meaningful validation/error messages.
- Navigate to authenticated screens after successful login.

### Session

After successful login:

- Store mock `access_token` and `refresh_token` securely.
- Do not store passwords locally.
- Do not log tokens.
- Use the provided `access_token_expires_in_seconds` value.
- Simulate access-token expiry after 15 minutes.
- Demonstrate a mock refresh-token flow.
- Logout must clear local session state.
- Authenticated screens must be inaccessible after logout.

### Register

Registration can simulate success locally without persisting a newly created user to a real backend.

### Optional

- Biometric unlock for an existing session.
- Automatic timeout after prolonged inactivity.

---

## 7. Project Management

### Project List

Each project should display:

- Project name
- Description
- Task count

The screen must support:

- Loading state
- Empty state
- Error state
- Pull-to-refresh

Projects must be scoped to the currently logged-in user's organization.

### Project Details

Display:

- Project information
- Task summary grouped by status
- Project task list

### Project Actions

Users with appropriate permissions can:

- Create project
- Edit project
- Delete project

Delete actions require confirmation.

After mutations, the project/task view must refresh.

---

## 8. Task Management

### Task List

Each task should show:

- Title
- Priority
- Status
- Assignee
- Due date

### Task Filters

Users should be able to filter by:

- Status
- Priority
- Assignee
- Due-date range

### Task Actions

Users can:

- View task
- Create task
- Edit task
- Delete task
- Update status
- Update priority
- Assign user
- Unassign user

Destructive actions require confirmation.

The UI must support loading, empty, success, and error states.

---

## 9. Task Assignment and Users

Organization members must be loaded by combining:

- `org_members`
- `users`

Only members of the current organization should be eligible for assignment.

The business-logic layer must additionally validate that the selected user belongs to the current organization. UI filtering alone is not sufficient.

The task screen should display the current assignee and allow assigning/removing a user.

---

## 10. State Management

Use a proper state-management solution such as:

- Riverpod
- Bloc
- Cubit
- Provider
- Another justified equivalent

Avoid excessive `setState`.

Each major feature should have clearly defined states, for example:

```text
Initial
  ↓
Loading
  ↓
Success
  ↓
Empty

or

Error
```

Example:

```text
TaskListState
├── initial
├── loading
├── success
├── empty
└── error
```

Business logic and data access must remain outside UI widgets.

---

## 11. Data Layer Architecture

Recommended separation:

```text
Presentation
    ↓
Business Logic / Use Cases
    ↓
Repository Interface
    ↓
Repository Implementation
    ↓
Mock Data Source
    ↓
JSON Asset / Local Storage
```

The data layer should provide:

- Centralized mock data reading/writing.
- Separate model classes.
- JSON serialization/deserialization.
- Request/response-style models where appropriate.
- Repository interfaces.
- Local state updates.

Dependency injection or another clean dependency-management approach should be used.

---

## 12. Simulated Errors

The application must provide a way to demonstrate realistic errors without a real backend.

At least a few conditions should be supported, such as:

- Simulated task not found / 404.
- Simulated network timeout.
- Simulated validation error.

Possible implementation:

- Debug toggle.
- Specific mock ID.
- Developer/settings switch.
- Configurable mock data behavior.

The exact trigger mechanism must be documented in the README.

Optional:

- Artificial delay of approximately 300–800 ms to demonstrate loading states.
- Request cancellation.

---

## 13. Offline Awareness

The application must simulate an offline state.

Requirements:

- Provide a connectivity/offline toggle or equivalent simulation.
- Preserve already-loaded project/task data.
- Show an appropriate offline message.
- Allow retry.
- Clearly indicate when displayed data may be stale.
- Do not crash when offline.

Optional:

- Queue task updates locally while offline.
- Synchronize pending operations when the application returns online.

---

## 14. Required Screens

Minimum screens:

1. Splash / Session Check
2. Login
3. Register
4. Home / Dashboard
5. Projects
6. Project Details
7. Task List
8. Task Details
9. Create / Edit Task
10. Profile / Settings

### Optional Bonus Screens / Features

- Notifications / Inbox
- Dark mode
- Tablet layout
- Animations
- Skeleton loading
- Accessibility improvements
- Internationalization
- Biometric unlock

---

## 15. Notifications

Notifications are optional.

The mock data contains notification records representing task-assignment events.

If implemented:

- Show notification list.
- Allow tapping a notification.
- Navigate to the related task.

Notifications are bonus functionality and are not required for a passing submission.

---

## 16. UI/UX Requirements

The UI should provide:

- Responsive layouts.
- Consistent spacing.
- Consistent typography.
- Reusable components.
- Form validation.
- Loading indicators.
- Empty states.
- Error states.
- Confirmation dialogs for destructive actions.
- Pull-to-refresh.
- Correct navigation and back-navigation behavior.

The interface should feel like a practical lightweight project-management application rather than a simple demo screen collection.

---

## 17. Testing Requirements

### Unit Tests

Minimum unit-test coverage should include:

- Authentication/session logic.
- Simulated token refresh.
- Task filtering logic.
- Validation logic.
- State-management/business logic.

### Widget Tests

Minimum widget tests:

- Login form validation.
- Task list loading/empty/error/success rendering.
- Task status update UI.

### Integration Tests

Minimum integration flows:

- Login using mock credentials.
- Project listing.
- Task listing.
- Create/update task.
- Task assignment.

Tests must not depend on execution order or real network connectivity.

The data layer should be mocked where appropriate.

---

## 18. Documentation Requirements

### README.md

README must explain:

- Project overview.
- Architecture.
- Folder structure.
- State-management approach.
- Mock data layer.
- Error and artificial-delay simulation.
- Offline simulation.
- Authentication/token flow.
- Local setup.
- Flutter/Dart version.
- How to run.
- How to test.
- How to build APK.
- How to trigger simulated errors/offline state.
- Known limitations.
- Technical decisions/trade-offs.

### Architecture Document

Include:

- Application architecture.
- State-management approach.
- Data layer.
- Authentication flow.
- Local storage.
- Error handling.
- Navigation.
- Key technical decisions.

A simple architecture diagram is encouraged.

---

## 19. Build Requirements

The project must:

- Run without manual source-code modifications.
- Successfully execute `flutter pub get`.
- Run with `flutter run`.
- Pass `flutter test`.
- Generate a release APK.
- Avoid committed secrets.
- Avoid unnecessary debug logging in release builds.
- Avoid obvious memory leaks.

Required commands:

```bash
flutter pub get
flutter run
flutter test
flutter build apk --release
```

---

## 20. Submission Requirements

The final submission must contain:

### GitHub Repository

- Complete Flutter source code.
- README.md.
- Tests.
- Mock data assets.
- Clean and meaningful commit history.

### Architecture Document

Document the architecture, state management, data layer, authentication, storage, error handling, navigation, and important decisions.

### Screen Recording

5–10 minute recording demonstrating:

1. Login.
2. Project listing.
3. Project details.
4. Task listing.
5. Task creation/editing.
6. Task assignment.
7. Status/priority update.
8. Simulated error handling.
9. Offline handling.
10. Logout.
11. Brief architecture explanation.

### Test Credentials

Provide mock credentials for:

- Organization A Admin
- Organization A Member
- Organization B Admin
- Organization B Member

Credentials should be taken from the provided `auth_mock` data.

---

## 21. Acceptance Criteria

The project is considered complete when:

- [ ] Flutter project builds successfully.
- [ ] Mock JSON is loaded through a data source/repository layer.
- [ ] No JSON is read directly from UI widgets.
- [ ] Login works using provided mock credentials.
- [ ] Session/token flow is simulated.
- [ ] Tokens are stored securely.
- [ ] Logout clears the session.
- [ ] Projects are scoped to the user's organization.
- [ ] Project CRUD works locally.
- [ ] Role-based project permissions work.
- [ ] Tasks can be viewed, created, edited, and deleted.
- [ ] Task filters work.
- [ ] Task status and priority can be updated.
- [ ] Task users can be assigned/unassigned.
- [ ] Invalid cross-organization assignment is blocked in business logic.
- [ ] Loading/empty/error states are implemented.
- [ ] Simulated errors can be demonstrated.
- [ ] Offline mode can be demonstrated.
- [ ] Previously loaded data is preserved offline.
- [ ] Required unit tests are implemented.
- [ ] Required widget tests are implemented.
- [ ] Required integration tests are implemented.
- [ ] README is complete.
- [ ] Architecture documentation is included.
- [ ] Release APK can be generated.
- [ ] Screen recording is prepared.
- [ ] Test credentials are documented.

---

## 22. Suggested Flutter Feature Structure

A scalable structure can follow this general organization:

```text
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── storage/
│   ├── theme/
│   └── utils/
│
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
├── presentation/
│   ├── auth/
│   ├── dashboard/
│   ├── projects/
│   ├── tasks/
│   ├── profile/
│   └── widgets/
│
└── main.dart

assets/
└── mock_data/
    └── TaskFlow-MockData.json

test/
├── unit/
├── widget/
└── integration_test/
```

The exact folder structure may vary, but presentation, business logic, and data-access responsibilities must remain separated.

---

## 23. Product Summary

TaskFlow is a **mock-data-driven Flutter project management app**.

The core user journey is:

```text
Splash
  ↓
Login
  ↓
Home / Dashboard
  ↓
Projects
  ↓
Project Details
  ↓
Tasks
  ↓
Task Details
  ↓
Create/Edit/Assign/Update
```

The main evaluation is not backend development. The primary focus is:

**Clean Architecture + State Management + Mock Data Layer + Simulated Authentication + Secure Local Storage + Role-Based Logic + Error/Offline Handling + Testing + Documentation.**
