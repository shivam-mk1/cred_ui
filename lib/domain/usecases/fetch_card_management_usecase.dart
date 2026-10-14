import '../entities/section_entity.dart';
import '../repositories/card_management_repository.dart';

class FetchCardManagementUseCase {
  const FetchCardManagementUseCase(this._repository);

  final CardManagementRepository _repository;

  Future<List<SectionEntity>> call() => _repository.fetchSections();
}
