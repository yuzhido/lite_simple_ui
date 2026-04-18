# DropdownChoose 下拉选择组件

## 简介

DropdownChoose 是一个基于底部弹窗的选择组件，提供灵活的数据展示和选择功能。通过回调函数的方式，支持任意数据类型的展示和选择。

## 特性

- ✅ **类型安全**：使用泛型确保编译时类型检查
- ✅ **灵活配置**：通过回调函数自定义显示文本和返回值
- ✅ **无需转换**：直接使用原始业务数据，无需额外封装
- ✅ **易于维护**：清晰的 API 设计，降低学习成本

## 使用方法

### 基本用法

```dart
import 'package:lite_simple_ui/lite_simple_ui.dart';

// 定义数据模型
class UserInfo {
  final String name;
  final int age;
  final int id;

  UserInfo({required this.name, required this.age, required this.id});
}

// 使用下拉选择
List<UserInfo> users = [
  UserInfo(name: '张三', age: 18, id: 1),
  UserInfo(name: '李四', age: 19, id: 2),
  UserInfo(name: '王五', age: 20, id: 3),
];

final selectedId = await BottomModalSheet.show<UserInfo>(
  context,
  title: '请选择用户',
  options: users,
  displayText: (user) => user.name,      // 指定显示字段
  valueExtractor: (user) => user.id,     // 指定返回值
);

print('选中的用户ID: $selectedId');
```

### 参数说明

#### BottomModalSheet.show()

| 参数              | 类型                           | 必需 | 说明                                 |
| ----------------- | ------------------------------ | ---- | ------------------------------------ |
| `context`         | `BuildContext`                 | ✅   | Flutter 上下文                       |
| `options`         | `List<T>`                      | ✅   | 备选数据列表                         |
| `displayText`     | `String Function(T)`           | ✅   | 显示文本提取函数                     |
| `valueExtractor`  | `dynamic Function(T)`          | ❌   | 值提取函数，默认为返回数据项本身     |
| `title`           | `String?`                      | ❌   | 弹窗标题，默认为"请选择相关备选数据" |
| `showAdd`         | `bool?`                        | ❌   | 是否显示添加按钮                     |
| `remote`          | `bool?`                        | ❌   | 是否通过远程接口获取数据             |
| `forceRefresh`    | `bool?`                        | ❌   | 是否强制刷新                         |
| `remoteMethod`    | `Future<List<T>?> Function()?` | ❌   | 远程获取数据方法                     |
| `height`          | `double?`                      | ❌   | 弹窗高度                             |
| `backgroundColor` | `Color?`                       | ❌   | 背景颜色                             |
| `onDismissed`     | `VoidCallback?`                | ❌   | 关闭回调                             |

### 高级用法

#### 1. 复杂对象展示

```dart
class Product {
  final String name;
  final double price;
  final String category;

  Product({required this.name, required this.price, required this.category});
}

final selectedProduct = await BottomModalSheet.show<Product>(
  context,
  title: '选择商品',
  options: products,
  displayText: (product) => '${product.name} - ¥${product.price}',
  valueExtractor: (product) => product,  // 返回完整对象
);
```

#### 2. 自定义返回值

```dart
// 只返回 ID
final userId = await BottomModalSheet.show<User>(
  context,
  options: users,
  displayText: (user) => user.name,
  valueExtractor: (user) => user.id,
);

// 返回完整对象
final user = await BottomModalSheet.show<User>(
  context,
  options: users,
  displayText: (user) => user.name,
  valueExtractor: (user) => user,  // 或不传此参数，默认返回对象本身
);
```

#### 3. 远程数据加载

```dart
final result = await BottomModalSheet.show<ApiData>(
  context,
  title: '选择数据',
  options: [],  // 初始为空
  remote: true,
  remoteMethod: () async {
    // 从 API 获取数据
    final response = await http.get(Uri.parse('https://api.example.com/data'));
    return parseData(response.body);
  },
  displayText: (item) => item.name,
  valueExtractor: (item) => item.id,
);
```

## 设计思路

### 为什么使用回调函数而不是封装模型？

我们对比了三种方案：

1. **封装模型方案**（旧方案）

   ```dart
   // 需要手动转换
   List<ChooseDataModel<UserInfo, int>> users = originalUsers
     .map((u) => ChooseDataModel(data: u, name: u.name, value: u.id))
     .toList();
   ```

   - ❌ 代码冗余
   - ❌ 维护成本高

2. **Map 配置方案**

   ```dart
   BottomModalSheet.show(
     options: users,
     displayField: 'name',
     valueField: 'id',
   );
   ```

   - ❌ 失去类型安全
   - ❌ 运行时错误风险

3. **回调函数方案**（当前方案）✅
   ```dart
   BottomModalSheet.show(
     options: users,
     displayText: (user) => user.name,
     valueExtractor: (user) => user.id,
   );
   ```

   - ✅ 类型安全
   - ✅ 灵活性强
   - ✅ IDE 友好
   - ✅ 易于维护

## 注意事项

1. **displayText 是必需的**：必须提供如何从数据项中提取显示文本的逻辑
2. **valueExtractor 可选**：如果不提供，默认返回数据项本身
3. **返回值类型**：返回值的类型由 `valueExtractor` 的返回值决定
4. **空数据处理**：如果 `options` 为空列表，会显示"暂无数据"提示

## 示例代码

完整示例请参考：

- [lib/src/dropdown_choose/index.dart](../../../lib/src/dropdown_choose/index.dart)
- [example/lib/pages/dropdown_choose/index.dart](../../../example/lib/pages/dropdown_choose/index.dart)

## 更新日志

### v1.0.0 (最新)

- ✨ 重构为回调函数方式
- ✨ 支持泛型类型安全
- ✨ 简化使用流程，无需数据转换
- 🐛 修复返回值逻辑
