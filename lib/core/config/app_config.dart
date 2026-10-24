/// Runtime configuration constants for networking and endpoints.
///
/// Values can be overridden at build or run time using `--dart-define` flags.
abstract final class AppConfig {
  /// Base endpoint URL for fetching card management sections.
  ///
  /// Override with: `--dart-define CARD_MANAGEMENT_URL=https://...`
  static const String cardManagementUrl = String.fromEnvironment(
    'CARD_MANAGEMENT_URL',
    defaultValue: 'https://api.mocklets.com/p87/card-management',
  );
}
