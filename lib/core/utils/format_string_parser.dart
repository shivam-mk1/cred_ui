import 'package:flutter/material.dart';

/// Parses backend formatted strings containing `<text fgClr="#hex">text</text>`
/// tags into [TextSpan]s.
///
/// Strips optional surrounding `<format>` and `</format>` wrappers.
/// Returns an empty list when [raw] is null or empty.
List<TextSpan> parseFormatString(String? raw, {TextStyle? defaultStyle}) {
  if (raw == null || raw.isEmpty) return const [];

  final stripped = _stripOuter(raw);
  if (stripped.isEmpty) return const [];

  final spans = <TextSpan>[];
  final tagRe = RegExp(
    r'<text\s+fgClr="(#[0-9A-Fa-f]{6,8})">(.*?)</text>',
    dotAll: true,
  );

  int cursor = 0;
  for (final match in tagRe.allMatches(stripped)) {
    if (match.start > cursor) {
      final plain = stripped.substring(cursor, match.start);
      if (plain.isNotEmpty) spans.add(TextSpan(text: plain, style: defaultStyle));
    }
    final color = _hexToColor(match.group(1)!);
    final text = match.group(2) ?? '';
    spans.add(TextSpan(
      text: text,
      style: (defaultStyle ?? const TextStyle()).copyWith(color: color),
    ));
    cursor = match.end;
  }

  if (cursor < stripped.length) {
    final tail = stripped.substring(cursor);
    if (tail.isNotEmpty) spans.add(TextSpan(text: tail, style: defaultStyle));
  }

  return spans.isEmpty ? [TextSpan(text: stripped, style: defaultStyle)] : spans;
}

/// Returns the plain-text content of a format string with all XML-like tags
/// stripped.
///
/// Useful for accessibility labels and semantic descriptions where tags should
/// not be read.
String stripFormatTags(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  return _stripOuter(raw)
      .replaceAll(RegExp(r'<[^>]+>'), '');
}

String _stripOuter(String raw) => raw
    .replaceAll('<format>', '')
    .replaceAll('</format>', '')
    .trim();

Color _hexToColor(String hex) {
  final clean = hex.replaceFirst('#', '');
  final value = int.tryParse(clean, radix: 16);
  if (value == null) return Colors.black;
  return clean.length == 6 ? Color(0xFF000000 | value) : Color(value);
}
