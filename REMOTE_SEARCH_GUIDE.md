# ChooseTree 远程搜索功能使用说明

## 功能概述

ChooseTree 组件现在支持完整的远程搜索功能，允许从服务器动态加载树形数据。主要特性包括：

- ✅ 弹窗打开时自动加载初始数据
- ✅ 支持实时搜索和点击搜索两种模式（可配置）
- ✅ 可配置的缓存策略（总是缓存/从不缓存/会话期间缓存）
- ✅ 加载状态显示
- ✅ 搜索框仅在远程搜索模式下显示

## 新增配置项

### 1. CacheStrategy - 缓存策略枚举

```dart
enum CacheStrategy {
  always,    // 总是缓存：首次加载后始终使用缓存，不再请求
  never,     // 从不缓存：每次都重新请求接口
  session    // 会话期间缓存：弹窗会话期间使用缓存，关闭后清除
}
```

### 2. SearchTriggerMode - 搜索触发模式枚举

```dart
enum SearchTriggerMode {
  realTime,  // 实时搜索：输入即搜索，不显示搜索按钮
  click      // 点击搜索：需要点击搜索按钮才触发搜索
}
```

### 3. ChooseTree 新增参数

```dart
ChooseTree(
  // 是否启用远程搜索模式（必填，当需要远程搜索时）
  remoteSearch: true,

  // 远程搜索方法（必填，当 remoteSearch=true 时）
  // 参数：keyword - 搜索关键字（null 表示初始加载）
  // 返回：Future<List<Map<String, dynamic>>>
  remoteMethod: (String? keyword) async {
    // 调用 API 获取数据
    final response = await api.search(keyword);
    return response.data;
  },

  // 缓存策略（可选，默认：CacheStrategy.session）
  cacheStrategy: CacheStrategy.session,

  // 搜索触发模式（可选，默认：SearchTriggerMode.realTime）
  searchTriggerMode: SearchTriggerMode.realTime,

  // ... 其他参数
)
```

## 使用示例

### 示例 1：实时搜索模式（推荐）

```dart
ChooseTree<String, Map<String, dynamic>>(
  title: '请选择地区',
  remoteSearch: true,
  remoteMethod: _searchRegions,
  cacheStrategy: CacheStrategy.session,
  searchTriggerMode: SearchTriggerMode.realTime, // 默认值，可省略
  selectType: SelectType.multiple,
  onSelectChanged: (selected) {
    print('选中：$selected');
  },
)

// 实现远程搜索方法
Future<List<Map<String, dynamic>>> _searchRegions(String? keyword) async {
  // 模拟网络延迟
  await Future.delayed(const Duration(milliseconds: 500));

  if (keyword == null || keyword.isEmpty) {
    // 初始加载：返回全部数据
    return allRegions;
  } else {
    // 搜索：根据关键字过滤
    return allRegions.where((item) =>
      item['name'].contains(keyword)
    ).toList();
  }
}
```

### 示例 2：点击搜索模式

```dart
ChooseTree<String, Map<String, dynamic>>(
  title: '请选择部门',
  remoteSearch: true,
  remoteMethod: _searchDepartments,
  cacheStrategy: CacheStrategy.never, // 每次都重新请求
  searchTriggerMode: SearchTriggerMode.click, // 显示搜索按钮
  selectType: SelectType.single,
  onSingleConfirm: (id, data) {
    print('确认选择：$id - ${data['name']}');
  },
)
```

### 示例 3：总是缓存模式（性能优化）

```dart
ChooseTree<String, Map<String, dynamic>>(
  title: '请选择城市',
  remoteSearch: true,
  remoteMethod: _searchCities,
  cacheStrategy: CacheStrategy.always, // 只请求一次
  searchTriggerMode: SearchTriggerMode.realTime,
  selectType: SelectType.multiple,
)
```

## 行为说明

### 1. 初始加载

- 当 `remoteSearch: true` 且提供了 `remoteMethod` 时
- 弹窗打开时自动调用 `remoteMethod(null)` 获取初始数据
- 显示加载动画直到数据加载完成

### 2. 搜索行为

#### 实时搜索模式 (`SearchTriggerMode.realTime`)

- 用户输入时自动触发搜索
- 不显示搜索按钮
- 默认启用防抖（300ms）
- 每次输入都调用 `remoteMethod(keyword)`

#### 点击搜索模式 (`SearchTriggerMode.click`)

- 用户输入后需要点击搜索按钮
- 显示搜索按钮
- 点击按钮时调用 `remoteMethod(keyword)`

