import 'package:flutter/material.dart';

/// 一个支持异步操作的智能按钮组件
///
/// 详细文档请查看: readme.md
class Button extends StatefulWidget {
  /// 点击回调函数
  ///
  /// 支持同步和异步两种形式：
  /// - 同步：`onTap: () { print('hello'); }`
  /// - 异步：`onTap: () async { await fetchData(); }`
  ///
  /// 当回调返回 Future 时，按钮会自动进入 loading 状态
  final dynamic Function()? onTap;

  /// 按钮显示的文字
  ///
  /// 与 [child] 二选一，如果同时提供，优先使用 [text]
  final String? text;

  /// 按钮显示的自定义 Widget
  ///
  /// 与 [text] 二选一，用于更复杂的按钮内容布局
  final Widget? child;

  /// 自定义加载状态显示的 Widget
  ///
  /// 如果不提供，默认显示：旋转图标 + "处理中..." 文字
  final Widget? loadingWidget;

  /// 按钮宽度
  ///
  /// 不指定时，按钮宽度会根据内容自适应
  final double? width;

  /// 按钮高度
  ///
  /// 不指定时，按钮高度会根据内容自适应
  final double? height;

  /// 按钮背景颜色
  ///
  /// 不指定时使用 ElevatedButton 默认颜色
  final Color? backgroundColor;

  /// 禁用状态或加载状态的背景颜色
  ///
  /// 不指定时使用灰色 (Colors.grey.shade300)
  final Color? disabledColor;

  /// 加载状态显示的文字
  ///
  /// 不指定时使用 "处理中..."
  final String? loadingText;

  /// 加载状态显示的文字颜色
  ///
  /// 不指定时使用白色 (Colors.white)
  final Color? loadingTextColor;

  /// 加载状态显示的文字大小
  ///
  /// 不指定时使用 16
  final double? loadingTextSize;

  /// 按钮样式
  final ButtonStyle? style;

  /// 创建按钮组件
  ///
  /// [text] 和 [child] 必须至少提供一个
  const Button({
    super.key,
    this.onTap,
    this.text,
    this.child,
    this.loadingWidget,
    this.width,
    this.height,
    this.backgroundColor,
    this.disabledColor,
    this.loadingText,
    this.loadingTextColor,
    this.loadingTextSize,
    this.style,
  });

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading || widget.onTap == null) return;

    final result = widget.onTap!();

    // 判断返回值是否为 Future，自动处理异步/同步
    if (result is Future) {
      setState(() => _isLoading = true);
      try {
        await result;
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果提供了 text，则使用 Text widget；否则使用 child
    final content = widget.text != null ? Text(widget.text!) : widget.child;

    if (content == null) {
      throw FlutterError('Button组件 text 或者 child 属性必须有其中一个');
    }

    final button = ElevatedButton(
      onPressed: _isLoading ? null : (widget.onTap != null ? () => _handlePress() : null),
      style: widget.style ?? ElevatedButton.styleFrom(backgroundColor: _isLoading ? widget.disabledColor ?? Colors.grey.shade300 : widget.backgroundColor),
      child: _isLoading
          ? (widget.loadingWidget ??
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                    const SizedBox(width: 8),
                    Text(
                      widget.loadingText ?? '处理中...',
                      style: TextStyle(color: widget.loadingTextColor ?? Colors.white, fontSize: widget.loadingTextSize ?? 16),
                    ),
                  ],
                ))
          : content,
    );

    // 只有在明确指定宽度或高度时才使用 SizedBox 包裹
    if (widget.width != null || widget.height != null) {
      return SizedBox(width: widget.width, height: widget.height, child: button);
    }
    return button;
  }
}
