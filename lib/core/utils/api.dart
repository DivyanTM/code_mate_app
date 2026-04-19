import 'package:code_mate/core/configs/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../data/sources/global_state.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  late final Dio _tokenDio;

  ApiService._internal() {
    final baseOptions = BaseOptions(
      baseUrl: APIConstants.PRODUCTION_BASE_URL,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    );

    _dio = Dio(baseOptions);
    _tokenDio = Dio(baseOptions);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final bool authRequired = options.extra['authRequired'] ?? true;

          if (authRequired) {
            final token = GlobalState().accessToken;
            if (token != null && token.isNotEmpty) {
              final cleanToken = token
                  .replaceAll('\n', '')
                  .replaceAll('\r', '')
                  .trim();

              options.headers['Authorization'] = 'Bearer $cleanToken';
            }
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            debugPrint("Access token expired, attempting refresh...");
            final isRefreshed = await _refreshToken();

            if (isRefreshed) {
              final retryOptions = e.requestOptions;
              retryOptions.headers['Authorization'] =
                  'Bearer ${GlobalState().accessToken}';

              try {
                final retryResponse = await _dio.fetch(retryOptions);
                return handler.resolve(retryResponse);
              } on DioException catch (retryError) {
                return handler.next(retryError);
              }
            } else {
              await GlobalState().clearPrefs();
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    final refreshToken = GlobalState().refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final response = await _tokenDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['data']['tokens']['accessToken'];
        final newRefreshToken = response.data['data']['tokens']['refreshToken'];

        await GlobalState().saveTokens(
          access: newAccessToken,
          refresh: newRefreshToken,
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      return false;
    }
  }

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? query,
    bool authRequired = true,
  }) async {
    try {
      return await _dio.get(
        endpoint,
        queryParameters: query,
        options: Options(extra: {'authRequired': authRequired}),
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Response> post(
    String endpoint,
    dynamic data, {
    bool authRequired = true,
  }) async {
    try {
      return await _dio.post(
        endpoint,
        data: data,
        options: Options(extra: {'authRequired': authRequired}),
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? query,
    bool authRequired = true,
  }) async {
    try {
      return await _dio.delete(
        endpoint,
        data: data,
        queryParameters: query,
        options: Options(extra: {'authRequired': authRequired}),
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Response> patch(
    String endpoint,
    dynamic data, {
    bool authRequired = true,
  }) async {
    try {
      return await _dio.patch(
        endpoint,
        data: data,
        options: Options(extra: {'authRequired': authRequired}),
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Response> put(
    String endpoint,
    dynamic data, {
    bool authRequired = true,
  }) async {
    try {
      return await _dio.put(
        endpoint,
        data: data,
        options: Options(extra: {'authRequired': authRequired}),
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return "Connection Timeout";
      case DioExceptionType.receiveTimeout:
        return "Receive Timeout";
      case DioExceptionType.connectionError:
        return "Can't reach the server";
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          return data['message'] ??
              "Received invalid status code: ${e.response?.statusCode}";
        }
        return "Server returned ${e.response?.statusCode}. Check your endpoint URL and POST/PUT method.";
      default:
        return e.message ?? "An unexpected error occurred";
    }
  }
}
