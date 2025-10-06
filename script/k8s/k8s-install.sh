#!/bin/bash

# Kubernetes单节点安装脚本 - Alibaba Cloud Linux 3

set -e

echo "=== Kubernetes 单节点安装开始 ==="

# 1. 系统准备
echo "1. 准备系统环境..."

# 关闭防火墙
systemctl stop firewalld 2>/dev/null || true
systemctl disable firewalld 2>/dev/null || true

# 关闭SELinux
setenforce 0 2>/dev/null || true
sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config

# 关闭swap
swapoff -a
sed -ri 's/.*swap.*/#&/' /etc/fstab

# 配置内核参数
cat <<EOF > /etc/modules-load.d/k8s.conf
br_netfilter
overlay
EOF

modprobe br_netfilter
modprobe overlay

cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

echo "系统环境准备完成"

# 2. 安装容器运行时 - containerd
echo "2. 安装containerd..."

# 安装依赖
yum install -y yum-utils device-mapper-persistent-data lvm2

# 添加Docker仓库（containerd包含在其中）
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 安装containerd
yum install -y containerd.io

# 配置containerd
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml

# 配置systemd cgroup驱动
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# 配置镜像加速
sed -i 's|registry.k8s.io/pause:3.6|registry.aliyuncs.com/google_containers/pause:3.9|' /etc/containerd/config.toml

systemctl enable containerd
systemctl start containerd

echo "containerd安装完成"

# 3. 安装kubeadm、kubelet、kubectl
echo "3. 安装Kubernetes组件..."

# 添加Kubernetes仓库
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

# 安装
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# 启用kubelet
systemctl enable kubelet

echo "Kubernetes组件安装完成"

echo "=== 安装脚本执行完成 ==="
echo "接下来请运行以下命令初始化集群："
echo "kubeadm init --image-repository registry.aliyuncs.com/google_containers --kubernetes-version v1.28.2 --pod-network-cidr=10.244.0.0/16"
