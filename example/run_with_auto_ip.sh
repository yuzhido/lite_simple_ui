#!/bin/bash

# Flutter 运行脚本 - 自动获取局域网 IP
# 使用方法: ./run_with_auto_ip.sh [device_id]

echo "🔍 正在获取局域网 IP..."

# 获取局域网 IP（排除 127.0.0.1）
LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -n 1)

if [ -z "$LOCAL_IP" ]; then
    echo "❌ 无法获取局域网 IP，请手动配置"
    exit 1
fi

echo "✅ 检测到局域网 IP: $LOCAL_IP"
echo ""

# 检查参数
DEVICE_PARAM=""
if [ ! -z "$1" ]; then
    DEVICE_PARAM="-d $1"
    echo "📱 目标设备: $1"
fi

echo "🚀 启动 Flutter 应用..."
echo "   API Host: $LOCAL_IP"
echo "   API Port: 3000"
echo ""

# 运行 Flutter，通过 --dart-define 传递环境变量
flutter run \
    --dart-define=API_HOST=$LOCAL_IP \
    --dart-define=API_PORT=3000 \
    $DEVICE_PARAM
