import 'package:flutter/material.dart';
import '../../model/tree_select.dart';
import '../widgets/form_item/horizontal_form_item_wrapper.dart';

/// 表单项配置基类（密封类）
///
/// 用于为不同类型的表单项提供类型安全的配置
sealed class FormItemConfig {}

/// 整数输入框配置
///
/// 用于 [FormType.int] 类型的表单项
class IntInputConfig extends FormItemConfig {
  /// 占位符文本
  final String? hintText;

  /// 是否允许负数
  final bool allowNegative;

  /// 最小值（可选）
  final int? minValue;

  /// 最大值（可选）
  final int? maxValue;

  /// Label 区域宽度
  final double? labelWidth;

  /// 是否显示清除按钮
  final bool showClearButton;

  /// 清除按钮显示模式
  final ClearButtonDisplay? clearButtonDisplay;

  IntInputConfig({this.hintText, this.allowNegative = false, this.minValue, this.maxValue, this.labelWidth, this.showClearButton = true, this.clearButtonDisplay});
}

/// 浮点数输入框配置
///
/// 用于 [FormType.double] 类型的表单项
class DoubleInputConfig extends FormItemConfig {
  /// 占位符文本
  final String? hintText;

  /// 是否允许负数
  final bool allowNegative;

  /// 最小值（可选）
  final double? minValue;

  /// 最大值（可选）
  final double? maxValue;

  /// 小数位数精度
  final int precision;

  DoubleInputConfig({this.hintText, this.allowNegative = false, this.minValue, this.maxValue, this.precision = 2});
}

/// 下拉选择器配置
///
/// 用于 [FormType.dropdownChoose] 类型的表单项
class DropdownChooseConfig extends FormItemConfig {
  /// 选项列表
  final List<Map<String, dynamic>> options;

  /// 占位符文本
  final String? placeholder;

  /// Label 区域宽度
  final double? labelWidth;

  /// 是否显示清除按钮
  final bool showClearButton;

  /// 清除按钮显示模式
  final ClearButtonDisplay? clearButtonDisplay;

  DropdownChooseConfig({required this.options, this.placeholder, this.labelWidth, this.showClearButton = true, this.clearButtonDisplay});
}

/// 树形选择器配置
///
/// 用于 [FormType.chooseTree] 类型的表单项
class ChooseTreeConfig extends FormItemConfig {
  /// 树形数据
  final List<Map<String, dynamic>> data;

  /// 字段映射配置
  final FieldMapping? fieldMapping;

  /// 是否显示搜索框
  final bool showSearch;

  /// Label 区域宽度
  final double? labelWidth;

  /// 是否显示清除按钮
  final bool showClearButton;

  /// 清除按钮显示模式
  final ClearButtonDisplay? clearButtonDisplay;

  ChooseTreeConfig({required this.data, this.fieldMapping, this.showSearch = false, this.labelWidth, this.showClearButton = true, this.clearButtonDisplay});
}

/// 自定义组件配置
///
/// 用于 [FormType.custom] 类型的表单项
class CustomConfig extends FormItemConfig {
  /// 额外的配置参数
  final Map<String, dynamic>? extraConfig;

  CustomConfig({this.extraConfig});
}

/// 单行文本输入框配置
///
/// 用于 [FormType.text] 类型的表单项
class TextInputConfig extends FormItemConfig {
  /// 占位符文本
  final String? hintText;

  /// 最大长度（可选）
  final int? maxLength;

  /// 是否只读
  final bool readOnly;

  /// 键盘类型
  final TextInputType keyboardType;

  /// Label 区域宽度
  final double? labelWidth;

  /// 是否显示清除按钮
  final bool showClearButton;

  /// 清除按钮显示模式
  final ClearButtonDisplay? clearButtonDisplay;

  TextInputConfig({
    this.hintText,
    this.maxLength,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.labelWidth,
    this.showClearButton = true,
    this.clearButtonDisplay,
  });
}

/// 多行文本输入框配置
///
/// 用于 [FormType.textarea] 类型的表单项
class TextareaInputConfig extends FormItemConfig {
  /// 占位符文本
  final String? hintText;

  /// 最大长度（可选）
  final int? maxLength;

  /// 最小行数
  final int minLines;

  /// 最大行数（超过滚动）
  final int maxLines;

  /// 是否只读
  final bool readOnly;

  /// Label 区域宽度
  final double? labelWidth;

  /// 是否显示清除按钮
  final bool showClearButton;

  /// 清除按钮显示模式
  final ClearButtonDisplay? clearButtonDisplay;

  TextareaInputConfig({
    this.hintText,
    this.maxLength,
    this.minLines = 3,
    this.maxLines = 10,
    this.readOnly = false,
    this.labelWidth,
    this.showClearButton = true,
    this.clearButtonDisplay,
  });
}
