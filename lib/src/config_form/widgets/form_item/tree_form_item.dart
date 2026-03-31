import 'package:flutter/material.dart';
import '../../src/form_item.dart';
import '../../src/form_config.dart';
import '../../src/form_item_config.dart';
import '../../../choose_tree/index.dart';
import '../../../model/index.dart';
import 'horizontal_form_item_wrapper.dart';

/// 树形选择器表单项组件
class TreeFormItem extends StatelessWidget {
  final FormItem item;
  final dynamic value;
  final Function(dynamic) onChanged;
  final FormConfig config;
  final bool hasError;

  const TreeFormItem({super.key, required this.item, required this.value, required this.onChanged, required this.config, required this.hasError});

  @override
  Widget build(BuildContext context) {
    // 从 config 中获取配置参数（类型安全）
    ChooseTreeConfig? treeConfig;
    if (item.config is ChooseTreeConfig) {
      treeConfig = item.config as ChooseTreeConfig;
    }

    final treeData = treeConfig?.data ?? [];
    final fieldMapping = treeConfig?.fieldMapping;
    final showClearButton = treeConfig?.showClearButton ?? true;

    // 确保 value 是正确的格式：List<Map<String, dynamic>>
    final List<Map<String, dynamic>>? treeValue;
    if (value != null) {
      if (value is Map<String, dynamic>) {
        treeValue = [value];
      } else if (value is Map) {
        treeValue = [Map<String, dynamic>.from(value)];
      } else {
        treeValue = null;
      }
    } else {
      treeValue = null;
    }

    // 从 config 中获取 fieldMapping
    final fieldMappingConfig = fieldMapping;

    // 创建输入区域组件
    final inputWidget = GestureDetector(
      onTap: () => _showTreeSelect(context, treeData, fieldMappingConfig),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(child: Text(treeValue?.isNotEmpty == true ? (treeValue!.first['label'] ?? '请选择') : '请选择', style: const TextStyle(fontSize: 14))),
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

  /// 显示树形选择器
  void _showTreeSelect(BuildContext context, List<Map<String, dynamic>> data, FieldMapping? fieldMapping) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(item.label)),
          body: ChooseTree(
            data: data,
            value: value != null ? [value] : [],
            title: item.label,
            selectType: SelectType.single,
            onSingleConfirm: (id, data) {
              onChanged(data);
              Navigator.of(context).pop();
            },
            onMultiConfirm: (ids, dataList) {
              onChanged(dataList);
              Navigator.of(context).pop();
            },
            fieldMapping: fieldMapping ?? const FieldMapping(),
          ),
        ),
      ),
    );
  }
}
