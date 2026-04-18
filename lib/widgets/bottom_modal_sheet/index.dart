import 'package:flutter/material.dart';

import 'main_content.dart';

/// 底部弹窗工具类
///
/// 提供便捷的底部弹窗显示方法，支持自定义内容、样式和行为
class BottomModalSheet {
  /// 显示底部弹窗
  ///
  /// ## 参数说明
  /// - [context]: BuildContext
  /// - [R]: 返回值类型（第一个泛型参数，更直观）
  /// - [T]: 数据项类型
  /// - [title]: 弹窗标题（可选）
  /// - [options]: 备选内容列表（必需）
  /// - [displayText]: 显示文本提取函数（可选），默认使用数据项的 `name` 字段
  /// - [valueExtractor]: 值提取函数（可选），默认使用数据项的 `id` 字段
  /// - [height]: 弹窗高度（可选，默认自适应）
  /// - [backgroundColor]: 背景颜色（默认白色）
  /// - [onDismissed]: 关闭回调（可选）
  /// - [showAdd]: 是否显示添加按钮（可选）
  /// - [remote]: 是否通过远程接口获取数据（可选）
  /// - [forceRefresh]: 是否强制刷新（可选）
  /// - [remoteMethod]: 远程获取数据方法（可选）
  ///
  /// ## 默认约定
  /// 如果不提供 `displayText` 和 `valueExtractor`，组件会自动尝试访问数据项的：
  /// - `name` 字段用于显示文本
  /// - `id` 字段用于返回值
  ///
  static Future<R?> show<R, T>(
    BuildContext context, {
    required List<T> options,
    String Function(T)? displayText,
    R Function(T)? valueExtractor,
    R? defaultValue, // 新增：默认选中值
    String? title = '请选择相关备选数据',
    bool? showAdd,
    bool? remote,
    bool? forceRefresh,
    Future<List<T>?> Function()? remoteMethod,
    double? height,
    Color? backgroundColor,
    VoidCallback? onDismissed,
  }) {
    // 默认显示文本提取函数：尝试访问 name 字段
    final defaultDisplayText =
        displayText ??
        ((item) {
          final dynamicObj = item as dynamic;
          return dynamicObj.name?.toString() ?? dynamicObj.toString();
        });

    // 默认值提取函数：尝试访问 id 字段
    final defaultValueExtractor =
        valueExtractor ??
        ((item) {
          final dynamicObj = item as dynamic;
          return dynamicObj.id as R;
        });
    return showModalBottomSheet<R>(
      context: context,
      isScrollControlled: true,
      backgroundColor: backgroundColor ?? Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
      builder: (BuildContext context) {
        final screenHeight = MediaQuery.of(context).size.height;
        return Container(
          height: screenHeight * 0.7,
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 10, right: 10),
          child: MainContent<R, T>(
            // 标题
            title: title,
            // 备选内容列表
            options: options,
            // 显示文本提取函数
            displayText: defaultDisplayText,
            // 值提取函数
            valueExtractor: defaultValueExtractor,
            // 默认选中值
            defaultValue: defaultValue,
            // 是否显示添加按钮
            showAdd: showAdd,
            // 是否通过远程接口获取数据
            remote: remote,
            // 是否强制刷新
            forceRefresh: forceRefresh,
            // 远程获取数据方法
            remoteMethod: remoteMethod,
          ),
        );
      },
    ).then((value) {
      onDismissed?.call();
      return value;
    });
  }
}
