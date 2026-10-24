import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../cubit/card_management_state.dart';

class TabToggleWidget extends StatelessWidget {
  const TabToggleWidget({
    super.key,
    required this.active,
    required this.dueCount,
    required this.onToggle,
    this.totalDueLabel = 'TOTAL DUE',
    this.recentSpendsLabel = 'RECENT SPENDS',
  });

  final ActiveToggle active;
  final int? dueCount;
  final ValueChanged<ActiveToggle> onToggle;
  final String totalDueLabel;
  final String recentSpendsLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E7E2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: active == ActiveToggle.totalDue
                ? Alignment.centerLeft
                : Alignment.centerRight,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                    BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 4,
                        offset: Offset(0, 1))
                  ])),
            ),
          ),
          Row(
            children: [
              _Tab(
                label: totalDueLabel,
                isActive: active == ActiveToggle.totalDue,
                badgeCount: dueCount,
                onTap: () => onToggle(ActiveToggle.totalDue),
              ),
              _Tab(
                label: recentSpendsLabel,
                isActive: active == ActiveToggle.recentSpends,
                onTap: () => onToggle(ActiveToggle.recentSpends),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.isActive,
    this.badgeCount = 0,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final int? badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool showBadge = badgeCount != null && badgeCount! > 0;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          decoration: isActive
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                )
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: isActive
                    ? AppTextStyles.tabActive
                    : AppTextStyles.tabInactive,
              ),
              if (showBadge) ...[
                const SizedBox(width: 4),
                Container(
                  width: 15,
                  height: 15,
                  padding: const EdgeInsets.all(1),
                  decoration: const BoxDecoration(
                    color: AppColors.pillAlertRed,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
