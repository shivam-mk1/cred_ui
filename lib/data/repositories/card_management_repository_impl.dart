import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/section_entity.dart';
import '../../domain/entities/top_bar_entity.dart';
import '../../domain/entities/statement_info_entity.dart';
import '../../domain/entities/card_instrument_entity.dart';
import '../../domain/entities/offer_banner_entity.dart';
import '../../domain/repositories/card_management_repository.dart';
import '../datasources/card_management_remote_datasource.dart';

class CardManagementRepositoryImpl implements CardManagementRepository {
  const CardManagementRepositoryImpl(this._datasource);

  final CardManagementRemoteDatasource _datasource;

  @override
  Future<List<SectionEntity>> fetchSections({CancelToken? cancelToken}) async {
    try {
      final raw = await _datasource.fetchRaw(cancelToken: cancelToken);
      final items = raw['items'] as List<dynamic>? ?? [];
      return items
          .map((e) => _parseSection(e as Map<String, dynamic>? ?? {}))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel || CancelToken.isCancel(e)) {
        rethrow;
      }
      throw _mapDioException(e);
    } on FormatException catch (e) {
      if (kDebugMode) {
        debugPrint('[CardManagementRepository] FormatException: ${e.message}');
      }
      throw const ParseFailure();
    } on TypeError catch (e) {
      if (kDebugMode) {
        debugPrint('[CardManagementRepository] TypeError: $e');
      }
      throw const ParseFailure();
    } on AppFailure {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CardManagementRepository] Unhandled error: ${e.runtimeType}');
      }
      throw const UnknownFailure();
    }
  }

  AppFailure _mapDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == 429) {
      return const RateLimitFailure();
    }
    if (statusCode != null && statusCode >= 500 && statusCode < 600) {
      return const ServerFailure();
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
        return const NoInternetFailure();
      case DioExceptionType.badResponse:
        if (statusCode == 429) {
          return const RateLimitFailure();
        }
        if (statusCode != null && statusCode >= 500) {
          return const ServerFailure();
        }
        if (kDebugMode) {
          debugPrint('[CardManagementRepository] HTTP client error: $statusCode');
        }
        return const UnknownFailure();
      case DioExceptionType.cancel:
        return const UnknownFailure('Request was cancelled');
      case DioExceptionType.badCertificate:
        if (kDebugMode) {
          debugPrint('[CardManagementRepository] Bad certificate error');
        }
        return const UnknownFailure('Security certificate verification failed');
      case DioExceptionType.unknown:
        if (e.error is SocketException ||
            (e.error != null &&
                e.error.toString().toLowerCase().contains('socket'))) {
          return const NoInternetFailure();
        }
        if (kDebugMode) {
          debugPrint('[CardManagementRepository] Unknown error: ${e.error?.runtimeType}');
        }
        return const UnknownFailure();
    }
  }

  SectionEntity _parseSection(Map<String, dynamic> map) {
    final templateName = (map['template_name'] as String?) ?? '';
    final externalId = map['external_id'] as String?;
    final props = map['template_properties'] as Map<String, dynamic>? ?? {};
    final body = props['body'] as Map<String, dynamic>? ?? {};
    final rawChildList = props['child_list'] as List<dynamic>? ?? [];
    final childList = rawChildList
        .map((e) => _parseSection(e as Map<String, dynamic>? ?? {}))
        .toList();

    return switch (templateName) {
      'cm_top_bar' => TopBarSection(
          externalId: externalId,
          body: TopBarEntity.fromMap(body),
        ),
      'unbilled_statement_info_section_v2' => StatementInfoSection(
          externalId: externalId,
          body: StatementInfoEntity.fromMap(body),
          childList: childList,
        ),
      'cm_card_instrument' => CardInstrumentSection(
          externalId: externalId,
          body: CardInstrumentEntity.fromMap(body),
        ),
      'unbilled_statement_info_section_offer_2' => OfferBannerSection(
          externalId: externalId,
          body: OfferBannerEntity.fromMap(body),
        ),
      _ => UnknownSection(templateName),
    };
  }
}
