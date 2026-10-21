import 'package:flutter/material.dart';

/// Fallback for unknown server-driven UI templates.
/// Per requirements: unknown templates are skipped without crashing.
class UnknownTemplate extends StatelessWidget {
  const UnknownTemplate({super.key, this.templateName});

  final String? templateName;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
