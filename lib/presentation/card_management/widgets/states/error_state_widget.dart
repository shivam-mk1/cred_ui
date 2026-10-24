import 'package:flutter/material.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Error state widget with typed failure support and disabled state during in-flight requests.
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.failure,
    required this.onRetry,
    this.isLoading = false,
  });

  final AppFailure failure;
  final VoidCallback onRetry;
  final bool isLoading;

  IconData _getIcon() {
    return switch (failure) {
      NoInternetFailure() => Icons.wifi_off_rounded,
      TimeoutFailure() => Icons.timer_outlined,
      RateLimitFailure() => Icons.speed_rounded,
      ServerFailure() => Icons.cloud_off_rounded,
      _ => Icons.error_outline_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIcon(),
              size: 52,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              failure.message,
              style: AppTextStyles.errorMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ctaBgDark,
                foregroundColor: AppColors.ctaTextLight,
                disabledBackgroundColor: AppColors.ctaBgDark.withValues(alpha: 0.5),
                disabledForegroundColor: AppColors.ctaTextLight.withValues(alpha: 0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
