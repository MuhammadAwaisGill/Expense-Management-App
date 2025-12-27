import 'package:expense_management_app/models/tag.dart';
import 'package:expense_management_app/models/category.dart';

class Expense {
  int id;
  String title;
  double amount;
  String date;
  Category category;
  Tag tag;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.tag,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date,
      'category': category.toMap(),
      'tag': tag.toMap(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: map['date'] as String,
      category: Category.fromMap(Map<String, dynamic>.from(map['category'])),
      tag: Tag.fromMap(Map<String, dynamic>.from(map['tag'])),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Expense &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}