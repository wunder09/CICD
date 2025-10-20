#!/bin/bash

# Kubernetes集群初始化脚本
# 作者：AI助手

set -e

echo "=== 开始初始化Kubernetes集群 ==="

# 1. 初始化控制平面
echo "1. 初始化Master节点..."

kubeadm init \
  --image-repository registry.aliyuncs.com/google_containers \
  --kubernetes-version v1.28.2 \
  --pod-network-cidr=10.244.0.0/16 \
  --apiserver-advertise-address=$(hostname -I | awk '{print $1}') \
  --ignore-preflight-errors=all

echo "Master节点初始化完成"

# 2. 配置kubectl
echo "2. 配置kubectl..."

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "kubectl配置完成"

# 3. 移除master节点的污点，使其可以调度Pod
echo "3. 配置单节点集群..."

kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl taint nodes --all node-role.kubernetes.io/master- 2>/dev/null || true

echo "单节点配置完成"

# 4. 安装网络插件 - Flannel
echo "4. 安装Flannel网络插件..."

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

echo "网络插件安装完成"

# 5. 等待节点就绪
echo "5. 等待节点就绪..."

echo "等待所有pods启动..."
sleep 30

# 显示集群状态
echo "=== 集群状态 ==="
kubectl get nodes
echo ""
kubectl get pods -A

echo "=== Kubernetes单节点集群安装完成 ==="
echo ""
echo "常用命令："
echo "  kubectl get nodes           # 查看节点状态"
echo "  kubectl get pods -A         # 查看所有pods"
echo "  kubectl create deployment nginx --image=nginx  # 创建测试应用"
echo "  kubectl get svc             # 查看服务"