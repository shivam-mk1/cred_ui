import '../entities/section_entity.dart';
import '../repositories/card_management_repository.dart';

/// Encapsulates fetching and cancelling card management section hierarchies.
///
/// Coordinates between presentation cubits and the [CardManagementRepository],
/// isolating presentation state from network contracts.
class FetchCardManagementUseCase {
  const FetchCardManagementUseCase(this._repository);

  final CardManagementRepository _repository;

  /// Fetches the top-level section hierarchy from the repository.
  ///
  /// Returns a list of [SectionEntity] nodes representing parsed server templates.
  /// Throws an [AppFailure] subtype if network, rate-limiting, or parsing fails.
  Future<List<SectionEntity>> call() => _repository.fetchSections();

  /// Cancels all active in-flight requests initiated through this use case.
  void cancel() => _repository.cancel();
}
