import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Loads and caches remote network images with graceful null and error
/// handling.
class ServerImageWidget extends StatelessWidget {
  const ServerImageWidget({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final resolved = url;
    if (resolved == null || resolved.isEmpty) return const SizedBox.shrink();
    return CachedNetworkImage(
      imageUrl: resolved,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => _placeholder(),
      errorWidget: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() => Container(
        width: width,
        height: height,
        color: const Color(0xFFD9D9D9),
      );
}
