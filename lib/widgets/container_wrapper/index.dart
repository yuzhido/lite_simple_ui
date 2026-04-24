import 'package:flutter/material.dart';
import 'package:lite_simple_ui/config/ui_theme.dart';
import 'package:lite_simple_ui/model/index.dart';

import 'widgets/prefix_icon_label.dart';
import 'widgets/suffix_clear_icon.dart';

class ContainerWrapper<R> extends StatefulWidget {
  final String label;
  final String? tip;
  final R? selectedValue;
  final List<R>? selectedValues;
  final bool required;
  final Widget? displayText;
  final VoidCallback? onTap;
  // 容器输入模式-输入/选择/自定义
  final InputMode inputMode;

  /// 清空选中回调
  final VoidCallback? onClear;

  /// 验证错误文本
  final String? errorText;

  /// 是否有验证错误
  final bool hasError;

  /// 是否启用组件
  final bool enabled;

  const ContainerWrapper({
    required this.label,
    this.required = true,
    this.selectedValue,
    this.displayText,
    this.onTap,
    this.onClear,
    super.key,
    this.selectedValues,
    this.tip,
    this.inputMode = InputMode.select,
    this.errorText,
    this.hasError = false,
    this.enabled = true,
  });
  @override
  State<ContainerWrapper> createState() => _ContainerWrapperState();
}

class _ContainerWrapperState<R> extends State<ContainerWrapper<R>> {
  bool isExpanded = false;
  late String tipInfo;
  @override
  void initState() {
    super.initState();
    getTipInfo();
  }

  @override
  void didUpdateWidget(covariant ContainerWrapper<R> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValue != widget.selectedValue) {
      setState(() {});
    }
  }

  /// 获取组件提示信息
  void getTipInfo() {
    if (widget.inputMode == InputMode.input) {
      tipInfo = widget.tip ?? '请输入${widget.label}';
    } else if (widget.inputMode == InputMode.select) {
      tipInfo = widget.tip ?? '请选择${widget.label}';
    } else if (widget.inputMode == InputMode.custom) {
      tipInfo = widget.tip ?? '请自定义${widget.label}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.enabled ? widget.onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: widget.enabled ? Colors.white : Colors.grey.shade100,
          border: Border.all(color: widget.hasError ? Colors.red : UiTheme.borderColor, width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.all(10),
        child: Row(
          spacing: 5,
          children: [
            PrefixIconLabel(label: widget.label),
            // 选中值
            if (widget.selectedValue != null || (widget.selectedValues?.isNotEmpty ?? false))
              Expanded(child: widget.displayText ?? SizedBox.shrink())
            // 验证错误信息
            else if (widget.hasError && widget.errorText != null)
              Expanded(
                child: Text(widget.errorText!, style: TextStyle(fontSize: 16, color: Colors.red.shade600)),
              )
            // 提示信息
            else
              Expanded(
                child: Text(tipInfo, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
              ),
            // 清空按钮
            SuffixClearIcon(
              onTap: (widget.selectedValue != null || (widget.selectedValues?.isNotEmpty ?? false)) ? widget.onClear : widget.onTap,
              selectedValue: widget.selectedValue,
              selectedValues: widget.selectedValues,
            ),
          ],
        ),
      ),
    );
  }
}
