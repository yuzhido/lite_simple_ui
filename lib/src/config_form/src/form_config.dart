import 'package:flutter/material.dart';
import 'enums.dart';

/// 表单配置类
class FormConfig {
  /// 布局风格
  final LayoutStyle layout;

  /// label 宽度（horizontal 模式）
  final double? labelWidth;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// label 样式
  final TextStyle? labelStyle;

  /// 错误提示样式
  final TextStyle? errorStyle;

  /// 输入框装饰
  final InputDecoration? decoration;

  /// 是否显示必填标记 *
  final bool showRequiredMark;

  /// 验证失败时的边框颜色
  final Color? errorBorderColor;

  /// 全局清除按钮构建器
  final Widget Function()? clearButtonBuilder;

  /// 是否显示底部分割线
  final bool showDivider;

  /// 分割线颜色
  final Color? dividerColor;

  const FormConfig({
    this.layout = LayoutStyle.vertical,
    this.labelWidth,
    this.padding,
    this.labelStyle,
    this.errorStyle,
    this.decoration,
    this.showRequiredMark = true,
    this.errorBorderColor = Colors.red,
    this.clearButtonBuilder,
    this.showDivider = false,
    this.dividerColor,
  });
}
