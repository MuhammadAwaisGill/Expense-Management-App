
import 'dart:convert';
import 'package:expense_management_app/models/category.dart';
import 'package:expense_management_app/models/tag.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class StorageService {

  static const String _kExpenses = 'expenses';
  static const String _kCategories = 'categories';
  static const String _kTags = 'tags';

  static Future<void> saveExpenses(List<Expense> expenses) async {

    final prefs = await SharedPreferences.getInstance();

    final List<Map<String, dynamic>> mapped =
        expenses.map((e) => e.toMap()).toList();

    final String encoded = jsonEncode(mapped);

    await prefs.setString(_kExpenses, encoded);
  }

  static Future<List<Expense>> loadExpenses() async {

    final prefs = await SharedPreferences.getInstance();

    final String? encoded = prefs.getString(_kExpenses);

    if (encoded == null || encoded.isEmpty) return <Expense>[];

    final List<dynamic> decoded = jsonDecode(encoded);

    return decoded.map((m) => Expense.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  static Future<void> saveCategories(List<Category> categories) async {

    final prefs = await SharedPreferences.getInstance();

    final List<Map<String, dynamic>> mapped =
        categories.map((c) => c.toMap()).toList();

    final String encoded = jsonEncode(mapped);

    await prefs.setString(_kCategories, encoded);
  }

  static Future<List<Category>> loadCategories() async {

    final prefs = await SharedPreferences.getInstance();

    final String? encoded = prefs.getString(_kCategories);

    if (encoded == null || encoded.isEmpty) return <Category>[];

    final List<dynamic> decoded = jsonDecode(encoded);

    return decoded.map((m) => Category.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  static Future<void> saveTags(List<Tag> tags) async {

    final prefs = await SharedPreferences.getInstance();

    final List<Map<String, dynamic>> mapped =
        tags.map((t) => t.toMap()).toList();

    final String encoded = jsonEncode(mapped);

    await prefs.setString(_kTags, encoded);
  }

  static Future<List<Tag>> loadTags() async {

    final prefs = await SharedPreferences.getInstance();

    final String? encoded = prefs.getString(_kTags);

    if (encoded == null || encoded.isEmpty) return <Tag>[];

    final List<dynamic> decoded = jsonDecode(encoded);

    return decoded.map((m) => Tag.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  static Future<void> clearAll() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_kTags);

    await prefs.remove(_kCategories);

    await prefs.remove(_kExpenses);
  }

}

