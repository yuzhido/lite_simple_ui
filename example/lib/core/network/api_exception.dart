/// API 异常类 - 统一处理网络和业务异常
class ApiException implements Exception {
  /// 错误码
  final int code;

  /// 错误消息
  final String message;

  /// 原始数据（可选）
  final dynamic data;

  /// 堆栈跟踪（可选）
  final StackTrace? stackTrace;

  ApiException({required this.code, required this.message, this.data, this.stackTrace});

  @override
  String toString() => 'ApiException(code: $code, message: $message)';
}

/// 网络异常 - 连接超时、DNS解析失败等
class NetworkException extends ApiException {
  NetworkException({required super.code, required super.message, super.data, super.stackTrace});
}

/// 业务异常 - HTTP状态码错误或服务端返回错误
class BusinessException extends ApiException {
  BusinessException({required super.code, required super.message, super.data, super.stackTrace});
}

/// 认证异常 - Token过期、权限不足等
class AuthException extends ApiException {
  AuthException({required super.code, required super.message, super.data, super.stackTrace});
}

/// 服务器异常 - 5xx 错误
class ServerException extends ApiException {
  ServerException({required super.code, required super.message, super.data, super.stackTrace});
}

/// 客户端异常 - 4xx 错误（除认证外）
class ClientException extends ApiException {
  ClientException({required super.code, required super.message, super.data, super.stackTrace});
}

/// 未知异常
class UnknownException extends ApiException {
  UnknownException({required super.code, required super.message, super.data, super.stackTrace});
}
