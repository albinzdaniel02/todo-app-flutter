# UI Wireframes & Layout Mockups: Flutter Todo App

This document outlines the UI layout design for both Mobile and Web/Widescreen views, featuring ASCII layout mappings and visual mockup renders.

---

## 1. Mobile Layout Wireframe

### 1.1 Home / Active Tasks Screen
```text
+------------------------------------------+
|  [=]  My Tasks              (Search) [Q] |
|  --------------------------------------  |
|  (All)  (Work)  (Personal)  (Shopping)   |  <- Category Filter Chips
|  --------------------------------------  |
|  [ ] Buy groceries                       |  <- Task Card
|      [High]  [Shopping]  [Due: Today]    |  
|                                          |
|  [x] Prep team presentation              |  <- Completed Task (Strike-through)
|      [Medium]  [Work]                    |
|                                          |
|  [ ] Book dental appointment             |  
|      [Low]  [Due: 18 Jun, 14:00]         |  <- Task with Notification Alarm
|                                          |
|                                     (+)  |  <- Floating Add Button
+------------------------------------------+
|   [List] Todo   [Category] Tags   [Setting] | <- Bottom Navigation Bar
+------------------------------------------+
```

### 1.2 Task Details & Subtasks Sheet
```text
+------------------------------------------+
|  [X] Close                         [Save] |
|  --------------------------------------  |
|  Title: Buy groceries                    |
|  Description: Milk, eggs, and bread      |
|  --------------------------------------  |
|  Category: [ Shopping v ]                |
|  Priority: [ Low ]  [ Medium ]  [*High*] |
|  Due Date: [ 15 Jun 2026, 10:00 AM ]     |
|  --------------------------------------  |
|  Checklist / Subtasks:                   |
|  [x] Buy milk                            |
|  [ ] Buy eggs                            |
|  [ ] Buy bread                           |
|  [+ Add Subtask]                         |
|  --------------------------------------  |
|  [Delete Task]                           |
+------------------------------------------+
```

### 1.3 Mobile Mockup Render
![Mobile Wireframe Mockup](file:///C:/Users/ALBIN/.gemini/antigravity-cli/brain/008f787e-bd77-4d90-8195-c745deccba72/todo_mobile_view_1781284011335.png)

---

## 2. Web / Widescreen Layout Wireframe

On desktop and web screens, the layout leverages a split-pane interface to maximize real estate and prevent unnecessary context switching.

```text
+-----------------------------------------------------------------------------+
| [=] Todo Dashboard                      (Search Tasks...) [Q]  [Theme Switch] |
+-----------+-----------------------------------------+-----------------------+
|  Tasks    | [All]  [Work]  [Personal]  [Filter v]   | Task Details          |
|  Category | --------------------------------------- | --------------------- |
|  Archive  | [ ] Buy groceries                       | Title: Buy groceries  |
|  Trash    |     [High]  [Shopping]                  |                       |
|           |                                         | [x] Buy milk          |
|  Settings | [x] Prep team presentation              | [ ] Buy eggs          |
|           |     [Medium]  [Work]                    | [ ] Buy bread         |
|           |                                         |                       |
|           | [ ] Book dental appointment             | Priority: [ High ]    |
|           |     [Low]  [Due: 18 Jun]                | Due: 15 Jun, 10:00 AM |
|           |                                         |                       |
|           |                                         | [Save]    [Delete]    |
+-----------+-----------------------------------------+-----------------------+
```

### 2.1 Web Mockup Render
![Widescreen Web Wireframe Mockup](file:///C:/Users/ALBIN/.gemini/antigravity-cli/brain/008f787e-bd77-4d90-8195-c745deccba72/todo_web_view_1781284028761.png)
