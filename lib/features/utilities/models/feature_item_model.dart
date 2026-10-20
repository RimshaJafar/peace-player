import 'package:flutter/material.dart';

class FeatureItem {
  final String title;
  final IconData? icon;
  final String? imagePath;
  final VoidCallback onTap;

  FeatureItem({
    required this.title,
    this.icon,
    this.imagePath,
    required this.onTap,
  });
}
