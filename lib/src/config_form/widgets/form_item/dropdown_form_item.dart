import 'package:flutter/material.dart';
import '../../src/form_item.dart';
import '../../src/form_config.dart';
import '../../src/form_item_config.dart';
import '../../../dropdown_choose/index.dart';
import '../../../model/index.dart';
import 'horizontal_form_item_wrapper.dart';

/// 下拉选择器表单项组件
class DropdownFormItem extends StatelessWidget {
  final FormItem item;
  final dynamic value;
  final Function(dynamic) onChanged;
  final FormConfig config;
  final bool hasError;

  const DropdownFormItem({super.key, required this.item, required this.value, required this.onChanged, required this.config, required this.hasError});

  @override
  Widget build(BuildContext context) {
    // 从 config 中获取配置参数（类型安全）
    DropdownChooseConfig? dropdownConfig;
    if (item.config is DropdownChooseConfig) {
      dropdownConfig = item.config as DropdownChooseConfig;
    }

    final options = dropdownConfig?.options ?? [];
    final showClearButton = dropdownConfig?.showClearButton ?? true;

    // 确保 value 是正确的格式：List<Map<String, dynamic>>
    final List<Map<String, dynamic>>? dropdownValue;
    if (value != null) {
      if (value is Map<String, dynamic>) {
        dropdownValue = [value];
      } else if (value is Map) {
        // 如果是 Map 但不是泛型版本，转换为 Map<String, dynamic>
        dropdownValue = [Map<String, dynamic>.from(value)];
      } else {
        dropdownValue = null;
      }
    } else {
      dropdownValue = null;
    }

    // 创建输入区域组件
    final inputWidget = GestureDetector(
      onTap: () => _showDropdown(context, options),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(child: Text(dropdownValue?.isNotEmpty == true ? (dropdownValue!.first['label'] ?? '请选择') : '请选择', style: const TextStyle(fontSize: 14))),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );

    return HorizontalFormItemWrapper(
      inputWidget: inputWidget,
      showClearButton: showClearButton,
      value: value,
      onClear: () {
        onChanged(null);
      },
    );
  }

  /// 显示下拉选择器
  void _showDropdown(BuildContext context, List<Map<String, dynamic>> options) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(item.label)),
          body: DropdownChoose(
            options: options,
            value: value != null ? [value] : [],
            onValueChange: (ids, dataList) {
              final newValue = dataList.isNotEmpty ? dataList.first : null;
              onChanged(newValue);
              Navigator.of(context).pop();
            },
            title: item.label,
            selectType: SelectType.single,
          ),
        ),
      ),
    );
  }
}
