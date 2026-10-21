import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/cta_dispatcher.dart';
import '../../../../domain/entities/offer_banner_entity.dart';
import '../shared/format_text_widget.dart';
import '../shared/server_image_widget.dart';

/// Renders template `unbilled_statement_info_section_offer_2`.
/// Cash voucher / coupon banner pill located under the "Pay bill" button.
class OfferBannerTemplate extends StatelessWidget {
  const OfferBannerTemplate({
    super.key,
    required this.offer,
    required this.ctaDispatcher,
  });

  final OfferBannerEntity offer;
  final CtaDispatcher ctaDispatcher;

  @override
  Widget build(BuildContext context) {
    final activeConfig =
        offer.flipperConfig.isNotEmpty ? offer.flipperConfig.first : null;

    final text = activeConfig?.text1;
    final cta = activeConfig?.cta;

    return GestureDetector(
      onTap: () => ctaDispatcher.dispatch(context, cta),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Voucher / coupon image asset
            if (offer.asset?.hasUrl == true) ...[
              ServerImageWidget(
                url: offer.asset!.url!,
                width: 18,
                height: 18,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
            ],
            // Formatted markup text
            if (text != null)
              Flexible(
                child: FormatTextWidget(
                  raw: text,
                  defaultStyle: AppTextStyles.offerText,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: Color(0xFF6A3C6A),
            ),
          ],
        ),
      ),
    );
  }
}
