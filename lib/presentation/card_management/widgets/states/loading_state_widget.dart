import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Skeleton loading state for card management screen.
class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top bar skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ShimmerBox(width: 36, height: 36, borderRadius: 18),
              _ShimmerBox(width: 200, height: 36, borderRadius: 18),
              _ShimmerBox(width: 36, height: 36, borderRadius: 18),
            ],
          ),

          SizedBox(height: 28),

          // Statement label skeleton
          _ShimmerBox(width: 140, height: 12, borderRadius: 6),
          SizedBox(height: 10),

          // Amount skeleton
          _ShimmerBox(width: 180, height: 32, borderRadius: 8),
          SizedBox(height: 16),

          // Pay bill button skeleton
          _ShimmerBox(width: 90, height: 34, borderRadius: 17),
          SizedBox(height: 16),

          // Offer banner skeleton
          _ShimmerBox(width: 280, height: 38, borderRadius: 19),
          SizedBox(height: 24),

          // Card skeleton
          AspectRatio(
            aspectRatio: 1.586,
            child: _ShimmerBox(width: double.infinity, height: double.infinity, borderRadius: 16),
          ),
          SizedBox(height: 14),

          // Flipper pill skeleton
          Align(
            alignment: Alignment.centerLeft,
            child: _ShimmerBox(width: 130, height: 28, borderRadius: 14),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
