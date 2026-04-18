# Button 组件

一个支持异步操作的智能按钮组件

## 特性

- 自动识别同步/异步回调，异步操作时显示加载状态
- 支持直接传递文字或自定义 Widget
- Loading 状态切换时保持按钮宽度不变
- 可自定义加载动画、颜色、尺寸等

## 使用示例

### 1. 简洁用法 - 直接传递文字（同步）

```dart
Button(
  text: '点击我',
  onTap: () {
    print('同步操作');
  },
)
```

### 2. 异步操作 - 自动显示 loading

```dart
Button(
  text: '提交',
  onTap: () async {
    await http.post('/api/submit');
  },
)
```

### 3. 自定义 Widget

```dart
Button(
  child: Row(
    children: [
      Icon(Icons.send),
      Text('发送'),
    ],
  ),
  onTap: () async {
    await sendMessage();
  },
)
```

### 4. 自定义样式

```dart
Button(
  text: '确认',
  width: 200,
  height: 50,
  backgroundColor: Colors.blue,
  onTap: () => confirm(),
)
```

### 5. 自定义加载动画

```dart
Button(
  text: '保存',
  loadingWidget: Row(
    children: [
      CircularProgressIndicator(),
      SizedBox(width: 8),
      Text('保存中...'),
    ],
  ),
  onTap: () async {
    await saveData();
  },
)
```

### 6. 自定义加载文字样式

```dart
Button(
  text: '上传',
  loadingText: '上传中...',
  loadingTextColor: Colors.yellow,
  loadingTextSize: 14,
  onTap: () async {
    await uploadFile();
  },
)
```

## API 文档

### 构造函数

```dart
const Button({
  Key? key,
  dynamic Function()? onTap,
  String? text,
  Widget? child,
  Widget? loadingWidget,
  double? width,
  double? height,
  Color? backgroundColor,
  Color? disabledColor,
  String? loadingText,
  Color? loadingTextColor,
  double? loadingTextSize,
})
```

### 参数说明

| 参数               | 类型                  | 说明                         | 默认值                 |
| ------------------ | --------------------- | ---------------------------- | ---------------------- |
| `onTap`            | `dynamic Function()?` | 点击回调函数，支持同步和异步 | -                      |
| `text`             | `String?`             | 按钮显示的文字               | -                      |
| `child`            | `Widget?`             | 按钮显示的自定义 Widget      | -                      |
| `loadingWidget`    | `Widget?`             | 自定义加载状态显示的 Widget  | 旋转图标 + "处理中..." |
| `width`            | `double?`             | 按钮宽度                     | 自适应                 |
| `height`           | `double?`             | 按钮高度                     | 自适应                 |
| `backgroundColor`  | `Color?`              | 按钮背景颜色                 | ElevatedButton 默认色  |
| `disabledColor`    | `Color?`              | 禁用/加载状态的背景颜色      | `Colors.grey.shade300` |
| `loadingText`      | `String?`             | 加载状态显示的文字           | `"处理中..."`          |
| `loadingTextColor` | `Color?`              | 加载状态文字颜色             | `Colors.white`         |
| `loadingTextSize`  | `double?`             | 加载状态文字大小             | `16`                   |

> **注意**: `text` 和 `child` 必须至少提供一个，如果同时提供，优先使用 `text`

## 核心特性详解

### 自动识别同步/异步

组件会自动检测 `onTap` 回调的返回值类型：

- 如果返回 `Future`，自动进入 loading 状态
- 如果是同步函数，直接执行，不显示 loading

```dart
// 同步 - 不显示 loading
onTap: () {
  Navigator.pop(context);
}

// 异步 - 自动显示 loading
onTap: () async {
  await fetchData();
}
```

### 布局稳定性

使用 `Stack` + `Opacity` 方案，确保 loading 状态切换时按钮宽度保持不变，避免布局跳动。

### 灵活的自定义

- 通过 `loadingWidget` 完全自定义加载动画
- 通过 `loadingText`、`loadingTextColor`、`loadingTextSize` 快速调整加载文字样式
- 通过 `backgroundColor` 和 `disabledColor` 控制不同状态的颜色
