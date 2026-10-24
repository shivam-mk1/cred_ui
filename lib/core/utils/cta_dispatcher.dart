import 'package:flutter/material.dart';
import '../../domain/entities/cta_entity.dart';

/// Routes user actions triggered by CTA models to target flows or deeplinks.
abstract interface class CtaDispatcher {
  /// Dispatches the appropriate interaction for [cta].
  ///
  /// Safe to call with null [cta]; no action is executed in that case.
  void dispatch(BuildContext context, CtaEntity? cta);
}

/// Standard production implementation of [CtaDispatcher].
///
/// Handles external URLs via deeplinks and dialog flows defined by the server.
class CtaDispatcherImpl implements CtaDispatcher {
  const CtaDispatcherImpl();

  @override
  void dispatch(BuildContext context, CtaEntity? cta) {
    if (cta == null) return;
    switch (cta.type) {
      case CtaType.deeplink:
        _handleDeeplink(context, cta.deeplink?.url);
      case CtaType.flow:
        _handleFlow(context, cta.flow?.type);
      case CtaType.unknown:
        return;
    }
  }

  void _handleDeeplink(BuildContext context, String? url) {
    if (url == null || url.isEmpty) return;
    _showFeedback(context, 'Deeplink: $url');
  }

  void _handleFlow(BuildContext context, String? flowType) {
    if (flowType == null || flowType.isEmpty) return;
    switch (flowType) {
      case 'unbilled_statement_info_dialog':
        _showInfoDialog(context);
      default:
        return;
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

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}
