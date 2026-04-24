import 'package:flutter/material.dart';

class SuffixClearIcon<R> extends StatelessWidget {
  final R? selectedValue;
  final VoidCallback? onTap;
  final List<R>? selectedValues;
  final bool isExpanded;
  const SuffixClearIcon({super.key, this.selectedValue, this.selectedValues, this.isExpanded = false, this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
    );
  }
}
