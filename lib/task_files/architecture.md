# TaskFlow — Architecture Document

## 1. Architecture Overview

TaskFlow is a Flutter mobile application for lightweight project and task management.

The architecture is designed around clear separation between:

- Presentation
- State management
- Business logic
- Domain entities
- Repository interfaces
- Repository implementations
- Data sources
- Local storage

The application uses the provided `TaskFlow-MockData.json` as its local mock data source. There is no real backend or live API.

The most important architectural requirement is that the presentation layer must not depend directly on the JSON structure. The repository abstraction should make it possible to replace the local mock data source with a real HTTP API later with minimal changes to the rest of the application.

---

## 2. High-Level Architecture

```text
┌──────────────────────────────────────────┐
│              Presentation                │
│                                          │
│ Screens / Widgets / Reusable Components  │
└────────────────────┬─────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────┐
│            State Management              │
│          Riverpod / Bloc / Cubit         │
└────────────────────┬─────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────┐
│          Business Logic / Use Cases      │
│                                          │
│ Auth / Projects / Tasks / Assignment     │
│ Validation / Authorization / Filtering   │
└────────────────────┬─────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────┐
│          Repository Interfaces           │
│                                          │
│ AuthRepository                           │
│ ProjectRepository                        │
│ TaskRepository                           │
│ UserRepository                           │
└────────────────────┬─────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────┐
│       Repository Implementations         │
└────────────────────┬─────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────┐
│              Data Sources                │
│                                          │
│ Mock JSON Data Source                    │
│ Local Storage Data Source                │
└────────────────────┬─────────────────────┘
                     │
             ┌───────┴────────┐
             ▼                ▼
┌────────────────────┐  ┌─────────────────┐
│ TaskFlow-MockData  │  │ Secure/Local    │
│      .json         │  │ Storage         │
└────────────────────┘  └─────────────────┘
```

---

## 3. Architectural Principles

### Separation of Concerns

Each layer should have one clear responsibility.

The UI should display state and send user actions.

Business logic should contain rules such as:

- Role authorization
- Organization scoping
- Task filtering
- Assignment validation
- Session handling

The data layer should handle:

- JSON reading
- JSON parsing
- Local persistence
- Mock data mutations

### Dependency Direction

Dependencies should move toward abstractions.

```text
Presentation
    ↓
Domain abstractions
    ↓
Data implementation
```

The UI should not directly depend on JSON files or concrete data-source implementations.

---

# 4. Recommended Flutter Folder Structure

