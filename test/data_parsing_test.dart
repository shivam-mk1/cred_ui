import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:cred_assignment/core/error/failures.dart';
import 'package:cred_assignment/data/datasources/card_management_remote_datasource.dart';
import 'package:cred_assignment/data/repositories/card_management_repository_impl.dart';
import 'package:cred_assignment/domain/entities/section_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Parses mock JSON file into SDUI sections correctly', () async {
    final file = File('test/fixtures/api_response.json');
    final jsonStr = await file.readAsString();
    final rawMap = jsonDecode(jsonStr) as Map<String, dynamic>;

    final repo = CardManagementRepositoryImpl(
      _FakeDatasource(rawMap),
    );

    final sections = await repo.fetchSections();

    expect(sections.isNotEmpty, true);
    expect(sections.whereType<TopBarSection>().length, 1);
    expect(sections.whereType<StatementInfoSection>().length, 1);

    final cards = sections.whereType<CardInstrumentSection>().toList();
    expect(cards.length, 6);

    // Verify first card (Axis Bank)
    final firstCard = cards.first.body;
    expect(firstCard.text3, '•• 1234');
    expect(firstCard.statement?.text1, '₹50,000.00');

    // Verify last card (IDFC RuPay)
    final lastCard = cards.last.body;
    expect(lastCard.rupaySupported, true);
    expect(lastCard.provider, 'RUPAY');
  });

  test('CardManagementRemoteDatasource rethrows DioException honestly when Dio fails', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException.connectionError(
              requestOptions: options,
              reason: 'Connection refused',
            ),
          );
        },
      ),
    );

    final datasource = CardManagementRemoteDatasource(dio);
    expect(() => datasource.fetchRaw(), throwsA(isA<DioException>()));
  });

  test('CardManagementRepositoryImpl maps Dio connection error to NoInternetFailure', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException.connectionError(
              requestOptions: options,
              reason: 'No internet',
            ),
          );
        },
      ),
    );

    final datasource = CardManagementRemoteDatasource(dio);
    final repository = CardManagementRepositoryImpl(datasource);

    expect(
      () => repository.fetchSections(),
      throwsA(isA<NoInternetFailure>()),
    );
  });
}

class _FakeDatasource extends CardManagementRemoteDatasource {
  _FakeDatasource(this.data) : super(Dio());

  final Map<String, dynamic> data;

  @override
  Future<Map<String, dynamic>> fetchRaw({CancelToken? cancelToken}) async => data;
}
