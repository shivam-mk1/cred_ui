/// System-wide fallback copy and constant labels for card management.
///
/// These tokens represent safe presentation defaults rendered when the backend
/// response omits optional header or section label fields.
abstract final class CardManagementConstants {
  /// Default label for the total due tab toggle when omitted by the server.
  static const String totalDueLabel = 'TOTAL DUE';

  /// Default label for the recent spends tab toggle when omitted by the server.
  static const String recentSpendsLabel = 'RECENT SPENDS';

  /// Fallback header title for the detail sheet when card statement date is
  /// absent.
  static const String cardDetailsFallbackTitle = 'CARD DETAILS';
}
