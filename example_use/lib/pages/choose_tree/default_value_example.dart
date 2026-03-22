import 'package:flutter/material.dart';
import 'package:lite_simple_ui/lite_simple_ui.dart';

/// 默认值示例页面 - 演示如何设置默认选中值
class DefaultValueExamplePage extends StatefulWidget {
  const DefaultValueExamplePage({super.key});

  @override
  State<DefaultValueExamplePage> createState() => _DefaultValueExamplePageState();
}

class _DefaultValueExamplePageState extends State<DefaultValueExamplePage> {
  // 默认选中的值
  List<Map<String, dynamic>> _selectedValues = [
    {'id': 'region_1_1', 'name': '上海市', 'children': []},
  ];

  String? _confirmResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('默认值示例')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('默认值功能演示', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('• 组件加载时自动显示默认选中值\n• 打开弹窗时自动选中对应的节点\n• 支持通过 value 属性控制选中状态', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),

            // 示例 1：使用 value 属性设置默认值（受控模式）
            const Text('示例 1：受控模式 - 使用 value 属性', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            ChooseTree<String, Map<String, dynamic>>(
              title: '请选择地区（默认选中上海市）',
              data: _getRegionData(),
              value: _selectedValues, // ← 关键：传入默认值
              selectType: SelectType.multiple,
              onSelectChanged: (selected) {
                setState(() {
                  _selectedValues = selected;
                });
                print('选中变化：${selected.map((e) => e['name']).join(', ')}');
              },
              onMultiConfirm: (ids, dataList) {
                setState(() {
                  _confirmResult = '已确认：${dataList.map((e) => e['name']).join(', ')}';
                });
              },
            ),
            if (_selectedValues.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('当前选中：${_selectedValues.map((e) => e['name']).join(', ')}', style: const TextStyle(fontSize: 14, color: Colors.blue)),
              ),
            const SizedBox(height: 16),

            // 重置按钮
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedValues = [
                    {'id': 'region_1_1', 'name': '上海市', 'children': []},
                  ];
                  _confirmResult = null;
                });
              },
              child: const Text('重置为默认值'),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedValues = [];
                  _confirmResult = null;
                });
              },
              child: const Text('清空选中值'),
            ),
            if (_confirmResult != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_confirmResult!, style: const TextStyle(fontSize: 14, color: Colors.green)),
              ),
            const SizedBox(height: 32),

            // 示例 2：多选多个默认值
            const Text('示例 2：多选多个默认值', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            MultiDefaultExample(),
            const SizedBox(height: 32),

            // 示例 3：单选默认值
            const Text('示例 3：单选默认值', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            SingleDefaultExample(),
          ],
        ),
      ),
    );
  }

  /// 获取地区数据
  List<Map<String, dynamic>> _getRegionData() {
    return [
      {
        'id': 'region_1',
        'name': '华东地区',
        'children': [
          {'id': 'region_1_1', 'name': '上海市', 'children': []},
          {'id': 'region_1_2', 'name': '杭州市', 'children': []},
          {'id': 'region_1_3', 'name': '南京市', 'children': []},
        ],
      },
      {
        'id': 'region_2',
        'name': '华北地区',
        'children': [
          {'id': 'region_2_1', 'name': '北京市', 'children': []},
          {'id': 'region_2_2', 'name': '天津市', 'children': []},
        ],
      },
      {
        'id': 'region_3',
        'name': '华南地区',
        'children': [
          {'id': 'region_3_1', 'name': '广州市', 'children': []},
          {'id': 'region_3_2', 'name': '深圳市', 'children': []},
        ],
      },
    ];
  }
}

/// 多选多个默认值示例
class MultiDefaultExample extends StatefulWidget {
  const MultiDefaultExample({super.key});

  @override
  State<MultiDefaultExample> createState() => _MultiDefaultExampleState();
}

class _MultiDefaultExampleState extends State<MultiDefaultExample> {
  List<Map<String, dynamic>> _selectedValues = [
    {'id': 'region_1_1', 'name': '上海市', 'children': []},
    {'id': 'region_2_1', 'name': '北京市', 'children': []},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChooseTree<String, Map<String, dynamic>>(
          title: '请选择多个城市（默认选中上海 + 北京）',
          data: _getRegionData(),
          value: _selectedValues, // ← 传入多个默认值
          selectType: SelectType.multiple,
          onSelectChanged: (selected) {
            setState(() {
              _selectedValues = selected;
            });
          },
        ),
        if (_selectedValues.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('当前选中：${_selectedValues.map((e) => e['name']).join(', ')}', style: const TextStyle(fontSize: 14, color: Colors.blue)),
          ),
      ],
    );
  }

  List<Map<String, dynamic>> _getRegionData() {
    return [
      {
        'id': 'region_1',
        'name': '华东地区',
        'children': [
          {'id': 'region_1_1', 'name': '上海市', 'children': []},
          {'id': 'region_1_2', 'name': '杭州市', 'children': []},
          {'id': 'region_1_3', 'name': '南京市', 'children': []},
        ],
      },
      {
        'id': 'region_2',
        'name': '华北地区',
        'children': [
          {'id': 'region_2_1', 'name': '北京市', 'children': []},
          {'id': 'region_2_2', 'name': '天津市', 'children': []},
        ],
      },
      {
        'id': 'region_3',
        'name': '华南地区',
        'children': [
          {'id': 'region_3_1', 'name': '广州市', 'children': []},
          {'id': 'region_3_2', 'name': '深圳市', 'children': []},
        ],
      },
    ];
  }
}

/// 单选默认值示例
class SingleDefaultExample extends StatefulWidget {
  const SingleDefaultExample({super.key});

  @override
  State<SingleDefaultExample> createState() => _SingleDefaultExampleState();
}

class _SingleDefaultExampleState extends State<SingleDefaultExample> {
  // 单选模式：使用单个 Map 而不是 List
  Map<String, dynamic>? _selectedValue = {'id': 'region_1_2', 'name': '杭州市', 'children': []};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChooseTree<String, Map<String, dynamic>>(
          title: '请选择单个城市（默认选中杭州市）',
          data: _getRegionData(),
          value: _selectedValue != null ? [_selectedValue!] : [], // ← 转换为 List 传递给组件
          selectType: SelectType.single,
          selectableMode: SelectableMode.all, // 所有节点可选
          onSelectChanged: (selected) {
            setState(() {
              _selectedValue = selected.isNotEmpty ? selected.first : null;
            });
          },
          onSingleConfirm: (id, data) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('确认选择：${data['name']}')));
          },
        ),
        if (_selectedValue != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('当前选中：${_selectedValue!['name']}', style: const TextStyle(fontSize: 14, color: Colors.blue)),
          ),
      ],
    );
  }

  List<Map<String, dynamic>> _getRegionData() {
    return [
      {
        'id': 'region_1',
        'name': '华东地区',
        'children': [
          {'id': 'region_1_1', 'name': '上海市', 'children': []},
          {'id': 'region_1_2', 'name': '杭州市', 'children': []},
          {'id': 'region_1_3', 'name': '南京市', 'children': []},
        ],
      },
      {
        'id': 'region_2',
        'name': '华北地区',
        'children': [
          {'id': 'region_2_1', 'name': '北京市', 'children': []},
          {'id': 'region_2_2', 'name': '天津市', 'children': []},
        ],
      },
    ];
  }
}
