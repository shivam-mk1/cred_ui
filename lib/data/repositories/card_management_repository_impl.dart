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

/// Implementation of [CardManagementRepository] managing networking and failure translation.
///
/// Pools cancellation tokens to enable fine-grained request lifecycles without leaking
/// tokens across concurrent calls. Translates raw framework errors into typed [AppFailure]s.
class CardManagementRepositoryImpl implements CardManagementRepository {
  CardManagementRepositoryImpl(this._datasource);

  final CardManagementRemoteDatasource _datasource;
  final Set<CancelToken> _activeTokens = <CancelToken>{};
  CancelToken? _lastToken;

  /// Returns the most recently created or active cancellation token for testing.
  @visibleForTesting
  CancelToken? get currentCancelToken => _activeTokens.lastOrNull ?? _lastToken;

  /// Returns unmodifiable view of active in-flight request cancellation tokens.
  @visibleForTesting
  Set<CancelToken> get activeTokens => Set.unmodifiable(_activeTokens);

  @override
  Future<List<SectionEntity>> fetchSections() async {
    final token = CancelToken();
    _lastToken = token;
    _activeTokens.add(token);

    try {
      final raw = await _datasource.fetchRaw(cancelToken: token);
      final rawItems = raw['items'];
      if (rawItems == null || rawItems is! List) {
        throw const ParseFailure('Missing or invalid "items" list in response.');
      }
      return rawItems
          .map((e) {
            if (e is! Map) {
              throw const ParseFailure('Section element is not a valid JSON map.');
            }
            return _parseSection(Map<String, dynamic>.from(e));
          })
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on FormatException catch (e) {
      if (kDebugMode) {
        debugPrint('[CardManagementRepository] FormatException: ${e.message}');
      }
      throw const ParseFailure('Malformed JSON response payload.');
    } on TypeError catch (e) {
      if (kDebugMode) {
        debugPrint('[CardManagementRepository] TypeError: $e');
      }
      throw const ParseFailure('Type mismatch during JSON parsing.');
    } on AppFailure {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CardManagementRepository] Unhandled error: ${e.runtimeType}');
      }
      throw const UnknownFailure();
    } finally {
      // Clean up strictly this request's token; never touches sibling tokens.
      _activeTokens.remove(token);
    }
  }

  @override
  void cancel() {
    for (final token in _activeTokens) {
      if (!token.isCancelled) {
        token.cancel();
      }
    }
    _activeTokens.clear();
    _lastToken?.cancel();
  }

  /// Maps low-level [DioException] instances into typed [AppFailure]s.
  AppFailure _mapDioException(DioException e) {
    if (e.type == DioExceptionType.cancel || CancelToken.isCancel(e)) {
      return const CancelledFailure();
    }

    final statusCode = e.response?.statusCode;
    if (statusCode == 429) {
      return const RateLimitFailure();
    }
    if (statusCode != null && statusCode >= 500 && statusCode < 600) {
      return const ServerFailure();
    }

    switch (e.type) {
      case DioExceptionType.cancel:
        return const CancelledFailure();
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
      case DioExceptionType.badCertificate:
        if (kDebugMode) {
          debugPrint('[CardManagementRepository] Bad certificate error');
        }
        return const UnknownFailure('Security certificate verification failed');
      case DioExceptionType.unknown:
        // Handle lower-level socket errors that Dio categorizes as unknown.
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

  /// Recursively parses a section map into a strongly typed [SectionEntity].
  SectionEntity _parseSection(Map<String, dynamic> map) {
    final templateName = map['template_name'];
    if (templateName == null || templateName is! String) {
      throw const ParseFailure('Missing or invalid "template_name" in section.');
    }
    final externalId = map['external_id'] as String?;

    final props = map['template_properties'];
    if (props == null || props is! Map) {
      throw const ParseFailure('Missing or invalid "template_properties" in section.');
    }
    final propsMap = Map<String, dynamic>.from(props);

    final body = propsMap['body'];
    if (body != null && body is! Map) {
      throw const ParseFailure('Invalid "body" structure in template_properties.');
    }
    final bodyMap = body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};

    final rawChildList = propsMap['child_list'];
    if (propsMap.containsKey('child_list') && rawChildList is! List) {
      throw const ParseFailure('Invalid "child_list" structure in section.');
    }
    final childList = rawChildList is List
        ? rawChildList.map((e) {
            if (e is! Map) {
              throw const ParseFailure('Child section element is not a valid JSON map.');
            }
            return _parseSection(Map<String, dynamic>.from(e));
          }).toList()
        : <SectionEntity>[];

    return switch (templateName) {
      'cm_top_bar' => TopBarSection(
          externalId: externalId,
          body: TopBarEntity.fromMap(bodyMap),
        ),
      'unbilled_statement_info_section_v2' => StatementInfoSection(
          externalId: externalId,
          body: StatementInfoEntity.fromMap(bodyMap),
          childList: childList,
        ),
      'cm_card_instrument' => CardInstrumentSection(
          externalId: externalId,
          body: CardInstrumentEntity.fromMap(bodyMap),
        ),
      'unbilled_statement_info_section_offer_2' => OfferBannerSection(
          externalId: externalId,
          body: OfferBannerEntity.fromMap(bodyMap),
        ),
      _ => UnknownSection(templateName),
    };
  }
}
