# Lite Simple UI Example - 构建工具使用指南

## 📦 已创建的文件

1. **build.ps1** - PowerShell 构建脚本（主要使用）
2. **build.bat** - 批处理文件（最简单，无需配置）
3. **Makefile** - GNU Make 格式（需要安装 make）
4. **setup_alias.ps1** - PowerShell 别名设置脚本

---

## 🚀 使用方法

### 方法一：使用批处理文件（最简单 ⭐推荐）

直接使用 `build.bat`，无需任何配置：

```cmd
build.bat dev           # 开发模式运行
build.bat apk           # 构建 Android APK
build.bat windows       # 构建 Windows 应用
build.bat web           # 构建 Web 应用
build.bat clean         # 清理缓存
build.bat deps          # 获取依赖
build.bat test          # 运行测试
build.bat help          # 显示帮助
```

**组合命令示例：**

```cmd
build.bat clean & build.bat deps      # 清理并重新获取依赖
build.bat clean & build.bat deps & build.bat apk   # 完整构建流程
```

---

### 方法二：使用 PowerShell 脚本

#### 方式 A：直接使用脚本

```powershell
.\build.ps1 dev           # 开发模式
.\build.ps1 apk           # 构建 APK
.\build.ps1 windows       # 构建 Windows 应用
.\build.ps1 clean         # 清理
```

#### 方式 B：设置别名后使用（类似 make 命令）

1. **临时设置（仅当前会话有效）：**

```powershell
function make { .\build.ps1 $args }
make dev                  # 开发模式
make apk                  # 构建 APK
```

2. **永久设置（添加到 PowerShell 配置文件）：**

```powershell
# 查看配置文件路径
echo $PROFILE

# 用记事本打开该文件，添加以下内容：
function make { .\build.ps1 $args }

# 保存后重启 PowerShell，就可以直接使用：
make dev
make apk
make windows
```

---

### 方法三：使用 Makefile（需要安装 GNU Make）

1. **安装 GNU Make for Windows：**

使用 Chocolatey（推荐）：

```cmd
choco install make
```

或手动下载：https://gnuwin32.sourceforge.net/packages/make.htm

2. **安装后使用：**

```bash
make dev              # 开发模式
make apk              # 构建 APK
make windows          # 构建 Windows 应用
make web              # 构建 Web 应用
make clean            # 清理
make deps             # 获取依赖
make test             # 运行测试
```

---

## 📋 可用命令列表

| 命令      | 说明                        | 输出位置                                           |
| --------- | --------------------------- | -------------------------------------------------- |
| `dev`     | 开发模式（热重载）          | -                                                  |
| `apk`     | 构建 Android APK            | `build\app\outputs\flutter-apk\app-release.apk`    |
| `aab`     | 构建 Android App Bundle     | `build\app\outputs\bundle\release\app-release.aab` |
| `windows` | 构建 Windows 应用           | `build\windows\x64\runner\Release\`                |
| `web`     | 构建 Web 应用               | `build\web\`                                       |
| `ios`     | 构建 iOS 应用（需 macOS）   | -                                                  |
| `macos`   | 构建 macOS 应用（需 macOS） | -                                                  |
| `linux`   | 构建 Linux 应用             | -                                                  |
| `clean`   | 清理构建缓存                | -                                                  |
| `deps`    | 获取 Flutter 依赖           | -                                                  |
| `test`    | 运行测试                    | -                                                  |
| `help`    | 显示帮助信息                | -                                                  |

---

## 🔧 常见问题

### Q: 为什么执行 build.ps1 时报错"禁止运行脚本"？

A: 这是 PowerShell 的安全策略。解决方法：

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Q: 如何快速启动开发模式？

A: 推荐使用批处理文件：

```cmd
build.bat dev
```

或使用设置了别名的 PowerShell：

```powershell
make dev
```

### Q: 如何清理并重新构建？

A:

```cmd
# 批处理方式
build.bat clean & build.bat deps & build.bat apk

# PowerShell 方式
.\build.ps1 clean; .\build.ps1 deps; .\build.ps1 apk

# Make 方式
make clean deps apk
```

---

## 💡 最佳实践

1. **首次使用项目时：**

```cmd
build.bat deps
build.bat dev
```

2. **准备发布时：**

```cmd
build.bat clean
build.bat deps
build.bat apk
```

3. **日常开发：**

```cmd
build.bat dev
```

---

## 📝 注意事项

- ✅ 确保 Flutter 已安装并添加到系统 PATH
- ✅ 构建 Windows 应用需要在 Windows 10/11 上
- ✅ 构建 Android 应用需要 Android SDK
- ⚠️ iOS/macOS 构建只能在 macOS 系统上进行
- 💾 构建产物都在 `build/` 目录下

---

## 🎯 快速参考

最简单的使用方式：

```cmd
build.bat dev       # 开发
build.bat apk       # 打包 APK
build.bat clean     # 清理
```

就这么简单！🎉
