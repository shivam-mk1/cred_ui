import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/cta_entity.dart';

class CtaButtonWidget extends StatelessWidget {
  const CtaButtonWidget({
    super.key,
    required this.cta,
    this.onTap,
    this.isLightStyle = false,
  });

  final CtaEntity cta;
  final VoidCallback? onTap;

  /// Override style: when true uses white fill (matches card-face "Pay now").
  final bool isLightStyle;

  bool get _light => isLightStyle || cta.ctaType == 'light_flat';

  @override
  Widget build(BuildContext context) {
    final title = cta.title;
    if (title == null || title.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: _light ? AppColors.ctaBgLight : AppColors.ctaBgDark,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          title,
          style: _light
              ? AppTextStyles.ctaButtonLight
              : AppTextStyles.ctaButtonDark,
        ),
      ),
    );
  }
}
