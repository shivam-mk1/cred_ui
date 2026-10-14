import '../entities/section_entity.dart';

abstract interface class CardManagementRepository {
  Future<List<SectionEntity>> fetchSections();
}
