# TaskFlow — UI/UX Design Specification for Stitch

## 1. Design Goal

Design a polished, modern mobile project-management application called **TaskFlow**.

TaskFlow should feel like a real lightweight productivity/product-management app, not a basic college/demo application.

The design must support the requirements in the PRD:
- Authentication
- Organization-based projects
- Project details
- Task management
- Task filtering
- Task assignment
- Role-based actions
- Loading, empty, and error states
- Offline awareness
- Profile/settings

This document is intended to be used as the design brief/prompt for **Google Stitch** to generate the UI screens and visual system.

---

# 2. Overall Visual Direction

## Style

Use a **premium modern SaaS/productivity-app aesthetic** optimized for Android mobile.

Visual characteristics:
- Clean
- Minimal
- Professional
- Spacious
- Modern
- Slightly rounded cards
- Strong visual hierarchy
- Subtle elevation
- Clear status indicators
- High readability
- Smooth, restrained interactions

Avoid:
- Excessive gradients
- Excessive glassmorphism
- Cartoon-style UI
- Overly colorful screens
- Huge decorative illustrations
- Cluttered dashboards
- Desktop-style layouts squeezed into mobile

The application should look credible as a production-ready project management product.

---

# 3. Color System

Use a light-first theme.

### Primary
- Deep indigo / blue-violet for primary actions and active navigation.

### Background
- Very light neutral gray/off-white.

### Surface
- White cards and sheets.

### Text
- Dark charcoal for primary text.
- Medium gray for secondary text.
- Light gray for metadata.

### Semantic Colors
Use restrained semantic colors:
- Green = completed/success
- Amber = medium priority/warning
- Red = high priority/error/destructive
- Blue = informational/in-progress

Do not make the entire UI highly saturated.

---

# 4. Typography

Use a modern sans-serif font such as **Inter** or an equivalent clean system font.

Typography hierarchy:

- Large page title: bold
- Section heading: semibold
- Card title: semibold
- Body: regular
- Metadata: smaller regular
- Buttons: medium/semibold
- Status labels: medium

Maintain consistent typography across all screens.

---

# 5. Shape and Spacing System

Use:
- 8px base spacing system.
- Approximately 12–16px screen horizontal padding.
- 12–16px card corner radius.
- 10–12px input corner radius.
- Rounded chips/pills for status and priority.
- Comfortable touch targets.

Cards should have subtle elevation/border separation without heavy shadows.

---

# 6. Navigation

Use a mobile-first navigation structure.

Primary bottom navigation:

1. Home
2. Projects
3. Tasks
4. Profile

The active item should have a clear visual indicator.

Use standard mobile back navigation inside secondary screens.

Notifications can appear as a bell icon in the Home/Top App Bar and may open an optional notification inbox.

---

# 7. Global Components

Create reusable components for:

- App bar
- Bottom navigation
- Primary button
- Secondary button
- Destructive button
- Search field
- Text input
- Dropdown/select field
- Filter chip
- Status chip
- Priority chip
- Avatar
- User row
- Project card
- Task card
- Empty state
- Error state
- Loading skeleton
- Confirmation dialog
- Bottom sheet
- Snackbar/toast
- Pull-to-refresh
- Offline banner

Components should be visually consistent across all screens.

---

# 8. Screen 01 — Splash / Session Check

## Purpose

Check whether an existing local authenticated session exists.

## Design

Minimal premium splash screen.

Include:
- TaskFlow logo/wordmark
- Small loading indicator
- Clean neutral background

Do not overcrowd the splash screen.

Possible states:
- Checking session
- Session found → Home
- No session → Login

---

# 9. Screen 02 — Login

## Layout

Top:
- TaskFlow logo/wordmark
- Welcome headline
- Short supporting text

Middle:
- Email input
- Password input
- Password visibility toggle

Bottom:
- Primary "Sign In" button
- "Create account" secondary action

## Validation

Show inline validation below fields.

Examples:
- Enter a valid email
- Password is required
- Invalid email or password

Loading state:
- Disable form
- Show progress indicator inside button

Error state:
- Show a clear error message without exposing tokens or technical details.

---

# 10. Screen 03 — Register

## Fields

- Full name
- Email
- Password
- Confirm password

Actions:
- Create account
- Back to login

Use strong client-side validation.

Since registration is simulated, communicate success naturally and navigate to the appropriate authenticated flow.

---

# 11. Screen 04 — Home / Dashboard

This is the main overview screen.

## Top Area

- Greeting using the logged-in user's name
- Organization name
- Notification bell
- Avatar

## Summary Cards

Show useful high-level information:

- Total Projects
- Active Tasks
- Completed Tasks
- Overdue Tasks

Use compact cards rather than oversized dashboard widgets.

## Main Content

Sections:

### Recent Projects
Horizontal or vertical project cards.

Each project card:
- Project name
- Short description
- Task count
- Progress/status indicator

