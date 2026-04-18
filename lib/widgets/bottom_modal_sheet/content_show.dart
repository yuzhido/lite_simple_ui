import 'package:flutter/material.dart';

class ContentShow<R, T> extends StatefulWidget {
  final List<T>? options;
  final String Function(T) displayText;
  final R Function(T) valueExtractor;
  final R? defaultValue; // 新增：默认选中值

  const ContentShow({super.key, this.options, required this.displayText, required this.valueExtractor, this.defaultValue});
  @override
  State<ContentShow<R, T>> createState() => _ContentShowState<R, T>();
}

class _ContentShowState<R, T> extends State<ContentShow<R, T>> {
  // 记录选中的索引
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    // 初始化时查找默认值对应的索引
    if (widget.defaultValue != null && widget.options != null) {
      _selectedIndex = widget.options!.indexWhere((item) => widget.valueExtractor(item) == widget.defaultValue);
      if (_selectedIndex == -1) _selectedIndex = null;
    }
  }

  void _onItemSelected(int index, T item) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop(widget.valueExtractor(item));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.options?.length ?? 0,
      itemBuilder: (context, index) {
        final item = widget.options![index];
        final isSelected = _selectedIndex == index;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.blue.withAlpha(51), // 0.2 * 255 = 51
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
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
                    // 左侧单选框图标
                    Container(
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
                        style: TextStyle(fontSize: 16, color: isSelected ? Colors.blue.shade900 : Colors.black87, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
