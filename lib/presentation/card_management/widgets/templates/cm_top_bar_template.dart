import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/cta_dispatcher.dart';
import '../../../../domain/entities/cta_entity.dart';
import '../../../../domain/entities/top_bar_entity.dart';
import '../shared/format_text_widget.dart';
import '../shared/server_image_widget.dart';

/// Renders template `cm_top_bar`.
/// Left: cta_2 (offers/rewards %)
/// Center: custom [centerWidget] (e.g. TabToggleWidget) or cta_1 (wallet balance)
/// Right: cta_3 (settings gear)
class CmTopBarTemplate extends StatelessWidget {
  const CmTopBarTemplate({
    super.key,
    required this.topBar,
    required this.ctaDispatcher,
    this.centerWidget,
  });

  final TopBarEntity topBar;
  final CtaDispatcher ctaDispatcher;
  final Widget? centerWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left CTA (% icon)
          _CircleIconButton(
            cta: topBar.cta2,
            fallbackIcon: Icons.percent_rounded,
            onTap: () => ctaDispatcher.dispatch(context, topBar.cta2),
          ),

          // Center: TabToggleWidget or balance CTA
          if (centerWidget != null)
            Flexible(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: centerWidget!,
            ))
          else if (topBar.cta1 != null)
            _CenterBalance(
              cta: topBar.cta1!,
              onTap: () => ctaDispatcher.dispatch(context, topBar.cta1),
            )
          else
            const Spacer(),

          // Right CTA (settings gear)
          _CircleIconButton(
            cta: topBar.cta3,
            fallbackIcon: Icons.settings_outlined,
            onTap: () => ctaDispatcher.dispatch(context, topBar.cta3),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.cta,
    required this.fallbackIcon,
    required this.onTap,
  });

  final CtaEntity? cta;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        padding: const EdgeInsets.all(7),
        child: cta?.asset?.hasUrl == true
            ? ServerImageWidget(
                url: cta!.asset!.url!,
                fit: BoxFit.contain,
              )
            : Icon(fallbackIcon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _CenterBalance extends StatelessWidget {
  const _CenterBalance({required this.cta, required this.onTap});

  final CtaEntity cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (cta.asset?.hasUrl == true) ...[
            ServerImageWidget(
              url: cta.asset!.url!,
              width: 18,
              height: 18,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 6),
          ],
          if (cta.title != null)
            FormatTextWidget(
              raw: cta.title!,
              defaultStyle: AppTextStyles.topBarAmount,
            ),
        ],
      ),
    );
  }
}
