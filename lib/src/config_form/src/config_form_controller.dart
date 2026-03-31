import 'package:flutter/material.dart';
import 'form_item.dart';

/// 表单控制器
class ConfigFormController extends ChangeNotifier {
  // 保存当前表单值
  Map<String, dynamic> _values = {};

  // 保存初始值（用于重置）
  final Map<String, dynamic> _initialValues = {};

  // 保存错误信息
  Map<String, String> _errors = {};

  // 保存表单项配置
  List<FormItem> _items = [];

  // 获取值
  dynamic getValue(String property) => _values[property];

  // 设置值
  void setValue(String property, dynamic value) {
    _values[property] = value;
    notifyListeners();
  }

  // 获取所有值
  Map<String, dynamic> getAllValues() => Map.from(_values);

  // 重置单个字段
  void resetField(String property) {
    if (_initialValues.containsKey(property)) {
      _values[property] = _initialValues[property];
      _errors.remove(property);
      notifyListeners();
    }
  }

  // 重置所有字段
  void reset() {
    _values = Map.from(_initialValues);
    _errors.clear();
    notifyListeners();
  }

  // 清除单个字段值
  void clearField(String property) {
    _values[property] = null;
    _errors.remove(property);
    notifyListeners();
  }

  // 验证单个字段
  String? validateField(String property) {
    // 找到对应的 FormItem
    final item = _items.firstWhere((i) => i.property == property, orElse: () => throw Exception('FormItem not found: $property'));

    // 获取实际的验证器
    final validator = item.actualValidator;

    if (validator != null) {
      final value = _values[property];
      final error = validator(value);

      if (error != null) {
        _errors[property] = error;
      } else {
        _errors.remove(property);
      }

      notifyListeners();
      return error;
    }

    return null;
  }

  // 验证所有字段（用于提交时）
  bool validateAll() {
    bool isValid = true;

    for (final item in _items) {
      final error = validateField(item.property);
      if (error != null) {
        isValid = false;
      }
    }

    return isValid;
  }

  // 初始化
  void initializeValues(List<FormItem> items) {
    _items = items;
    for (final item in items) {
      _values[item.property] = item.initialValue;
      _initialValues[item.property] = item.initialValue;
    }
  }

  // 获取错误信息
  String? getError(String property) => _errors[property];

  // 是否有错误
  bool hasError(String property) => _errors.containsKey(property);

  // 清除所有错误
  void clearErrors() {
    _errors.clear();
    notifyListeners();
  }

  // 清除单个错误
  void clearError(String property) {
    _errors.remove(property);
    notifyListeners();
  }

  @override
  void dispose() {
    _values.clear();
    _initialValues.clear();
    _errors.clear();
    _items.clear();
    super.dispose();
  }
}
