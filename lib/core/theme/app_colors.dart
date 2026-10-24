import 'package:flutter/material.dart';

abstract final class AppColors {
  // Backgrounds
  static const Color screenBg = Color(0xFFF2F1EC);
  static const Color cardBg = Color(0xFF1A1A1A);
  static const Color surfaceCard = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFF9B9B9B);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnDarkSecondary = Color(0xB3FFFFFF); // 70% white

  // Top bar
  static const Color topBarAmountText = Color(0xFF1A1A1A);

  // Statement / Tab bar
  static const Color tabActive = Color(0xFF1A1A1A);
  static const Color tabInactive = Color(0xFF9B9B9B);

  // Flipper pill
  static const Color pillText = Color(0xFF1A1A1A);
  static const Color pillAlertRed = Color(0xFFE53935);

  // CTA buttons
  static const Color ctaBgLight = Color(0xFFFFFFFF);
  static const Color ctaTextDark = Color(0xFF1A1A1A);
  static const Color ctaBgDark = Color(0xFF1A1A1A);
  static const Color ctaTextLight = Color(0xFFFFFFFF);

  // Offer banner
  static const Color offerBannerText = Color(0xFF6A3C6A);

  // Detail panel
  static const Color detailPanelBg = Color(0xFFFFFFFF);
  static const Color detailRowDivider = Color(0xFFF0F0F0);
  static const Color detailSectionLabel = Color(0xFF9B9B9B);

  // Error
  static const Color error = Color(0xFFE53935);

  // Skeleton shimmer
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
