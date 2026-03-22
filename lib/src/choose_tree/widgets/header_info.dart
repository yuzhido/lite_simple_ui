import 'package:flutter/material.dart';

class HeaderInfo extends StatelessWidget {
  /// 自定义标题
  final String? customTitle;

  /// 关闭按钮点击回调
  final VoidCallback? onClose;

  const HeaderInfo({super.key, this.customTitle, this.onClose});

  @override
  Widget build(BuildContext context) {
    final title = customTitle != null && customTitle!.isNotEmpty ? '请选择${customTitle}' : '选择';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87, letterSpacing: 0.3),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(35),
              child: const Icon(Icons.close, size: 18, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
