import '../entities/section_entity.dart';

/// Contract interface for accessing and managing card management data.
abstract interface class CardManagementRepository {
  /// Fetches top-level section templates from the data layer.
  ///
  /// Returns a list of parsed [SectionEntity] items.
  /// Throws an [AppFailure] subtype if networking, rate-limiting, or parsing
  /// fails.
  Future<List<SectionEntity>> fetchSections();

  /// Cancels all in-flight requests across all consumers sharing this
  /// repository singleton instance.
  void cancel();
}
