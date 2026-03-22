import 'package:flutter/material.dart';

/// 底部确认回调 typedef
typedef BottomConfirmCallback = void Function();

/// 底部操作栏组件
class BottomAction extends StatelessWidget {
  /// 已选中的节点数量
  final int selectedCount;

  /// 取消选中回调
  final VoidCallback? onCancel;

  /// 确定回调
  final VoidCallback? onConfirm;

  /// 是否显示取消按钮 (默认 true)
  final bool showCancelButton;

  /// 确定按钮文字
  final String confirmText;

  /// 取消按钮文字
  final String cancelText;

  const BottomAction({super.key, required this.selectedCount, this.onCancel, this.onConfirm, this.showCancelButton = true, this.confirmText = '确定', this.cancelText = '取消选中'});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                decoration: BoxDecoration(
                  color: selectedCount > 0 ? Colors.blue.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: selectedCount > 0 ? Colors.blue.shade200 : Colors.transparent, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 18, color: selectedCount > 0 ? Colors.blue.shade600 : Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '已选择 $selectedCount 项',
                        style: TextStyle(color: selectedCount > 0 ? Colors.blue.shade700 : Colors.grey.shade500, fontWeight: FontWeight.w600, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 中间：取消选中按钮
            if (showCancelButton && selectedCount > 0)
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    cancelText,
                    style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

            const SizedBox(width: 12),

            // 右侧：确定按钮
            ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(confirmText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