### 3. 清除行为

- 点击清除按钮时，如果 `cacheStrategy != CacheStrategy.always`
- 自动调用 `remoteMethod(null)` 重新加载初始数据
- 如果 `cacheStrategy == CacheStrategy.always`，则使用缓存数据

### 4. 缓存策略

#### `CacheStrategy.always`（总是缓存）

- 首次调用 `remoteMethod` 后缓存数据
- 后续所有操作都使用缓存数据
- 适用于数据变化不频繁的场景

#### `CacheStrategy.never`（从不缓存）

- 每次操作都重新调用 `remoteMethod`
- 不保存任何缓存
- 适用于数据实时性要求高的场景

#### `CacheStrategy.session`（会话期间缓存，默认）

- 弹窗打开期间使用缓存
- 弹窗关闭后清除缓存
- 下次打开弹窗重新加载数据
- 平衡性能和数据新鲜度

## 注意事项

### 1. 必填验证

当设置 `remoteSearch: true` 时，必须提供 `remoteMethod` 回调函数：

```dart
// ❌ 错误：缺少 remoteMethod
ChooseTree(
  remoteSearch: true,
  // 没有 remoteMethod
)

// ✅ 正确
ChooseTree(
  remoteSearch: true,
  remoteMethod: _yourSearchMethod,
)
```

### 2. 返回值格式

`remoteMethod` 必须返回 `List<Map<String, dynamic>>` 格式的数据：

```dart
Future<List<Map<String, dynamic>>> _searchMethod(String? keyword) async {
  return [
    {
      'id': '1',
      'name': '节点名称',
      'children': [], // 可选的子节点
    },
    // ...
  ];
}
```

### 3. 字段映射

组件会自动使用默认的字段映射：

- `idField: 'id'` - ID 字段名
- `labelField: 'name'` - 显示文本字段名
- `childrenField: 'children'` - 子节点字段名

如需自定义，请在 TreeSelectConfig 中配置：

```dart
ChooseTree(
  remoteSearch: true,
  remoteMethod: _searchMethod,
  // 在 popup_view 内部通过 config.fieldMapping 使用
)
```

### 4. 错误处理

远程请求失败时会：

- 显示加载结束状态
- 在控制台打印错误信息
- 不影响 UI 正常使用

建议在 `remoteMethod` 中添加错误处理：

```dart
Future<List<Map<String, dynamic>>> _searchMethod(String? keyword) async {
  try {
    final response = await api.search(keyword);
    return response.data;
  } catch (e) {
    print('搜索失败：$e');
    return []; // 返回空数组
  }
}
```

## 向后兼容

为了保持向后兼容，组件保留了旧的远程搜索配置：

- `enableRemoteSearch` - 旧的远程搜索开关（保留）
- `onSearch` - 旧的搜索回调（保留）

**推荐使用新的配置方式**：

- 旧方式：等待用户输入后才开始搜索
- 新方式：弹窗打开时自动加载数据

## 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:lite_simple_ui/lite_simple_ui.dart';

class RemoteSearchPage extends StatefulWidget {
  const RemoteSearchPage({super.key});

  @override
  State<RemoteSearchPage> createState() => _RemoteSearchPageState();
}

class _RemoteSearchPageState extends State<RemoteSearchPage> {
  List<Map<String, dynamic>> _selectedValues = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('远程搜索示例')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ChooseTree<String, Map<String, dynamic>>(
              title: '请选择地区',
              remoteSearch: true,
              remoteMethod: _simulateRemoteSearch,
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
                child: Text('已选择：${_selectedValues.map((e) => e['name']).join(', ')}'),
              ),
          ],
        ),
      ),
    );
  }

  /// 模拟远程搜索
  Future<List<Map<String, dynamic>>> _simulateRemoteSearch(String? keyword) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    final allData = [
      {'id': '1', 'name': '上海市', 'children': []},
      {'id': '2', 'name': '北京市', 'children': []},
      {'id': '3', 'name': '广州市', 'children': []},
      {'id': '4', 'name': '深圳市', 'children': []},
    ];

    if (keyword == null || keyword.isEmpty) {
      return allData;
    } else {
      return allData
          .where((item) => item['name'].contains(keyword))
          .toList();
    }
  }
}
```

## 参考示例

查看完整的使用示例：

- 文件路径：`example_use/lib/pages/choose_tree/remote_search_example.dart`

该示例展示了：

1. 实时搜索模式的使用
2. 点击搜索模式的使用
3. 不同缓存策略的效果
4. 单选和多选模式的配置
