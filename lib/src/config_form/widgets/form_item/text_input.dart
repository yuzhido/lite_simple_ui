import 'package:flutter/material.dart';

/// 单行文本输入框组件
class TextInput extends StatefulWidget {
  /// 初始值
  final String? initialValue;

  /// 占位符文本
  final String? hintText;

  /// 最大长度（可选）
  final int? maxLength;

  /// 是否只读
  final bool readOnly;

  /// 键盘类型
  final TextInputType keyboardType;

  /// 错误状态
  final bool hasError;

  /// 错误边框颜色
  final Color? errorBorderColor;

  /// 错误信息（可选，用于外部传递错误）
  final String? errorMessage;

  /// 值变化回调
  final Function(String)? onChanged;

  /// 边框样式
  final InputBorder? border;

  /// 内容内边距
  final EdgeInsetsGeometry? contentPadding;

  const TextInput({
    super.key,
    this.initialValue,
    this.hintText,
    this.maxLength,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.hasError = false,
    this.errorBorderColor,
    this.errorMessage,
    this.onChanged,
    this.border,
    this.contentPadding,
  });

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _focusNode = FocusNode();
    _validate(_controller.text);
  }

  @override
  void didUpdateWidget(TextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果 initialValue 变化且当前为空，更新值
    if (oldWidget.initialValue != widget.initialValue && _controller.text.isEmpty && widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 验证输入值
  void _validate(String value) {
    String? error;

    // 空值处理
    if (value.isEmpty) {
      setState(() {
        _errorText = null;
      });
      return;
    }

    // 长度验证
    if (widget.maxLength != null && value.length > widget.maxLength!) {
      error = '不能超过${widget.maxLength}个字符';
    }

    setState(() {
      _errorText = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 判断是否为横向布局
    final isHorizontal = widget.border == InputBorder.none;

    // 错误信息优先级：外部 errorMessage > 内部 _errorText
    final hasExternalError = widget.hasError && widget.errorMessage != null;
    final displayHintText = hasExternalError ? widget.errorMessage! : (_errorText ?? (widget.hintText ?? '请输入'));

    // 有错误时使用红色样式，否则使用默认样式
    final hasAnyError = hasExternalError || _errorText != null;
    final hintStyle = hasAnyError ? const TextStyle(color: Colors.red, fontSize: 14) : null;

    // 纵向布局使用完整边框
    final borderDecoration = isHorizontal
        ? InputBorder.none
        : const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          );

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: displayHintText,
        hintStyle: hintStyle,
        contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: widget.border ?? borderDecoration,
        enabledBorder: widget.border ?? borderDecoration,
        focusedBorder: widget.border ?? borderDecoration.copyWith(borderSide: const BorderSide(color: Color(0xFF1890FF), width: 2)),
        // 有错误时不显示 errorText，因为我们用 hintText 显示错误
        errorText: null,
        // 移除 counterText，由外层 HorizontalFormItemWrapper 统一显示
        counterText: null,
      ),
      readOnly: widget.readOnly,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      // 禁用 TextField 自带的计数器
      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
      onChanged: (value) {
        _validate(value);
        widget.onChanged?.call(value);
      },
    );
  }
}
