import 'package:flutter/material.dart';

class CategoryModel {
  final String name;
  final IconData icon;
  final Color? color; // Optional: specific color per category

  const CategoryModel({required this.name, required this.icon, this.color});

  // 🌟 The Single Source of Truth
  static const List<CategoryModel> list = [
    CategoryModel(name: 'General', icon: Icons.category_rounded),
    CategoryModel(name: 'Food', icon: Icons.fastfood_rounded),
    CategoryModel(name: 'Transportation', icon: Icons.directions_bus_rounded),
    CategoryModel(name: 'Shopping', icon: Icons.shopping_bag_rounded),
    CategoryModel(name: 'Entertainment', icon: Icons.movie_rounded),
    CategoryModel(name: 'Bills', icon: Icons.receipt_long_rounded),
    CategoryModel(name: 'Health', icon: Icons.favorite_rounded),
    CategoryModel(name: 'Education', icon: Icons.school_rounded),
  ];

  // Helper to find category by name (for AI/Database mapping)
  static CategoryModel fromName(String name) {
    return list.firstWhere(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
      orElse: () => list[0], // Default to General
    );
  }
}
