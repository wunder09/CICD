#!/bin/bash

# 获取Kubernetes Dashboard长期有效管理员Token脚本
# 用于快速获取已创建的长期有效管理员token

echo "=========================================="
echo "获取Kubernetes Dashboard长期有效管理员Token"
echo "=========================================="

# 检查Secret是否存在
if ! kubectl -n kube-system get secret dashboard-admin-token &> /dev/null; then
    echo "❌ 错误: Secret 'dashboard-admin-token' 不存在"
    echo "请先运行 ./deploy-admin-token.sh 创建长期有效管理员Token"
    exit 1
fi

echo "✅ Secret 'dashboard-admin-token' 存在"

# 获取长期有效的token
echo "🔑 正在获取长期有效的管理员token..."
TOKEN=$(kubectl -n kube-system get secret dashboard-admin-token -o jsonpath="{.data.token}" | base64 --decode)

if [ -n "$TOKEN" ]; then
    echo "✅ 长期有效管理员Token获取成功"
    echo ""
    echo "=========================================="
    echo "🎯 长期有效管理员Token:"
    echo "=========================================="
    echo "$TOKEN"
    echo "=========================================="
    
    # 保存token到文件
    echo "$TOKEN" > admin-token.txt
    echo "长期有效Token已保存到 admin-token.txt"
else
    echo "❌ Token获取失败"
    exit 1
fi
