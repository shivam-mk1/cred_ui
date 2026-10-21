import 'package:flutter/widgets.dart';
import '../../../../core/utils/format_string_parser.dart';

class FormatTextWidget extends StatelessWidget {
  const FormatTextWidget({
    super.key,
    required this.raw,
    required this.defaultStyle,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  });

  final String? raw;
  final TextStyle defaultStyle;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    final spans = parseFormatString(raw, defaultStyle: defaultStyle);
    if (spans.isEmpty) return const SizedBox.shrink();
    return RichText(
      text: TextSpan(children: spans),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
