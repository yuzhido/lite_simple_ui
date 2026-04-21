import 'package:flutter/foundation.dart';

const String appName = "Lite Simple UI";
const String appVersion = "1.0.0";
const String apiVersion = "v1";

/// API 基础 URL 配置
///
/// 根据不同平台自动选择合适的 API 地址：
/// - Web/macOS: 使用 localhost
/// - Android/iOS: 使用局域网 IP（可配置）
class ApiConfig {
  /// 开发环境的局域网 IP（Mac 电脑的 IP 地址）
  ///
  /// 💡 如何获取当前电脑的 IP：
  /// 1. 查看 mock_data 服务器启动时的输出信息
  /// 2. 或在终端运行: ifconfig | grep "inet " | grep -v 127.0.0.1
  /// 3. 或使用命令: ipconfig getifaddr en0 (macOS)
  ///
  /// ⚠️ 注意：如果 IP 变化，请修改此值
  static const String _localNetworkIP = String.fromEnvironment(
    'API_HOST',
    defaultValue: '192.168.8.75', // 默认值，编译时可通过 --dart-define 覆盖
  );

  /// 后端服务端口
  static const int _port = int.fromEnvironment('API_PORT', defaultValue: 3000);

  /// API 路径前缀
  static const String _apiPrefix = '/api';

  /// 获取当前平台的 API 基础 URL
  static String get baseUrl {
    if (kIsWeb) {
      // Web 平台：使用 localhost
      return 'http://localhost:$_port$_apiPrefix';
    }

    // 根据目标平台判断
    if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
      // 移动设备：使用局域网 IP
      return 'http://$_localNetworkIP:$_port$_apiPrefix';
    }

    // macOS/Windows/Linux：使用 localhost
    return 'http://localhost:$_port$_apiPrefix';
  }

  /// 完整的基础 URL（包含版本）
  static String get baseUrlWithVersion => '$baseUrl/$apiVersion';

  /// 调试信息：显示当前使用的配置
  static void printConfig() {
    debugPrint('🔧 API Configuration:');
    debugPrint('   Platform: ${defaultTargetPlatform.name}');
    debugPrint('   Base URL: $baseUrl');
    debugPrint('   Local IP: $_localNetworkIP');
    debugPrint('   Port: $_port');
  }
}