### My Tasks
Show a few upcoming/current tasks.

Task item:
- Task title
- Project
- Priority
- Status
- Due date

### Quick Action

Prominent but compact:
- Create Task

Admin users may additionally see:
- Create Project

---

# 12. Screen 05 — Projects

## App Bar

Title:
"Projects"

Actions:
- Search
- Add Project (admin only)

## Project Cards

Each card should contain:
- Project name
- Description
- Task count
- Progress/status summary
- Optional overflow menu

Example actions:
- Open
- Edit
- Delete (admin only)

Use pull-to-refresh.

## States

### Loading
Use skeleton project cards.

### Empty
Show:
- Simple project illustration/icon
- "No projects yet"
- Admin: "Create your first project"

### Error
Show:
- Error icon
- Friendly message
- Retry button

---

# 13. Screen 06 — Project Details

## Header

- Project name
- Description
- Task count
- Project progress/status

Admin:
- Edit action
- More menu
- Delete action

## Task Summary

Show compact status counts:

- To Do
- In Progress
- Completed

Use a simple segmented visualization or progress indicators.

## Project Tasks

List project tasks with:
- Task title
- Priority
- Status
- Assignee
- Due date

Floating/primary action:
- Add Task

---

# 14. Screen 07 — Task List

## Header

Title:
"Tasks"

Actions:
- Search
- Filter
- Add Task

## Filter Controls

Provide a filter bottom sheet with:

### Status
- To Do
- In Progress
- Completed

### Priority
- Low
- Medium
- High

### Assignee
- All
- Organization members

### Due Date
- All
- Today
- This week
- Custom range

Show selected filters as removable chips below the app bar.

## Task Card

Each task should clearly show:

- Title
- Project
- Status chip
- Priority chip
- Assignee avatar/name
- Due date

Make overdue dates visually noticeable.

---

# 15. Screen 08 — Task Details

## Header

- Back button
- Task title
- More menu

## Main Information

Show:

- Task title
- Description
- Project
- Status
- Priority
- Assignee
- Due date
- Created date

## Quick Controls

Use compact controls for:
- Change status
- Change priority
- Assign user

## Comments

If comments are available in the mock data, show a clean comments section.

## Bottom Actions

- Edit
- Delete

Delete must open a confirmation dialog.

---

# 16. Screen 09 — Create / Edit Task

Use a clean form.

Fields:

- Task title
- Description
- Project
- Status
- Priority
- Assignee
- Due date

Actions:
- Save Task
- Cancel

Validation must be clear and inline.

For assignment:
- Only show members belonging to the current organization.
- The design should make the current assignee obvious.

Saving state:
- Disable duplicate submission
- Show progress indicator

Success:
- Return to task list/details
- Refresh displayed task data

---

# 17. Screen 10 — Profile / Settings

## Profile Header

Show:
- Avatar
- User name
- Email
- Organization
- Role badge: Admin / Member

## Settings

Sections:

### Account
- Profile information
- Organization
- Role

### App
- Theme
- Notifications
- Offline/debug mode if exposed for reviewer demonstration

### Session
- Logout

Logout should use a confirmation dialog.

Admin-only:
- Member management entry if implemented.

---

# 18. Optional Notification Inbox

If implemented:

## Notification List

Each notification:
- Icon
- Short message
- Timestamp
- Read/unread state

Example:
"Alex assigned you a task."

Tapping a notification should navigate to the related task.

---

# 19. Admin vs Member UI

The design must visually communicate role-based permissions.

## Admin

Admin can see:
- Add Project
- Edit Project
- Delete Project
- Member Management

## Member

Member should not see admin-only actions in normal UI.

However, authorization must also exist in the business logic layer. UI hiding is not the security mechanism.

Use a subtle role badge:
- Admin
- Member

Avoid making roles visually aggressive.

---

# 20. Loading States

Every major data screen must have a loading state.

Use skeleton placeholders instead of a full-screen spinner whenever practical.

Required:
- Project list loading
- Task list loading
- Project details loading
- Task details loading
- Form submission/loading

---

# 21. Empty States

Design useful empty states.

Examples:

### No Projects
"No projects yet"
"Create a project to start organizing your work."

### No Tasks
"No tasks found"
"Try changing your filters or create a new task."

### No Search Results
"No matching tasks"
"Try another search or remove a filter."

Use simple line-style illustrations/icons.

---

# 22. Error States

Errors should be friendly and actionable.

### Generic Error

"Something went wrong."
"Please try again."

Action:
"Retry"

### Task Not Found

"Task not found."
"The task may have been removed or is no longer available."

Action:
"Back to Tasks"

### Validation Error

Show the error next to the relevant field.

---

# 23. Offline Mode

When offline, display a persistent but compact banner near the top:

"You're offline. Showing saved data."

Use a subtle warning/info treatment.

Previously loaded data remains visible.

Provide:
- Retry
- Refresh when online

