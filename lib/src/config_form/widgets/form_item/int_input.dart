import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 整数输入框组件
class IntInput extends StatefulWidget {
  /// 初始值
  final String? initialValue;

  /// 是否允许负数
  final bool allowNegative;

  /// 最小值（可选）
  final int? minValue;

  /// 最大值（可选）
  final int? maxValue;

  /// 占位符文本
  final String? hintText;

  /// 是否只读
  final bool readOnly;

  /// 值变化回调
  final Function(String)? onChanged;

  /// 错误状态
  final bool hasError;

  /// 错误边框颜色
  final Color? errorBorderColor;

  /// 错误信息（可选，用于外部传递错误）
  final String? errorMessage;

  /// 输入装饰
  final InputDecoration? inputDecoration;

  /// 边框样式
  final InputBorder? border;

  /// 内容内边距
  final EdgeInsetsGeometry? contentPadding;

  const IntInput({
    super.key,
    this.initialValue,
    this.allowNegative = false,
    this.minValue,
    this.maxValue,
    this.hintText,
    this.readOnly = false,
    this.onChanged,
    this.hasError = false,
    this.errorBorderColor,
    this.errorMessage,
    this.inputDecoration,
    this.border,
    this.contentPadding,
  });

  @override
  State<IntInput> createState() => _IntInputState();
}

class _IntInputState extends State<IntInput> {
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
  void didUpdateWidget(IntInput oldWidget) {
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

    // 整数格式验证
    final regex = widget.allowNegative ? RegExp(r'^-?\d+$') : RegExp(r'^\d+$');
    if (!regex.hasMatch(value)) {
      error = '请输入有效的整数';
    } else {
      // 数值范围验证
      final intValue = int.tryParse(value);
      if (intValue != null) {
        if (widget.minValue != null && intValue < widget.minValue!) {
          error = '不能小于${widget.minValue}';
        } else if (widget.maxValue != null && intValue > widget.maxValue!) {
          error = '不能大于${widget.maxValue}';
        }
      }
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
    final displayHintText = hasExternalError ? widget.errorMessage! : (_errorText ?? (widget.hintText ?? '请输入整数'));

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

    // 合并装饰器
    final decoration =
        widget.inputDecoration ??
        InputDecoration(
          hintText: displayHintText,
          hintStyle: hintStyle,
          contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          border: widget.border ?? borderDecoration,
          enabledBorder: widget.border ?? borderDecoration,
          focusedBorder: widget.border ?? borderDecoration.copyWith(borderSide: const BorderSide(color: Color(0xFF1890FF), width: 2)),
          // 有错误时不显示 errorText，因为我们用 hintText 显示错误
          errorText: null,
        );

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: decoration,
      readOnly: widget.readOnly,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.left,
      inputFormatters: [
        // 允许负号（如果配置了）和数字
        FilteringTextInputFormatter.allow(widget.allowNegative ? RegExp(r'^-?\d*') : RegExp(r'\d*')),
      ],
      onChanged: (value) {
        _validate(value);
        widget.onChanged?.call(value);
      },
    );
  }
}
