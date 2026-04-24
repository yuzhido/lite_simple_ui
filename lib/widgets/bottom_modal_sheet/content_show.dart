import 'package:flutter/material.dart';

class ContentShow<R, T> extends StatefulWidget {
  final List<T>? options;
  final String Function(T) displayText;
  final R Function(T) valueExtractor;
  final dynamic defaultValue;
  final bool isMultiSelect;
  final Function(R, T, bool)? onChange; // 第三个参数：isSelected
  final Function(List<R>, List<T>)? onConfirm;

  const ContentShow({
    super.key,
    this.options,
    required this.displayText,
    required this.valueExtractor,
    this.defaultValue,
    this.isMultiSelect = false,
    this.onChange,
    this.onConfirm,
  });
  @override
  State<ContentShow<R, T>> createState() => _ContentShowState<R, T>();
}

class _ContentShowState<R, T> extends State<ContentShow<R, T>> {
  // 记录选中的 ID 集合（多选）
  List<R> _selectedIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.isMultiSelect) {
      // 处理多选默认值
      if (widget.defaultValue is List) {
        _selectedIds = widget.defaultValue as List<R>;
      } else if (widget.defaultValue != null) {
        _selectedIds.add(widget.defaultValue as R);
      }
    } else {
      // 处理单选默认值
      if (widget.defaultValue != null) {
        _selectedIds = [widget.defaultValue as R];
      }
    }
  }

  void _onItemSelected(int index, T item) {
    final id = widget.valueExtractor(item);

    if (widget.isMultiSelect) {
      // 多选：判断是选中还是取消
      final isSelected = !_selectedIds.contains(id);
      setState(() {
        if (isSelected) {
          _selectedIds.add(id);
        } else {
          _selectedIds.remove(id);
        }
      });
      widget.onChange?.call(id, item, isSelected);
    } else {
      // 单选：始终为选中状态
      Navigator.of(context).pop(id);
      widget.onChange?.call(id, item, true);
    }
  }

  void _confirmSelection() {
    // 只返回选中的对象
    final selectedItems = <T>[];
    for (final id in _selectedIds) {
      for (final item in widget.options!) {
        if (widget.valueExtractor(item) == id) {
          selectedItems.add(item);
          break;
        }
      }
    }
    widget.onConfirm?.call(_selectedIds, selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: widget.options?.length ?? 0,
            itemBuilder: (context, index) {
              final item = widget.options![index];
              final id = widget.valueExtractor(item);
              final displayTextValue = widget.displayText(item).trim();
              final avatarChar = displayTextValue.isNotEmpty ? displayTextValue[0] : '';
              final isSelected = _selectedIds.contains(id);
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(color: isSelected ? const Color(0xFFF5EEFF) : Colors.white, borderRadius: BorderRadius.circular(8)),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _onItemSelected(index, item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          // 左侧圆形图标（带首字母）
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(color: isSelected ? const Color(0xFFD4B8FF) : Colors.grey.shade100, shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                avatarChar,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey.shade700),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 文本内容
                          Expanded(
                            child: Text(
                              displayTextValue,
                              style: TextStyle(
                                fontSize: 15,
                                color: isSelected ? const Color(0xFF6B21A8) : Colors.black87,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                          // 右侧勾选标记（单选时显示）
                          if (!widget.isMultiSelect && isSelected) const Icon(Icons.check_circle, color: Color(0xFF7C3AED), size: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.isMultiSelect)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消', style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _selectedIds.isEmpty ? null : _confirmSelection,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, disabledBackgroundColor: Colors.grey.shade300),
                  child: const Text('确认'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
