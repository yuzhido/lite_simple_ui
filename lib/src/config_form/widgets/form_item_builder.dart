import 'package:flutter/material.dart';
import '../src/enums.dart';
import '../src/form_item.dart';
import '../src/form_config.dart';
import 'form_item/index.dart';

/// 表单项构建器
class FormItemBuilder extends StatefulWidget {
  final FormItem item;
  final dynamic value;
  final Function(dynamic) onChanged;
  final VoidCallback? onBlur;
  final FormConfig config;
  final bool hasError;
  final String? errorMessage;

  const FormItemBuilder({
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
  State<FormItemBuilder> createState() => _FormItemBuilderState();
}

class _FormItemBuilderState extends State<FormItemBuilder> {
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
    // 如果提供了自定义 contentBuilder，优先使用
    if (widget.item.contentBuilder != null) {
      return widget.item.contentBuilder!(context, widget.value, widget.onChanged);
    }

    // 根据 formType 返回不同的组件
    switch (widget.item.formType) {
      case FormType.text:
        return TextInputFormItem(
          item: widget.item,
          value: widget.value,
          onChanged: widget.onChanged,
          onBlur: widget.onBlur,
          config: widget.config,
          hasError: widget.hasError,
          errorMessage: widget.errorMessage,
        );
      case FormType.textarea:
        return TextareaInputFormItem(
          item: widget.item,
          value: widget.value,
          onChanged: widget.onChanged,
          onBlur: widget.onBlur,
          config: widget.config,
          hasError: widget.hasError,
          errorMessage: widget.errorMessage,
        );
      case FormType.int:
        return IntInputFormItem(
          item: widget.item,
          value: widget.value,
          onChanged: widget.onChanged,
          onBlur: widget.onBlur,
          config: widget.config,
          hasError: widget.hasError,
          errorMessage: widget.errorMessage,
        );
      case FormType.double:
        return const Text('浮点数输入框待实现');
      case FormType.dropdownChoose:
        return DropdownFormItem(item: widget.item, value: widget.value, onChanged: widget.onChanged, config: widget.config, hasError: widget.hasError);
      case FormType.chooseTree:
        return TreeFormItem(item: widget.item, value: widget.value, onChanged: widget.onChanged, config: widget.config, hasError: widget.hasError);
      case FormType.custom:
        return CustomFormItem(item: widget.item, value: widget.value, onChanged: widget.onChanged, onBlur: widget.onBlur, config: widget.config, hasError: widget.hasError);
    }
  }
}
