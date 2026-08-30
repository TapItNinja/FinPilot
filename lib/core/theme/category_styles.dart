//lib/core/theme/category_styles.dart
import 'package:flutter/material.dart';

class CategoryStyle {
  final IconData icon;
  final Color color;

  const CategoryStyle(this.icon, this.color);
}

const Map<String, CategoryStyle> categoryStyles = {
  'Food': CategoryStyle(Icons.restaurant_rounded, Color(0xFFFF9F43)),

  'Shopping': CategoryStyle(Icons.shopping_bag_rounded, Color(0xFF6C63FF)),

  'Transport': CategoryStyle(Icons.directions_car_rounded, Color(0xFF48DBFB)),

  'Entertainment': CategoryStyle(Icons.movie_rounded, Color(0xFFFF6B81)),

  'Utilities': CategoryStyle(Icons.bolt_rounded, Color(0xFFFECA57)),

  'Health': CategoryStyle(Icons.favorite_rounded, Color(0xFFFF6B6B)),

  'Finance': CategoryStyle(Icons.account_balance_rounded, Color(0xFF2DC78B)),

  'Education': CategoryStyle(Icons.school_rounded, Color(0xFF54A0FF)),

  'Income': CategoryStyle(Icons.south_west_rounded, Color(0xFF2DC78B)),

  'Uncategorized': CategoryStyle(Icons.help_outline_rounded, Color(0xFF8395A7)),
};

CategoryStyle getCategoryStyle(String category) {
  return categoryStyles[category] ??
      const CategoryStyle(Icons.circle_outlined, Color(0xFF8395A7));
}
