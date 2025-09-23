#!/bin/bash

# Kubernetes Dashboard 长期有效管理员Token一键部署脚本
# 适用于测试环境，创建长期有效且不会改变的管理员token

echo "=========================================="
echo "Kubernetes Dashboard 长期有效管理员Token"
echo "=========================================="

# 检查kubectl是否可用
if ! command -v kubectl &> /dev/null; then
    echo "❌ 错误: kubectl 命令未找到，请确保已安装kubectl"
    exit 1
fi

# 检查kubectl连接
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ 错误: 无法连接到Kubernetes集群，请检查kubeconfig配置"
    exit 1
fi

echo "✅ kubectl 连接正常"

# 应用管理员权限配置
echo "📝 正在创建ServiceAccount和ClusterRoleBinding..."
kubectl apply -f dashboard-admin.yaml

if [ $? -eq 0 ]; then
    echo "✅ ServiceAccount和ClusterRoleBinding创建成功"
else
    echo "❌ 创建失败，请检查配置文件"
    exit 1
fi

# 创建长期有效的Secret
echo "🔐 正在创建长期有效的Secret..."
kubectl apply -f dashboard-admin-secret.yaml

if [ $? -eq 0 ]; then
    echo "✅ 长期有效Secret创建成功"
else
    echo "❌ Secret创建失败，请检查配置文件"
    exit 1
fi

# 等待Secret创建完成
echo "⏳ 等待Secret创建完成..."
sleep 3

# 获取长期有效的token
echo "�� 正在获取长期有效的管理员token..."
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
    echo "💾 长期有效Token已保存到 admin-token.txt"
    
    echo ""
    echo "🌟 Token特点:"
    echo "   ✅ 长期有效，不会过期"
    echo "   ✅ Token不会改变，除非删除重建"
    echo "   ✅ 具有cluster-admin超级管理员权限"
    echo "   ✅ 适合测试环境使用"
    echo ""
    echo "🚀 使用方法:"
    echo "   1. 启动kubectl代理: kubectl proxy"
    echo "   2. 访问Dashboard: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
    echo "   3. 选择'Token'登录方式，粘贴上面的token"
    echo ""
    echo "   或者使用端口转发:"
    echo "   kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8443:443"
    echo "   然后访问: https://localhost:8443"
    echo "=========================================="
    
    echo ""
    echo "🔧 管理命令:"
    echo "   查看Secret: kubectl -n kube-system get secret dashboard-admin-token"
    echo "   重新获取Token: ./get-admin-token.sh"
    echo "   删除配置: kubectl delete -f dashboard-admin.yaml -f dashboard-admin-secret.yaml"
else
    echo "❌ Token获取失败"
    exit 1
fi
