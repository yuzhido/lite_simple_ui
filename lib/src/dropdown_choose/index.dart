import 'package:flutter/material.dart';
import 'package:lite_simple_ui/config/ui_theme.dart';
import 'package:lite_simple_ui/widgets/bottom_modal_sheet/index.dart';
import 'package:lite_simple_ui/widgets/container_wrapper/index.dart';

import 'controller.dart';
import 'data_helper.dart';
import 'display_mode.dart';
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

  /// 从对象中提取 ID（默认提取 id 字段）
  final R Function(T)? valueExtractor;

  /// 从对象中提取显示文本（默认提取 name 字段）
  final String Function(T)? displayText;

  /// 选中时的回调
  /// - [R]: 选中项的 ID
  /// - [T]: 选中项的完整数据对象
  /// - [bool]: isSelected - 单选时始终为 true；多选时 true 表示选中，false 表示取消
  final void Function(R, T, bool)? onChange;

  /// 确认时的回调（多选）
  final void Function(List<R>, List<T>)? onConfirm;

  /// 控制器（可选）
  final DropdownChooseController<R>? controller;

  /// 初始显示值（用于编辑回显）
  ///
  /// 当只有 ID 但没有完整对象时，传入一个包含 id 和 name 的最小化对象用于界面回显。
  /// 注意：这与 [defaultValue] 不同，[defaultValue] 是表单的实际选中值，而此参数仅影响 UI 展示。
  final T? initialDisplayValue;

  /// 是否启用组件
  final bool enabled;

  /// 显示模式（默认：标签胶囊模式）
  final DropdownDisplayMode displayMode;

  /// 自定义显示构建器（优先级高于 displayMode）
  final Widget Function(BuildContext, List<T>)? customDisplayBuilder;

  /// 折叠模式下最大显示的标签数量
  final int maxVisibleTags;

  DropdownChoose({
    required this.options,
    this.isMultiSelect = false,
    super.key,
    required this.label,
    this.tip,
    dynamic defaultValue, // 默认值：单选为 R?，多选为 List<R>?
    this.valueExtractor,
    this.displayText,
    this.onChange,
    this.onConfirm,
    this.controller,
    this.initialDisplayValue,
    this.enabled = true,
    this.displayMode = DropdownDisplayMode.tags,
    this.customDisplayBuilder,
    this.maxVisibleTags = 3,
    FormFieldValidator<dynamic>? validator,
    super.autovalidateMode = AutovalidateMode.disabled,
  }) : super(
         initialValue: defaultValue,
         validator: _buildValidator(validator, isMultiSelect, label),
         builder: (FormFieldState<dynamic> field) {
           return _DropdownChooseField<R, T>(
             options: options,
             isMultiSelect: isMultiSelect,
             label: label,
             tip: tip,
             defaultValue: defaultValue,
             valueExtractor: valueExtractor,
             displayText: displayText,
             onChange: onChange,
             onConfirm: onConfirm,
             controller: controller,
             initialDisplayValue: initialDisplayValue,
             enabled: enabled,
             displayMode: displayMode,
             customDisplayBuilder: customDisplayBuilder,
             maxVisibleTags: maxVisibleTags,
             field: field,
           );
         },
       );

  /// 构建验证器：优先使用自定义验证器，否则使用默认验证
  static FormFieldValidator<dynamic>? _buildValidator(FormFieldValidator<dynamic>? customValidator, bool isMultiSelect, String label) {
    // 如果提供了自定义验证器，直接使用
    if (customValidator != null) return customValidator;

    // 返回默认验证器
    return (value) {
      if (isMultiSelect) {
        final list = value as List?;
        if (list == null || list.isEmpty) {
          return '请至少选择一个$label';
        }
      } else {
        if (value == null) {
          return '$label是必选的项';
        }
      }
      return null;
    };
  }
}

/// 内部字段组件 - 与 FormField 集成
class _DropdownChooseField<R, T> extends StatefulWidget {
  final List<T> options;
  final bool isMultiSelect;
  final String label;
  final String? tip;
  final dynamic defaultValue;
  final R Function(T)? valueExtractor;
  final String Function(T)? displayText;
  final void Function(R, T, bool)? onChange;
  final void Function(List<R>, List<T>)? onConfirm;
  final DropdownChooseController<R>? controller;
  final T? initialDisplayValue;
  final bool enabled;
  final DropdownDisplayMode displayMode;
  final Widget Function(BuildContext, List<T>)? customDisplayBuilder;
  final int maxVisibleTags;
  final FormFieldState<dynamic> field;

