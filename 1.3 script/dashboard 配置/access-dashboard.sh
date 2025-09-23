#!/bin/bash

# 启动Kubernetes Dashboard访问脚本
# 提供多种方式访问Dashboard

echo "=========================================="
echo "Kubernetes Dashboard 访问方式"
echo "=========================================="

# 检查Dashboard是否已部署
if ! kubectl -n kubernetes-dashboard get service kubernetes-dashboard &> /dev/null; then
    echo "❌ 错误: Kubernetes Dashboard未部署"
    echo "请先部署Kubernetes Dashboard"
    exit 1
fi

echo "✅ Kubernetes Dashboard已部署"

echo ""
echo "🚀 选择访问方式:"
echo "1. kubectl proxy (推荐)"
echo "2. 端口转发"
echo "3. 显示当前token"
echo ""

read -p "请选择访问方式 (1-3): " choice

case $choice in
    1)
        echo "启动kubectl proxy..."
        echo "访问地址: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
        echo "按 Ctrl+C 停止代理"
        kubectl proxy
        ;;
    2)
        echo "启动端口转发..."
        echo "访问地址: https://localhost:8443"
        echo "按 Ctrl+C 停止转发"
        kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8443:443
        ;;
    3)
        if [ -f "admin-token.txt" ]; then
            echo "当前管理员Token:"
            cat admin-token.txt
        else
            echo "❌ admin-token.txt 文件不存在"
            echo "请先运行 ./deploy-admin-token.sh 创建token"
        fi
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac
