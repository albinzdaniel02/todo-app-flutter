# Testing Plan: Flutter Todo App

This document outlines the testing strategy, frameworks, test suites, and manual validation checklists to ensure the stability, responsiveness, and performance of the offline-first Todo application.

---

## 1. Testing Strategy Overview

The testing hierarchy guarantees correctness across layers:

| Test Type | Scope | Key Libraries |
| :--- | :--- | :--- |
| **Unit Tests** | State Controllers, Repository business logic, and Serialization. | `flutter_test`, `mocktail` |
| **Widget (UI) Tests** | UI renders correctly, responds to actions, adapts to theme shifts. | `flutter_test` |
| **Integration Tests** | End-to-end user flows, local database persist/retrieve verification. | `integration_test` |

---

## 2. Unit Testing Scope

### 2.1 Model Testing
- **Serialization / Deserialization**: Verify tasks and categories map cleanly to and from JSON.
- **Value Equality**: Ensure the `Equatable` package is correctly working (tasks with identical IDs and fields evaluate as equal).

### 2.2 Riverpod Controller Testing
- Mock repository layers using `mocktail` to intercept Hive reads and writes.
- Write tests to verify:
  - Adding a task correctly updates the controller state.
  - Deleting a task transitions it to the soft-deleted trash state.
  - Checking off a task updates completion state properly.
  - Category filters accurately subset the active list.

---

## 3. Widget & UI Testing Scope

### 3.1 Material 3 Component Validation
- Verify that standard buttons, task tiles, and category chips render with custom themed colors (not standard Flutter defaults).
- Ensure the floating action button opens the creation sheet.

### 3.2 Responsive Screen Sizes
- Test the responsive layout builder:
  - Simulate a mobile device viewport (e.g., width: 375px) -> Verify only mobile navigation bar and task list are visible.
  - Simulate a desktop/web viewport (e.g., width: 1024px) -> Verify the split-pane dashboard and navigation rail render correctly.

---

## 4. Integration Testing (E2E)

### 4.1 Database Persistence Verification
- Perform sequence:
  1. Open local Hive box.
  2. Create a set of test tasks.
  3. Close app / reset database container.
  4. Reload app, read tasks -> Verify data is fetched correctly and state is unchanged.

### 4.2 Notification Integration
- Simulate scheduling a notification due time and verify that `flutter_local_notifications` registers the scheduled alarm ID.

---

## 5. Manual QA Checklist

### 5.1 Storage Verification
- [ ] Add multiple tasks, close browser tab (Web) or force close app (Mobile). Re-open -> Check if tasks persist.
- [ ] Add tasks with subtasks, toggle some, close and reload -> Check if subtask completion state persists.

### 5.2 Offline Behavior
- [ ] Disable all network connections (turn off Wi-Fi/cellular).
- [ ] Run the app -> Verify the interface loads immediately with zero load latency and all features (CRUD, categories, custom styling) function normally.

### 5.3 Reminders & Alerts
- [ ] Set a due date reminder 1 minute in the future.
- [ ] Put the app in the background (Mobile).
- [ ] Verify that a push notification is delivered exactly at the set time.
- [ ] Tap the notification -> Verify that the app launches and navigates to the detailed task view.
