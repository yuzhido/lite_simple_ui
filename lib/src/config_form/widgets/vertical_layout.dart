import 'package:flutter/material.dart';
import '../src/form_item.dart';
import '../src/form_config.dart';
import '../src/config_form_controller.dart';
import '../src/enums.dart';
import 'form_item_builder.dart';

/// 纵向布局策略
class VerticalLayoutStrategy {
  /// 构建表单项
  Widget buildFormItem(BuildContext context, FormItem item, ConfigFormController controller, FormConfig config) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final hasError = controller.hasError(item.property);
        final error = controller.getError(item.property);
        final value = controller.getValue(item.property);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label 区域（错误信息显示在 label 后面）
            _buildLabel(context, item, hasError, error, config),
            const SizedBox(height: 4),
            // 内容区域
            FormItemBuilder(
              item: item,
              value: value,
              onChanged: (newValue) {
                controller.setValue(item.property, newValue);
                // 如果配置了 onChanged 触发验证
                if (item.validateTriggers.contains(ValidateTrigger.onChanged)) {
                  controller.validateField(item.property);
                }
              },
              onBlur: () {
                // 如果配置了 onBlur 触发验证
                if (item.validateTriggers.contains(ValidateTrigger.onBlur)) {
                  controller.validateField(item.property);
                }
              },
              config: config,
              hasError: hasError,
              errorMessage: error,
            ),
            // 纵向布局：错误已在 label 后面显示，内容下方不再显示
          ],
        );
      },
    );
  }

  /// 构建 Label
  Widget _buildLabel(BuildContext context, FormItem item, bool hasError, String? error, FormConfig config) {
    // 如果提供了自定义 labelBuilder，优先使用
    if (item.labelBuilder != null) {
      return item.labelBuilder!(context, hasError: hasError, isRequired: item.required);
    }

    // 默认 label 构建
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.required && config.showRequiredMark) const Text('*', style: TextStyle(color: Colors.red, fontSize: 14)),
        const SizedBox(width: 4),
        Text(item.label, style: config.labelStyle ?? const TextStyle(fontSize: 14)),
        // 纵向布局：错误显示在 label 后面
        if (hasError && error != null) ...[const SizedBox(width: 8), Text(error, style: config.errorStyle ?? const TextStyle(color: Colors.red, fontSize: 12))],
      ],
    );
  }
}
