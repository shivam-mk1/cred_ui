import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

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
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(requestBody: true, responseBody: true),
      );
    }
  }

  late final Dio _dio;

  Dio get dio => _dio;
}
