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
  }

  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    await StorageService.saveExpenses(_expenses);
    notifyListeners();
  }

  Future<void> deleteExpense(int id) async {
    _expenses.removeWhere((e) => e.id == id);
    await StorageService.saveExpenses(_expenses);
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    _categories.add(category);
    await StorageService.saveCategories(_categories);
    notifyListeners();
  }

  Future<void> deleteCategory(int id) async {
    final deleted = _categories.firstWhere(
            (c) => c.id == id,
        orElse: () => Category(id: -1, name: "", colorValue: 0xFFFF0000)
    );
    if (deleted.id == -1) return;

    for (var e in _expenses) {
      if (e.category.id == id) {
        e.category = _defaultCategory;
      }
    }

    _categories.removeWhere((c) => c.id == id);
    await StorageService.saveCategories(_categories);
    await StorageService.saveExpenses(_expenses);
    notifyListeners();
  }

  Future<void> updateCategory(Category updatedCategory) async {
    final index = _categories.indexWhere((c) => c.id == updatedCategory.id);
    if (index != -1) {
      _categories[index] = updatedCategory;
      await StorageService.saveCategories(_categories);
      notifyListeners();
    }
  }

  Future<void> addTag(Tag tag) async {
    _tags.add(tag);
    await StorageService.saveTags(_tags);
    notifyListeners();
  }

  Future<void> deleteTag(int id) async {
    final deleted = _tags.firstWhere(
            (t) => t.id == id,
        orElse: () => Tag(id: -1, name: "")
    );
    if (deleted.id == -1) return;

    for (var e in _expenses) {
      if (e.tag.id == id) {
        e.tag = _defaultTag;
      }
    }

    _tags.removeWhere((t) => t.id == id);
    await StorageService.saveTags(_tags);
    await StorageService.saveExpenses(_expenses);
    notifyListeners();
  }

  Future<void> updateTag(Tag updatedTag) async {
    final index = _tags.indexWhere((t) => t.id == updatedTag.id);
    if (index != -1) {
      _tags[index] = updatedTag;
      await StorageService.saveTags(_tags);
      notifyListeners();
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