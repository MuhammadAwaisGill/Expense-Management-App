import 'package:flutter/material.dart';

class Category {
  int id;
  String name;
  int colorValue;

  Category ({
    required this.id,
    required this.name,
    required this.colorValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      colorValue: map['colorValue'] as int,
    );
  }
}