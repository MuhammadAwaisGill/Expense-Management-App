# Expense Manager

A beginner-friendly Flutter app to track expenses. Implements adding, viewing, grouping, filtering, and deleting expenses with persistent local storage.

---

## Project Overview
Build an expense management app using Flutter to practice core Flutter concepts: models, JSON (fromJson/toJson), local storage, widgets, navigation, and basic state management with `provider`.

### Objectives
- Implement the specified user stories.
- Apply basic Flutter concepts and widgets.
- Use classes and methods for expense operations.
- Persist data locally so it survives app restarts.

---

## Key Features
- List expenses to view spending history.
- Add expenses (payee, amount, date, notes, category, tag).
- Group expenses by category.
- Delete expenses.
- Manage categories and tags in settings.
- Persistent local storage.

---

## Concepts & Tech
- Dependencies: `intl`, `provider`, `collection`, `localstorage`
- Models: `Expense`, `Category`, `Tag` (each with `fromJson()` / `toJson()`)
- State: `ExpenseProvider extends ChangeNotifier`
- Storage methods: `_loadExpensesFromStorage()`, `_saveExpensesToStorage()`
- Provider methods: `addExpense()`, `addOrUpdateExpense()`, `removeExpense()`
- Widgets/screens: `AddCategoryDialog`, `AddTagDialog`, `AddExpenseScreen`, `CategoryManagementScreen`, `TagManagementScreen`, `HomeScreen`

---

## Minimal File Structure
lib/
├─ main.dart
├─ models/
│ ├─ expense.dart
│ ├─ category.dart
│ └─ tag.dart
├─ providers/
│ └─ expense_provider.dart
├─ screens/
│ ├─ home_screen.dart
│ ├─ add_expense_screen.dart
│ ├─ category_management_screen.dart
│ └─ tag_management_screen.dart
├─ widgets/
│ ├─ add_category_dialog.dart
│ ├─ add_tag_dialog.dart
│ └─ expense_tile.dart
└─ utils/
└─ storage_service.dart

---

## User Stories
- “I want to view a list of all my expenses to see my spending history at a glance.”
- “I want to add an expense with a payee, amount, notes, date, category, and tag.”
- “I want to save my expenses locally, so I do not lose them when I close and reopen the app.”
- “I want to group my expenses by category.”
- “I want to delete an expense to remove incorrect or unnecessary entries.”
- “I want to manage categories and tags in the app settings.”