Clearly label stale content where necessary.

Do not replace the entire screen with an error page if cached data is available.

---

# 24. Simulated Error / Debug UI

Because this is a technical assignment, provide a controlled developer/debug area in Settings or a hidden debug section.

Possible controls:

- Simulate Offline
- Simulate Timeout
- Simulate 404
- Simulate Validation Error
- Artificial Delay

This area should look intentionally like a developer/testing feature and should not dominate the normal user experience.

---

# 25. Confirmation Dialogs

Use confirmation dialogs for destructive actions.

### Delete Project

Title:
"Delete project?"

Message:
"This action cannot be undone."

Actions:
- Cancel
- Delete

### Delete Task

Title:
"Delete task?"

Message:
"This action cannot be undone."

Actions:
- Cancel
- Delete

Keep destructive actions visually distinct.

---

# 26. Responsive Design

Primary target:
- Android phones

Also support:
- Large Android phones
- Tablet layouts where practical

Use flexible layouts and avoid fixed-width elements.

The same component system should scale across screen sizes.

---

# 27. Interaction and Motion

Use subtle animations only.

Recommended:
- Screen transitions
- Card press feedback
- Filter sheet transition
- Status change feedback
- Snackbar after mutations
- Skeleton loading shimmer

Avoid excessive animation.

---

# 28. Accessibility

Ensure:
- Good text contrast
- Minimum comfortable touch targets
- Icons are paired with accessible labels
- Status is not communicated by color alone
- Form errors are readable
- Text remains readable at larger font sizes

---

# 29. Recommended Screen Generation Order in Stitch

Generate the design in this order:

1. Login
2. Register
3. Home / Dashboard
4. Projects
5. Project Details
6. Tasks
7. Task Details
8. Create/Edit Task
9. Profile / Settings
10. Splash
11. Optional Notifications
12. Error / Empty / Offline states

First establish the visual design system using Login + Home + Projects, then keep the same system across all remaining screens.

---

# 30. Stitch Design Prompt

Use the following as the primary Stitch prompt:

> Design a premium modern Android mobile app called TaskFlow, a lightweight project-management application for organizations, projects, and tasks.
>
> Create a cohesive production-quality design system with a light neutral background, white surfaces, deep indigo/blue-violet primary actions, dark charcoal typography, subtle semantic colors, rounded cards, consistent 8px spacing, and clean Inter-style typography.
>
> The app should feel like a polished SaaS productivity product. Use spacious layouts, strong hierarchy, compact cards, clear status/priority chips, avatars, subtle borders/elevation, and restrained animations.
>
> Create these connected screens: Splash, Login, Register, Home Dashboard, Projects, Project Details, Task List with filters, Task Details, Create/Edit Task, Profile/Settings, plus loading, empty, error, confirmation-dialog, and offline states.
>
> Home should show greeting, organization, notification icon, project/task summary cards, recent projects, upcoming tasks, and quick actions.
>
> Projects should show searchable project cards with name, description, task count and progress. Admin users can create/edit/delete projects; members cannot see admin-only actions.
>
> Project Details should show project information, task status summary, and project tasks.
>
> Task List should support filters for status, priority, assignee, and due-date range. Task cards should show title, project, status, priority, assignee and due date.
>
> Task Details should show complete task information, comments when available, and controls for status, priority and assignment.
>
> Create/Edit Task should use a clean validated form.
>
> Profile/Settings should show user identity, organization, role, app settings, debug/offline controls for assignment demonstration, and logout.
>
> Include clear loading skeletons, useful empty states, actionable error states, destructive confirmation dialogs, and a compact offline banner saying that saved data is being displayed.
>
> Maintain the same design language, spacing, typography, components, navigation, colors, and interaction patterns across every screen. Optimize for Android mobile first and make layouts responsive for larger screens.
>
> Avoid excessive gradients, excessive glassmorphism, cartoon visuals, clutter, and overly decorative UI. Prioritize usability and professional product quality.

---

# 31. Design Acceptance Criteria

- [ ] All required screens have a consistent visual language.
- [ ] Login/Register feel like part of the same product.
- [ ] Dashboard gives a useful overview without clutter.
- [ ] Project cards clearly show project information and task count.
- [ ] Project details clearly summarize task status.
- [ ] Task list supports all required filters visually.
- [ ] Task cards expose the required task metadata.
- [ ] Task details support status, priority and assignment actions.
- [ ] Create/Edit Task form is clear and validated.
- [ ] Admin/member differences are represented in UI.
- [ ] Loading states are designed.
- [ ] Empty states are designed.
- [ ] Error states are designed.
- [ ] Offline state is designed.
- [ ] Destructive confirmation dialogs are designed.
- [ ] Profile/settings screen includes logout.
- [ ] Components are reusable and visually consistent.
- [ ] Android mobile layout is prioritized.
- [ ] Design feels production-ready rather than like a basic assignment mockup.
