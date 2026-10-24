import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Configures and provides a configured [Dio] HTTP client instance.
///
/// Applies 10-second connection and transmission limits to prevent hanging
/// requests. Logging interceptors are strictly compiled out in production
/// release builds.
class DioClient {
  DioClient() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
      ),
    );
    // Logging is restricted to debug mode to prevent leaking payload data in
    // release builds.
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(requestBody: true, responseBody: true),
      );
    }
  }

  late final Dio _dio;

  /// The underlying [Dio] instance configured for application networking.
  Dio get dio => _dio;
}
