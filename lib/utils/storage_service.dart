import 'dart:convert';
import 'package:expense_management_app/models/category.dart';
import 'package:expense_management_app/models/tag.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/expense.dart';

class StorageService {

  static const String _kExpenses = 'expenses';
  static const String _kCategories = 'categories';
  static const String _kTags = 'tags';

  static Future<void> saveExpenses(List<Expense> expenses) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final List<Map<String, dynamic>> mapped =
      expenses.map((e) => e.toMap()).toList();

      final String encoded = jsonEncode(mapped);

      await prefs.setString(_kExpenses, encoded);
    } catch (e) {
      debugPrint('Error saving expenses: $e');
      rethrow;
    }
  }

  static Future<List<Expense>> loadExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? encoded = prefs.getString(_kExpenses);

      if (encoded == null || encoded.isEmpty) return <Expense>[];

      final List<dynamic> decoded = jsonDecode(encoded);

      return decoded.map((m) => Expense.fromMap(Map<String, dynamic>.from(m))).toList();
    } catch (e) {
      debugPrint('Error loading expenses: $e');
      return <Expense>[];
    }
  }

  static Future<void> saveCategories(List<Category> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final List<Map<String, dynamic>> mapped =
      categories.map((c) => c.toMap()).toList();

      final String encoded = jsonEncode(mapped);

      await prefs.setString(_kCategories, encoded);
    } catch (e) {
      debugPrint('Error saving categories: $e');
      rethrow;
    }
  }

  static Future<List<Category>> loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? encoded = prefs.getString(_kCategories);

      if (encoded == null || encoded.isEmpty) return <Category>[];

      final List<dynamic> decoded = jsonDecode(encoded);

      return decoded.map((m) => Category.fromMap(Map<String, dynamic>.from(m))).toList();
    } catch (e) {
      debugPrint('Error loading categories: $e');
      return <Category>[];
    }
  }

  static Future<void> saveTags(List<Tag> tags) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final List<Map<String, dynamic>> mapped =
      tags.map((t) => t.toMap()).toList();

      final String encoded = jsonEncode(mapped);

      await prefs.setString(_kTags, encoded);
    } catch (e) {
      debugPrint('Error saving tags: $e');
      rethrow;
    }
  }

  static Future<List<Tag>> loadTags() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? encoded = prefs.getString(_kTags);

      if (encoded == null || encoded.isEmpty) return <Tag>[];

      final List<dynamic> decoded = jsonDecode(encoded);

      return decoded.map((m) => Tag.fromMap(Map<String, dynamic>.from(m))).toList();
    } catch (e) {
      debugPrint('Error loading tags: $e');
      return <Tag>[];
    }
  }

  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_kTags);
      await prefs.remove(_kCategories);
      await prefs.remove(_kExpenses);
    } catch (e) {
      debugPrint('Error clearing all data: $e');
      rethrow;
    }
  }
}