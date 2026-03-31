# ConfigForm 配置表单组件

一个高度可配置的 Flutter 表单组件，支持多种验证方式、灵活的布局风格和智能验证器。

## 功能特性

✅ **多种表单类型**：支持下拉选择、树形选择、自定义组件
✅ **智能验证系统**：内置常用验证器（手机号、邮箱、身份证等）
✅ **灵活的验证触发**：支持失焦、实时、提交时验证的组合
✅ **两种布局风格**：纵向布局和横向布局
✅ **高度自定义**：Label、内容区、清除按钮都可自定义
✅ **表单控制器**：统一管理表单状态、验证、重置等操作
✅ **错误提示**：根据布局风格智能显示错误信息

## 快速开始

### 1. 基础使用（纵向布局）

```dart
import 'package:lite_simple_ui/lite_simple_ui.dart';

final _controller = ConfigFormController();

final _formItems = [
  // 必填 + 手机号验证
  FormItem(
    property: 'phone',
    label: '手机号',
    formType: FormType.custom,
    required: true,
    valueType: ValidateType.phone,
    validateTriggers: {ValidateTrigger.onBlur},
    customBuilder: () => TextField(
      decoration: InputDecoration(
        hintText: '请输入手机号',
        border: OutlineInputBorder(),
      ),
    ),
  ),

  // 必填 + 邮箱验证 + 实时验证
  FormItem(
    property: 'email',
    label: '邮箱',
    formType: FormType.custom,
    required: true,
    valueType: ValidateType.email,
    validateTriggers: {
      ValidateTrigger.onChanged,
      ValidateTrigger.onBlur,
      ValidateTrigger.onSubmit, // 提交时也需要验证
    },
    customBuilder: () => TextField(
      decoration: InputDecoration(
        hintText: '请输入邮箱',
        border: OutlineInputBorder(),
      ),
    ),
  ),
];

@override
Widget build(BuildContext context) {
  return ConfigForm(
    items: _formItems,
    controller: _controller,
    config: FormConfig(layout: LayoutStyle.vertical),
  );
}
```

### 2. 横向布局 + 自定义 Label 和清除按钮

```dart
final _formItems = [
  FormItem(
    property: 'icon',
    label: '图标',
    formType: FormType.custom,
    required: false,
    // 自定义 Label
    labelBuilder: (context, {required hasError, required isRequired}) {
      return Row(
        children: [
          Icon(Icons.image, color: Colors.grey),
          SizedBox(width: 8),
          Text('图标'),
        ],
      );
    },
    // 自定义内容区
    contentBuilder: (context, value, onChanged) {
      return TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: '图标 URL',
          prefixIcon: Icon(Icons.link),
        ),
      );
    },
    // 自定义清除按钮
    clearButtonBuilder: (onClear) {
      return IconButton(
        icon: Icon(Icons.cancel, color: Colors.red),
        onPressed: onClear,
      );
    },
  ),
];

ConfigForm(
  items: _formItems,
  config: FormConfig(
    layout: LayoutStyle.horizontal,
    labelWidth: 100,
  ),
)
```

### 3. 表单验证和提交

```dart
// 提交时验证所有字段
ElevatedButton(
  onPressed: () {
    final isValid = _controller.validateAll();
    if (isValid) {
      // 验证通过，获取表单值
      final values = _controller.getAllValues();
      print('表单值：$values');
    } else {
      print('验证失败');
    }
  },
  child: Text('提交'),
)

// 重置表单
TextButton(
  onPressed: () => _controller.reset(),
  child: Text('重置'),
)

// 清除单个字段
_controller.clearField('phone');
```

**⚠️ 重要提示：**

- `validateAll()` 只会验证配置了 `ValidateTrigger.onSubmit` 的字段
- 必须为需要提交验证的字段添加 `ValidateTrigger.onSubmit` 到 `validateTriggers`
- 推荐配置：`validateTriggers: {ValidateTrigger.onBlur, ValidateTrigger.onSubmit}`

## 验证类型（ValidateType）

内置以下验证器：

- `ValidateType.string`：字符串（默认）
- `ValidateType.int`：整数
- `ValidateType.double`：浮点数
- `ValidateType.email`：邮箱
- `ValidateType.phone`：手机号
- `ValidateType.url`：URL
- `ValidateType.idCard`：身份证
- `ValidateType.postalCode`：邮编

## 验证触发器（ValidateTrigger）

支持组合使用：

- `ValidateTrigger.onBlur`：失焦验证
- `ValidateTrigger.onChanged`：实时验证
- `ValidateTrigger.onSubmit`：提交验证

```dart
// 组合使用
validateTriggers: {
  ValidateTrigger.onChanged,  // 输入时验证
  ValidateTrigger.onBlur,     // 失焦时验证
}
```

## 验证器优先级

1. **自定义 validator**（最高优先级）
2. **valueType 类型验证器**
3. **required 非空验证**（最低优先级）

```dart
// 示例：使用自定义 validator 覆盖默认验证
FormItem(
  property: 'customPhone',
  label: '自定义手机',
  required: true,
  valueType: ValidateType.phone,  // 这个会被下面的 validator 覆盖
  validator: (value) {
    if (value == null || value.isEmpty) {
      return '手机号不能为空';
    }
    // 自定义验证规则：允许带国际区号
    final phoneRegex = RegExp(r'^(\+86)?1[3-9]\d{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return '请输入正确的手机号（支持 +86 区号）';
    }
    return null;
  },
)
```

## 布局风格

### 纵向布局（LayoutStyle.vertical）

- Label 在上，输入在下
- 错误信息显示在 label 后面 + 内容下方
- 适合复杂表单和移动端

### 横向布局（LayoutStyle.horizontal）

- Label 和输入在同一行
- 错误信息显示在输入框下方
- 输入框边框变红提示错误
- 右侧可显示清除按钮
- 适合简单表单和桌面端

## 表单控制器（ConfigFormController）

常用方法：

```dart
// 获取/设置值
dynamic getValue(String property);
void setValue(String property, dynamic value);
Map<String, dynamic> getAllValues();

// 重置
void reset();              // 重置所有字段
void resetField(String property);  // 重置单个字段
void clearField(String property);  // 清除单个字段值

// 验证
String? validateField(String property);  // 验证单个字段
bool validateAll();                      // 验证所有字段

// 错误管理
String? getError(String property);
bool hasError(String property);
void clearErrors();
void clearError(String property);
```

## 完整示例

查看 `example/config_form_example.dart` 获取完整使用示例。

## 注意事项

1. **FormItem 的 property 必须唯一**
2. **验证器返回 null 表示验证通过**
3. **横向布局需要设置 labelWidth 以获得最佳效果**
4. **使用控制器时记得在 dispose 中释放**

```dart
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

## TODO

- [ ] 集成 DropdownChoose 组件
- [ ] 集成 ChooseTree 组件
- [ ] 添加更多内置验证器
- [ ] 支持表单联动
- [ ] 支持动态添加/删除表单项
