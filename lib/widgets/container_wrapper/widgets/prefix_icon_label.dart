import 'package:flutter/material.dart';
import 'package:lite_simple_ui/config/ui_theme.dart';

class PrefixIconLabel extends StatelessWidget {
  final bool required;
  final String label;
  const PrefixIconLabel({super.key, this.required = true, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 2,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 前面图标
        Icon(Icons.branding_watermark_outlined, size: 20, color: UiTheme.primaryColor),
        // 必填标识
        if (required)
          Text(
            '*',
            style: TextStyle(color: UiTheme.errorColor, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        // 标签
        Text(label, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
