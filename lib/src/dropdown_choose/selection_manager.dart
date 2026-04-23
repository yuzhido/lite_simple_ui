import 'package:flutter/material.dart';

import 'controller.dart';

/// 选择管理器 - 统一管理选中状态和同步逻辑
class SelectionManager<R> {
  R? _selectedValue;
  List<R>? _selectedValues;
  final bool isMultiSelect;
  final DropdownChooseController<R>? controller;
  final FormFieldState<dynamic> field;
  final VoidCallback? onStateChanged;

  SelectionManager({required this.isMultiSelect, this.controller, required this.field, this.onStateChanged});

  R? get selectedValue => _selectedValue;
  List<R>? get selectedValues => _selectedValues;

  /// 初始化值
  void initialize(R? initialValue, List<R>? initialValues) {
    if (controller != null) {
      _selectedValue = isMultiSelect ? null : controller!.value;
      _selectedValues = isMultiSelect ? controller!.values : null;
    } else {
      _selectedValue = initialValue;
      _selectedValues = initialValues;
    }
  }

  /// 设置单选值
  void setSingleValue(R value) {
    _selectedValue = value;
    controller?.setValue(value);
    field.didChange(value);
    onStateChanged?.call();
  }

  /// 设置多选值
  void setMultiValues(List<R> values) {
    _selectedValues = values;
    controller?.setValues(values);
    field.didChange(values);
    onStateChanged?.call();
  }

  /// 清空所有值
  void clear() {
    _selectedValue = null;
    _selectedValues = null;
    controller?.clear();
    field.didChange(null);
    onStateChanged?.call();
  }

  /// 从控制器同步值
  void syncFromController() {
    if (controller == null) return;

    if (isMultiSelect) {
      _selectedValues = controller!.values;
    } else {
      _selectedValue = controller!.value;
    }
    field.didChange(isMultiSelect ? _selectedValues : _selectedValue);
    onStateChanged?.call();
  }

  /// 添加控制器监听
  void addControllerListener(VoidCallback listener) {
    controller?.addListener(listener);
  }

  /// 移除控制器监听
  void removeControllerListener(VoidCallback listener) {
    controller?.removeListener(listener);
  }
}
