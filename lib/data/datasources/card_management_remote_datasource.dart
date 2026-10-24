import 'dart:convert';
import 'package:dio/dio.dart';

class CardManagementRemoteDatasource {
  const CardManagementRemoteDatasource(this._dio);

  final Dio _dio;

  static const _url = 'https://api.mocklets.com/p87/card-management';

  Future<Map<String, dynamic>> fetchRaw({CancelToken? cancelToken}) async {
    final response = await _dio.get<dynamic>(
      _url,
      cancelToken: cancelToken,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is String) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    throw const FormatException('Unexpected response payload format');
  }
}
