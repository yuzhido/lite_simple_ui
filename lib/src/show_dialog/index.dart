import 'package:flutter/material.dart';

/// 弹窗显示一些内容
class ShowDialog {
  static bool _isShowDialog = false;

  /// 中间弹框
  static void show(
    BuildContext context, {
    String title = '温馨提示',
    bool isBoldTitle = true,
    bool clickBtnPop = true,
    String leftText = '取消',
    String rightText = '确认',
    final String? content,
    final VoidCallback? onCancel,
    final VoidCallback? onConfirm,
  }) {
    if (_isShowDialog) {
      return;
    }
    _isShowDialog = true;

    showDialog(
      context: context,
      barrierDismissible: !clickBtnPop,
      builder: (dialogContext) {
        return AnimatedPadding(
          padding: MediaQuery.of(dialogContext).viewInsets + const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeInCubic,
          child: MediaQuery.removeViewInsets(
            removeLeft: true,
            removeTop: true,
            removeRight: true,
            removeBottom: true,
            context: dialogContext,
            child: Center(
              child: SizedBox(
                width: 270.0,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: isBoldTitle ? FontWeight.bold : FontWeight.normal),
                        ),
                      ),
                      if (content == null)
                        const SizedBox(height: 18)
                      else ...[
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Text(content, style: const TextStyle(fontSize: 16.0)),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      const Divider(height: 1),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: SizedBox(
                              height: 48.0,
                              child: TextButton(
                                onPressed: () {
                                  if (onCancel != null) {
                                    onCancel.call();
                                  } else {
                                    Navigator.pop(dialogContext);
                                  }
                                },
                                style: ButtonStyle(
                                  foregroundColor: WidgetStateProperty.all(Color(0xFF999999)),
                                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0))),
                                  splashFactory: InkSplash.splashFactory,
                                ),
                                child: Text(leftText, style: const TextStyle(fontSize: 18)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 48.0, width: 0.6, child: VerticalDivider()),
                          Expanded(
                            child: SizedBox(
                              height: 48.0,
                              child: TextButton(
                                onPressed: () {
                                  if (clickBtnPop == true) {
                                    Navigator.pop(dialogContext);
                                  }
                                  onConfirm?.call();
                                },
                                style: ButtonStyle(
                                  foregroundColor: WidgetStateProperty.all(Theme.of(dialogContext).primaryColor),
                                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0))),
                                  splashFactory: InkSplash.splashFactory,
                                ),
                                child: Text(rightText, style: const TextStyle(fontSize: 18)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).then((value) => _isShowDialog = false);
  }

  /// 当clickBtnPop=false时，手动隐藏弹框
  static void hide(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pop(context);
    _isShowDialog = false;
  }
}
