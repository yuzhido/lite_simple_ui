import 'package:dio/dio.dart';
import 'interceptors.dart';
import 'response_handler.dart';

/// HTTP 客户端 - 单例模式管理 Dio 实例
class HttpClient {
  static HttpClient? _instance;
  late Dio _dio;

  /// 是否启用日志
  bool _enableLog = true;

  /// 基础URL
  String _baseUrl = '';

  /// 连接超时时间（毫秒）
  int _connectTimeout = 30000;

  /// 接收超时时间（毫秒）
  int _receiveTimeout = 30000;

  /// 发送超时时间（毫秒）
  int _sendTimeout = 30000;

  HttpClient._internal() {
    _initDio();
  }

  /// 获取单例实例
  static HttpClient getInstance() {
    _instance ??= HttpClient._internal();
    return _instance!;
  }

  /// 初始化 Dio
  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: Duration(milliseconds: _connectTimeout),
        receiveTimeout: Duration(milliseconds: _receiveTimeout),
        sendTimeout: Duration(milliseconds: _sendTimeout),
        headers: {'Content-Type': 'application/json; charset=utf-8', 'Accept': 'application/json'},
      ),
    );

    // 添加拦截器
    _dio.interceptors.addAll(InterceptorManager.getInterceptors(enableLog: _enableLog));
  }

  /// 配置客户端
  void configure({String? baseUrl, int? connectTimeout, int? receiveTimeout, int? sendTimeout, bool? enableLog}) {
    if (baseUrl != null) {
      _baseUrl = baseUrl;
      _dio.options.baseUrl = baseUrl;
    }

    if (connectTimeout != null) {
      _connectTimeout = connectTimeout;
      _dio.options.connectTimeout = Duration(milliseconds: connectTimeout);
    }

    if (receiveTimeout != null) {
      _receiveTimeout = receiveTimeout;
      _dio.options.receiveTimeout = Duration(milliseconds: receiveTimeout);
    }

    if (sendTimeout != null) {
      _sendTimeout = sendTimeout;
      _dio.options.sendTimeout = Duration(milliseconds: sendTimeout);
    }

    if (enableLog != null) {
      _enableLog = enableLog;
      // 重新初始化拦截器以应用日志设置
      _dio.interceptors.clear();
      _dio.interceptors.addAll(InterceptorManager.getInterceptors(enableLog: _enableLog));
    }
  }

  /// GET 请求
  Future<T> get<T>(String path, {Map<String, dynamic>? queryParameters, Options? options, T? Function(dynamic)? parser}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters, options: options);
      return ResponseHandler.handleResponse<T>(response, parser: parser);
    } on DioException catch (e) {
      throw ResponseHandler.handleDioException(e);
    }
  }

  /// POST 请求
  Future<T> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, T? Function(dynamic)? parser}) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
      return ResponseHandler.handleResponse<T>(response, parser: parser);
    } on DioException catch (e) {
      throw ResponseHandler.handleDioException(e);
    }
  }

  /// PUT 请求
  Future<T> put<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, T? Function(dynamic)? parser}) async {
    try {
      final response = await _dio.put(path, data: data, queryParameters: queryParameters, options: options);
      return ResponseHandler.handleResponse<T>(response, parser: parser);
    } on DioException catch (e) {
      throw ResponseHandler.handleDioException(e);
    }
  }

  /// DELETE 请求
  Future<T> delete<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, T? Function(dynamic)? parser}) async {
    try {
      final response = await _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
      return ResponseHandler.handleResponse<T>(response, parser: parser);
    } on DioException catch (e) {
      throw ResponseHandler.handleDioException(e);
    }
  }

  /// PATCH 请求
  Future<T> patch<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, T? Function(dynamic)? parser}) async {
    try {
      final response = await _dio.patch(path, data: data, queryParameters: queryParameters, options: options);
      return ResponseHandler.handleResponse<T>(response, parser: parser);
    } on DioException catch (e) {
      throw ResponseHandler.handleDioException(e);
    }
  }

  /// 下载文件
  Future<Response> download(String url, String savePath, {ProgressCallback? onReceiveProgress, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.download(url, savePath, onReceiveProgress: onReceiveProgress, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw ResponseHandler.handleDioException(e);
    }
  }

  /// 上传文件
  Future<T> upload<T>(String path, FormData formData, {ProgressCallback? onSendProgress, Options? options, T? Function(dynamic)? parser}) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        options: options?.copyWith(headers: {'Content-Type': 'multipart/form-data'}) ?? Options(headers: {'Content-Type': 'multipart/form-data'}),
        onSendProgress: onSendProgress,
      );
      return ResponseHandler.handleResponse<T>(response, parser: parser);
    } on DioException catch (e) {
      throw ResponseHandler.handleDioException(e);
    }
  }

  /// 取消所有请求
  void cancelAllRequests() {
    _dio.close(force: true);
    _initDio();
  }

  /// 获取 Dio 实例（用于高级用法）
  Dio get dio => _dio;
}