```text
lib/
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── asset_paths.dart
│   │
│   ├── errors/
│   │   ├── app_exception.dart
│   │   ├── auth_exception.dart
│   │   ├── network_exception.dart
│   │   └── validation_exception.dart
│   │
│   ├── storage/
│   │   ├── secure_storage_service.dart
│   │   └── local_storage_service.dart
│   │
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_theme.dart
│   │   └── app_text_styles.dart
│   │
│   ├── routing/
│   │   └── app_router.dart
│   │
│   └── utils/
│       ├── validators.dart
│       └── date_utils.dart
│
├── data/
│   ├── datasources/
│   │   ├── mock_data_source.dart
│   │   └── local_storage_data_source.dart
│   │
│   ├── models/
│   │   ├── organization_model.dart
│   │   ├── user_model.dart
│   │   ├── organization_member_model.dart
│   │   ├── project_model.dart
│   │   ├── task_model.dart
│   │   ├── comment_model.dart
│   │   ├── notification_model.dart
│   │   └── auth_model.dart
│   │
│   └── repositories/
│       ├── auth_repository_impl.dart
│       ├── project_repository_impl.dart
│       ├── task_repository_impl.dart
│       └── user_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   ├── organization.dart
│   │   ├── user.dart
│   │   ├── project.dart
│   │   ├── task.dart
│   │   └── notification.dart
│   │
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── project_repository.dart
│   │   ├── task_repository.dart
│   │   └── user_repository.dart
│   │
│   └── usecases/
│       ├── login.dart
│       ├── logout.dart
│       ├── refresh_session.dart
│       ├── get_projects.dart
│       ├── create_project.dart
│       ├── update_project.dart
│       ├── delete_project.dart
│       ├── get_tasks.dart
│       ├── create_task.dart
│       ├── update_task.dart
│       ├── delete_task.dart
│       ├── assign_task.dart
│       └── filter_tasks.dart
│
├── presentation/
│   ├── auth/
│   │   ├── splash/
│   │   ├── login/
│   │   └── register/
│   │
│   ├── dashboard/
│   │
│   ├── projects/
│   │   ├── project_list/
│   │   └── project_details/
│   │
│   ├── tasks/
│   │   ├── task_list/
│   │   ├── task_details/
│   │   └── task_form/
│   │
│   ├── profile/
│   │
│   └── widgets/
│       ├── app_button.dart
│       ├── project_card.dart
│       ├── task_card.dart
│       ├── status_chip.dart
│       ├── priority_chip.dart
│       ├── user_avatar.dart
│       ├── loading_state.dart
│       ├── empty_state.dart
│       └── error_state.dart
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

The exact structure can vary, but the responsibilities must remain separated.

---

# 5. Data Architecture

## 5.1 Mock JSON

The provided JSON contains these top-level collections:

```text
organizations
users
org_members
projects
tasks
comments
notifications
auth_mock
```

It should be registered as a Flutter asset.

Example:

```yaml
flutter:
  assets:
    - assets/mock_data/TaskFlow-MockData.json
```

---

## 5.2 Mock Data Source

`MockDataSource` is responsible for:

- Loading the JSON asset.
- Parsing the JSON.
- Exposing entity collections to repositories.
- Maintaining local in-memory mutations.
- Simulating delays.
- Simulating errors.
- Simulating offline behavior.

The UI must never access `rootBundle` or parse JSON directly.

Conceptually:

```text
MockDataSource
    ↓
JSON
    ↓
Parsed Models
```

---

# 6. Repository Layer

Repositories provide an abstraction between business logic and data sources.

Example:

```text
AuthRepository
├── login()
├── logout()
├── getCurrentSession()
└── refreshToken()

ProjectRepository
├── getProjects()
├── getProjectById()
├── createProject()
├── updateProject()
└── deleteProject()

TaskRepository
├── getTasks()
├── getTaskById()
├── createTask()
├── updateTask()
├── deleteTask()
├── assignTask()
└── unassignTask()

UserRepository
└── getOrganizationMembers()
```

The domain layer should depend on repository interfaces.

The data layer implements those interfaces.

This allows a future architecture such as:

```text
Current:
Repository → MockDataSource → JSON

Future:
Repository → RemoteDataSource → REST API
```

without changing the screens.

---

# 7. Domain Layer

The domain layer contains business rules and application-independent concepts.

Examples:

### Organization Scoping

A user should only see projects belonging to their `org_id`.

### Role Authorization

```text
org_admin
    → Can delete projects
    → Can manage members

member
    → Cannot delete projects
    → Cannot manage members
```

### Assignment Validation

A task cannot be assigned to a user who does not belong to the current organization.

This must be checked in business logic even if the UI filters the member picker.

### Task Filtering

Filtering should be implemented outside widgets so it can be unit tested independently.

---

# 8. State Management

Use a proper state-management solution.

Recommended choice:

**Riverpod**

Riverpod can manage:

- Authentication state
- Project state
- Task state
- User/member state
- Filters
- Offline state
- Debug/simulation state

Example:

```text
TaskListState
├── initial
├── loading
├── success
├── empty
└── error
```

A task-list controller/provider should handle:

```text
Load tasks
     ↓
Apply filters
     ↓
Update task
     ↓
Refresh
     ↓
Emit new state
```

Widgets should consume the state and render it.

---

# 9. Authentication Architecture

Authentication is simulated using the provided `auth_mock` data.

## Login Flow

```text
Login Screen
     ↓
