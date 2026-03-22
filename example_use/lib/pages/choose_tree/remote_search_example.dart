import 'package:flutter/material.dart';
import 'package:lite_simple_ui/lite_simple_ui.dart';

/// 远程搜索示例页面
class RemoteSearchExamplePage extends StatefulWidget {
  const RemoteSearchExamplePage({super.key});

  @override
  State<RemoteSearchExamplePage> createState() => _RemoteSearchExamplePageState();
}

class _RemoteSearchExamplePageState extends State<RemoteSearchExamplePage> {
  List<Map<String, dynamic>> _selectedValues = [];
  String? _remoteSearchResult;

  // 远程搜索模式的默认值示例
  List<Map<String, dynamic>> _remoteDefaultValues = [
    {'id': 'region_1_1', 'name': '上海市', 'children': []},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('远程搜索示例')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('远程搜索功能演示', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('• 打开弹窗时自动加载初始数据\n• 实时搜索模式：输入时自动搜索（无搜索按钮）\n• 点击搜索模式：需要点击搜索按钮\n• 清除后自动重新加载初始数据', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),

            // 示例 1：实时搜索模式（默认）- 使用标准字段
            const Text('示例 1：实时搜索模式（输入即搜索）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            ChooseTree<String, Map<String, dynamic>>(
              title: '请选择地区（标准字段：id, name）',
              remoteSearch: true,
              remoteMethod: _loadRegionData,
              cacheStrategy: CacheStrategy.session,
              searchTriggerMode: SearchTriggerMode.realTime,
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
                child: Text('已选择：${_selectedValues.map((e) => e['name']).join(', ')}', style: const TextStyle(fontSize: 14)),
              ),

            const SizedBox(height: 24),

            // 示例 2：点击搜索模式 - 使用自定义字段映射
            const Text('示例 2：点击搜索模式（自定义字段：deptId, deptName）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            ChooseTree<String, Map<String, dynamic>>(
              title: '请选择部门（点击搜索）',
              remoteSearch: true,
              remoteMethod: _loadDepartmentData,
              fieldMapping: const FieldMapping(
                idField: 'deptId', // 自定义 ID 字段
                labelField: 'deptName', // 自定义名称字段
                childrenField: 'subDepts', // 自定义子节点字段
              ),
              cacheStrategy: CacheStrategy.never,
              searchTriggerMode: SearchTriggerMode.click,
              selectType: SelectType.single,
              onSelectChanged: (selected) {
                print('选中变化：$selected');
              },
              onSingleConfirm: (id, data) {
                print('单选确认：$id - ${data['deptName']}');
                setState(() {
                  _remoteSearchResult = '单选确认：$id - ${data['deptName']}';
                });
              },
            ),
            if (_remoteSearchResult != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_remoteSearchResult!, style: const TextStyle(fontSize: 14)),
              ),

            const SizedBox(height: 24),

            // 示例 3：总是缓存模式 - 使用另一套自定义字段
            const Text('示例 3：总是缓存模式（自定义字段：cityCode, cityName）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            ChooseTree<String, Map<String, dynamic>>(
              title: '请选择城市（总是缓存）',
              remoteSearch: true,
              remoteMethod: _loadCityData,
              fieldMapping: const FieldMapping(
                idField: 'cityCode', // 自定义 ID 字段
                labelField: 'cityName', // 自定义名称字段
                childrenField: 'districts', // 自定义子节点字段
              ),
              cacheStrategy: CacheStrategy.always,
              searchTriggerMode: SearchTriggerMode.realTime,
              selectType: SelectType.multiple,
              onSelectChanged: (selected) {
                debugPrint('缓存模式选中：${selected.length} 个');
                // 显示自定义字段的数据
                if (selected.isNotEmpty) {
                  final names = selected.map((e) => e['cityName'] as String).join(', ');
                  debugPrint('选中城市名称：$names');
                }
              },
            ),

            const SizedBox(height: 24),

            // 示例 4：远程搜索 + 默认值模式
            const Text('示例 4：远程搜索 + 默认值（加载时自动选中上海市）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            ChooseTree<String, Map<String, dynamic>>(
              title: '请选择地区（默认选中上海市）',
              remoteSearch: true,
              remoteMethod: _loadRegionData,
              cacheStrategy: CacheStrategy.session,
              searchTriggerMode: SearchTriggerMode.realTime,
              selectType: SelectType.multiple,
              value: _remoteDefaultValues, // ← 关键：传入默认值
              onSelectChanged: (selected) {
                setState(() {
                  _remoteDefaultValues = selected;
                });
              },
            ),
            if (_remoteDefaultValues.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('已选择：${_remoteDefaultValues.map((e) => e['name']).join(', ')}', style: const TextStyle(fontSize: 14)),
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _remoteDefaultValues = [
                    {'id': 'region_1_1', 'name': '上海市', 'children': []},
                  ];
                });
              },
              child: const Text('重置为默认值'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _remoteDefaultValues = [];
                });
              },
              child: const Text('清空默认值'),
            ),
          ],
        ),
      ),
    );
  }

  /// 加载地区数据（示例 1 和示例 4 使用）
  /// 标准字段：id, name, children
  Future<List<Map<String, dynamic>>> _loadRegionData(String? keyword) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final allData = [
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

    if (keyword == null || keyword.isEmpty) {
      return allData;
    } else {
      return _filterRegionData(allData, keyword);
    }
  }

  /// 递归过滤地区数据
  List<Map<String, dynamic>> _filterRegionData(List<Map<String, dynamic>> regions, String keyword) {
    final result = <Map<String, dynamic>>[];
    for (final region in regions) {
      final name = region['name'] as String?;
      final children = region['children'] as List<Map<String, dynamic>>?;

      // 如果当前节点匹配
      if (name?.toLowerCase().contains(keyword.toLowerCase()) ?? false) {
        result.add(region);
      } else if (children != null && children.isNotEmpty) {
        // 递归过滤子节点
        final filteredChildren = _filterRegionData(children, keyword);
        if (filteredChildren.isNotEmpty) {
          result.add({...region, 'children': filteredChildren});
        }
      }
    }
    return result;
  }

  /// 加载部门数据（示例 2 使用）
  /// 自定义字段：deptId, deptName, subDepts
  Future<List<Map<String, dynamic>>> _loadDepartmentData(String? keyword) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final allData = [
      {
        'deptId': 'dept_1',
        'deptName': '技术部',
        'subDepts': [
          {'deptId': 'dept_1_1', 'deptName': '研发部', 'subDepts': []},
          {'deptId': 'dept_1_2', 'deptName': '测试部', 'subDepts': []},
          {'deptId': 'dept_1_3', 'deptName': '产品部', 'subDepts': []},
        ],
      },
      {
        'deptId': 'dept_2',
        'deptName': '市场部',
        'subDepts': [
          {'deptId': 'dept_2_1', 'deptName': '销售部', 'subDepts': []},
          {'deptId': 'dept_2_2', 'deptName': '运营部', 'subDepts': []},
        ],
      },
      {'deptId': 'dept_3', 'deptName': '人事部', 'subDepts': []},
      {'deptId': 'dept_4', 'deptName': '财务部', 'subDepts': []},
    ];

    if (keyword == null || keyword.isEmpty) {
      return allData;
    } else {
      return _filterDepartmentData(allData, keyword);
    }
  }

  /// 递归过滤部门数据
  List<Map<String, dynamic>> _filterDepartmentData(List<Map<String, dynamic>> depts, String keyword) {
    final result = <Map<String, dynamic>>[];
    for (final dept in depts) {
      final name = dept['deptName'] as String?;
      final children = dept['subDepts'] as List<Map<String, dynamic>>?;

      if (name?.toLowerCase().contains(keyword.toLowerCase()) ?? false) {
        result.add(dept);
      } else if (children != null && children.isNotEmpty) {
        final filteredChildren = _filterDepartmentData(children, keyword);
        if (filteredChildren.isNotEmpty) {
          result.add({...dept, 'subDepts': filteredChildren});
        }
      }
    }
    return result;
  }

  /// 加载城市数据（示例 3 使用）
  /// 自定义字段：cityCode, cityName, districts
  Future<List<Map<String, dynamic>>> _loadCityData(String? keyword) async {
    // 总是缓存模式：只在首次调用
    await Future.delayed(const Duration(milliseconds: 300));

    final allData = [
      {
        'cityCode': '110000',
        'cityName': '北京市',
        'districts': [
          {'cityCode': '110100', 'cityName': '朝阳区', 'districts': []},
          {'cityCode': '110200', 'cityName': '海淀区', 'districts': []},
        ],
      },
      {
        'cityCode': '310000',
        'cityName': '上海市',
        'districts': [
          {'cityCode': '310100', 'cityName': '浦东新区', 'districts': []},
          {'cityCode': '310200', 'cityName': '黄浦区', 'districts': []},
        ],
      },
      {
        'cityCode': '440000',
        'cityName': '广东省',
        'districts': [
          {'cityCode': '440100', 'cityName': '广州市', 'districts': []},
          {'cityCode': '440300', 'cityName': '深圳市', 'districts': []},
        ],
      },
      {
        'cityCode': '330000',
        'cityName': '浙江省',
        'districts': [
          {'cityCode': '330100', 'cityName': '杭州市', 'districts': []},
          {'cityCode': '330200', 'cityName': '宁波市', 'districts': []},
        ],
      },
    ];

    if (keyword == null || keyword.isEmpty) {
      return allData;
    } else {
      return _filterCityData(allData, keyword);
    }
  }

  /// 递归过滤城市数据
  List<Map<String, dynamic>> _filterCityData(List<Map<String, dynamic>> cities, String keyword) {
    final result = <Map<String, dynamic>>[];
    for (final city in cities) {
      final name = city['cityName'] as String?;
      final children = city['districts'] as List<Map<String, dynamic>>?;

      if (name?.toLowerCase().contains(keyword.toLowerCase()) ?? false) {
        result.add(city);
      } else if (children != null && children.isNotEmpty) {
        final filteredChildren = _filterCityData(children, keyword);
        if (filteredChildren.isNotEmpty) {
          result.add({...city, 'districts': filteredChildren});
        }
      }
    }
    return result;
  }
}
