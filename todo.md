# Task Checklist: Flutter Todo App

This checklist tracks progress throughout the implementation phase. Each task corresponds to a feature or setup step and must be completed in its own branch using atomic commits and the PR review workflow.

---

## Workflow Instructions (Mandatory)

1. **Branching**: For every task (e.g. `P0-1`, `P3-2`), create and switch to a branch of the exact same name:
   ```bash
   git checkout -b <task-name>
   ```
2. **Commits**: Make atomic, clean commits for changes.
3. **Pull Request (PR)**:
   - Push the branch to GitHub: `git push -u origin <task-name>`
   - Create a Pull Request using `gh cli`:
     ```bash
     gh pr create --title "task-name: short description" --body "Closes task-name"
     ```
4. **Code Review Subagent**:
   - Define and launch a new subagent (using `define_subagent` and `invoke_subagent`) with minimal context. Prompt it to review the PR code changes (`gh pr diff` output) and add comments or criticisms.
   - Address any comments or feedback in the branch.
5. **CI Checking**:
   - If CI checks are running, wait for the GitHub Action status. Ensure all checks pass.
6. **Merge & Cleanup**:
   - Merge the PR to `main` branch: `gh pr merge --squash --delete-branch`
   - Switch back to `main` and pull: `git checkout main && git pull`

---

## Phase 0: Setup and CI/CD (`P0`)

- [x] **P0-1**: Initialize Flutter project in the root folder.
  - Commands: `flutter create --org com.todoapp --platforms android,ios,web .`
- [x] **P0-2**: Configure `pubspec.yaml` with required dependencies:
  - `flutter_riverpod`, `riverpod_annotation`, `hive`, `hive_flutter`, `uuid`, `equatable`, `intl`, `flutter_local_notifications`, `timezone`
  - Dev dependencies: `build_runner`, `riverpod_generator`, `hive_generator`
- [x] **P0-3**: Create GitHub Actions CI workflow (`.github/workflows/ci.yml`):
  - Run static analysis (`flutter analyze`), format check (`flutter format --set-exit-if-changed .`), and tests (`flutter test`) on every pull request to `main`.

### P0 Exit Checks
- [x] Flutter project files successfully initialized in root.
- [x] All dependencies resolved correctly with `flutter pub get`.
- [x] CI workflow file exists and triggers on pull requests.

---

## Phase 1: Local Database & Schema (`P1`)

- [x] **P1-1**: Implement `Subtask` database model with Hive annotations and run code generator.
- [x] **P1-2**: Implement `Category` database model with Hive annotations and run code generator.
- [x] **P1-3**: Implement main `Task` database model containing subtasks list, category relationships, and priority enum mapping. Run generator.
- [x] **P1-4**: Implement database bootstrapper in `main.dart` (initialize Hive, register type adapters, and open boxes).

### P1 Exit Checks
- [x] `g.dart` adapters successfully generated for all Hive models.
- [x] Database bootstraps successfully without errors on app startup.

---

## Phase 2: Repository Layer (`P2`)

- [x] **P2-1**: Design abstract repository interfaces `TodoRepository` and `CategoryRepository`.
- [x] **P2-2**: Implement `HiveCategoryRepository` to support reading streams of custom categories and saving/deleting them.
- [x] **P2-3**: Implement `HiveTodoRepository` to manage database operations (reading active tasks, archives, trashed/soft-deleted items).

### P2 Exit Checks
- [x] Repository boundaries cleanly separate database entities from domains.
- [x] All database actions are reactive and emit updates via Streams.

---

## Phase 3: State Management (`P3`)

- [x] **P3-1**: Implement Riverpod `CategoryListController` to expose and manipulate categories.
- [x] **P3-2**: Implement Riverpod `TodoListController` to manage task creation, completion toggles, subtask updates, filters, search queries, archiving, and soft-deletes.

### P3 Exit Checks
- [x] Controllers are stateful, predictable, and handle modifications cleanly without UI dependencies.
- [x] Code generation runs successfully with Riverpod annotations.

---

## Phase 4: Platform Services & Notifications (`P4`)

- [x] **P4-1**: Define abstract `NotificationService` interface.
- [x] **P4-2**: Implement `MobileNotificationService` using `flutter_local_notifications` (handling alarms, icon channels, permissions).
- [ ] **P4-3**: Implement `WebNotificationService` fallback (HTML5 Notifications API and graceful permission handling).
- [ ] **P4-4**: Build a unified notification controller that schedules or cancels notifications based on task due date changes.

### P4 Exit Checks
- [ ] Notifications scheduling compiles and executes smoothly on mobile view.
- [ ] Web application runs without crashing when accessing the notification service.

---

## Phase 5: Mobile UI (`P5`)

- [ ] **P5-1**: Setup Material 3 Design System colors, theme providers, and light/dark theme toggle logic.
- [ ] **P5-2**: Build mobile Home View containing navigation tabs, search/filter bar, and lists of tasks.
- [ ] **P5-3**: Build Task Tile Card with swipe gestures (swipe-left to soft-delete/archive, swipe-right to toggle completion).
- [ ] **P5-4**: Build Bottom Sheet Task Creator with forms, due date picker, priority selector, and category dropdown.
- [ ] **P5-5**: Build Category management lists (add/edit tags with custom colors) and Trash/Archive views.

### P5 Exit Checks
- [ ] Mobile view renders cleanly on Android/iOS simulators.
- [ ] Swipe gestures trigger the correct database mutations.

---

## Phase 6: Web & Responsive UI (`P6`)

- [ ] **P6-1**: Create a responsive `ResponsiveLayout` wrapper component to switch layouts based on viewport width.
- [ ] **P6-2**: Build widescreen left navigation sidebar/rail.
- [ ] **P6-3**: Build widescreen split-pane layout (Middle: scrollable task list; Right: side sheet editor showing notes, subtask checklist, and metadata).

### P6 Exit Checks
- [ ] Interface switches seamlessly when resizing window (e.g. crossing 768px width).
- [ ] Selecting tasks on Web opens details immediately in the right pane.

---

## Phase 7: Testing & Final Polish (`P7`)

- [ ] **P7-1**: Write unit tests for database models and Riverpod state controllers.
- [ ] **P7-2**: Write widget tests checking light/dark mode and responsive layouts.
- [ ] **P7-3**: Conduct manual QA validations for database state persistence and offline usage.

### P7 Exit Checks
- [ ] 100% of unit and widget tests pass.
- [ ] Database state survives full application restarts and web refreshes.
