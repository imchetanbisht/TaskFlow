# TaskFlow — Screen Recording Script

Target duration: **5–10 minutes**

## 0:00–0:30 — Introduction
Briefly introduce TaskFlow and explain that it uses local mock JSON instead of a real backend.

## 0:30–1:15 — Login
- Splash/session check
- Login with mock credentials
- Successful navigation to Home
- Briefly mention secure token storage and simulated authentication

## 1:15–2:00 — Projects
- Open Projects
- Show organization-scoped projects
- Show loading/refresh behavior
- Open a project

## 2:00–2:45 — Project Details
- Show project information
- Task status summary
- Project task list
- Demonstrate admin action if logged in as admin

## 2:45–4:00 — Tasks
- Open Task List
- Demonstrate filters: status, priority, assignee, due date
- Open Task Details
- Create/edit a task
- Update status and priority

## 4:00–4:45 — Assignment
- Open assignee picker
- Assign a current-organization member
- Unassign
- Show updated task

## 4:45–5:30 — Role-Based Authorization
Switch to a member account if practical.
Show that admin-only operations are blocked by business logic.

## 5:30–6:15 — Simulated Errors
Demonstrate the implemented:
- 404/task not found
- timeout
- validation error

Show error UI and retry.

## 6:15–7:00 — Offline
Enable simulated offline mode.
Show:
- offline message
- previously loaded data
- stale-data indication if implemented
- retry

## 7:00–7:30 — Logout
Profile/Settings → Logout → confirm → return to Login.

## 7:30–8:30 — Architecture
Briefly explain:

```text
Presentation
↓
State Management
↓
Business Logic / Use Cases
↓
Repository
↓
Mock Data Source
↓
JSON
```

Mention secure storage, local cache, authorization and future API replacement.

## 8:30–9:30 — Tests / Build
Show:

```bash
flutter test
flutter build apk --release
```

Briefly mention unit, widget and integration tests.

## 9:30–10:00 — Closing
State that the app satisfies the mock-data assignment and is structured for future API replacement.
