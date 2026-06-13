# Implementation Plan: Flutter Todo App

This document outlines the step-by-step development roadmap for implementing the offline-first Todo application across mobile and web platforms.

---

## Phase 1: Initial Setup & Configuration (Est: Day 1)

### 1.1 Flutter Project Creation
- Initialize the project with target platform configurations:
  ```bash
  flutter create --org com.todoapp --platforms android,ios,web todo_app
  ```

### 1.2 Dependency Integration
- Configure `pubspec.yaml` with the following packages:
  - **State Management**: `flutter_riverpod`, `riverpod_annotation`
  - **Local Database**: `hive`, `hive_flutter`
  - **Utilities**: `uuid`, `equatable`, `intl`
  - **Notifications**: `flutter_local_notifications`, `timezone`
  - **Dev Dependencies**: `build_runner`, `riverpod_generator`, `hive_generator`

### 1.3 Folder Setup
- Scaffold the feature-first directory layout under the `lib/` directory:
  - `core/` (services, theme, utils)
  - `features/todo/` (data, domain, presentation)
  - `features/category/` (data, domain, presentation)

---

## Phase 2: Database Layer & Data Models (Est: Day 2)

### 2.1 Hive Adapters & Annotations
- Create Hive models for `Task`, `Subtask`, and `Category` with corresponding `@HiveType` and `@HiveField` decorators.
- Run code generation:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

### 2.2 Database Initialization
- Implement database startup checks in `main.dart`:
  - Initialize Hive inside `main()` using `Hive.initFlutter()`.
  - Register adapters.
  - Open essential boxes (`tasks`, `categories`).

---

## Phase 3: Domain & Data Repositories (Est: Day 2-3)

### 3.1 Repository Interfaces (Domain)
- Create `TodoRepository` and `CategoryRepository` abstract interfaces.

### 3.2 Hive Repository Implementation (Data)
- Write the database concrete implementations:
  - `HiveTodoRepository`: Exposes reactive streams via Hive streams or box listeners.
  - `HiveCategoryRepository`: Handles saving, deleting, and fetching categories.

---

## Phase 4: State Management & Controllers (Est: Day 3-4)

### 4.1 Riverpod Providers
- Setup Riverpod notifiers:
  - `TodoListController` (manages task CRUD, state updates, filters, and sorting).
  - `CategoryListController` (manages tags/categories).
- Implement test mocks for these controllers.

---

## Phase 5: Notification Service (Est: Day 4)

### 5.1 Abstract Service Configuration
- Implement `NotificationService` wrapper.
- **Android**: Configure custom alarm channels, notifications icon, and receiver configurations in `AndroidManifest.xml`.
- **iOS**: Request user alert/sound permissions on launch.
- **Web**: Setup local timers and check `Notification.permission` statuses.

---

## Phase 6: Presentation / UI Layer (Est: Day 5-6)

### 6.1 Theme & UI Core
- Set up a clean Material 3 design system with custom light and dark color schemes (deep indigo, purples, slate grays).

### 6.2 Mobile Views (Portrait UI)
- Construct the `HomeScreen` navigation tabs.
- Implement the task cards (with swipe-to-dismiss support).
- Create the "Create Task" task composer bottom sheet.

### 6.3 Web Views (Responsive Widescreen UI)
- Create a layout builder (`LayoutBuilder`) to toggle layouts based on screen size.
- Construct the widescreen split-pane dashboard (Left navigation rail, Middle task list, Right detail side-sheet).

---

## Phase 7: Optimization, Polish & Deployment (Est: Day 7)

### 7.1 Testing & Validations
- Verify database state updates across app restarts.
- Test notification alarms trigger exactly on schedule.
- Validate web IndexedDB persists across page refreshes.

### 7.2 Release Preparation
- Mobile: Configure launcher icons and keystores.
- Web: Build and verify optimized production JS bundle:
  ```bash
  flutter build web --release --web-renderer canvaskit
  ```
