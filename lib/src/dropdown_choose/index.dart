import 'package:flutter/material.dart';
import 'package:lite_simple_ui/config/ui_theme.dart';
import 'package:lite_simple_ui/widgets/bottom_modal_sheet/index.dart';
import 'package:lite_simple_ui/widgets/container_wrapper/index.dart';

import 'controller.dart';

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
    required this.field,
  });

  @override
  State<_DropdownChooseField<R, T>> createState() => _DropdownChooseFieldState<R, T>();
}

class _DropdownChooseFieldState<R, T> extends State<_DropdownChooseField<R, T>> {
  R? _selectedValue;
  List<R>? _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
    _selectedValues = widget.selectedValues;

    // 如果提供了控制器，初始化值并监听变化
    if (widget.controller != null) {
      if (widget.isMultiSelect) {
        _selectedValues = widget.controller!.values;
      } else {
        _selectedValue = widget.controller!.value;
      }

      // 监听控制器变化
      widget.controller!.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    // 移除监听器
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  /// 控制器值变化时的回调
  void _onControllerChanged() {
    if (widget.controller == null) return;

    setState(() {
      if (widget.isMultiSelect) {
        _selectedValues = widget.controller!.values;
      } else {
        _selectedValue = widget.controller!.value;
      }
    });

    // 通知 Form 状态变化
    if (widget.isMultiSelect) {
      widget.field.didChange(_selectedValues);
    } else {
      widget.field.didChange(_selectedValue);
    }
  }

  @override
  void didUpdateWidget(covariant _DropdownChooseField<R, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValue != widget.selectedValue) {
      setState(() {
        _selectedValue = widget.selectedValue;
      });
    }
    if (oldWidget.selectedValues != widget.selectedValues) {
      setState(() {
        _selectedValues = widget.selectedValues;
      });
    }
  }

  /// 清空选中值
  void onClear() {
    setState(() {
      _selectedValue = null;
      _selectedValues = null;
    });

    // 同步清空控制器
    widget.controller?.clear();

    // 通知 Form 状态变化
    widget.field.didChange(null);
  }

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
      final ids = _selectedValues ?? [];
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
      if (_selectedValue == null) return Text(tipInfo, style: TextStyle(fontSize: 16, color: Colors.grey.shade600));
      final item = _findOptionById(_selectedValue as R);
      return Text(item != null ? _extractDisplayText(item) : _selectedValue.toString());
    }
  }

  /// 点击显示弹窗-显示选中值
  void onShowChoose() async {
    final res = await BottomModalSheet.show<R, T>(
      context,
      title: widget.label,
      options: widget.options,
      defaultValue: widget.isMultiSelect ? _selectedValues : _selectedValue,
      isMultiSelect: widget.isMultiSelect,
      displayText: widget.displayText,
      valueExtractor: widget.valueExtractor,
      onChange: (R r, T data) {
        // 更新选中值
        setState(() {
          _selectedValue = r;
        });

        // 同步更新控制器
        if (widget.controller != null) {
          widget.controller!.setValue(r);
        }

        // 通知 Form 状态变化
        widget.field.didChange(r);

        if (widget.onChange != null) {
          widget.onChange!(r, data, null);
        }
      },
      onConfirm: (List<R> r, List<T> data) {
        setState(() {
          _selectedValues = r;
        });

        // 同步更新控制器
        if (widget.controller != null) {
          widget.controller!.setValues(r);
        }

        // 通知 Form 状态变化
        widget.field.didChange(r);

        if (widget.onConfirm != null) {
          widget.onConfirm!(r, data);
        }
      },
    );

    if (res != null) {
      setState(() {
        if (widget.isMultiSelect) {
          _selectedValues = res as List<R>?;
        } else {
          _selectedValue = res as R?;
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
      selectedValue: _selectedValue,
      selectedValues: _selectedValues,
      displayText: _getDisplayText(),
      onClear: onClear,
      onTap: onShowChoose,
      // 传递错误信息
      errorText: hasError ? widget.field.errorText : null,
      hasError: hasError,
    );
  }
}
