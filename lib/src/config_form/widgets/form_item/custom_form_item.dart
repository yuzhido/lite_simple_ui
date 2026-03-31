import 'package:flutter/material.dart';
import '../../src/form_item.dart';
import '../../src/form_config.dart';
import '../../src/form_item_config.dart';
import 'horizontal_form_item_wrapper.dart';

/// 自定义表单项组件
class CustomFormItem extends StatefulWidget {
  final FormItem item;
  final dynamic value;
  final Function(dynamic) onChanged;
  final VoidCallback? onBlur;
  final FormConfig config;
  final bool hasError;

  const CustomFormItem({super.key, required this.item, required this.value, required this.onChanged, this.onBlur, required this.config, required this.hasError});

  @override
  State<CustomFormItem> createState() => _CustomFormItemState();
}

class _CustomFormItemState extends State<CustomFormItem> {
  late FocusNode _focusNode;
  bool _wasFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      // 检测失去焦点
      if (_wasFocused && !_focusNode.hasFocus) {
        widget.onBlur?.call();
      }
      _wasFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item.customBuilder == null) {
      return const SizedBox.shrink();
    }

    // 如果 customBuilder 返回的是 TextField，需要包装 FocusNode
    final customWidget = widget.item.customBuilder!();

    // 如果是 TextField 且没有设置 focusNode，自动包装
    if (customWidget is TextField && customWidget.focusNode == null) {
      // 获取原始 decoration 的 hintText
      final originalHintText = customWidget.decoration?.hintText ?? '';

      // 有错误时显示错误信息，否则显示原始 hintText
      final displayHintText = widget.hasError ? (widget.item.actualValidator?.call(widget.value) ?? originalHintText) : originalHintText;

      // 有错误时使用红色样式，否则使用默认样式
      final hintStyle = widget.hasError ? const TextStyle(color: Colors.red, fontSize: 14) : null;

      final textField = TextField(
        focusNode: _focusNode,
        decoration:
            customWidget.decoration?.copyWith(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: displayHintText, // 替换 hintText 为错误信息或原始提示
              hintStyle: hintStyle, // 设置 hint 样式
              errorText: null, // 不显示 errorText
            ) ??
            InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, hintText: displayHintText, hintStyle: hintStyle),
        controller: customWidget.controller,
        onChanged: (value) {
          if (customWidget.onChanged != null) {
            customWidget.onChanged!(value);
          }
          widget.onChanged(value);
        },
        onTap: customWidget.onTap,
        readOnly: customWidget.readOnly,
        keyboardType: customWidget.keyboardType,
        textInputAction: customWidget.textInputAction,
      );

      // 使用包装器包裹自定义组件
      return HorizontalFormItemWrapper(
        inputWidget: textField,
        showClearButton: false, // 自定义组件自行处理清除
        value: widget.value,
      );
    }

    // 其他情况直接返回，但需要手动触发 onBlur
    final wrappedWidget = Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus && _wasFocused) {
          widget.onBlur?.call();
        }
        _wasFocused = hasFocus;
      },
      child: customWidget,
    );

    // 使用包装器包裹自定义组件
    return HorizontalFormItemWrapper(
      inputWidget: wrappedWidget,
      showClearButton: false, // 自定义组件自行处理清除
      value: widget.value,
    );
  }
}
