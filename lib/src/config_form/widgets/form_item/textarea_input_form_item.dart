import 'package:flutter/material.dart';
import '../../src/form_item.dart';
import '../../src/form_config.dart';
import '../../src/form_item_config.dart';
import '../../src/enums.dart';
import 'textarea_input.dart';
import 'horizontal_form_item_wrapper.dart';

/// 多行文本表单项组件
class TextareaInputFormItem extends StatelessWidget {
  final FormItem item;
  final dynamic value;
  final Function(dynamic) onChanged;
  final VoidCallback? onBlur;
  final FormConfig config;
  final bool hasError;
  final String? errorMessage;

  const TextareaInputFormItem({
    super.key,
    required this.item,
    required this.value,
    required this.onChanged,
    this.onBlur,
    required this.config,
    required this.hasError,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    // 从 config 中获取配置参数（类型安全）
    TextareaInputConfig? textareaConfig;
    if (item.config is TextareaInputConfig) {
      textareaConfig = item.config as TextareaInputConfig;
    }

    final hintText = textareaConfig?.hintText;
    final maxLength = textareaConfig?.maxLength;
    final minLines = textareaConfig?.minLines ?? 3;
    final maxLines = textareaConfig?.maxLines ?? 10;
    final readOnly = textareaConfig?.readOnly ?? false;
    final showClearButton = textareaConfig?.showClearButton ?? true;
    final clearButtonDisplay = textareaConfig?.clearButtonDisplay ?? ClearButtonDisplay.auto;

    // 计算字符计数
    final currentValue = value?.toString() ?? '';
    final currentLength = currentValue.length;
    final counterText = maxLength != null ? '$currentLength/$maxLength' : null;

    // 判断是否为横向布局
    final isHorizontal = config.layout == LayoutStyle.horizontal;

    // 创建 TextareaInput
    final inputWidget = TextareaInput(
      initialValue: value?.toString(),
      hintText: hintText,
      maxLength: maxLength,
      minLines: minLines,
      maxLines: maxLines,
      readOnly: readOnly,
      hasError: hasError,
      errorMessage: errorMessage,
      errorBorderColor: config.errorBorderColor,
      // 横向布局无边框，纵向布局显示边框
      border: isHorizontal ? InputBorder.none : null,
      contentPadding: isHorizontal ? EdgeInsets.zero : null,
      onChanged: (stringValue) {
        if (stringValue.isEmpty) {
          onChanged(null);
        } else {
          onChanged(stringValue);
        }
      },
    );

    // 横向布局使用包装器，纵向布局直接返回
    if (isHorizontal) {
      return HorizontalFormItemWrapper(
        inputWidget: inputWidget,
        showClearButton: showClearButton,
        clearButtonDisplay: clearButtonDisplay,
        value: value,
        counterText: counterText,
        onClear: () {
          onChanged(null);
        },
      );
    } else {
      return inputWidget;
    }
  }
}
