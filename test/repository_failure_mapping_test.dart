import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:cred_assignment/core/error/failures.dart';
import 'package:cred_assignment/data/datasources/card_management_remote_datasource.dart';
import 'package:cred_assignment/data/repositories/card_management_repository_impl.dart';
import 'package:cred_assignment/domain/repositories/card_management_repository.dart';
import 'package:cred_assignment/domain/usecases/fetch_card_management_usecase.dart';
import 'package:cred_assignment/presentation/card_management/cubit/card_management_cubit.dart';
import 'package:cred_assignment/presentation/card_management/cubit/card_management_state.dart';

void main() {
  // Protects HTTP exception mapping to typed domain failures, cancel token pooling, and strict schema validation.
  group('CardManagementRepositoryImpl - DioException to AppFailure Mapping', () {
    Future<void> assertMapping({
      required DioException errorToThrow,
      required Type expectedFailureType,
    }) async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(errorToThrow);
          },
        ),
      );

      final datasource = CardManagementRemoteDatasource(dio);
      final repository = CardManagementRepositoryImpl(datasource);

      expect(
        () => repository.fetchSections(),
        throwsA(isA<AppFailure>().having(
          (f) => f.runtimeType,
          'runtimeType',
          expectedFailureType,
        )),
      );
    }

    final requestOptions = RequestOptions(path: 'https://api.mocklets.com/p87/card-management');

    test('maps connectionError to NoInternetFailure', () async {
      await assertMapping(
        errorToThrow: DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.connectionError,
          error: 'Connection failed',
        ),
        expectedFailureType: NoInternetFailure,
      );
    });

    test('maps connectionTimeout to TimeoutFailure', () async {
      await assertMapping(
        errorToThrow: DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.connectionTimeout,
        ),
        expectedFailureType: TimeoutFailure,
      );
    });

    test('maps sendTimeout to TimeoutFailure', () async {
      await assertMapping(
        errorToThrow: DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.sendTimeout,
        ),
        expectedFailureType: TimeoutFailure,
      );
    });

    test('maps receiveTimeout to TimeoutFailure', () async {
      await assertMapping(
        errorToThrow: DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.receiveTimeout,
        ),
        expectedFailureType: TimeoutFailure,
      );
    });

    test('maps transformTimeout to TimeoutFailure', () async {
      await assertMapping(
        errorToThrow: DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.transformTimeout,
        ),
        expectedFailureType: TimeoutFailure,
      );
    });

    test('maps badResponse with HTTP 429 Too Many Requests to RateLimitFailure', () async {
      await assertMapping(
        errorToThrow: DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 429,
            statusMessage: 'Too Many Requests',
          ),
        ),
        expectedFailureType: RateLimitFailure,
      );
    });

    test('maps badResponse with HTTP 500 Internal Server Error to ServerFailure', () async {
      await assertMapping(
        errorToThrow: DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 500,
            statusMessage: 'Internal Server Error',
          ),
        ),
        expectedFailureType: ServerFailure,
      );
    });

    test('maps badResponse with HTTP 502 Bad Gateway to ServerFailure', () async {
      await assertMapping(
        errorToThrow: DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 502,
            statusMessage: 'Bad Gateway',
          ),
        ),
        expectedFailureType: ServerFailure,
      );
    });

    test('maps badResponse with HTTP 503 Service Unavailable to ServerFailure', () async {
      await assertMapping(
        errorToThrow: DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 503,
            statusMessage: 'Service Unavailable',
          ),
        ),
        expectedFailureType: ServerFailure,
      );
    });

    test('maps badResponse with HTTP 504 Gateway Timeout to ServerFailure', () async {
      await assertMapping(
        errorToThrow: DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 504,
            statusMessage: 'Gateway Timeout',
          ),
        ),
        expectedFailureType: ServerFailure,
      );
    });

    test('maps badCertificate to UnknownFailure', () async {
      await assertMapping(
        errorToThrow: DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badCertificate,
        ),
        expectedFailureType: UnknownFailure,
      );
    });

    test('maps badResponse with HTTP 401 Unauthorized to UnknownFailure', () async {
      await assertMapping(
        errorToThrow: DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 401,
            statusMessage: 'Unauthorized',
          ),
        ),
        expectedFailureType: UnknownFailure,
      );
    });

    test('maps badResponse with HTTP 403 Forbidden to UnknownFailure', () async {
      await assertMapping(
        errorToThrow: DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 403,
            statusMessage: 'Forbidden',
          ),
        ),
        expectedFailureType: UnknownFailure,
      );
    });

    test('maps badResponse with HTTP 404 Not Found to UnknownFailure', () async {
      await assertMapping(
        errorToThrow: DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 404,
            statusMessage: 'Not Found',
          ),
        ),
        expectedFailureType: UnknownFailure,
      );
    });

    test('maps cancel to CancelledFailure', () async {
      await assertMapping(
        errorToThrow: DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.cancel,
        ),
        expectedFailureType: CancelledFailure,
      );
    });

    test('maps unknown to UnknownFailure', () async {
      await assertMapping(
        errorToThrow: DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.unknown,
        ),
        expectedFailureType: UnknownFailure,
      );
    });
  });

  group('CancelToken Real Lifecycle', () {
    test('fetch -> cancel -> fetch again succeeds with fresh uncancelled token', () async {
      final dio = Dio();
      int callCount = 0;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            callCount++;
            if (callCount == 1) {
              // Simulate in-flight async request waiting on network
              await Future<void>.delayed(const Duration(milliseconds: 50));
              if (options.cancelToken?.isCancelled == true) {
                return handler.reject(
                  DioException(
                    requestOptions: options,
                    type: DioExceptionType.cancel,
                  ),
                );
              }
              return handler.resolve(Response(
                requestOptions: options,
                data: {'items': []},
                statusCode: 200,
              ));
            } else {
              // Second request resolves immediately
              return handler.resolve(Response(
                requestOptions: options,
                data: {'items': []},
                statusCode: 200,
              ));
            }
          },
        ),
      );

      final datasource = CardManagementRemoteDatasource(dio);
      final repository = CardManagementRepositoryImpl(datasource);

      // Start first fetch
      final firstFetchFuture = repository.fetchSections();
      final firstToken = repository.currentCancelToken;
      expect(firstToken, isNotNull);
      expect(firstToken!.isCancelled, isFalse);

      // Cancel first fetch
      repository.cancel();
      expect(firstToken.isCancelled, isTrue);

      // First fetch should throw CancelledFailure
      await expectLater(
        firstFetchFuture,
        throwsA(isA<CancelledFailure>()),
      );

      // Trigger second fetch
      final secondFetchResult = await repository.fetchSections();
      final secondToken = repository.currentCancelToken;

      expect(secondToken, isNotNull);
      expect(secondToken, isNot(same(firstToken)));
      expect(secondToken!.isCancelled, isFalse);
      expect(secondFetchResult, isEmpty);
    });

    test('starts two fetches without awaiting first: cancelling first leaves second intact to succeed', () async {
      final dio = Dio();
      int callIndex = 0;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            callIndex++;
            final currentCall = callIndex;
            // Introduce small delay to ensure both requests are in flight
            await Future<void>.delayed(const Duration(milliseconds: 30));
            if (options.cancelToken?.isCancelled == true) {
              return handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.cancel,
                ),
              );
            }
            return handler.resolve(Response(
              requestOptions: options,
              data: {
                'items': [
                  {
                    'template_name': 'cm_top_bar',
                    'template_properties': {'body': {'id': currentCall}}
                  }
                ]
              },
              statusCode: 200,
            ));
          },
        ),
      );

      final datasource = CardManagementRemoteDatasource(dio);
      final repository = CardManagementRepositoryImpl(datasource);

      // Start two fetches without awaiting the first
      final fetch1 = repository.fetchSections();
      final token1 = repository.currentCancelToken;

      final fetch2 = repository.fetchSections();
      final token2 = repository.currentCancelToken;

      expect(token1, isNotNull);
      expect(token2, isNotNull);
      expect(token1, isNot(same(token2)));
      expect(repository.activeTokens.length, 2);

      // Cancel only the first request's token
      token1!.cancel('Cancelled request 1');

      // Assert first request throws CancelledFailure
      await expectLater(fetch1, throwsA(isA<CancelledFailure>()));

      // Assert second request succeeds intact
      final result2 = await fetch2;
      expect(result2.length, 1);
      expect(token2!.isCancelled, isFalse);
      // Assert tokens cleaned themselves up
      expect(repository.activeTokens, isEmpty);
    });

    test('cubit.close() cancels token; subsequent fetch on singleton repository creates new uncancelled token and succeeds', () async {
      final testSl = GetIt.asNewInstance();
      final dio = Dio();

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            if (options.cancelToken?.isCancelled == true) {
              return handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.cancel,
                ),
              );
            }
            return handler.resolve(Response(
              requestOptions: options,
              data: {
                'items': [
                  {
                    'template_name': 'cm_top_bar',
                    'template_properties': {'body': {}}
                  }
                ]
              },
              statusCode: 200,
            ));
          },
        ),
      );

      final datasource = CardManagementRemoteDatasource(dio);
      final repository = CardManagementRepositoryImpl(datasource);

      testSl.registerLazySingleton<CardManagementRepository>(() => repository);
      testSl.registerLazySingleton<FetchCardManagementUseCase>(
        () => FetchCardManagementUseCase(testSl<CardManagementRepository>()),
      );
      testSl.registerFactory<CardManagementCubit>(
        () => CardManagementCubit(testSl<FetchCardManagementUseCase>()),
      );

      // First cubit lifecycle
      final cubit1 = testSl<CardManagementCubit>();
      await cubit1.load();
      expect(cubit1.state.status, CardManagementStatus.loaded);

      // Closing cubit1 cancels the token on the singleton repository
      await cubit1.close();
      expect(repository.currentCancelToken?.isCancelled, isTrue);

      // Second cubit instantiated from factory with same repository singleton
      final cubit2 = testSl<CardManagementCubit>();
      expect(cubit2.state.status, CardManagementStatus.initial);

      // Second cubit load must create a brand new token and succeed
      await cubit2.load();
      expect(cubit2.state.status, CardManagementStatus.loaded);
      expect(repository.currentCancelToken?.isCancelled, isFalse);
      expect(cubit2.state.sections.length, 1);
    });
  });

  group('ParseFailure & Data Integrity', () {
    Future<void> assertPayloadThrowsParseFailure(dynamic responseData) async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(Response(
              requestOptions: options,
              data: responseData,
              statusCode: 200,
            ));
          },
        ),
      );

      final datasource = CardManagementRemoteDatasource(dio);
      final repository = CardManagementRepositoryImpl(datasource);

      expect(
        () => repository.fetchSections(),
        throwsA(isA<ParseFailure>()),
      );
    }

    test('missing items field in response throws ParseFailure', () async {
      await assertPayloadThrowsParseFailure(<String, dynamic>{});
    });

    test('items field of wrong type (not a list) throws ParseFailure', () async {
      await assertPayloadThrowsParseFailure(<String, dynamic>{'items': 'invalid'});
    });

    test('section element is not a map throws ParseFailure', () async {
      await assertPayloadThrowsParseFailure(<String, dynamic>{
        'items': ['string_instead_of_map']
      });
    });

    test('missing template_properties in section throws ParseFailure', () async {
      await assertPayloadThrowsParseFailure(<String, dynamic>{
        'items': [
          {'template_name': 'cm_top_bar'}
        ]
      });
    });

    test('template_properties of wrong type throws ParseFailure', () async {
      await assertPayloadThrowsParseFailure(<String, dynamic>{
        'items': [
          {
            'template_name': 'cm_top_bar',
            'template_properties': 'not_a_map',
          }
        ]
      });
    });

    test('child_list of wrong type in template_properties throws ParseFailure', () async {
      await assertPayloadThrowsParseFailure(<String, dynamic>{
        'items': [
          {
            'template_name': 'unbilled_statement_info_section_v2',
            'template_properties': {
              'body': {},
              'child_list': 'not_a_list',
            }
          }
        ]
      });
    });

    test('malformed JSON string response throws ParseFailure', () async {
      await assertPayloadThrowsParseFailure('{ malformed: json [');
    });

    test('TypeError from invalid cast maps to ParseFailure', () async {
      // Cause a TypeError during entity field extraction (e.g. priority expecting int/num)
      await assertPayloadThrowsParseFailure(<String, dynamic>{
        'items': [
          {
            'template_name': 'cm_card_instrument',
            'template_properties': {
              'body': {
                'flipper_pill': [
                  {
                    'priority': 'must_be_a_num_not_a_string',
                  }
                ]
              }
            }
          }
        ]
      });
    });
  });
}
