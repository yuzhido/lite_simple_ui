import 'package:flutter/material.dart';
import 'package:lite_simple_ui/config/ui_theme.dart';
import 'package:lite_simple_ui/widgets/bottom_modal_sheet/index.dart';
import 'package:lite_simple_ui/widgets/container_wrapper/index.dart';

class DropdownChoose<R, T> extends StatefulWidget {
  /// 选项列表
  final List<T> options;

  /// 是否多选
  final bool isMultiSelect;

  /// 标签名称
  final String label;

  /// 提示信息
  final String? tip;

  /// 选中的值
  final R? selectedValue;

  /// 选中的值列表
  final List<R>? selectedValues;

  /// 从对象中提取 ID（默认提取 id 字段）
  final R Function(T)? valueExtractor;

  /// 从对象中提取显示文本（默认提取 name 字段）
  final String Function(T)? displayText;

  /// 选中时的回调
  final void Function(R, T, bool?)? onChange;

  /// 确认时的回调
  final void Function(List<R>, List<T>)? onConfirm;

  const DropdownChoose({
    required this.options,
    this.isMultiSelect = false,
    super.key,
    required this.label,
    this.tip,
    this.selectedValue,
    this.selectedValues,
    this.valueExtractor,
    this.displayText,
    this.onChange,
    this.onConfirm,
  });
  @override
  State<DropdownChoose<R, T>> createState() => _DropdownChooseState<R, T>();
}

class _DropdownChooseState<R, T> extends State<DropdownChoose<R, T>> {
  R? selectedValue;
  List<R>? selectedValues;
  @override
  void initState() {
    super.initState();
    selectedValue = widget.selectedValue;
  }

  /// 清空选中值
  void onClear() {
    setState(() {
      selectedValue = null;
      selectedValues = null;
    });
  }

  dynamic _selectData;

  /// 从对象中提取 ID
  R _extractValue(T item) {
    if (widget.valueExtractor != null) return widget.valueExtractor!(item);
    final dynamicObj = item as dynamic;
    return dynamicObj.id as R;
  }

  /// 从对象中提取显示文本
  String _extractDisplayText(T item) {
    if (widget.displayText != null) return widget.displayText!(item);
    final dynamicObj = item as dynamic;
    return dynamicObj.name?.toString() ?? item.toString();
  }

  /// 通过 ID 在 options 中查找对象
  T? _findOptionById(R id) {
    for (var item in widget.options) {
      if (_extractValue(item) == id) return item;
    }
    return null;
  }

  /// 获取显示文本
  Widget _getDisplayText() {
    final tipInfo = widget.tip ?? '请选择${widget.label}';
    if (widget.isMultiSelect == true) {
      final ids = selectedValues ?? [];
      if (ids.isEmpty) return Text(tipInfo, style: TextStyle(fontSize: 16, color: UiTheme.tipTextFontColor));
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 6,
          children: ids.map((id) {
            final item = _findOptionById(id);
            final displayText = item != null ? _extractDisplayText(item) : id.toString();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFE8E0FF), borderRadius: BorderRadius.circular(15)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  Text(
                    displayText,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF6B21A8), fontWeight: FontWeight.w500),
                  ),
                  const Icon(Icons.close, size: 16, color: Color(0xFF6B21A8)),
                ],
              ),
            );
          }).toList(),
        ),
      );
    } else {
      if (selectedValue == null) return Text(tipInfo, style: TextStyle(fontSize: 16, color: Colors.grey.shade600));
      final item = _findOptionById(selectedValue as R);
      return Text(item != null ? _extractDisplayText(item) : selectedValue.toString());
    }
  }

  /// 点击显示弹窗-显示选中值
  void onShowChoose() async {
    final res = await BottomModalSheet.show<R, T>(
      context,
      title: widget.label,
      options: widget.options,
      defaultValue: widget.isMultiSelect ? selectedValues : selectedValue,
      isMultiSelect: widget.isMultiSelect,
      displayText: widget.displayText,
      valueExtractor: widget.valueExtractor,
      onChange: (R r, T data) {
        // 更新选中值 传递选中的实际值好还是选中这个完整对象好(后续评估取舍)
        selectedValue = r;
        _selectData = data;
        if (widget.onChange != null) {
          widget.onChange!(r, data, null);
        }
      },
      onConfirm: (List<R> r, List<T> data) {
        selectedValues = r;
        _selectData = data.map((item) => _extractDisplayText(item)).toList();
        if (widget.onConfirm != null) {
          widget.onConfirm!(r, data);
        }
        setState(() {});
      },
    );

    if (res != null) {
      setState(() {
        if (widget.isMultiSelect) {
          selectedValues = res as List<R>?;
        } else {
          selectedValue = res as R?;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContainerWrapper<R>(
      // 标签名称
      label: widget.label,
      tip: widget.tip,
      selectedValue: selectedValue,
      selectedValues: selectedValues,
      displayText: _getDisplayText(),
      onClear: onClear,
      onTap: onShowChoose,
    );
  }
}
