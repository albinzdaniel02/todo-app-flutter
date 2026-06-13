---
name: implement-todo
description: Automatically implement tasks from the Flutter Todo App task checklist (todo.md), following a strict git branching, PR creation, code review subagent, and CI/CD workflow. Ensure the main branch is aligned with remote before branching.
---

# Implement Todo Skill

This skill guides the AI assistant through the process of implementing the Flutter Todo App features, following a strict workflow to maintain repository hygiene and ensure code quality.

## Mandatory Workflow Instructions

For every task listed in [todo.md](file:///C:/Users/ALBIN/Desktop/main/Albin/DEV/todo-app/todo.md) (e.g., `P0-1`, `P1-2`), the agent must execute the following workflow steps:

### 1. Identify the Next Task
Read [todo.md](file:///C:/Users/ALBIN/Desktop/main/Albin/DEV/todo-app/todo.md) and find the first incomplete task (marked with `- [ ]`).

### 2. Align Main with Remote (CRITICAL)
Before creating any task branch, ensure your local `main` branch is fully aligned with the remote repository to prevent outdated code issues or conflicts.
Run:
```bash
git checkout main
git fetch origin
git pull origin main
```
Confirm that there are no uncommitted changes and that the local `main` branch is up to date with `origin/main`.

### 3. Create the Task Branch
Create and switch to a new branch named exactly after the task:
```bash
git checkout -b <task-name>
```
*Example:* `git checkout -b P0-1`

### 4. Implement the Feature
Implement the code modifications or setup described in the task checklist. Ensure the implementation aligns with the technical documentation in the `docs/` folder (such as requirements, technical architecture, and solution design).

### 5. Local Verification
Run local linting, formatting, and testing checks before pushing:
```bash
flutter format --set-exit-if-changed .
flutter analyze
flutter test
```

### 6. Make Clean, Atomic Commits
Commit changes with clear, descriptive commit messages. Keep commits focused and atomic.
```bash
git add .
git commit -m "feat(<task-name>): short description of implementation"
```

### 7. Push and Create Pull Request
Push the task branch to the remote repository:
```bash
git push -u origin <task-name>
```
Create a Pull Request using the GitHub CLI (`gh`):
```bash
gh pr create --title "<task-name>: short description" --body "Closes <task-name>"
```

### 8. Code Review Subagent
Launch a code review subagent to inspect the PR's diff and identify potential issues.
1. Use `define_subagent` to define a code reviewer if not already defined:
   - **Name**: `pr-reviewer`
   - **Description**: "Reviews PR diffs for quality, architectural alignment, style guide conformity, and correctness."
   - **System Prompt**: A prompt instructing the subagent to carefully review the git diff and provide criticisms.
2. Use `invoke_subagent` to run the review:
   - **Prompt**: Pass the output of `gh pr diff` and ask the reviewer to analyze it.
3. Address any comments or feedback provided by the reviewer by modifying the code on the same branch, committing, and pushing.

### 9. CI/CD Checks
Monitor the CI checks on the PR using the GitHub CLI or checking status:
```bash
gh pr status
```
Wait until all checks pass successfully.

### 10. Merge and Cleanup
Once approved and CI checks pass, merge the PR:
```bash
gh pr merge --squash --delete-branch
```
Switch back to `main` and pull the merged changes:
```bash
git checkout main
git pull origin main
```

### 11. Update Checklist
Modify [todo.md](file:///C:/Users/ALBIN/Desktop/main/Albin/DEV/todo-app/todo.md) to mark the task as complete (change `[ ]` to `[x]`). Commit and push this change to `main`:
```bash
git add todo.md
git commit -m "docs: mark <task-name> as completed"
git push origin main
```

---

## Tasks Reference Checklist

### Phase 0: Setup and CI/CD (`P0`)
- **P0-1**: Initialize Flutter project in the root folder.
  - `flutter create --org com.todoapp --platforms android,ios,web .`
- **P0-2**: Configure `pubspec.yaml` with required dependencies:
  - `flutter_riverpod`, `riverpod_annotation`, `hive`, `hive_flutter`, `uuid`, `equatable`, `intl`, `flutter_local_notifications`, `timezone`
  - Dev dependencies: `build_runner`, `riverpod_generator`, `hive_generator`
- **P0-3**: Create GitHub Actions CI workflow (`.github/workflows/ci.yml`):
  - Run static analysis (`flutter analyze`), format check (`flutter format --set-exit-if-changed .`), and tests (`flutter test`) on every pull request to `main`.

### Phase 1: Local Database & Schema (`P1`)
- **P1-1**: Implement `Subtask` database model with Hive annotations and run code generator.
- **P1-2**: Implement `Category` database model with Hive annotations and run code generator.
- **P1-3**: Implement main `Task` database model containing subtasks list, category relationships, and priority enum mapping. Run generator.
- **P1-4**: Implement database bootstrapper in `main.dart` (initialize Hive, register type adapters, and open boxes).

### Phase 2: Repository Layer (`P2`)
- **P2-1**: Design abstract repository interfaces `TodoRepository` and `CategoryRepository`.
- **P2-2**: Implement `HiveCategoryRepository` to support reading streams of custom categories and saving/deleting them.
- **P2-3**: Implement `HiveTodoRepository` to manage database operations (reading active tasks, archives, trashed/soft-deleted items).

### Phase 3: State Management (`P3`)
- **P3-1**: Implement Riverpod `CategoryListController` to expose and manipulate categories.
- **P3-2**: Implement Riverpod `TodoListController` to manage task creation, completion toggles, subtask updates, filters, search queries, archiving, and soft-deletes.

### Phase 4: Platform Services & Notifications (`P4`)
- **P4-1**: Define abstract `NotificationService` interface.
- **P4-2**: Implement `MobileNotificationService` using `flutter_local_notifications` (handling alarms, icon channels, permissions).
- **P4-3**: Implement `WebNotificationService` fallback (HTML5 Notifications API and graceful permission handling).
- **P4-4**: Build a unified notification controller that schedules or cancels notifications based on task due date changes.

### Phase 5: Mobile UI (`P5`)
- **P5-1**: Setup Material 3 Design System colors, theme providers, and light/dark theme toggle logic.
- **P5-2**: Build mobile Home View containing navigation tabs, search/filter bar, and lists of tasks.
- **P5-3**: Build Task Tile Card with swipe gestures (swipe-left to soft-delete/archive, swipe-right to toggle completion).
- **P5-4**: Build Bottom Sheet Task Creator with forms, due date picker, priority selector, and category dropdown.
- **P5-5**: Build Category management lists (add/edit tags with custom colors) and Trash/Archive views.

### Phase 6: Web & Responsive UI (`P6`)
- **P6-1**: Create a responsive `ResponsiveLayout` wrapper component to switch layouts based on viewport width.
- **P6-2**: Build widescreen left navigation sidebar/rail.
- **P6-3**: Build widescreen split-pane layout (Middle: scrollable task list; Right: side sheet editor showing notes, subtask checklist, and metadata).

### Phase 7: Testing & Final Polish (`P7`)
- **P7-1**: Write unit tests for database models and Riverpod state controllers.
- **P7-2**: Write widget tests checking light/dark mode and responsive layouts.
- **P7-3**: Conduct manual QA validations for database state persistence and offline usage.
