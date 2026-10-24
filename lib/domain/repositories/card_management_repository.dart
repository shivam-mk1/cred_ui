import 'package:dio/dio.dart';
import '../entities/section_entity.dart';

abstract interface class CardManagementRepository {
  Future<List<SectionEntity>> fetchSections({CancelToken? cancelToken});
}