Auth Controller
     ↓
Login Use Case
     ↓
Auth Repository
     ↓
Mock Data Source
     ↓
Validate credentials
     ↓
Return mock tokens
     ↓
Secure Storage
     ↓
Authenticated State
     ↓
Home
```

---

## Session Check

At application startup:

```text
Splash
  ↓
Read stored session
  ↓
Session exists?
  ├── No → Login
  │
  └── Yes
       ↓
Check token expiry
       ↓
Valid → Home
Expired → Refresh token
       ↓
Success → Home
Failure → Login
```

---

## Token Storage

Store:

- `access_token`
- `refresh_token`
- Expiry/session information as required

Use secure local storage.

Never:

- Store passwords.
- Log tokens.
- Hardcode credentials in UI.

---

# 10. Simulated Token Refresh

The assignment requires token expiry simulation using:

`access_token_expires_in_seconds`

After simulated expiry:

```text
Access Token Expired
        ↓
Refresh Token
        ↓
Mock Auth Data
        ↓
New Access Token
        ↓
Secure Storage
        ↓
Continue Session
```

If refresh fails:

```text
Refresh Failure
      ↓
Clear Session
      ↓
Navigate to Login
```

---

# 11. Project Flow

```text
Projects Screen
      ↓
Project Controller
      ↓
Get Projects Use Case
      ↓
Project Repository
      ↓
Mock Data Source
      ↓
Filter by current org_id
      ↓
Return Projects
      ↓
Project State
      ↓
UI
```

Project mutations:

```text
UI Action
   ↓
Authorization Check
   ↓
Use Case
   ↓
Repository
   ↓
Mock Data Source
   ↓
Update Local State
   ↓
Refresh
   ↓
Updated UI
```

---

# 12. Task Flow

```text
Task List
    ↓
Task Controller
    ↓
Task Use Case
    ↓
Task Repository
    ↓
Mock Data Source
    ↓
Tasks
    ↓
Filter
    ↓
Task State
    ↓
UI
```

Task operations include:

- Create
- Read
- Update
- Delete
- Status update
- Priority update
- Assign
- Unassign

---

# 13. Task Filtering

Filtering should not be implemented directly in widgets.

Recommended flow:

```text
Selected Filters
      ↓
Task Controller
      ↓
Filter Use Case
      ↓
Task List
      ↓
Filtered Tasks
      ↓
State Update
      ↓
UI
```

Supported filters:

- Status
- Priority
- Assignee
- Due-date range

This logic should have dedicated unit tests.

---

# 14. Task Assignment Architecture

```text
Task Details
     ↓
Select Assignee
     ↓
Task Controller
     ↓
Assignment Use Case
     ↓
Validate User
     ↓
Does user belong to current org?
     ├── No → Validation Error
     │
     └── Yes
          ↓
Task Repository
          ↓
Update task
          ↓
Refresh task state
```

The member picker should display only current organization members, but business logic must independently validate the assignment.

---

# 15. Local Storage

Local storage has two main responsibilities.

## Secure Storage

Used for authentication/session information:

```text
access_token
refresh_token
session/expiry information
```

## Normal Local Storage

Used for cached application data such as:

```text
last successfully loaded projects
last successfully loaded tasks
offline/debug configuration
```

Passwords must not be stored.

---

# 16. Offline Architecture

The assignment uses simulated offline awareness.

Flow:

```text
User enables Offline Mode
          ↓
Offline State = true
          ↓
Repository/Data Source blocks simulated network-like operations
          ↓
Previously cached data remains available
          ↓
UI shows offline banner
          ↓
User can retry
```

When cached data exists:

```text
Offline
  ↓
Show saved projects/tasks
  ↓
Display "Data may be stale"
```

The application must not crash because of the offline state.

---

# 17. Error Simulation

The data layer should support controlled error scenarios.

Suggested debug configuration:

```text
DebugSimulation
├── offline
├── timeout
├── notFound
├── validationError
└── artificialDelay
```

Example:

```text
Task ID = special test ID
       ↓
