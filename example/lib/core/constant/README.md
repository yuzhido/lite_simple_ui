# API 配置说明

## 🚀 快速开始（推荐）

### 方法 1：使用自动获取 IP 脚本（最简单）

**macOS/Linux:**

```bash
cd example
./run_with_auto_ip.sh
```

**Windows:**

```cmd
cd example
run_with_auto_ip.bat
```

脚本会自动：

- ✅ 检测当前电脑的局域网 IP
- ✅ 启动 Flutter 应用并传入正确的 IP
- ✅ 显示配置信息

### 方法 2：手动指定设备

```bash
# 查看可用设备
flutter devices

# 指定设备运行
./run_with_auto_ip.sh emulator-5554
```

---

## 📝 配置文件位置

`example/lib/core/constant/index.dart`

## 🔧 如何修改 API 地址

### 方式 1：通过命令行参数（推荐）

使用 `--dart-define` 在运行时传递配置：

```bash
flutter run \
  --dart-define=API_HOST=192.168.1.100 \
  --dart-define=API_PORT=3000
```

### 方式 2：修改默认值

如果不想每次都用命令行，可以修改 `ApiConfig` 类中的默认值：

```dart
static const String _localNetworkIP = String.fromEnvironment(
  'API_HOST',
  defaultValue: '192.168.8.75', // 修改这里的默认值
);

static const int _port = int.fromEnvironment(
  'API_PORT',
  defaultValue: 3000, // 修改这里的默认端口
);
```

### 方式 3：修改 API 前缀

如果 API 路径前缀不是 `/api`，请修改 `_apiPrefix`：

```dart
static const String _apiPrefix = '/api'; // 改成您的前缀
```

## 💡 工作原理

`ApiConfig.baseUrl` 会根据运行平台自动选择合适的 API 地址：

- **Web 平台** (`kIsWeb`): 使用 `http://localhost:3000/api`
- **Android/iOS**: 使用 `http://{API_HOST}:3000/api`（从环境变量或默认值获取）
- **macOS/Windows/Linux**: 使用 `http://localhost:3000/api`

配置优先级：

1. 命令行参数 `--dart-define=API_HOST=xxx` （最高优先级）
2. 代码中的 `defaultValue` （默认值）

## 🔍 获取当前电脑的 IP 地址

### macOS

```bash
# 方法 1
ifconfig | grep "inet " | grep -v 127.0.0.1

# 方法 2（更精确）
ipconfig getifaddr en0
```

### Linux

```bash
ip addr show | grep "inet " | grep -v 127.0.0.1
```

### Windows

```cmd
ipconfig | findstr "IPv4"
```

### 查看服务器启动输出

mock_data 服务器启动时会显示：

```
🌐 Server URLs:
   • Local:   http://localhost:3000
   • Network: http://192.168.8.75:3000  ← 使用这个 IP
```

## ⚠️ 注意事项

1. **确保设备在同一网络**：移动设备必须与开发电脑在同一 Wi-Fi 网络下
2. **防火墙设置**：确保防火墙允许 3000 端口的入站连接
3. **IP 变化**：如果重启路由器或切换网络，IP 可能会变化
   - 使用自动脚本可以避免这个问题
   - 或每次运行前检查服务器输出的 IP
4. **生产环境**：生产环境应该使用域名或固定的服务器地址
5. **调试信息**：应用启动时会在控制台打印当前使用的配置

## 📌 使用示例

### 在代码中使用

```dart
import '../../core/constant/index.dart';

// 自动根据平台获取正确的 URL
final String baseUrl = ApiConfig.baseUrl;

// 或者使用带版本的完整 URL
final String fullUrl = ApiConfig.baseUrlWithVersion;

// 打印配置信息（用于调试）
ApiConfig.printConfig();
```

### 运行应用

```bash
# 方法 1：使用自动脚本（推荐）
./run_with_auto_ip.sh

# 方法 2：手动指定 IP
flutter run --dart-define=API_HOST=192.168.8.75

# 方法 3：指定设备和 IP
flutter run -d emulator-5554 --dart-define=API_HOST=192.168.8.75
```

## 🎯 最佳实践

1. **开发阶段**：使用 `run_with_auto_ip.sh` 脚本，自动获取 IP
2. **团队协作**：将脚本加入版本控制，每个人都可以直接使用
3. **CI/CD**：在构建脚本中使用 `--dart-define` 传递配置
4. **生产发布**：修改默认值为生产服务器地址
