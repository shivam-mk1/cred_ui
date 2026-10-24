import 'package:flutter/material.dart';

/// Presentation model for detail panel rows.
class DetailPanelRow {
  const DetailPanelRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
}
