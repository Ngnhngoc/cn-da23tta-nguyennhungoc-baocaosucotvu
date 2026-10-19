import 'package:flutter/material.dart';

class CategoryModel {
  final int id;
  final String name;
  final String? icon;
  final String? description;
  final int incidentCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.description,
    this.incidentCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'],
      description: json['description'],
      incidentCount: json['incidentCount'] ?? 0,
    );
  }

  IconData get iconData {
    switch (icon) {
      case 'lightbulb':
        return Icons.lightbulb_outline;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'computer':
        return Icons.computer;
      case 'water_drop':
        return Icons.water_drop_outlined;
      case 'chair':
        return Icons.chair_outlined;
      case 'cleaning_services':
        return Icons.cleaning_services_outlined;
      default:
        return Icons.build_circle_outlined;
    }
  }
}
