import 'package:flutter/material.dart';
import '../../src/form_item.dart';
import '../../src/form_config.dart';
import '../../src/form_item_config.dart';
import '../../src/enums.dart';
import 'int_input.dart';
import 'horizontal_form_item_wrapper.dart';

/// 整数输入表单项组件
class IntInputFormItem extends StatelessWidget {
  final FormItem item;
  final dynamic value;
  final Function(dynamic) onChanged;
  final VoidCallback? onBlur;
  final FormConfig config;
  final bool hasError;
  final String? errorMessage;

  const IntInputFormItem({
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
    IntInputConfig? intConfig;
    if (item.config is IntInputConfig) {
      intConfig = item.config as IntInputConfig;
    }

    final allowNegative = intConfig?.allowNegative ?? false;
    final minValue = intConfig?.minValue;
    final maxValue = intConfig?.maxValue;
    final hintText = intConfig?.hintText;
    final showClearButton = intConfig?.showClearButton ?? true;
    final clearButtonDisplay = intConfig?.clearButtonDisplay ?? ClearButtonDisplay.auto;

    // 判断是否为横向布局
    final isHorizontal = config.layout == LayoutStyle.horizontal;

    // 创建 IntInput
    final inputWidget = IntInput(
      initialValue: value?.toString(),
      allowNegative: allowNegative,
      minValue: minValue,
      maxValue: maxValue,
      hintText: hintText,
      hasError: hasError,
      errorMessage: errorMessage,
      errorBorderColor: config.errorBorderColor,
      // 横向布局无边框，纵向布局显示边框
      border: isHorizontal ? InputBorder.none : null,
      contentPadding: isHorizontal ? EdgeInsets.zero : null,
      onChanged: (stringValue) {
        // 转换为整数并传递
        if (stringValue.isEmpty) {
          onChanged(null);
        } else {
          final intValue = int.tryParse(stringValue);
          onChanged(intValue);
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
        onClear: () {
          onChanged(null);
        },
      );
    } else {
      return inputWidget;
    }
  }
}
