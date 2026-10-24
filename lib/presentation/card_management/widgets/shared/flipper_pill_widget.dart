import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/flipper_pill_entity.dart';
import 'format_text_widget.dart';
import 'server_image_widget.dart';

/// Displays a pill badge with status information or pending action callouts.
class FlipperPillWidget extends StatelessWidget {
  const FlipperPillWidget({
    super.key,
    required this.pills,
    this.isLight = false,
  });

  final List<FlipperPillEntity> pills;

  /// When true uses a dark background (for light-themed cards).
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    if (pills.isEmpty) return const SizedBox.shrink();
    final pill = pills.first;
    final title = pill.cta1?.title;
    final iconUrl = pill.cta1?.asset?.url;
    final isPendingAction = pill.type == 'pending_action';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isPendingAction)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: const BoxDecoration(
                    color: AppColors.pillAlertRed,
                    shape: BoxShape.circle,
                  ),
                )
              else if (iconUrl != null && iconUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: ServerImageWidget(url: iconUrl, width: 14, height: 14, fit: BoxFit.contain),
                ),
              if (title != null)
                FormatTextWidget(
                  raw: title,
                  defaultStyle: AppTextStyles.pillText,
                ),
              const SizedBox(width: 2),
              const Icon(Icons.chevron_right, size: 14, color: AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }
}
