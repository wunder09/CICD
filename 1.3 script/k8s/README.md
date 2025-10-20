# Kubernetes安装指南

##  安装状态

- **集群版本**: Kubernetes v1.28.2

- **容器运行时**: containerd 1.6.32

- **网络插件**: Flannel

- **节点状态**: Ready

- **所有系统组件**: 正常运行

  

##  已完成的安装

1. ✅ **系统环境准备**: 防火墙、SELinux、swap、内核参数
2. ✅ **容器运行时**: containerd 1.6.32 安装配置
3. ✅ **Kubernetes组件**: kubeadm、kubelet、kubectl 1.28.2
4. ✅ **集群初始化**: Master节点配置完成
5. ✅ **网络插件**: Flannel网络插件部署
6. ✅ **单节点配置**: 移除污点，允许调度
7. ✅ **kubectl配置**: 管理员权限配置

##  快速验证

```bash
# 检查集群状态
kubectl get nodes
kubectl get pods -A

# 运行完整验证
./k8s-production-verify.sh
```



## 系统要求
- ✅ 内存: 最少2GB，推荐4GB+ 
- ✅ CPU: 最少2核 
- ✅ 磁盘: 最少20GB 
- ✅ 操作系统: Alibaba Cloud Linux 3   (ali 4 不可安装)



## 安装

```bash
# 1. 运行安装脚本
sudo ./k8s-install.sh

# 2. 初始化集群
sudo ./k8s-init.sh

# 3. 验证安装
kubectl get nodes
kubectl get pods -A

# 4. 部署测试应用
./k8s-test-app.sh
```


