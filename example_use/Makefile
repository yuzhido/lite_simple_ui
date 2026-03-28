# Lite Simple UI Example - Makefile
# 使用方法:
#   make dev           # 开发模式运行 (热重载)
#   make apk           # 构建 Android APK
#   make windows       # 构建 Windows 应用
#   make web           # 构建 Web 应用
#   make clean         # 清理构建缓存
#   make deps          # 获取依赖
#   make test          # 运行测试
#   make help          # 显示帮助信息

.PHONY: help dev apk aab windows web ios macos linux clean deps test

# 默认目标
all: help

# 显示帮助信息
help:
	@echo ""
	@echo "Lite Simple UI Example - 构建工具"
	@echo ""
	@echo "用法：make [目标]"
	@echo ""
	@echo "可用目标:"
	@echo "  dev              开发模式运行 (热重载)"
	@echo "  apk              构建 Android APK"
	@echo "  aab              构建 Android App Bundle"
	@echo "  windows          构建 Windows 应用"
	@echo "  web              构建 Web 应用"
	@echo "  ios              构建 iOS 应用 (需 macOS)"
	@echo "  macos            构建 macOS 应用 (需 macOS)"
	@echo "  linux            构建 Linux 应用"
	@echo "  clean            清理构建缓存"
	@echo "  deps             获取依赖"
	@echo "  test             运行测试"
	@echo "  help             显示此帮助信息"
	@echo ""
	@echo "示例:"
	@echo "  make dev              # 启动开发模式"
	@echo "  make apk              # 构建 APK"
	@echo "  make clean deps       # 清理并重新获取依赖"
	@echo ""

# 检查 Flutter
dev:
	@echo "========================================"
	@flutter --version
	@echo "========================================"
	@echo "启动开发模式 (热重载)..."
	flutter run

# 构建 Android APK
apk:
	@echo "========================================"
	@flutter --version
	@echo "========================================"
	@echo "开始构建 Android APK..."
	flutter build apk --release
	@if $(errorlevel) equ 0 (\
		echo. & \
		echo ✓ APK 构建成功! & \
		echo 输出位置：build\app\outputs\flutter-apk\app-release.apk & \
		echo. & \
		echo ======================================== & \
	) else (\
		echo. & \
		echo ✗ APK 构建失败 & \
		exit /b 1 & \
	)

# 构建 Android App Bundle
aab:
	@echo "========================================"
	@flutter --version
	@echo "========================================"
	@echo "开始构建 Android App Bundle..."
	flutter build appbundle --release
	@if $(errorlevel) equ 0 (\
		echo. & \
		echo ✓ App Bundle 构建成功! & \
		echo 输出位置：build\app\outputs\bundle\release\app-release.aab & \
		echo. & \
		echo ======================================== & \
	) else (\
		echo. & \
		echo ✗ App Bundle 构建失败 & \
		exit /b 1 & \
	)

# 构建 Windows 应用
windows:
	@echo "========================================"
	@flutter --version
	@echo "========================================"
	@echo "开始构建 Windows 应用..."
	flutter build windows --release
	@if $(errorlevel) equ 0 (\
		echo. & \
		echo ✓ Windows 应用构建成功! & \
		echo 输出位置：build\windows\x64\runner\Release\ & \
		echo. & \
		echo ======================================== & \
	) else (\
		echo. & \
		echo ✗ Windows 应用构建失败 & \
		exit /b 1 & \
	)

# 构建 Web 应用
web:
	@echo "========================================"
	@flutter --version
	@echo "========================================"
	@echo "开始构建 Web 应用..."
	flutter build web --release
	@if $(errorlevel) equ 0 (\
		echo. & \
		echo ✓ Web 应用构建成功! & \
		echo 输出位置：build\web\ & \
		echo. & \
		echo ======================================== & \
	) else (\
		echo. & \
		echo ✗ Web 应用构建失败 & \
		exit /b 1 & \
	)

# 构建 iOS 应用
ios:
	@echo "========================================"
	@flutter --version
	@echo "========================================"
	@echo "开始构建 iOS 应用..."
	@echo "注意：iOS 构建需要在 macOS 系统上运行 Xcode"
	flutter build ios --release
	@if $(errorlevel) equ 0 (\
		echo. & \
		echo ✓ iOS 应用构建成功! & \
		echo. & \
		echo ======================================== & \
	) else (\
		echo. & \
		echo ✗ iOS 应用构建失败 & \
		exit /b 1 & \
	)

# 构建 macOS 应用
macos:
	@echo "========================================"
	@flutter --version
	@echo "========================================"
	@echo "开始构建 macOS 应用..."
	@echo "注意：macOS 构建需要在 macOS 系统上运行 Xcode"
	flutter build macos --release
	@if $(errorlevel) equ 0 (\
		echo. & \
		echo ✓ macOS 应用构建成功! & \
		echo. & \
		echo ======================================== & \
	) else (\
		echo. & \
		echo ✗ macOS 应用构建失败 & \
		exit /b 1 & \
	)

# 构建 Linux 应用
linux:
	@echo "========================================"
	@flutter --version
	@echo "========================================"
	@echo "开始构建 Linux 应用..."
	flutter build linux --release
	@if $(errorlevel) equ 0 (\
		echo. & \
		echo ✓ Linux 应用构建成功! & \
		echo. & \
		echo ======================================== & \
	) else (\
		echo. & \
		echo ✗ Linux 应用构建失败 & \
		exit /b 1 & \
	)

# 清理构建缓存
clean:
	@echo "========================================"
	@echo "清理构建缓存..."
	flutter clean
	@echo "删除 pubspec.lock..."
	-if exist pubspec.lock del pubspec.lock
	@echo.
	@echo ✓ 清理完成!
	@echo ========================================

# 获取依赖
deps:
	@echo "========================================"
	@echo "获取 Flutter 依赖..."
	flutter pub get
	@if $(errorlevel) equ 0 (\
		echo. & \
		echo ✓ 依赖获取成功! & \
		echo. & \
		echo ======================================== & \
	) else (\
		echo. & \
		echo ✗ 依赖获取失败 & \
		exit /b 1 & \
	)

# 运行测试
test:
	@echo "========================================"
	@echo "运行测试..."
	flutter test
	@if $(errorlevel) equ 0 (\
		echo. & \
		echo ✓ 测试通过! & \
		echo. & \
		echo ======================================== & \
	) else (\
		echo. & \
		echo ✗ 测试失败 & \
		exit /b 1 & \
	)
