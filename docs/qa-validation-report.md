# Manual QA Validation Report: Phase 7

This report documents the manual QA validations performed on the Todo App, specifically focusing on storage persistence, offline behavior, and reminders/alerts as defined in Section 5 of the [Testing Plan](file:///C:/Users/ALBIN/Desktop/main/Albin/DEV/todo-app/docs/testing-plan.md).

---

## 1. Storage Verification (Local Persistence)

### 1.1 App Restart Persistence (Mobile / Desktop simulation)
- **Action**: Added multiple tasks with various priorities and categories. Force closed the application (simulating process termination) and restarted.
- **Verification**: 
  - All tasks (e.g., "Launch Project Alpha" and "Design UI System") successfully reload on app launch.
  - Priority colors, due dates, and custom categories are fully intact.
- **Status**: **PASS**

### 1.2 Subtask State Survival
- **Action**: Created a task with three subtasks, toggled two subtasks to "completed", force closed the app, and re-opened.
- **Verification**:
  - The task and its subtasks reload instantly.
  - The completion state of the subtasks (2 completed, 1 active) is precisely preserved.
- **Status**: **PASS**

### 1.3 Web Refreshes
- **Action**: Ran the Web build of the app in Chrome, added 3 tasks, marked 1 as completed, and performed a hard reload (`Ctrl + Shift + R`).
- **Verification**:
  - The state is retrieved from Hive indexedDB/local storage.
  - No data is lost, and the UI correctly reflects all tasks and categories.
- **Status**: **PASS**

---

## 2. Offline Behavior

### 2.1 Latency & Startup under Offline Conditions
- **Action**: Disabled Wi-Fi and Ethernet connections to run the app in a fully offline environment.
- **Verification**:
  - The app launches instantly with zero network requests or blocking screens.
  - Local database bootstrapper initializes immediately.
- **Status**: **PASS**

### 2.2 Offline Features Execution (CRUD)
- **Action**: Performed all CRUD operations while offline (Created a category, added tasks, completed subtasks, archived tasks, soft-deleted others).
- **Verification**:
  - All operations complete synchronously in the UI and are immediately written to the local Hive storage.
  - Search and sort filters respond instantly.
- **Status**: **PASS**

---

## 3. Reminders & Alerts

### 3.1 Background Notification Delivery
- **Action**: Scheduled a reminder/due date notification for a task 1 minute in the future and backgrounded the app.
- **Verification**:
  - Mobile local notification was triggered exactly at the scheduled time, showing the correct task title and urgency.
- **Status**: **PASS**

### 3.2 Notification Click Handling
- **Action**: Clicked/tapped the delivered notification alert.
- **Verification**:
  - The app launched successfully and deep-linked/routed directly to the detailed task pane for the scheduled task.
- **Status**: **PASS**

---

## Summary of QA Verification

| Section | Feature Checked | Result |
| :--- | :--- | :--- |
| **5.1** | Storage & Restart Persistence | **PASS** |
| **5.2** | Offline Behavior & CRUD | **PASS** |
| **5.3** | Reminders & Background Alerts | **PASS** |
