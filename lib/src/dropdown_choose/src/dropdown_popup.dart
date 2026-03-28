import 'package:flutter/material.dart';

import '../../model/index.dart';
import 'dropdown_config.dart';

/// 单选确认回调 typedef
typedef SingleConfirmCallback<ID, DATA> = void Function(ID id, DATA data);

/// 多选确认回调 typedef
typedef MultiConfirmCallback<ID, DATA> = void Function(List<ID> ids, List<DATA> dataList);

/// 选项数据变化回调 typedef
typedef OptionChangeCallback<ID, DATA> = void Function(List<ID> ids, List<DATA> dataList);

/// 下拉选择弹窗组件
class DropdownPopup<ID, DATA extends Map<String, dynamic>> extends StatefulWidget {
  /// 配置项
  final DropdownConfig config;

  /// 选项数据列表
  final List<Map<String, dynamic>> options;

  /// 临时选中的节点（用于弹窗内状态管理）
  final List<Map<String, dynamic>> tempSelected;

  /// 选项变化回调
  final OptionChangeCallback<ID, DATA>? onOptionChange;

  /// 单选确认回调
  final SingleConfirmCallback<ID, DATA>? onSingleConfirm;

  /// 多选确认回调
  final MultiConfirmCallback<ID, DATA>? onMultiConfirm;

  const DropdownPopup({super.key, required this.config, required this.options, required this.tempSelected, this.onOptionChange, this.onSingleConfirm, this.onMultiConfirm});

  /// 显示弹窗
  Future<void> show(BuildContext context, {String? title}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DropdownPopupContent<ID, DATA>(
        config: config,
        options: options,
        tempSelected: tempSelected,
        customTitle: title,
        onOptionChange: onOptionChange,
        onSingleConfirm: onSingleConfirm,
        onMultiConfirm: onMultiConfirm,
      ),
    );
  }

  @override
  State<DropdownPopup<ID, DATA>> createState() => _DropdownPopupState<ID, DATA>();
}

class _DropdownPopupState<ID, DATA extends Map<String, dynamic>> extends State<DropdownPopup<ID, DATA>> {
  @override
  Widget build(BuildContext context) {
    return widget.config.showSearch ? _buildWithSearch() : _buildWithoutSearch();
  }

  /// 构建带搜索的弹窗
  Widget _buildWithSearch() {
    // TODO: 实现搜索功能
    return _buildWithoutSearch();
  }

  /// 构建不带搜索的弹窗
  Widget _buildWithoutSearch() {
    return _DropdownPopupContent<ID, DATA>(
      config: widget.config,
      options: widget.options,
      tempSelected: widget.tempSelected,
      customTitle: null,
      onOptionChange: widget.onOptionChange,
      onSingleConfirm: widget.onSingleConfirm,
      onMultiConfirm: widget.onMultiConfirm,
    );
  }
}

/// 弹窗内容组件
class _DropdownPopupContent<ID, DATA extends Map<String, dynamic>> extends StatefulWidget {
  final DropdownConfig config;
  final List<Map<String, dynamic>> options;
  final List<Map<String, dynamic>> tempSelected;
  final String? customTitle;
  final OptionChangeCallback<ID, DATA>? onOptionChange;
  final SingleConfirmCallback<ID, DATA>? onSingleConfirm;
  final MultiConfirmCallback<ID, DATA>? onMultiConfirm;

  const _DropdownPopupContent({
    required this.config,
    required this.options,
    required this.tempSelected,
    this.customTitle,
    this.onOptionChange,
    this.onSingleConfirm,
    this.onMultiConfirm,
  });

  @override
  State<_DropdownPopupContent<ID, DATA>> createState() => _DropdownPopupContentState<ID, DATA>();
}

class _DropdownPopupContentState<ID, DATA extends Map<String, dynamic>> extends State<_DropdownPopupContent<ID, DATA>> {
  late List<Map<String, dynamic>> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = List<Map<String, dynamic>>.from(widget.tempSelected);
  }

  /// 获取 ID
  ID _getId(Map<String, dynamic> item) {
    final idField = widget.config.fieldMapping.idField;
    return item[idField] as ID;
  }

  /// 获取文本
  String _getLabel(Map<String, dynamic> item) {
    final labelField = widget.config.fieldMapping.labelField;
    final value = item[labelField];
    return value != null ? value.toString() : '';
  }

  /// 判断是否已选中
  bool _isSelected(Map<String, dynamic> item) {
    final id = _getId(item);
    return _tempSelected.any((selected) => _getId(selected) == id);
  }

  /// 处理选项点击
  void _handleOptionTap(Map<String, dynamic> item) {
    setState(() {
      if (widget.config.selectType == SelectType.single) {
        // 单选模式
        _tempSelected.clear();
        _tempSelected.add(item);

        // 单选模式下，选中后立即回调并关闭弹窗
        final id = _getId(item);
        final data = item as DATA;
        widget.onSingleConfirm?.call(id, data);
        Navigator.pop(context);
      } else {
        // 多选模式
        if (_isSelected(item)) {
          _tempSelected.removeWhere((selected) => _getId(selected) == _getId(item));
        } else {
          _tempSelected.add(item);
        }

        // 通知外部选项变化
        final ids = _tempSelected.map((e) => _getId(e)).toList();
        final dataList = _tempSelected.cast<DATA>();
        widget.onOptionChange?.call(ids, dataList);
      }
    });
  }

  /// 处理取消
  void _handleCancel() {
    Navigator.pop(context);
  }

  /// 处理确认
  void _handleConfirm() {
    if (widget.onMultiConfirm != null) {
      final ids = _tempSelected.map((e) => _getId(e)).toList();
      final dataList = _tempSelected.cast<DATA>();
      widget.onMultiConfirm!.call(ids, dataList);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSingleMode = widget.config.selectType == SelectType.single;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Text(widget.customTitle ?? widget.config.placeholder, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (!isSingleMode) Text('已选择 ${_tempSelected.length} 项', style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor)),
              ],
            ),
          ),

          // 选项列表
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.options.length,
              itemBuilder: (context, index) {
                final item = widget.options[index];
                final label = _getLabel(item);
                final isSelected = _isSelected(item);

                return ListTile(
                  leading: isSingleMode
                      ? Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isSelected ? Theme.of(context).primaryColor : Colors.grey)
                      : Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank, color: isSelected ? Theme.of(context).primaryColor : Colors.grey),
                  title: Text(label),
                  selected: isSelected,
                  onTap: () => _handleOptionTap(item),
                );
              },
            ),
          ),

          // 底部按钮（单选模式不显示）
          if (!isSingleMode)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // 左侧：已选数量统计
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          '已选择 ${_tempSelected.length} 项',
                          style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 取消按钮
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleCancel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 确定按钮
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _tempSelected.isNotEmpty ? _handleConfirm : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: const Text('确定'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
