import 'package:flutter/material.dart';

import '../model/index.dart';

class InputContainer extends StatelessWidget {
  /// 点击回调
  final VoidCallback? onTap;

  /// 自定义 label 文本
  final String? label;

  /// 已选中的值（用于显示在内容区域）
  final String? selectedValue;

  /// 清空选中回调
  final VoidCallback? onClear;

  /// 是否展开（控制箭头方向）
  final bool isExpanded;

  /// 显示模式
  final DisplayMode? displayMode;

  /// 选中的值列表（用于标签模式）
  final List<String>? selectedValues;

  /// 自定义内容区构建器
  final Widget Function(BuildContext context, List<String>? selectedValues)? customContentBuilder;

  const InputContainer({
    super.key,
    this.onTap,
    this.label,
    this.selectedValue,
    this.onClear,
    this.customContentBuilder,
    this.isExpanded = false,
    this.displayMode,
    this.selectedValues,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(3),
      ),
      child: InkWell(
        onTap: onTap,
        child: customContentBuilder != null
            ? customContentBuilder!(context, selectedValues)
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 20,
                children: [
                  Text(label ?? 'label 区域'),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 内容区域：显示已选中的值
                        Expanded(
                          child: displayMode == DisplayMode.tags && selectedValues != null && selectedValues!.isNotEmpty
                              ? _buildTagsMode() // 标签模式
                              : _buildTextMode(), // 文本模式
                        ),
                        // 操作按钮：箭头/关闭图标
                        InkWell(
                          onTap: (selectedValue != null || (selectedValues?.isNotEmpty ?? false)) ? onClear : onTap,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: (selectedValue != null || (selectedValues?.isNotEmpty ?? false)) ? Colors.red.shade50 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              selectedValue != null || (selectedValues?.isNotEmpty ?? false)
                                  ? Icons.close
                                  : isExpanded
                                  ? Icons.keyboard_arrow_down_rounded
                                  : Icons.keyboard_arrow_right_rounded,
                              size: 20,
                              color: selectedValue != null || (selectedValues?.isNotEmpty ?? false) ? Colors.red.shade400 : Colors.blue.shade600,
                              weight: 2.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// 构建文本模式（可水平滚动）
  Widget _buildTextMode() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Text(selectedValue ?? '内容区域', style: TextStyle(color: selectedValue != null ? Colors.black : Colors.grey.shade400)),
    );
  }

  /// 构建标签模式（可水平滚动的标签列表）
  Widget _buildTagsMode() {
    if (selectedValues == null || selectedValues!.isEmpty) {
      return Text('内容区域', style: TextStyle(color: Colors.grey.shade400));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: selectedValues!.map((value) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200, width: 1),
            ),
            child: Text(
              value,
              style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
            ),
          );
        }).toList(),
      ),
    );
  }
}
