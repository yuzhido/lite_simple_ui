import 'package:flutter/material.dart';
import 'package:lite_simple_ui/config/ui_theme.dart';
import 'package:lite_simple_ui/model/index.dart';

class ContainerWrapper<R> extends StatefulWidget {
  final String label;
  final String? tip;
  final R? selectedValue;
  final Widget? displayText;
  final List<R>? selectedValues;
  final bool required;
  final VoidCallback? onTap;
  // 容器输入模式-输入/选择/自定义
  final InputMode inputMode;

  /// 清空选中回调
  final VoidCallback? onClear;
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
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: UiTheme.borderColor, width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.all(10),
        child: Row(
          spacing: 5,
          children: [
            // 前面图标
            Icon(Icons.branding_watermark_outlined, size: 20, color: UiTheme.primaryColor),
            // 必填标识
            if (widget.required)
              Text(
                '*',
                style: TextStyle(color: UiTheme.errorColor, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            // 标签
            Text(widget.label, style: TextStyle(fontSize: 16)),
            // 选中值
            if (widget.selectedValue != null)
              Expanded(child: widget.displayText ?? SizedBox.shrink())
            // 提示信息
            else
              Expanded(
                child: Text(tipInfo, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
              ),

            // 清空按钮
            InkWell(
              onTap: (widget.selectedValue != null || (widget.selectedValues?.isNotEmpty ?? false)) ? widget.onClear : widget.onTap,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (widget.selectedValue != null || (widget.selectedValues?.isNotEmpty ?? false)) ? Colors.red.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  widget.selectedValue != null || (widget.selectedValues?.isNotEmpty ?? false)
                      ? Icons.close
                      : isExpanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_right_rounded,
                  size: 20,
                  color: widget.selectedValue != null || (widget.selectedValues?.isNotEmpty ?? false) ? Colors.red.shade400 : Colors.blue.shade600,
                  weight: 2.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
