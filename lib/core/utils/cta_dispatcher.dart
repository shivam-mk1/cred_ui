import 'package:flutter/material.dart';
import '../../domain/entities/cta_entity.dart';
import 'format_string_parser.dart';

/// Routes user actions triggered by CTA models to target flows or deeplinks.
abstract interface class CtaDispatcher {
  /// Dispatches the appropriate interaction for [cta].
  ///
  /// Safe to call with null [cta]; no action is executed in that case.
  void dispatch(BuildContext context, CtaEntity? cta);

  /// Displays floating feedback that the requested CTA or action is
  /// intentionally unimplemented in this demo.
  void notifyUnimplemented(BuildContext context, [String? actionName]);
}

/// Standard production implementation of [CtaDispatcher].
///
/// Handles external URLs via deeplinks and dialog flows defined by the server.
class CtaDispatcherImpl implements CtaDispatcher {
  const CtaDispatcherImpl();

  // CTAs such as external payment flows, deep links, and secondary card
  // management actions are intentionally unimplemented per assignment scope.
  /// Displays a floating SnackBar informing the user that an action is
  /// intentionally unimplemented per the assignment scope.
  static void showUnimplemented(BuildContext context, [String? actionName]) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final formattedName = _formatActionName(actionName);
    final text = formattedName != null
        ? '$formattedName is not available in this demo'
        : 'Not available in this demo';

    messenger.showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static String? _formatActionName(String? raw) {
    if (raw == null) return null;
    final cleaned = stripFormatTags(raw).trim();
    if (cleaned.isEmpty || cleaned.contains('₹')) return null;
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  @override
  void notifyUnimplemented(BuildContext context, [String? actionName]) {
    showUnimplemented(context, actionName);
  }

  @override
  void dispatch(BuildContext context, CtaEntity? cta) {
    if (cta == null) return;
    switch (cta.type) {
      case CtaType.deeplink:
        notifyUnimplemented(context, cta.title);
      case CtaType.flow:
        _handleFlow(context, cta);
      case CtaType.unknown:
        notifyUnimplemented(context, cta.title);
    }
  }

  void _handleFlow(BuildContext context, CtaEntity cta) {
    switch (cta.flow?.type) {
      case 'unbilled_statement_info_dialog':
        _showInfoDialog(context);
      default:
        notifyUnimplemented(context, cta.title);
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Statement Info'),
        content: const Text(
          'Your statement due amount includes all outstanding balances.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