  const _DropdownChooseField({
    required this.options,
    required this.isMultiSelect,
    required this.label,
    this.tip,
    this.defaultValue,
    this.valueExtractor,
    this.displayText,
    this.onChange,
    this.onConfirm,
    this.controller,
    this.initialDisplayValue,
    required this.enabled,
    required this.displayMode,
    this.customDisplayBuilder,
    required this.maxVisibleTags,
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

    // 初始化值：从 FormField 的 initialValue 或外部传入的值
    final value = widget.field.value ?? widget.defaultValue;
    if (widget.isMultiSelect) {
      _selectionManager.initialize(null, value as List<R>?);
    } else {
      _selectionManager.initialize(value as R?, null);
    }

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
      final oldValue = oldWidget.defaultValue;
      final newValue = widget.defaultValue;
      if (oldValue != newValue) {
        setState(() {
          _selectionManager.initialize(widget.isMultiSelect ? null : newValue as R?, widget.isMultiSelect ? newValue as List<R>? : null);
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
    // 1. 优先使用自定义构建器
    if (widget.customDisplayBuilder != null) {
      final selectedItems = _getSelectedItems();
      return widget.customDisplayBuilder!(context, selectedItems);
    }

    // 2. 根据模式分发
    switch (widget.displayMode) {
      case DropdownDisplayMode.text:
        return _buildTextView();
      case DropdownDisplayMode.tags:
        return _buildTagsView();
      case DropdownDisplayMode.compact:
        return _buildCompactView();
    }
  }

  /// 获取当前选中的完整对象列表
  List<T> _getSelectedItems() {
    if (widget.isMultiSelect) {
      final ids = _selectionManager.selectedValues ?? [];
      return ids.map((id) => _dataHelper.findOptionById(id)).whereType<T>().toList();
    } else {
      final id = _selectionManager.selectedValue;
      if (id == null) return [];
      final item = _dataHelper.findOptionById(id);
      return item != null ? [item] : [];
    }
  }

  /// 纯文本模式
  Widget _buildTextView() {
    final tipInfo = widget.tip ?? '请选择${widget.label}';
    final items = _getSelectedItems();
    if (items.isEmpty) {
      return Text(tipInfo, style: TextStyle(fontSize: 16, color: Colors.grey.shade600));
    }
    final text = items.map((item) => _dataHelper.extractDisplayText(item)).join(', ');
    return Text(text, style: const TextStyle(fontSize: 16));
  }

  /// 标签胶囊模式（原有逻辑）
  Widget _buildTagsView() {
    final tipInfo = widget.tip ?? '请选择${widget.label}';
    if (!widget.isMultiSelect) {
      final item = _getSelectedItems().firstOrNull;
      if (item == null) return Text(tipInfo, style: TextStyle(fontSize: 16, color: Colors.grey.shade600));
      return Text(_dataHelper.extractDisplayText(item), style: const TextStyle(fontSize: 16));
    }

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
  }

  /// 折叠模式 (+X 更多)
  Widget _buildCompactView() {
    final tipInfo = widget.tip ?? '请选择${widget.label}';
    if (!widget.isMultiSelect) {
      return _buildTextView(); // 单选时折叠模式退化为文本模式
    }

    final ids = _selectionManager.selectedValues ?? [];
    if (ids.isEmpty) return Text(tipInfo, style: TextStyle(fontSize: 16, color: UiTheme.tipTextFontColor));

    final visibleIds = ids.take(widget.maxVisibleTags).toList();
    final remainingCount = ids.length - widget.maxVisibleTags;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 6,
        children: [
          ...visibleIds.map((id) {
            final item = _dataHelper.findOptionById(id);
            final displayText = item != null ? _dataHelper.extractDisplayText(item) : id.toString();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFE8E0FF), borderRadius: BorderRadius.circular(15)),
              child: Text(
                displayText,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B21A8), fontWeight: FontWeight.w500),
              ),
            );
          }),
          if (remainingCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(15)),
              child: Text(
                '+$remainingCount',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  /// 点击显示弹窗 - 展示备选列表或当前选中状态
  void onChoose() async {
    final res = await BottomModalSheet.show<R, T>(
      context,
      title: widget.label,
      options: widget.options,
      defaultValue: widget.isMultiSelect ? _selectionManager.selectedValues : _selectionManager.selectedValue,
      isMultiSelect: widget.isMultiSelect,
      displayText: widget.displayText,
      valueExtractor: widget.valueExtractor,
      initialDisplayValue: widget.initialDisplayValue,
      onChange: (R r, T data, bool isSelected) {
        // 单选时立即更新内部状态并关闭弹窗；多选时仅触发回调，由 onConfirm 统一处理
        if (!widget.isMultiSelect) {
          setState(() {
            _selectionManager.setSingleValue(r);
          });
        }
        widget.onChange?.call(r, data, isSelected);
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
      onTap: widget.enabled ? onChoose : null,
      enabled: widget.enabled,
      errorText: hasError ? widget.field.errorText : null,
      hasError: hasError,
    );
  }
}
