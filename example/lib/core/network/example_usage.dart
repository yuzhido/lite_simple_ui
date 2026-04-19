import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'index.dart';

/// 网络层使用示例
class NetworkExample {
  /// 初始化 HTTP 客户端
  static void initHttpClient() {
    final httpClient = HttpClient.getInstance();

    // 配置基础URL和超时时间
    httpClient.configure(
      baseUrl: 'https://api.example.com',
      connectTimeout: 30000,
      receiveTimeout: 30000,
      sendTimeout: 30000,
      enableLog: true, // 调试模式下开启日志
    );
  }

  /// GET 请求示例
  static Future<void> getUserList() async {
    try {
      final httpClient = HttpClient.getInstance();

      // 简单GET请求
      final users = await httpClient.get<List>('/api/users', queryParameters: {'page': 1, 'limit': 10});

      debugPrint('用户列表: $users');
    } on ApiException catch (e) {
      // 处理API异常
      debugPrint('API错误: ${e.code} - ${e.message}');

      if (e is AuthException) {
        // 处理认证异常，如跳转到登录页
        debugPrint('需要重新登录');
      } else if (e is NetworkException) {
        // 处理网络异常
        debugPrint('网络连接失败');
      }
    } catch (e) {
      debugPrint('未知错误: $e');
    }
  }

  /// POST 请求示例
  static Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      final httpClient = HttpClient.getInstance();

      final result = await httpClient.post<Map<String, dynamic>>('/api/users', data: userData);

      debugPrint('创建用户成功: $result');
    } on ApiException catch (e) {
      debugPrint('创建用户失败: ${e.message}');
    }
  }

  /// 带自定义解析器的请求示例
  static Future<void> getUserDetail(int userId) async {
    try {
      final httpClient = HttpClient.getInstance();

      final user = await httpClient.get<Map<String, dynamic>>(
        '/api/users/$userId',
        parser: (data) {
          // 在这里进行数据转换
          return data as Map<String, dynamic>;
        },
      );

      debugPrint('用户详情: $user');
    } on ApiException catch (e) {
      debugPrint('获取用户详情失败: ${e.message}');
    }
  }

  /// 文件上传示例
  static Future<void> uploadFile(String filePath) async {
    try {
      final httpClient = HttpClient.getInstance();

      final formData = FormData.fromMap({'file': await MultipartFile.fromFile(filePath), 'description': '文件描述'});

      final result = await httpClient.upload<Map<String, dynamic>>(
        '/api/upload',
        formData,
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).toStringAsFixed(2);
          debugPrint('上传进度: $progress%');
        },
      );

      debugPrint('上传成功: $result');
    } on ApiException catch (e) {
      debugPrint('上传失败: ${e.message}');
    }
  }

  /// 文件下载示例
  static Future<void> downloadFile(String url, String savePath) async {
    try {
      final httpClient = HttpClient.getInstance();

      await httpClient.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(2);
            debugPrint('下载进度: $progress%');
          }
        },
      );

      debugPrint('下载成功');
    } on ApiException catch (e) {
      debugPrint('下载失败: ${e.message}');
    }
  }

  /// 取消所有请求
  static void cancelAllRequests() {
    final httpClient = HttpClient.getInstance();
    httpClient.cancelAllRequests();
    debugPrint('已取消所有请求');
  }
}
