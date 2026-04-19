import 'package:flutter/material.dart';

class ContentShow<R, T> extends StatefulWidget {
  final List<T>? options;
  final String Function(T) displayText;
  final R Function(T) valueExtractor;
  final R? defaultValue; // 新增：默认选中值
  final bool isMultiSelect;

  const ContentShow({super.key, this.options, required this.displayText, required this.valueExtractor, this.defaultValue, this.isMultiSelect = false});
  @override
  State<ContentShow<R, T>> createState() => _ContentShowState<R, T>();
}

class _ContentShowState<R, T> extends State<ContentShow<R, T>> {
  // 记录选中的索引（单选）
  int? _selectedIndex;
  // 记录选中的 ID 集合（多选）
  Set<R> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    if (widget.isMultiSelect) {
      // 处理多选默认值
      if (widget.defaultValue is List) {
        _selectedIds = Set.from(widget.defaultValue as List);
      } else if (widget.defaultValue != null) {
        _selectedIds.add(widget.defaultValue as R);
      }
    } else {
      // 初始化时查找默认值对应的索引（单选）
      if (widget.defaultValue != null && widget.options != null) {
        _selectedIndex = widget.options!.indexWhere((item) => widget.valueExtractor(item) == widget.defaultValue);
        if (_selectedIndex == -1) _selectedIndex = null;
      }
    }
  }

  void _onItemSelected(int index, T item) {
    final id = widget.valueExtractor(item);
    if (widget.isMultiSelect) {
      setState(() {
        if (_selectedIds.contains(id)) {
          _selectedIds.remove(id);
        } else {
          _selectedIds.add(id);
        }
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
      Navigator.of(context).pop(id);
    }
  }

  void _confirmSelection() {
    Navigator.of(context).pop(_selectedIds.toList() as R);
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
              final isSelected = widget.isMultiSelect ? _selectedIds.contains(id) : _selectedIndex == index;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected ? [BoxShadow(color: Colors.blue.withAlpha(51), blurRadius: 8, offset: const Offset(0, 2))] : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _onItemSelected(index, item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          // 左侧勾选框或单选图标
                          widget.isMultiSelect
                              ? Checkbox(
                                  value: isSelected,
                                  activeColor: Colors.blue,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  onChanged: (_) => _onItemSelected(index, item),
                                )
                              : Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade400, width: 2),
                                    color: isSelected ? Colors.blue : Colors.transparent,
                                  ),
                                  child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                                ),
                          const SizedBox(width: 12),
                          // 文本内容
                          Expanded(
                            child: Text(
                              widget.displayText(item),
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected ? Colors.blue.shade900 : Colors.black87,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
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
