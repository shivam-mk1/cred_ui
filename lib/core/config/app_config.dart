abstract final class AppConfig {
  /// Base endpoint URL for fetching card management sections.
  /// Overridable at compile time via `--dart-define CARD_MANAGEMENT_URL=<url>`.
  static const String cardManagementUrl = String.fromEnvironment(
    'CARD_MANAGEMENT_URL',
    defaultValue: 'https://api.mocklets.com/p87/card-management',
  );
}
