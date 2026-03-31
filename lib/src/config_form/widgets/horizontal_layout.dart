import 'package:flutter/material.dart';
import '../src/form_item.dart';
import '../src/form_config.dart';
import '../src/config_form_controller.dart';
import '../src/enums.dart';
import 'form_item_builder.dart';

/// 横向布局策略
class HorizontalLayoutStrategy {
  /// 构建表单项
  Widget buildFormItem(BuildContext context, FormItem item, ConfigFormController controller, FormConfig config) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final hasError = controller.hasError(item.property);
        final error = controller.getError(item.property);
        final value = controller.getValue(item.property);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Label 区域
                if (config.labelWidth != null)
                  SizedBox(width: config.labelWidth, child: _buildLabel(context, item, hasError, config))
                else
                  _buildLabel(context, item, hasError, config),
                // 输入区域
                Expanded(
                  child: FormItemBuilder(
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
                  ),
                ),
                // 右侧状态区域
                if (item.statusBuilder != null) item.statusBuilder!(context, value),
              ],
            ),

            // 底部分割线
            if (config.showDivider) Divider(height: 1, color: config.dividerColor ?? Colors.grey.shade300),
          ],
        );
      },
    );
  }

  /// 构建 Label
  Widget _buildLabel(BuildContext context, FormItem item, bool hasError, FormConfig config) {
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
      ],
    );
  }
}
