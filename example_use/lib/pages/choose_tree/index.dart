import 'package:flutter/material.dart';
import 'package:lite_simple_ui/lite_simple_ui.dart';

class ChooseTreePage extends StatefulWidget {
  const ChooseTreePage({super.key});
  @override
  State<ChooseTreePage> createState() => _ChooseTreePageState();
}

class _ChooseTreePageState extends State<ChooseTreePage> {
  List<Map<String, dynamic>> _treeData = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _selectedValues = [];
  Map<String, dynamic>? _singleSelectedValue;
  List<Map<String, dynamic>> _hierarchicalSelectedValues = [];
  List<Map<String, dynamic>> _tagsSelectedValues = [];
  List<Map<String, dynamic>> _hierarchicalTagsSelectedValues = [];

  // 用于显示确认结果
  String? _singleConfirmResult;
  List<Map<String, dynamic>>? _multiConfirmResult;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 加载数据（示例中使用测试数据）
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // 测试数据 (三级结构)
    final testData = [
      {
        'id': '1',
        'name': '上海市',
        'children': [
          {
            'id': '1-1',
            'name': '浦东新区',
            'children': [
              {'id': '1-1-1', 'name': '陆家嘴街道'},
              {'id': '1-1-2', 'name': '张江高科技园区'},
              {'id': '1-1-3', 'name': '花木街道'},
            ],
          },
          {
            'id': '1-2',
            'name': '黄浦区',
            'children': [
              {'id': '1-2-1', 'name': '外滩街道'},
              {'id': '1-2-2', 'name': '南京东路街道'},
              {'id': '1-2-3', 'name': '豫园街道'},
            ],
          },
          {
            'id': '1-3',
            'name': '徐汇区',
            'children': [
              {'id': '1-3-1', 'name': '徐家汇街道'},
              {'id': '1-3-2', 'name': '湖南路街道'},
              {'id': '1-3-3', 'name': '天平路街道'},
            ],
          },
        ],
      },
      {
        'id': '2',
        'name': '北京市',
        'children': [
          {
            'id': '2-1',
            'name': '朝阳区',
            'children': [
              {'id': '2-1-1', 'name': '三里屯街道'},
              {'id': '2-1-2', 'name': '国贸街道'},
              {'id': '2-1-3', 'name': '望京街道'},
              {'id': '2-1-4', 'name': '双井街道'},
            ],
          },
          {
            'id': '2-2',
            'name': '海淀区',
            'children': [
              {'id': '2-2-1', 'name': '中关村街道'},
              {'id': '2-2-2', 'name': '五道口街道'},
              {'id': '2-2-3', 'name': '上地街道'},
            ],
          },
          {
            'id': '2-3',
            'name': '东城区',
            'children': [
              {'id': '2-3-1', 'name': '王府井街道'},
              {'id': '2-3-2', 'name': '东单街道'},
              {'id': '2-3-3', 'name': '安定门街道'},
            ],
          },
        ],
      },
      {
        'id': '3',
        'name': '广东省',
        'children': [
          {
            'id': '3-1',
            'name': '广州市',
            'children': [
              {'id': '3-1-1', 'name': '天河区'},
              {'id': '3-1-2', 'name': '越秀区'},
              {'id': '3-1-3', 'name': '海珠区'},
              {'id': '3-1-4', 'name': '荔湾区'},
            ],
          },
          {
            'id': '3-2',
            'name': '深圳市',
            'children': [
              {'id': '3-2-1', 'name': '福田区'},
              {'id': '3-2-2', 'name': '南山区'},
              {'id': '3-2-3', 'name': '罗湖区'},
              {'id': '3-2-4', 'name': '宝安区'},
            ],
          },
          {
            'id': '3-3',
            'name': '东莞市',
            'children': [
              {'id': '3-3-1', 'name': '南城街道'},
              {'id': '3-3-2', 'name': '东城街道'},
              {'id': '3-3-3', 'name': '莞城街道'},
            ],
          },
        ],
      },
      {
        'id': '4',
        'name': '浙江省',
        'children': [
          {
            'id': '4-1',
            'name': '杭州市',
            'children': [
              {'id': '4-1-1', 'name': '西湖区'},
              {'id': '4-1-2', 'name': '上城区'},
              {'id': '4-1-3', 'name': '下城区'},
              {'id': '4-1-4', 'name': '江干区'},
            ],
          },
          {
            'id': '4-2',
            'name': '宁波市',
            'children': [
              {'id': '4-2-1', 'name': '海曙区'},
              {'id': '4-2-2', 'name': '江北区'},
              {'id': '4-2-3', 'name': '鄞州区'},
            ],
          },
        ],
      },
      {
        'id': '5',
        'name': '江苏省',
        'children': [
          {
            'id': '5-1',
            'name': '南京市',
            'children': [
              {'id': '5-1-1', 'name': '玄武区'},
              {'id': '5-1-2', 'name': '鼓楼区'},
              {'id': '5-1-3', 'name': '建邺区'},
            ],
          },
          {
            'id': '5-2',
            'name': '苏州市',
            'children': [
              {'id': '5-2-1', 'name': '姑苏区'},
              {'id': '5-2-2', 'name': '吴中区'},
              {'id': '5-2-3', 'name': '相城区'},
              {'id': '5-2-4', 'name': '工业园区'},
            ],
          },
        ],
      },
    ];

