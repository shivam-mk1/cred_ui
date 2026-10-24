import 'package:flutter/material.dart';

/// Local model for items not present in the API.
class ActionGridItem {
  const ActionGridItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}

/// Local model for detail panel rows not present in the API.
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

/// Static definitions for content not served by the API.
abstract final class CardDetailStaticData {
  static const String detailSectionDate = 'SEPTEMBER 7TH';

  static const List<ActionGridItem> actionGridItems = [
    ActionGridItem(
        icon: Icons.check_circle_outline_rounded, label: 'mark as paid'),
    ActionGridItem(icon: Icons.description_outlined, label: 'smart statement'),
    ActionGridItem(icon: Icons.history_rounded, label: 'payment history'),
    ActionGridItem(icon: Icons.local_offer_outlined, label: 'card offers'),
    ActionGridItem(
        icon: Icons.account_balance_wallet_outlined, label: 'recent spends'),
    ActionGridItem(icon: Icons.more_horiz_rounded, label: 'more actions'),
  ];

  // Top-row quick actions shown in the detail panel header.
  static const List<ActionGridItem> panelQuickActions = [
    ActionGridItem(
        icon: Icons.check_circle_outline_rounded, label: 'mark as paid'),
    ActionGridItem(icon: Icons.history_rounded, label: 'payment history'),
  ];

  static const List<DetailPanelRow> detailRows = [
    DetailPanelRow(
      icon: Icons.description_outlined,
      title: 'latest statement',
      subtitle: '₹50,000.00 bill generated on 28 Aug',
    ),
    DetailPanelRow(
      icon: Icons.account_balance_wallet_outlined,
      title: 'recent spends',
      subtitle: 'no spends since last statement',
    ),
    DetailPanelRow(
      icon: Icons.local_offer_outlined,
      title: 'card offers',
      subtitle: 'verify card to unlock',
    ),
  ];
}
