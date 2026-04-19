import 'package:dio/dio.dart';
import 'api_exception.dart';

/// 统一响应格式（适配 mock_data 后端）
class ApiResponse<T> {
  /// 是否成功
  final bool success;

  /// 消息
  final String message;

  /// 数据
  final T? data;

  /// HTTP 状态码（从响应头获取）
  final int? statusCode;

  /// 是否成功（兼容属性）
  bool get isSuccess => success;

  /// 错误码（兼容属性，从 statusCode 推导）
  int get code => statusCode ?? (success ? 200 : 500);

  ApiResponse({required this.success, required this.message, this.data, this.statusCode});

  /// 从 Map 创建 ApiResponse（适配 mock_data 后端格式）
  /// 后端返回格式：{ success: boolean, message: string, data?: any }
  factory ApiResponse.fromJson(Map<String, dynamic> json, {int? statusCode, T? Function(dynamic)? parser}) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: parser != null && json['data'] != null ? parser(json['data']) : json['data'] as T?,
      statusCode: statusCode,
    );
  }

  @override
  String toString() => 'ApiResponse(success: $success, message: $message, data: $data)';
}

/// 响应处理器
class ResponseHandler {
  /// 处理响应数据
  static T handleResponse<T>(Response response, {T? Function(dynamic)? parser}) {
    // 检查HTTP状态码
    if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
      throw _createExceptionFromResponse(response);
    }

    // 解析响应数据
    final responseData = response.data;

    // 如果响应数据是Map，尝试解析为标准格式
    if (responseData is Map<String, dynamic>) {
      final apiResponse = ApiResponse<T>.fromJson(responseData, statusCode: response.statusCode, parser: parser);

      if (!apiResponse.isSuccess) {
        throw BusinessException(code: apiResponse.code, message: apiResponse.message, data: apiResponse.data);
      }

      return apiResponse.data as T;
    }

    // 如果不是标准格式，直接返回数据
    return responseData as T;
  }

  /// 从响应创建异常
  static ApiException _createExceptionFromResponse(Response response) {
    final statusCode = response.statusCode ?? -1;
    final responseData = response.data;

    String message = '请求失败';
    dynamic data;

    if (responseData is Map<String, dynamic>) {
      message = responseData['message'] ?? responseData['msg'] ?? '请求失败';
      data = responseData['data'];
    } else if (responseData is String) {
      message = responseData;
    }

    // 根据状态码分类异常
    if (statusCode >= 500) {
      return ServerException(code: statusCode, message: message, data: data);
    } else if (statusCode == 401) {
      return AuthException(code: statusCode, message: message, data: data);
    } else if (statusCode >= 400 && statusCode < 500) {
      return ClientException(code: statusCode, message: message, data: data);
    } else {
      return UnknownException(code: statusCode, message: message, data: data);
    }
  }

  /// 处理DioException并转换为ApiException
  static ApiException handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(code: -1, message: error.message ?? '请求超时', stackTrace: error.stackTrace);

      case DioExceptionType.badResponse:
        final response = error.response;
        if (response != null) {
          return _createExceptionFromResponse(response);
        }
        return UnknownException(code: -1, message: error.message ?? '未知错误', stackTrace: error.stackTrace);

      case DioExceptionType.cancel:
        return UnknownException(code: -2, message: '请求已取消', stackTrace: error.stackTrace);

      case DioExceptionType.unknown:
        return NetworkException(code: -1, message: error.message ?? '网络异常', stackTrace: error.stackTrace);

      default:
        return UnknownException(code: -1, message: error.message ?? '未知错误', stackTrace: error.stackTrace);
    }
  }
}