    setState(() {
      _treeData = testData;
      _isLoading = false;
    });
  }

  /// 处理层级联动选择
  void _handleHierarchicalSelectChanged(List<Map<String, dynamic>> selected) {
    setState(() {
      _hierarchicalSelectedValues = selected;
    });
    debugPrint('层级联动选中 ${selected.length} 项：${selected.map((e) => e['name']).join(', ')}');
  }

  /// 处理标签模式选择
  void _handleTagsSelectChanged(List<Map<String, dynamic>> selected) {
    setState(() {
      _tagsSelectedValues = selected;
    });
    debugPrint('标签模式选中 ${selected.length} 项：${selected.map((e) => e['name']).join(', ')}');
  }

  /// 处理层级联动 + 标签模式选择
  void _handleHierarchicalTagsSelectChanged(List<Map<String, dynamic>> selected) {
    setState(() {
      _hierarchicalTagsSelectedValues = selected;
    });
    debugPrint('层级标签选中 ${selected.length} 项：${selected.map((e) => e['name']).join(', ')}');
  }

  /// 单选确认回调
  void _handleSingleConfirm(String id, Map<String, dynamic> data) {
    setState(() {
      _singleSelectedValue = data;
      _singleConfirmResult = '确认选中：$id - ${data['name']}';
    });
    debugPrint('单选确认：id=$id, data=$data');
  }

  /// 多选确认回调
  void _handleMultiConfirm(List<String> ids, List<Map<String, dynamic>> dataList) {
    setState(() {
      _selectedValues = dataList;
      _multiConfirmResult = dataList;
    });
    debugPrint('多选确认：ids=${ids.join(', ')}, count=${dataList.length}');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('导航栏标题')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ChooseTree(customContentUi: const Text('自定义内容'), title: '自定义选中', data: _treeData, value: _selectedValues, onMultiConfirm: _handleMultiConfirm),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('正式内容看下面...', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ),
            Container(
              height: 40, // 固定高度 30
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(color: const Color.fromARGB(255, 216, 6, 6)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 12,
                    right: 12,
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: '输入内容...',
                        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 使用示例 1：多选模式（默认）
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('多选模式（所有节点可选）', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('只使用 onMultiConfirm，选中后点击确定才回调', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ChooseTree(title: '区域位置', data: _treeData, value: _selectedValues, onMultiConfirm: _handleMultiConfirm),
            ),
            const SizedBox(height: 20),
            // 显示当前选中
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '当前选中：${_selectedValues.length} 项',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 4),
                  Text(_selectedValues.map((e) => e['name']).join(', '), style: const TextStyle(color: Colors.blue)),
                  if (_multiConfirmResult != null && _multiConfirmResult!.isNotEmpty) const SizedBox(height: 8),
                  if (_multiConfirmResult != null && _multiConfirmResult!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '确认选中 ${_multiConfirmResult!.length} 项',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                                ),
                                const SizedBox(height: 4),
                                Text(_multiConfirmResult!.map((e) => e['name']).join(', '), style: const TextStyle(fontSize: 11, color: Colors.blue)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // 使用示例 2：单选模式
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('单选模式', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('只使用 onSingleConfirm，选中后立即回调并关闭弹窗', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ChooseTree(
                title: '单选区域',
                data: _treeData,
                selectType: SelectType.single,
                value: _singleSelectedValue != null ? [_singleSelectedValue!] : [],
                onSingleConfirm: _handleSingleConfirm,
              ),
            ),
            const SizedBox(height: 20),
            // 显示单选选中
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '单选选中：${_singleSelectedValue != null ? _singleSelectedValue!['name'] : '无'}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  if (_singleConfirmResult != null) const SizedBox(height: 8),
                  if (_singleConfirmResult != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_singleConfirmResult!, style: const TextStyle(fontSize: 12, color: Colors.green)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // 使用示例 3：层级联动模式
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('层级联动模式（选中父节点自动选中所有子节点）', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ChooseTree(
                title: '层级选择',
                data: _treeData,
                selectableMode: SelectableMode.hierarchical,
                value: _hierarchicalSelectedValues,
                onSelectChanged: _handleHierarchicalSelectChanged,
              ),
            ),
            const SizedBox(height: 20),
            // 显示层级联动选中
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '层级联动选中：${_hierarchicalSelectedValues.length} 项',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  const SizedBox(height: 4),
                  Text(_hierarchicalSelectedValues.map((e) => e['name']).join(', '), style: const TextStyle(color: Colors.orange)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // 使用示例 4：标签模式
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('标签模式（每个选中项显示为独立标签）', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ChooseTree(
                title: '标签显示',
                data: _treeData,
                selectableMode: SelectableMode.hierarchical,
                displayMode: DisplayMode.tags,
                value: _tagsSelectedValues,
                onSelectChanged: _handleTagsSelectChanged,
              ),
            ),
            const SizedBox(height: 20),
            // 显示标签模式选中
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '标签模式选中：${_tagsSelectedValues.length} 项',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
                  ),
                  const SizedBox(height: 4),
                  Text(_tagsSelectedValues.map((e) => e['name']).join(', '), style: const TextStyle(color: Colors.purple)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // 使用示例 5：层级联动 + 标签模式
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('层级联动 + 标签模式（选中父节点自动选中所有子节点，显示为标签）', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ChooseTree(
                title: '层级标签',
                data: _treeData,
                selectableMode: SelectableMode.hierarchical,
                displayMode: DisplayMode.tags,
                value: _hierarchicalTagsSelectedValues,
                onSelectChanged: _handleHierarchicalTagsSelectChanged,
              ),
            ),
            const SizedBox(height: 20),
            // 显示层级联动 + 标签模式选中
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '层级标签选中：${_hierarchicalTagsSelectedValues.length} 项',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  const SizedBox(height: 4),
                  Text(_hierarchicalTagsSelectedValues.map((e) => e['name']).join(', '), style: const TextStyle(color: Colors.teal)),
                  const SizedBox(height: 8),
                  const Text(
                    '提示：选中所有子节点时，父节点会自动选中；取消任一子节点，父节点自动取消',
                    style: TextStyle(fontSize: 11, color: Colors.teal, fontStyle: FontStyle.italic),
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
