import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';

/// Low-level HTTP data source executing requests against the card management
/// endpoint.
///
/// Unmarshalls payload responses into decoded JSON maps and accepts an optional
/// [CancelToken] for request aborts.
class CardManagementRemoteDatasource {
  const CardManagementRemoteDatasource(this._dio);

  final Dio _dio;

  /// Retrieves the raw card management JSON payload from
  /// [AppConfig.cardManagementUrl].
  ///
  /// Supports both pre-parsed JSON maps and raw string responses from Dio.
  /// Throws [DioException] on network/HTTP errors, or [FormatException] if
  /// the payload string cannot be decoded into a JSON map.
  Future<Map<String, dynamic>> fetchRaw({CancelToken? cancelToken}) async {
    final response = await _dio.get<dynamic>(
      AppConfig.cardManagementUrl,
      cancelToken: cancelToken,
    );
    final data = response.data;
    // Dio automatically decodes application/json, but falls back to String
    // when content-type headers are omitted or plain text is returned.
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is String) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    throw const FormatException('Unexpected response payload format');
  }
}
