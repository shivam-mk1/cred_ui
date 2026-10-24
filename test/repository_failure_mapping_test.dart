import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cred_assignment/core/error/failures.dart';
import 'package:cred_assignment/data/datasources/card_management_remote_datasource.dart';
import 'package:cred_assignment/data/repositories/card_management_repository_impl.dart';

void main() {
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

    test('maps badResponse with HTTP 429 to RateLimitFailure', () async {
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

    test('maps badResponse with HTTP 500 to ServerFailure', () async {
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

    test('maps badResponse with HTTP 503 to ServerFailure', () async {
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
}
