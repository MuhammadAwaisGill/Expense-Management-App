import 'package:expense_management_app/models/category.dart';
import 'package:expense_management_app/models/expense.dart';
import 'package:expense_management_app/models/tag.dart';
import 'package:expense_management_app/utils/storage_service.dart';
import 'package:flutter/material.dart';

class ExpenseProvider extends ChangeNotifier {

  List<Expense> _expenses = [];
  List<Category> _categories = [];
  List<Tag> _tags = [];

  List<Expense> get expenses => _expenses;

  final Category _defaultCategory = Category(id: -1, name: 'Uncategorized', colorValue: 0xFF9E9E9E);
  final Tag _defaultTag = Tag(id: -1, name: 'None');

  Category get defaultCategory => _defaultCategory;
  Tag get defaultTag => _defaultTag;

  List<Category> get categories => [_defaultCategory, ..._categories];
  List<Tag> get tags => [_defaultTag, ..._tags];

  final List<Category> _defaultCategories = [
    Category(id: 1, name: 'Food', colorValue: Colors.orange.value),
    Category(id: 2, name: 'Transport', colorValue: Colors.blue.value),
    Category(id: 3, name: 'Shopping', colorValue: Colors.purple.value),
    Category(id: 4, name: 'Bills', colorValue: Colors.red.value),
    Category(id: 5, name: 'Entertainment', colorValue: Colors.green.value),
  ];

  final List<Tag> _defaultTags = [
    Tag(id: 101, name: 'Urgent'),
    Tag(id: 102, name: 'Monthly'),
    Tag(id: 103, name: 'Personal'),
    Tag(id: 104, name: 'Work'),
  ];

  Future<void> updateExpense(Expense updatedExpense) async {
    final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
    if (index != -1) {
      _expenses[index] = updatedExpense;
      await StorageService.saveExpenses(_expenses);
      notifyListeners();
    }
  }

  Future<void> loadData() async {
    try {
      _expenses = await StorageService.loadExpenses();
      _categories = await StorageService.loadCategories();
      _tags = await StorageService.loadTags();

      if (_categories.isEmpty) {
        _categories.addAll(_defaultCategories);
        await StorageService.saveCategories(_categories);
      }

      if (_tags.isEmpty) {
        _tags.addAll(_defaultTags);
        await StorageService.saveTags(_tags);
      }

      notifyListeners();
    } catch (e) {
      // Log error or handle it appropriately
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      _expenses.add(expense);
      await StorageService.saveExpenses(_expenses);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding expense: $e');
      rethrow;
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      _expenses.removeWhere((e) => e.id == id);
      await StorageService.saveExpenses(_expenses);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      rethrow;
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      _categories.add(category);
      await StorageService.saveCategories(_categories);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      final deleted = _categories.firstWhere(
              (c) => c.id == id,
          orElse: () => Category(id: -1, name: "", colorValue: 0xFFFF0000)
      );
      if (deleted.id == -1) return;

      // Create new expense objects with updated category instead of mutating
      for (int i = 0; i < _expenses.length; i++) {
        if (_expenses[i].category.id == id) {
          _expenses[i] = Expense(
            id: _expenses[i].id,
            title: _expenses[i].title,
            amount: _expenses[i].amount,
            date: _expenses[i].date,
            category: _defaultCategory,
            tag: _expenses[i].tag,
          );
        }
      }

      _categories.removeWhere((c) => c.id == id);
      await StorageService.saveCategories(_categories);
      await StorageService.saveExpenses(_expenses);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(Category updatedCategory) async {
    try {
      final index = _categories.indexWhere((c) => c.id == updatedCategory.id);
      if (index != -1) {
        _categories[index] = updatedCategory;

        // Update all expenses that reference this category
        for (int i = 0; i < _expenses.length; i++) {
          if (_expenses[i].category.id == updatedCategory.id) {
            _expenses[i] = Expense(
              id: _expenses[i].id,
              title: _expenses[i].title,
              amount: _expenses[i].amount,
              date: _expenses[i].date,
              category: updatedCategory,
              tag: _expenses[i].tag,
            );
          }
        }

        await StorageService.saveCategories(_categories);
        await StorageService.saveExpenses(_expenses);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating category: $e');
      rethrow;
    }
  }

  Future<void> addTag(Tag tag) async {
    try {
      _tags.add(tag);
      await StorageService.saveTags(_tags);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding tag: $e');
      rethrow;
    }
  }

  Future<void> deleteTag(int id) async {
    try {
      final deleted = _tags.firstWhere(
              (t) => t.id == id,
          orElse: () => Tag(id: -1, name: "")
      );
      if (deleted.id == -1) return;

      // Create new expense objects with updated tag instead of mutating
      for (int i = 0; i < _expenses.length; i++) {
        if (_expenses[i].tag.id == id) {
          _expenses[i] = Expense(
            id: _expenses[i].id,
            title: _expenses[i].title,
            amount: _expenses[i].amount,
            date: _expenses[i].date,
            category: _expenses[i].category,
            tag: _defaultTag,
          );
        }
      }

      _tags.removeWhere((t) => t.id == id);
      await StorageService.saveTags(_tags);
      await StorageService.saveExpenses(_expenses);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting tag: $e');
      rethrow;
    }
  }

  Future<void> updateTag(Tag updatedTag) async {
    try {
      final index = _tags.indexWhere((t) => t.id == updatedTag.id);
      if (index != -1) {
        _tags[index] = updatedTag;

        // Update all expenses that reference this tag
        for (int i = 0; i < _expenses.length; i++) {
          if (_expenses[i].tag.id == updatedTag.id) {
            _expenses[i] = Expense(
              id: _expenses[i].id,
              title: _expenses[i].title,
              amount: _expenses[i].amount,
              date: _expenses[i].date,
              category: _expenses[i].category,
              tag: updatedTag,
            );
          }
        }

        await StorageService.saveTags(_tags);
        await StorageService.saveExpenses(_expenses);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating tag: $e');
      rethrow;
    }
  }

  double get totalAmount {
    double sum = 0;
    for (var e in _expenses) {
      sum += e.amount;
    }
    return sum;
  }
}