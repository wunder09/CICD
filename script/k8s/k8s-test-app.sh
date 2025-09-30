#!/bin/bash

# Kubernetes测试应用部署脚本
# 作者：AI助手

set -e

echo "=== 部署测试应用 ==="

# 1. 创建nginx部署
echo "1. 创建nginx部署..."

kubectl create deployment nginx-test --image=nginx:latest --replicas=2

echo "nginx部署创建完成"

# 2. 暴露服务
echo "2. 创建服务..."

kubectl expose deployment nginx-test --port=80 --target-port=80 --type=NodePort

echo "服务创建完成"

# 3. 等待Pod就绪
echo "3. 等待Pod就绪..."

kubectl wait --for=condition=ready pod -l app=nginx-test --timeout=300s

# 4. 显示部署状态
echo "4. 显示部署状态..."

echo "=== 部署状态 ==="
kubectl get deployments
echo ""
kubectl get pods
echo ""
kubectl get services

# 5. 获取访问信息
echo ""
echo "=== 访问信息 ==="
NODE_PORT=$(kubectl get service nginx-test -o jsonpath='{.spec.ports[0].nodePort}')
NODE_IP=$(hostname -I | awk '{print $1}')

echo "应用访问地址: http://${NODE_IP}:${NODE_PORT}"
echo ""
echo "测试命令:"
echo "  curl http://${NODE_IP}:${NODE_PORT}"
echo ""
echo "清理命令:"
echo "  kubectl delete deployment nginx-test"
echo "  kubectl delete service nginx-test"