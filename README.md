# 📋 todo-app-flutter

[![Platform Support](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web-blue?style=for-the-badge)](https://flutter.dev)
[![Architecture: Clean Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-brightgreen?style=for-the-badge)](file:///C:/Users/ALBIN/Desktop/main/Albin/DEV/todo-app/docs/technical-architecture.md)
[![State Management: Riverpod](https://img.shields.io/badge/State--Management-Riverpod-blueviolet?style=for-the-badge)](https://riverpod.dev)
[![Database: Hive](https://img.shields.io/badge/Database-Hive%20%28Offline--First%29-orange?style=for-the-badge)](https://pub.dev/packages/hive)

An offline-first, highly scalable, and beautifully designed Todo application built using **Flutter** and **Dart**. The project features an adaptive Material 3 UI design that adjusts seamlessly to mobile and widescreen viewports, backed by rigorous unit/widget test coverage, localized push notifications, and a robust feature-sliced architecture.

---

## 🌟 Highlights

*   **📱 Platform Independence**: Fully native support across Android, iOS, and Web environments.
*   **📐 Clean Architecture Design**: Organizes features (`todo` and `category`) into clean domain, data, and presentation layers for modular scalability.
*   **⚡ Local-First & Zero-Latency**: Utilizes Hive, an ultra-fast NoSQL local database, running adapters and caching queries with local index synchronization.
*   **🎨 Material 3 Premium Design System**: Employs elegant Indigo/Purple palettes, custom widgets, and a reactive dark/light theme toggle.
*   **🖥️ Responsive Layout Engine**: Dynamically matches device viewports, rearranging interfaces dynamically at a 768px width threshold.
*   **📝 Split-Pane Widescreen Details Editor**: Offers an inline widescreen editor containing checklists, category assignments, priority ratings, and due date pickers.
*   **🔔 Dual Platform Notifications**: Schedules tasks notifications using mobile-native alarms and browser-native fallback APIs.
*   **🧪 Bulletproof Test Coverage**: Verified by 86 unit and widget tests targeting controllers, serialization models, responsive layout rendering, and persistence survival.

---

## ℹ️ Overview

### Technical Architecture
This application departs from standard MVC/MVVM patterns by enforcing **Feature-First Clean Architecture**. Features are isolated into self-contained slices, dividing dependencies vertically rather than horizontally. This approach ensures code changes in one section (e.g., categories) never break another (e.g., task filters) and allows layers to be tested in isolation.

```
lib/
 ├── main.dart
 ├── core/
 │    ├── theme/           # Global theme controllers & Material 3 styles
 │    ├── services/        # Platform abstraction layers (Notifications)
 │    └── widgets/         # Shared presentation utilities
 └── features/
      ├── todo/            # Task-specific feature slice
      │    ├── data/       # Hive local boxes & serialization mappings
      │    ├── domain/     # Clean entities & repository interfaces
      │    └── presentation/# Riverpod controllers & view layers
      └── category/        # Category/Tag-specific feature slice
```

Each slice utilizes:
1.  **Data Layer**: Performs serialization and interfaces directly with Hive database boxes.
2.  **Domain Layer**: Establishes core Dart structures and abstract database rules, guaranteeing database implementations remain decoupled from UI states.
3.  **Presentation Layer**: Consists of reactive Riverpod widgets and controllers.

For details, refer to the [Technical Architecture Document](file:///C:/Users/ALBIN/Desktop/main/Albin/DEV/todo-app/docs/technical-architecture.md).

### Local Database Integration (Hive)
To facilitate seamless Web support alongside Android and iOS, the app leverages **Hive** as its storage foundation. Type adapters register immediately in [main.dart](file:///C:/Users/ALBIN/Desktop/main/Albin/DEV/todo-app/lib/main.dart) before the UI boots, opening boxes for categories and tasks asynchronously:
-   **Task Box**: Keeps record of task identifiers, completion status, due dates, categories, and references.
-   **Category Box**: Stores user-configured category tags, customized color keys, and code points.
-   On the Web platform, Hive automatically serializes data directly into the browser's native IndexedDB framework, ensuring persistence without requiring SQLite plugins.

### State Management (Riverpod)
The application utilizes [Riverpod](https://riverpod.dev) for dependency injection and state tracking, eliminating the risks of mutable global state:
-   `ThemeController` (defined in [theme_controller.dart](file:///C:/Users/ALBIN/Desktop/main/Albin/DEV/todo-app/lib/core/theme/theme_controller.dart)) manages global user settings (light/dark states) reactively.
-   `TodoListController` and `CategoryListController` track lists of items, apply dynamic text filters, order listings, and update cache boxes.

### Notification Pipeline
To deliver reliable alerts across platforms, a unified notification manager sits on top of an abstract service:
-   **Mobile Integration**: Schedules precise alarm managers via `flutter_local_notifications` inside [mobile_notification_service.dart](file:///C:/Users/ALBIN/Desktop/main/Albin/DEV/todo-app/lib/core/services/mobile_notification_service.dart).
-   **Web Integration**: Utilizes the standard HTML5 web worker standard inside [web_notification_service_web.dart](file:///C:/Users/ALBIN/Desktop/main/Albin/DEV/todo-app/lib/core/services/web_notification_service_web.dart), requesting permissions and presenting browser dialogs.

---

## 🚀 Usage

The application leverages a dynamic [ResponsiveLayout](file:///C:/Users/ALBIN/Desktop/main/Albin/DEV/todo-app/lib/core/widgets/responsive_layout.dart) container that changes structure based on a 768px viewport width threshold.

### Mobile Layout (< 768px)
*   **Navigation**: Powered by a bottom navigation bar switching between the active task list, categories manager, and system settings.
*   **Gestures**:
    *   **Swipe Right**: Toggles completion status.
    *   **Swipe Left**: Soft-deletes a task (sends it to the Trash).
*   **Creation Drawer**: A modular bottom sheet in [add_task_bottom_sheet.dart](file:///C:/Users/ALBIN/Desktop/main/Albin/DEV/todo-app/lib/features/todo/presentation/views/add_task_bottom_sheet.dart) handles validator forms, date configurations, priority selectors, and category binding.

### Widescreen/Desktop Layout (>= 768px)
*   **Navigation Rail**: A static left-side navigation rail provides access to main views.
*   **Split-Pane Interface**:
    *   **Left sidebar**: Lists tasks with instant filter search input and active category chips.
    *   **Right details panel**: Displays the active task inline, letting the user modify descriptions, title details, categories, due date/time, and compile checklists.
*   **Checklist Actions**: Add, complete, and delete subtasks inline inside [task_detail_pane.dart](file:///C:/Users/ALBIN/Desktop/main/Albin/DEV/todo-app/lib/features/todo/presentation/views/task_detail_pane.dart).

---

## ⬇️ Installation

### Prerequisites
*   [Flutter SDK](https://flutter.dev/docs/get-started/install) (Stable channel)
*   Dart SDK (bundled with Flutter)

### Setup & Run Steps

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/albinzdaniel02/todo-app-flutter.git
    cd todo-app-flutter
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Generate files (Hive adapters & Riverpod notifiers)**:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **Run in development mode**:
    ```bash
    flutter run
    ```

5.  **Build production release web bundle**:
    ```bash
    flutter build web --release --web-renderer canvaskit
    ```

---

## 🧪 Testing

The project maintains high stability through 86 automated unit and widget tests:

*   **Unit Tests** (`test/unit/`): Cover models, type serializers, data structures, and state transitions of Riverpod controllers.
*   **Widget & UI Tests** (`test/`): Validate interactive layouts, bottom sheets, swipe gestures, and theme triggers.

### Running Tests
To execute the complete test suite locally:
```bash
flutter test
```

### Key Test Suites:
*   [responsive_layout_test.dart](file:///C:/Users/ALBIN/Desktop/main/Albin/DEV/todo-app/test/responsive_layout_test.dart): Verifies layout switching at the 768px threshold.
*   [theme_and_responsiveness_test.dart](file:///C:/Users/ALBIN/Desktop/main/Albin/DEV/todo-app/test/theme_and_responsiveness_test.dart): Tests reactive theme state updates.
*   [swipe_gesture_test.dart](file:///C:/Users/ALBIN/Desktop/main/Albin/DEV/todo-app/test/swipe_gesture_test.dart): Assures gesture operations (swipe-to-complete, swipe-to-delete) behave correctly.
*   [add_task_bottom_sheet_test.dart](file:///C:/Users/ALBIN/Desktop/main/Albin/DEV/todo-app/test/add_task_bottom_sheet_test.dart): Tests input validators and due date scheduling setup.

---

## 💭 Feedback & Contributing

We welcome contributions to this project! If you encounter issues, have feature suggestions, or want to contribute enhancements, please get involved:

1.  **Report Issues**: Search existing issues or open a new one in the repository to discuss bugs or feature requests.
2.  **Submit Pull Requests**:
    *   Fork the repository.
    *   Create a clean branch (`git checkout -b feature/amazing-feature`).
    *   Ensure all tests pass (`flutter test`) and code analysis is clean (`flutter analyze`).
    *   Commit changes and open a PR for code review.

For instructions on branching guidelines and resume steps, refer to [recovery-guidelines.md](file:///C:/Users/ALBIN/Desktop/main/Albin/DEV/todo-app/docs/recovery-guidelines.md).
