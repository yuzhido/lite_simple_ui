import 'package:flutter/material.dart';

import '../model/index.dart';
import '../widgets/input_container.dart';
import 'src/dropdown_config.dart';
import 'src/dropdown_popup.dart';

/// 单选确认回调 typedef
typedef DropdownSingleConfirmCallback<ID, DATA> = void Function(ID id, DATA data);

/// 多选确认回调 typedef
typedef DropdownMultiConfirmCallback<ID, DATA> = void Function(List<ID> ids, List<DATA> dataList);

/// 值变化回调 typedef
typedef DropdownValueChangeCallback<ID, DATA> = void Function(List<ID> ids, List<DATA> dataList);

class DropdownChoose<ID, DATA extends Map<String, dynamic>> extends StatefulWidget {
  /// 自定义标题，用于显示在 label 区域和弹窗标题
  final String? title;

  /// 选项数据列表
  final List<Map<String, dynamic>> options;

  /// 值变化回调
  final DropdownValueChangeCallback<ID, DATA>? onValueChange;

  /// 当前选中的值（由外部控制）
  final List<Map<String, dynamic>>? value;

  /// 选择类型（单选/多选）
  final SelectType selectType;

  /// 显示模式（文本模式/标签模式）
  final DisplayMode displayMode;

  /// 单选确认回调
  final DropdownSingleConfirmCallback<ID, DATA>? onSingleConfirm;

  /// 多选确认回调
  final DropdownMultiConfirmCallback<ID, DATA>? onMultiConfirm;

  /// 自定义内容区构建器
  final Widget Function(BuildContext context, List<Map<String, dynamic>> selectedValues)? customContentBuilder;

  /// 自定义容器构建器
  final Widget Function(BuildContext context, VoidCallback onTap)? customContainerBuilder;

  /// 清除选中回调
  final VoidCallback? onClear;

  /// 字段映射配置
  final FieldMapping fieldMapping;

  /// 配置项
  final DropdownConfig? config;

  const DropdownChoose({
    super.key,
    required this.options,
    this.title,
    this.onValueChange,
    this.value,
    this.selectType = SelectType.multiple,
    this.displayMode = DisplayMode.text,
    this.onSingleConfirm,
    this.onMultiConfirm,
    this.customContentBuilder,
    this.customContainerBuilder,
    this.onClear,
    this.fieldMapping = const FieldMapping(),
    this.config,
  });

  @override
  State<DropdownChoose<ID, DATA>> createState() => _DropdownChooseState<ID, DATA>();
}

class _DropdownChooseState<ID, DATA extends Map<String, dynamic>> extends State<DropdownChoose<ID, DATA>> {
  List<Map<String, dynamic>> _selectedValues = [];
  String? _selectedValueText; // 用于显示在内容区域的选中值
  bool _isExpanded = false; // 是否展开弹窗

  @override
  void initState() {
    super.initState();
    _initializeSelectedValues();
  }

  @override
  void didUpdateWidget(DropdownChoose<ID, DATA> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // value 变化时重新初始化选中值
    if (widget.value != oldWidget.value) {
      _initializeSelectedValues();
    }
  }

  /// 初始化选中的值
  void _initializeSelectedValues() {
    setState(() {
      if (widget.value == null || widget.value!.isEmpty) {
        _selectedValues = [];
        _selectedValueText = null;
      } else {
        _selectedValues = List<Map<String, dynamic>>.from(widget.value!);
        _updateSelectedValueText();
      }
    });
  }

  /// 更新选中文本
  void _updateSelectedValueText() {
    if (_selectedValues.isEmpty) {
      _selectedValueText = null;
      return;
    }

    if (widget.displayMode == DisplayMode.tags) {
      // 标签模式不需要拼接文本
      _selectedValueText = null;
    } else {
      // 文本模式：逗号拼接
      final labels = _selectedValues.map((item) {
        final labelField = widget.fieldMapping.labelField;
        final value = item[labelField];
        return value != null ? value.toString() : '';
      }).toList();
      _selectedValueText = labels.join(', ');
    }
  }

  /// 显示弹窗
  void _showPopup() {
    setState(() {
      _isExpanded = true;
    });

    final popupView = DropdownPopup<ID, DATA>(
      config:
          widget.config ?? DropdownConfig(selectType: widget.selectType, displayMode: widget.displayMode, fieldMapping: widget.fieldMapping, placeholder: widget.title ?? '请选择'),
      options: widget.options,
      tempSelected: _selectedValues,
      onOptionChange: (ids, dataList) {
        // 多选模式下选项变化时的回调
        setState(() {
          _selectedValues = dataList.toList();
          _updateSelectedValueText();
        });
        widget.onValueChange?.call(ids, dataList);
      },
      onSingleConfirm: widget.onSingleConfirm != null
          ? (id, data) {
              setState(() {
                _selectedValues = [data];
                _updateSelectedValueText();
              });
              widget.onSingleConfirm!.call(id, data);
              widget.onValueChange?.call([id], [data]);
            }
          : null,
      onMultiConfirm: widget.onMultiConfirm != null
          ? (ids, dataList) {
              setState(() {
                _selectedValues = dataList;
                _updateSelectedValueText();
              });
              widget.onMultiConfirm!.call(ids, dataList);
              widget.onValueChange?.call(ids, dataList);
            }
          : null,
    );

    popupView.show(context, title: widget.title).then((_) {
      // 弹窗关闭后，设置箭头为收起状态
      setState(() {
        _isExpanded = false;
      });
    });
  }

  /// 清空选中
  void _clearSelection() {
    setState(() {
      _selectedValues = [];
      _selectedValueText = null;
    });
    // 调用外部清除回调
    widget.onClear?.call();
    // 通知值变化
    widget.onValueChange?.call([], []);
  }

  /// 获取标签模式的值列表
  List<String>? _getTagValues() {
    if (widget.displayMode != DisplayMode.tags || _selectedValues.isEmpty) {
      return null;
    }

    return _selectedValues.map((item) {
      final labelField = widget.fieldMapping.labelField;
      final value = item[labelField];
      return value != null ? value.toString() : '';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // 如果提供了自定义容器构建器，使用自定义容器
    if (widget.customContainerBuilder != null) {
      return widget.customContainerBuilder!(context, _showPopup);
    }

    // 使用默认容器
    return InputContainer(
      onTap: _showPopup,
      label: widget.title,
      selectedValue: _selectedValueText,
      isExpanded: _isExpanded,
      displayMode: widget.displayMode,
      selectedValues: _getTagValues(),
      customContentBuilder: widget.customContentBuilder != null ? (context, tagValues) => widget.customContentBuilder!(context, _selectedValues) : null,
      onClear: _clearSelection,
    );
  }
}
