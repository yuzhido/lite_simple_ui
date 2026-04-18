import 'package:flutter/material.dart';

class AppRouter {
  /// 路由跳转，接收 Widget 实例
  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(context, MaterialPageRoute(builder: (context) => page));
  }

  /// 路由跳转，接收 Widget 类型（自动实例化）
  static Future<T?> pushType<T>(BuildContext context, Widget Function() pageBuilder) {
    return Navigator.push<T>(context, MaterialPageRoute(builder: (context) => pageBuilder()));
  }

  /// 替换当前路由
  static Future<T?> pushReplacement<T, TO>(BuildContext context, Widget page) {
    return Navigator.pushReplacement<T, TO>(context, MaterialPageRoute(builder: (context) => page));
  }

  /// 清空栈并跳转到指定路由
  static Future<T?> pushAndRemoveUntil<T>(BuildContext context, Widget page) {
    return Navigator.pushAndRemoveUntil<T>(context, MaterialPageRoute(builder: (context) => page), (route) => false);
  }
}
