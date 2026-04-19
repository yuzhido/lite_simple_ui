import 'package:flutter/material.dart';

class ContainerWrapper extends StatefulWidget {
  final String label;
  final String? selectedValue;
  final List<String>? selectedValues;
  final bool required;
  final VoidCallback? onTap;

  /// 清空选中回调
  final VoidCallback? onClear;
  const ContainerWrapper({this.label = '请传递标签label', this.required = true, this.selectedValue, this.onTap, this.onClear, super.key, this.selectedValues});
  @override
  State<ContainerWrapper> createState() => _ContainerWrapperState();
}

class _ContainerWrapperState extends State<ContainerWrapper> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.all(10),
        child: Row(
          spacing: 5,
          children: [
            Icon(Icons.branding_watermark_outlined),
            if (widget.required)
              Text(
                '*',
                style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            Text(widget.label),
            Expanded(child: Text('${widget.selectedValue}')),
            InkWell(
              onTap: (widget.selectedValue != null || (widget.selectedValues?.isNotEmpty ?? false)) ? widget.onClear : widget.onTap,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (widget.selectedValue != null || (widget.selectedValues?.isNotEmpty ?? false)) ? Colors.red.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  widget.selectedValue != null || (widget.selectedValues?.isNotEmpty ?? false)
                      ? Icons.close
                      : isExpanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_right_rounded,
                  size: 20,
                  color: widget.selectedValue != null || (widget.selectedValues?.isNotEmpty ?? false) ? Colors.red.shade400 : Colors.blue.shade600,
                  weight: 2.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
