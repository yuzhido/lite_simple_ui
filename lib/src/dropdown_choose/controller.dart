import 'package:flutter/foundation.dart';

/// DropdownChoose 控制器
///
/// 提供程序化控制 DropdownChoose 组件的能力，包括设置值、获取值、清空值和监听变化。
///
/// 使用示例：
/// ```dart
/// // 创建控制器
/// final controller = DropdownChooseController<int>();
///
/// // 在组件中使用
/// DropdownChoose<int, UserInfo>(
///   controller: controller,
///   options: users,
///   label: '用户',
/// ),
///
/// // 程序化设置值
/// controller.setValue(userId);
///
/// // 获取当前值
/// int? currentValue = controller.value;
///
/// // 清空
/// controller.clear();
///
/// // 监听变化
/// controller.addListener(() {
///   print('值变为: ${controller.value}');
/// });
/// ```
class DropdownChooseController<R> extends ChangeNotifier {
  R? _value;
  List<R>? _values;

  /// 单选值
  R? get value => _value;

  /// 多选值列表
  List<R>? get values => _values;

  /// 设置单选值
  ///
  /// 如果新值与当前值不同，会通知所有监听器
  void setValue(R? newValue) {
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
  }

  /// 设置多选值
  ///
  /// 如果新值列表与当前值列表不同，会通知所有监听器
  void setValues(List<R>? newValues) {
    if (!listEquals(_values, newValues)) {
      _values = newValues;
      notifyListeners();
    }
  }

  /// 清空所有值
  ///
  /// 如果有值被清空，会通知所有监听器
  void clear() {
    if (_value != null || _values != null) {
      _value = null;
      _values = null;
      notifyListeners();
    }
  }
}
