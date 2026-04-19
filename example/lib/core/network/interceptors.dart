import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// 拦截器管理器
class InterceptorManager {
  /// 获取所有拦截器
  static List<Interceptor> getInterceptors({bool enableLog = true}) {
    final interceptors = <Interceptor>[
      // 请求拦截器
      _RequestInterceptor(),

      // 响应拦截器
      _ResponseInterceptor(),

      // 错误拦截器
      _ErrorInterceptor(),
    ];

    // 在调试模式下添加日志拦截器
    if (enableLog) {
      interceptors.add(PrettyDioLogger(requestHeader: true, requestBody: true, responseBody: true, responseHeader: false, error: true, compact: true, maxWidth: 90));
    }

    return interceptors;
  }
}

/// 请求拦截器 - 添加通用headers和认证信息
class _RequestInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 添加通用headers
    options.headers['Content-Type'] = 'application/json; charset=utf-8';
    options.headers['Accept'] = 'application/json';

    // 添加时间戳（可用于防重放攻击）
    options.headers['X-Timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();

    // 添加请求ID（用于追踪）
    options.headers['X-Request-ID'] = _generateRequestId();

    // TODO: 在这里添加Token认证逻辑
    // 示例：从存储中获取token并添加到headers
    // final token = await TokenStorage.getToken();
    // if (token != null && token.isNotEmpty) {
    //   options.headers['Authorization'] = 'Bearer $token';
    // }

    super.onRequest(options, handler);
  }

  /// 生成唯一请求ID
  String _generateRequestId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_randomString(8)}';
  }

  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(Iterable.generate(length, (_) => chars.codeUnitAt(_randomInt(chars.length))));
  }

  int _randomInt(int max) {
    return DateTime.now().millisecondsSinceEpoch % max;
  }
}

/// 响应拦截器 - 统一处理响应数据
class _ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 可以在这里对响应数据进行统一处理
    // 例如：解密数据、验证签名等

    super.onResponse(response, handler);
  }
}

/// 错误拦截器 - 统一处理错误
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 根据错误类型进行分类处理
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        err = err.copyWith(message: '请求超时，请检查网络连接');
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode != null) {
          err = err.copyWith(message: _getErrorMessageByStatusCode(statusCode));
        }
        break;

      case DioExceptionType.cancel:
        err = err.copyWith(message: '请求已取消');
        break;

      case DioExceptionType.unknown:
        err = err.copyWith(message: '网络异常，请检查网络连接');
        break;

      default:
        err = err.copyWith(message: '未知错误');
        break;
    }

    super.onError(err, handler);
  }

  /// 根据状态码获取错误消息
  String _getErrorMessageByStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '禁止访问';
      case 404:
        return '请求的资源不存在';
      case 405:
        return '请求方法不允许';
      case 408:
        return '请求超时';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务不可用';
      case 504:
        return '网关超时';
      default:
        return '请求失败，状态码: $statusCode';
    }
  }
}
