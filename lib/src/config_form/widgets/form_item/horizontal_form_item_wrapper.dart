import 'package:flutter/material.dart';

/// 横向布局表单项统一包装器（仅用于输入区域）
///
/// 提供输入区域 + 清除按钮区域的布局
/// 无边框，简洁样式
///
/// 注意：Label 由外层 HorizontalLayoutStrategy 统一处理，此处不再显示
class HorizontalFormItemWrapper extends StatefulWidget {
  /// 输入区域组件
  final Widget inputWidget;

  /// 是否显示清除按钮
  final bool showClearButton;

  /// 清除按钮的显示逻辑
  final ClearButtonDisplay clearButtonDisplay;

  /// 清除回调
  final VoidCallback? onClear;

  /// 输入区域的值（用于自动判断是否显示清除按钮）
  final dynamic value;

  /// 字符计数文本（如 '14/20'）
  final String? counterText;

  const HorizontalFormItemWrapper({
    super.key,
    required this.inputWidget,
    this.showClearButton = true,
    this.clearButtonDisplay = ClearButtonDisplay.auto,
    this.onClear,
    this.value,
    this.counterText,
  });

  @override
  State<HorizontalFormItemWrapper> createState() => _HorizontalFormItemWrapperState();
}

class _HorizontalFormItemWrapperState extends State<HorizontalFormItemWrapper> {
  @override
  Widget build(BuildContext context) {
    // 判断是否应该显示清除按钮
    final bool shouldShowClear = _shouldShowClearButton();

    return Row(
      children: [
        // 输入区域
        Expanded(child: widget.inputWidget),

        // 右侧区域（字符计数 + 清除按钮）
        if (widget.counterText != null || (widget.showClearButton && shouldShowClear))
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 字符计数
              if (widget.counterText != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(widget.counterText!, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ),
              // 清除按钮
              if (widget.showClearButton && shouldShowClear)
                SizedBox(
                  width: 40,
                  child: Center(
                    child: GestureDetector(
                      onTap: widget.onClear,
                      child: Icon(Icons.clear, size: 18, color: Colors.grey.shade600),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  /// 判断是否应该显示清除按钮
  bool _shouldShowClearButton() {
    if (!widget.showClearButton) {
      return false;
    }

    switch (widget.clearButtonDisplay) {
      case ClearButtonDisplay.auto:
        // 自动模式：有内容时显示
        if (widget.value == null) {
          return false;
        }
        if (widget.value is String) {
          return (widget.value as String).isNotEmpty;
        }
        return true;

      case ClearButtonDisplay.always:
        // 始终显示
        return true;

      case ClearButtonDisplay.never:
        // 从不显示
        return false;
    }
  }
}

/// 清除按钮显示模式
enum ClearButtonDisplay {
  /// 自动模式：有内容时显示
  auto,

  /// 始终显示
  always,

  /// 从不显示
  never,
}