Mock Data Source
       ↓
Simulated 404
       ↓
Repository converts error
       ↓
Business logic state = error
       ↓
Error UI
```

The README must document how reviewers trigger each error.

---

# 18. Loading / Empty / Error State Flow

Every major repository operation should expose predictable states.

```text
Initial
   ↓
Loading
   ↓
Success
```

or:

```text
Loading
   ↓
Empty
```

or:

```text
Loading
   ↓
Error
```

The UI should never show a blank screen when data is loading, empty, or failed.

---

# 19. Navigation Architecture

Recommended route structure:

```text
/
├── splash
├── login
├── register
│
└── authenticated
    ├── home
    ├── projects
    │   ├── project-details
    │   └── project-form
    │
    ├── tasks
    │   ├── task-details
    │   └── task-form
    │
    └── profile
```

Authenticated routes should be protected by session state.

After logout:

```text
Logout
  ↓
Clear session
  ↓
Clear authentication state
  ↓
Navigate to Login
  ↓
Block authenticated routes
```

---

# 20. Dependency Injection

Dependencies should be injected rather than instantiated throughout widgets.

Example conceptual dependency graph:

```text
TaskScreen
    ↓
TaskController
    ↓
TaskUseCase
    ↓
TaskRepository
    ↓
MockDataSource
```

This makes testing easier because repositories/data sources can be replaced with mocks.

---

# 21. UI Architecture

Widgets should be focused on presentation.

A screen should generally:

- Read state.
- Render UI.
- Trigger controller actions.

A screen should not:

- Parse JSON.
- Read assets directly.
- Implement repository logic.
- Perform authorization rules.
- Perform complex filtering.
- Manage authentication tokens.

---

# 22. Reusable UI Components

Create reusable components for:

```text
AppButton
AppTextField
ProjectCard
TaskCard
StatusChip
PriorityChip
UserAvatar
UserSelector
FilterSheet
LoadingState
EmptyState
ErrorState
OfflineBanner
ConfirmDialog
```

This keeps screens smaller and consistent.

---

# 23. Testing Architecture

Testing should be separated into:

```text
test/
├── unit/
├── widget/
└── integration_test/
```

## Unit Tests

Test:

- Login/session logic
- Token refresh
- Task filtering
- Validation
- Authorization
- Task assignment
- State/business logic

## Widget Tests

Test:

- Login validation
- Task list loading state
- Task list empty state
- Task list error state
- Task list success state
- Status update UI

## Integration Tests

Test complete flows:

```text
Login
  ↓
Project Listing
  ↓
Task Listing
  ↓
Create/Update Task
  ↓
Task Assignment
```

Tests should not use real network connectivity.

---

# 24. Error Handling Strategy

Use application-level exceptions instead of exposing raw low-level errors to UI.

Example:

```text
Data Source Error
      ↓
Repository
      ↓
Domain/App Exception
      ↓
State = Error
      ↓
User-friendly UI message
```

Possible exceptions:

```text
AuthException
ValidationException
NotFoundException
TimeoutException
OfflineException
AuthorizationException
```

---

# 25. Role-Based Authorization

Authorization should exist in business logic.

Example:

```text
deleteProject(projectId, currentUser)
          ↓
Is currentUser org_admin?
     ├── No → AuthorizationException
     └── Yes → Delete project
```

The UI may hide the delete button for members, but the use case must still reject unauthorized requests.

This satisfies the assignment requirement for simulated backend-like authorization.

---

# 26. Repository Replacement Strategy

Current implementation:

```text
ProjectRepository
       ↓
ProjectRepositoryImpl
       ↓
MockDataSource
       ↓
JSON
```

Future implementation:

```text
ProjectRepository
       ↓
ProjectRepositoryImpl
       ↓
RemoteDataSource
       ↓
REST API
```

The presentation and domain layers should not need to change when switching from mock data to a real API.

---

# 27. Data Mutation Strategy

Because there is no real backend, create/edit/delete operations update:

1. In-memory mock state.
2. Local cached state where required.

Example:

```text
Create Task
    ↓
Validate
    ↓
Repository
    ↓
Mock Data Source
    ↓
Add task to local collection
    ↓
Persist/cache if applicable
    ↓
Refresh Task State
```

The same approach applies to project mutations.

---

# 28. Application Startup

Recommended startup flow:

```text
main()
  ↓
Initialize Flutter bindings
  ↓
Initialize secure storage
  ↓
Initialize local storage
  ↓
Initialize dependency injection
  ↓
Initialize providers
  ↓
Run App
  ↓
Splash / Session Check
```

Avoid performing application logic directly inside `main.dart`.

---

# 29. Security Considerations

Even though authentication is simulated:

- Never hardcode credentials inside UI widgets.
- Never store passwords.
- Never print access/refresh tokens.
- Use secure storage for tokens.
- Keep authentication logic outside presentation.
- Keep authorization rules in business logic.
- Do not commit secrets.

The mock credentials should only be loaded through the data layer.

---

# 30. Performance and Maintainability

The architecture should avoid:

- Large "god classes".
- Business logic inside widgets.
- Direct JSON parsing in screens.
- Excessive `setState`.
- Repeated repository creation.
- Duplicate UI components.
- Unnecessary rebuilds.
- Uncontrolled listeners.

Use reusable providers/controllers and dependency injection.

---

# 31. Suggested Core Dependencies

The exact packages can be selected during implementation, but the architecture should support:

```text
State Management:
Riverpod / Bloc / Cubit / Provider

Secure Storage:
flutter_secure_storage or equivalent

Local Storage:
SharedPreferences / Hive / Isar / equivalent

JSON:
dart:convert or generated serialization

Testing:
Flutter test framework
Integration testing tools
```

No package should be added only for the sake of the assignment; dependencies should have a clear responsibility.

---

# 32. Architecture Decision Summary

| Area | Decision |
|---|---|
| Framework | Flutter |
| Language | Dart |
| Platform | Android required, iOS optional |
| Architecture | Clean/layered architecture |
| State Management | Riverpod recommended |
| Data Source | Local mock JSON |
| Repository | Abstract repository interfaces |
| Authentication | Simulated JWT-style flow |
| Token Storage | Secure local storage |
| Cached Data | Local storage |
| Backend | None |
| API | None |
| Role Management | Business-logic authorization |
| Offline | Simulated |
| Errors | Simulated through mock data layer |
| Testing | Unit + Widget + Integration |
| UI | Responsive mobile-first |

---

# 33. Final Architecture Flow

The complete application can be understood as:

```text
                         ┌───────────────┐
                         │   Flutter UI  │
                         └───────┬───────┘
                                 │
                                 ▼
                         ┌───────────────┐
                         │ State Manager │
                         │   Riverpod    │
                         └───────┬───────┘
                                 │
                                 ▼
                         ┌───────────────┐
                         │    Use Cases  │
                         │ Business Logic│
                         └───────┬───────┘
                                 │
                                 ▼
                         ┌───────────────┐
                         │  Repository   │
                         │  Interfaces   │
                         └───────┬───────┘
                                 │
                                 ▼
                     ┌───────────────────────┐
                     │ Repository Implement. │
                     └───────────┬───────────┘
                                 │
                   ┌─────────────┴─────────────┐
                   ▼                           ▼
          ┌─────────────────┐         ┌─────────────────┐
          │ Mock Data Source│         │ Local Storage   │
          └────────┬────────┘         └────────┬────────┘
                   │                           │
                   ▼                           ▼
          TaskFlow-MockData.json        Cached / Session
```

This architecture satisfies the core assignment requirement: the application behaves like a real project-management client while keeping the backend completely mocked and ensuring that the mock data source can later be replaced with a real API.
