import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CardManagementRemoteDatasource {
  const CardManagementRemoteDatasource(this._dio);

  final Dio _dio;

  static const _url = 'https://api.mocklets.com/p87/card-management';

  Future<Map<String, dynamic>> fetchRaw() async {
    try {
      final response = await _dio.get<dynamic>(_url);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data is String) {
        return jsonDecode(data) as Map<String, dynamic>;
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
          'DioException encountered (${e.type} - ${e.message}). '
          'Falling back to local mock payload to resolve browser CORS / rate limit issues.',
        );
      }
      return _loadFallbackMock();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Unexpected error ($e). Falling back to local mock payload.');
      }
      return _loadFallbackMock();
    }
    return _loadFallbackMock();
  }

  Future<Map<String, dynamic>> _loadFallbackMock() async {
    final jsonStr =
        await rootBundle.loadString('assessment_details/api_response.json');
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }
}
