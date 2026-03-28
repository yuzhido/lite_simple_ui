import 'package:flutter/material.dart';
import 'package:lite_simple_ui/lite_simple_ui.dart';

class DropdownChooseExamplePage extends StatefulWidget {
  const DropdownChooseExamplePage({super.key});

  @override
  State<DropdownChooseExamplePage> createState() => _DropdownChooseExamplePageState();
}

class _DropdownChooseExamplePageState extends State<DropdownChooseExamplePage> {
  // 单选选中值
  Map<String, dynamic>? _singleSelectedValue;

  // 多选选中值
  List<Map<String, dynamic>> _multiSelectedValues = [];

  // 标签模式选中值
  List<Map<String, dynamic>> _tagsSelectedValues = [];

  // 测试数据
  final List<Map<String, dynamic>> _optionsData = [
    {'id': '1', 'name': '选项一'},
    {'id': '2', 'name': '选项二'},
    {'id': '3', 'name': '选项三'},
    {'id': '4', 'name': '选项四'},
    {'id': '5', 'name': '选项五'},
    {'id': '6', 'name': '选项六'},
  ];

  /// 清除回调示例
  void _handleClear() {
    print('清除操作被调用');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已清除选中项'), duration: Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('下拉选择组件示例')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 示例 1：基础单选
            const Text('示例 1：基础单选', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownChoose<String, Map<String, dynamic>>(
              title: '请选择选项（单选）',
              options: _optionsData,
              selectType: SelectType.single,
              fieldMapping: const FieldMapping(idField: 'id', labelField: 'name'),
              value: _singleSelectedValue != null ? [_singleSelectedValue!] : [],
              onSingleConfirm: (id, data) {
                setState(() {
                  _singleSelectedValue = data;
                });
                print('单选确认：$id - ${data['name']}');
              },
              onClear: _handleClear,
            ),
            if (_singleSelectedValue != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('已选中：${_singleSelectedValue!['name']}', style: const TextStyle(fontSize: 14, color: Colors.green)),
              ),

            const SizedBox(height: 24),

            // 示例 2：基础多选
            const Text('示例 2：基础多选', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownChoose<String, Map<String, dynamic>>(
              title: '请选择选项（多选）',
              options: _optionsData,
              selectType: SelectType.multiple,
              fieldMapping: const FieldMapping(idField: 'id', labelField: 'name'),
              value: _multiSelectedValues,
              onMultiConfirm: (ids, dataList) {
                setState(() {
                  _multiSelectedValues = dataList;
                });
                print('多选确认：$ids');
              },
              onClear: _handleClear,
            ),
            if (_multiSelectedValues.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('已选中：${_multiSelectedValues.map((e) => e['name']).join(', ')}', style: const TextStyle(fontSize: 14, color: Colors.green)),
              ),

            const SizedBox(height: 24),

            // 示例 3：标签模式
            const Text('示例 3：标签模式（多选）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownChoose<String, Map<String, dynamic>>(
              title: '请选择标签',
              options: _optionsData,
              selectType: SelectType.multiple,
              displayMode: DisplayMode.tags,
              fieldMapping: const FieldMapping(idField: 'id', labelField: 'name'),
              value: _tagsSelectedValues,
              onClear: _handleClear,
              onMultiConfirm: (ids, dataList) {
                setState(() {
                  _tagsSelectedValues = dataList;
                });
              },
            ),

            const SizedBox(height: 24),

            // 示例 4：自定义容器
            const Text('示例 4：自定义容器', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownChoose<String, Map<String, dynamic>>(
              title: '自定义容器',
              options: _optionsData,
              selectType: SelectType.single,
              fieldMapping: const FieldMapping(idField: 'id', labelField: 'name'),
              customContainerBuilder: (context, onTap) {
                return Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade600]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _singleSelectedValue?['name'] ?? '点击选择明星选项',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
              onSingleConfirm: (id, data) {
                setState(() {
                  _singleSelectedValue = data;
                });
              },
            ),

            const SizedBox(height: 24),

            // 示例 5：自定义内容区
            const Text('示例 5：自定义内容区 UI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownChoose<String, Map<String, dynamic>>(
              title: '自定义内容',
              options: _optionsData,
              selectType: SelectType.multiple,
              fieldMapping: const FieldMapping(idField: 'id', labelField: 'name'),
              customContentBuilder: (context, selectedValues) {
                return Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedValues.isNotEmpty ? '${selectedValues.length} 个选项被选中' : '还没有选择哦~',
                        style: TextStyle(color: selectedValues.isNotEmpty ? Colors.amber.shade700 : Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                );
              },
              value: _multiSelectedValues,
              onMultiConfirm: (ids, dataList) {
                setState(() {
                  _multiSelectedValues = dataList;
                });
              },
            ),

            const SizedBox(height: 32),

            // 说明文字
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 使用说明',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. 单选模式：点击选项后立即确认并关闭弹窗\n'
                    '2. 多选模式：需要点击底部"确定"按钮才确认\n'
                    '3. 支持自定义容器和内容区 UI\n'
                    '4. 通过 value 属性控制数据回显\n'
                    '5. 支持文本模式和标签模式显示',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
