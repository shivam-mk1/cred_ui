import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  // Top bar
  static const TextStyle topBarAmount = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.topBarAmountText,
    letterSpacing: 0,
  );

  // Statement header
  static const TextStyle statementLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 1.2,
  );

  static const TextStyle statementAmount = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w300,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle statementAmountSmall = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w300,
    color: AppColors.textPrimary,
  );

  // Tab toggle
  static const TextStyle tabActive = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.tabActive,
    letterSpacing: 0.8,
  );

  static const TextStyle tabInactive = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.tabInactive,
    letterSpacing: 0.8,
  );

  // CTA buttons
  static const TextStyle ctaButtonDark = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.ctaTextLight,
  );

  static const TextStyle ctaButtonLight = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.ctaTextDark,
  );

  // Card face
  static const TextStyle cardBankName = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnDark,
    letterSpacing: 0.3,
  );

  static const TextStyle cardLastFour = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnDarkSecondary,
  );

  static const TextStyle cardHolderName = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnDarkSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle cardDueAmount = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnDark,
  );

  static const TextStyle cardDueDate = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnDarkSecondary,
    letterSpacing: 0.3,
  );

  // Flipper pill
  static const TextStyle pillText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Offer banner
  static const TextStyle offerText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.offerBannerText,
  );

  // List card row
  static const TextStyle listCardBank = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnDark,
  );

  static const TextStyle listCardSub = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnDarkSecondary,
  );

  // Detail panel
  static const TextStyle detailRowLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle detailRowValue = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle detailSectionDate = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.detailSectionLabel,
    letterSpacing: 0.5,
  );

  // Action grid
  static const TextStyle actionGridLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Error / empty states
  static const TextStyle errorMessage = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}
