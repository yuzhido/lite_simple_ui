import 'package:flutter/material.dart';
import 'package:lite_simple_ui/config/ui_theme.dart';
import 'package:lite_simple_ui/widgets/bottom_modal_sheet/index.dart';
import 'package:lite_simple_ui/widgets/container_wrapper/index.dart';

import 'controller.dart';
import 'data_helper.dart';
import 'selection_manager.dart';

/// 下拉选择组件 - 支持 Flutter Form 表单验证
class DropdownChoose<R, T> extends FormField<dynamic> {
  /// 选项列表
  final List<T> options;

  /// 是否多选
  final bool isMultiSelect;

  /// 标签名称
  final String label;

  /// 提示信息
  final String? tip;

  /// 选中的值（单选）
  final R? selectedValue;

  /// 选中的值列表（多选）
  final List<R>? selectedValues;

  /// 从对象中提取 ID（默认提取 id 字段）
  final R Function(T)? valueExtractor;

  /// 从对象中提取显示文本（默认提取 name 字段）
  final String Function(T)? displayText;

  /// 选中时的回调
  final void Function(R, T, bool?)? onChange;

  /// 确认时的回调（多选）
  final void Function(List<R>, List<T>)? onConfirm;

  /// 控制器（可选）
  final DropdownChooseController<R>? controller;

  /// 初始显示值（用于编辑回显）
  /// 当只有 ID 时，传入包含 id 和 name 的最小化对象
  final T? initialDisplayValue;

  DropdownChoose({
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
    this.controller,
    this.initialDisplayValue,
    super.validator,
    super.autovalidateMode = AutovalidateMode.disabled,
  }) : super(
         builder: (FormFieldState<dynamic> field) {
           return _DropdownChooseField<R, T>(
             options: options,
             isMultiSelect: isMultiSelect,
             label: label,
             tip: tip,
             selectedValue: selectedValue,
             selectedValues: selectedValues,
             valueExtractor: valueExtractor,
             displayText: displayText,
             onChange: onChange,
             onConfirm: onConfirm,
             controller: controller,
             initialDisplayValue: initialDisplayValue,
             field: field,
           );
         },
       );
}

/// 内部字段组件 - 与 FormField 集成
class _DropdownChooseField<R, T> extends StatefulWidget {
  final List<T> options;
  final bool isMultiSelect;
  final String label;
  final String? tip;
  final R? selectedValue;
  final List<R>? selectedValues;
  final R Function(T)? valueExtractor;
  final String Function(T)? displayText;
  final void Function(R, T, bool?)? onChange;
  final void Function(List<R>, List<T>)? onConfirm;
  final DropdownChooseController<R>? controller;
  final T? initialDisplayValue;
  final FormFieldState<dynamic> field;

  const _DropdownChooseField({
    required this.options,
    required this.isMultiSelect,
    required this.label,
    this.tip,
    this.selectedValue,
    this.selectedValues,
    this.valueExtractor,
    this.displayText,
    this.onChange,
    this.onConfirm,
    this.controller,
    this.initialDisplayValue,
    required this.field,
  });

  @override
  State<_DropdownChooseField<R, T>> createState() => _DropdownChooseFieldState<R, T>();
}

class _DropdownChooseFieldState<R, T> extends State<_DropdownChooseField<R, T>> {
  late final DropdownDataHelper<R, T> _dataHelper;
  late final SelectionManager<R> _selectionManager;

  @override
  void initState() {
    super.initState();

    // 初始化数据助手
    _dataHelper = DropdownDataHelper<R, T>(options: widget.options, valueExtractor: widget.valueExtractor, displayText: widget.displayText);

    // 初始化选择管理器
    _selectionManager = SelectionManager<R>(isMultiSelect: widget.isMultiSelect, controller: widget.controller, field: widget.field, onStateChanged: () => setState(() {}));

    // 初始化值
    _selectionManager.initialize(widget.selectedValue, widget.selectedValues);

    // 监听控制器变化
    _selectionManager.addControllerListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _selectionManager.removeControllerListener(_onControllerChanged);
    super.dispose();
  }

  /// 控制器值变化时的回调
  void _onControllerChanged() {
    _selectionManager.syncFromController();
  }

  @override
  void didUpdateWidget(covariant _DropdownChooseField<R, T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 重新创建数据助手（如果选项变化）
    if (oldWidget.options != widget.options || oldWidget.valueExtractor != widget.valueExtractor || oldWidget.displayText != widget.displayText) {
      _dataHelper = DropdownDataHelper<R, T>(options: widget.options, valueExtractor: widget.valueExtractor, displayText: widget.displayText);
    }

    // 同步外部传入的值（如果没有使用控制器）
    if (widget.controller == null) {
      if (oldWidget.selectedValue != widget.selectedValue) {
        setState(() {
          _selectionManager.initialize(widget.selectedValue, widget.selectedValues);
        });
      }
      if (oldWidget.selectedValues != widget.selectedValues) {
        setState(() {
          _selectionManager.initialize(widget.selectedValue, widget.selectedValues);
        });
      }
    }
  }

  /// 清空选中值
  void onClear() {
    _selectionManager.clear();
  }

  /// 获取显示文本
  Widget _getDisplayText() {
    final tipInfo = widget.tip ?? '请选择${widget.label}';
    if (widget.isMultiSelect == true) {
      final ids = _selectionManager.selectedValues ?? [];
      if (ids.isEmpty) return Text(tipInfo, style: TextStyle(fontSize: 16, color: UiTheme.tipTextFontColor));
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 6,
          children: ids.map((id) {
            final item = _dataHelper.findOptionById(id);
            final displayText = item != null ? _dataHelper.extractDisplayText(item) : id.toString();
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
      if (_selectionManager.selectedValue == null) return Text(tipInfo, style: TextStyle(fontSize: 16, color: Colors.grey.shade600));
      final item = _dataHelper.findOptionById(_selectionManager.selectedValue as R);
      return Text(item != null ? _dataHelper.extractDisplayText(item) : _selectionManager.selectedValue.toString());
    }
  }

  /// 点击显示弹窗-显示选中值
  void onShowChoose() async {
    final res = await BottomModalSheet.show<R, T>(
      context,
      title: widget.label,
      options: widget.options,
      defaultValue: widget.isMultiSelect ? _selectionManager.selectedValues : _selectionManager.selectedValue,
      isMultiSelect: widget.isMultiSelect,
      displayText: widget.displayText,
      valueExtractor: widget.valueExtractor,
      initialDisplayValue: widget.initialDisplayValue,
      onChange: (R r, T data) {
        setState(() {
          _selectionManager.setSingleValue(r);
        });
        widget.onChange?.call(r, data, null);
      },
      onConfirm: (List<R> r, List<T> data) {
        setState(() {
          _selectionManager.setMultiValues(r);
        });
        widget.onConfirm?.call(r, data);
      },
    );

    if (res != null) {
      setState(() {
        if (widget.isMultiSelect) {
          _selectionManager.initialize(null, res as List<R>?);
        } else {
          _selectionManager.initialize(res as R?, null);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 检查是否有验证错误
    final hasError = widget.field.errorText != null && widget.field.errorText!.isNotEmpty;

    return ContainerWrapper<R>(
      label: widget.label,
      tip: widget.tip,
      selectedValue: _selectionManager.selectedValue,
      selectedValues: _selectionManager.selectedValues,
      displayText: _getDisplayText(),
      onClear: onClear,
      onTap: onShowChoose,
      // 传递错误信息
      errorText: hasError ? widget.field.errorText : null,
      hasError: hasError,
    );
  }
}
