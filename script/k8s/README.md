# Alibaba Cloud Linux 3 单节点Kubernetes安装指南

## 🎉 安装状态

**✅ 您的Kubernetes集群已成功安装并运行！**

- **集群版本**: Kubernetes v1.28.2
- **容器运行时**: containerd 1.6.32
- **网络插件**: Flannel
- **节点状态**: Ready
- **所有系统组件**: 正常运行

## 📋 已完成的安装

1. ✅ **系统环境准备**: 防火墙、SELinux、swap、内核参数
2. ✅ **容器运行时**: containerd 1.6.32 安装配置
3. ✅ **Kubernetes组件**: kubeadm、kubelet、kubectl 1.28.2
4. ✅ **集群初始化**: Master节点配置完成
5. ✅ **网络插件**: Flannel网络插件部署
6. ✅ **单节点配置**: 移除污点，允许调度
7. ✅ **kubectl配置**: 管理员权限配置

## 🚀 快速验证

```bash
# 检查集群状态
kubectl get nodes
kubectl get pods -A

# 运行完整验证
./k8s-production-verify.sh
```

## 📚 相关文档

- **生产环境配置**: [production-guide.md](production-guide.md)
- **验证脚本**: [k8s-production-verify.sh](k8s-production-verify.sh)
- **测试应用**: [k8s-test-app.sh](k8s-test-app.sh)
- **Dashboard安装**: [k8s-dashboard-install-cn.sh](k8s-dashboard-install-cn.sh)
- **Dashboard教程**: [dashboard-tutorial.md](dashboard-tutorial.md)
- **Dashboard快速入门**: [dashboard-quickstart.md](dashboard-quickstart.md)

## 系统要求
- ✅ 内存: 最少2GB，推荐4GB+ (当前：8GB)
- ✅ CPU: 最少2核 (当前：4核)
- ✅ 磁盘: 最少20GB (当前：40GB)
- ✅ 操作系统: Alibaba Cloud Linux 3

## 安装方案对比

| 方案 | 优点 | 缺点 | 适用场景 |
|------|------|------|----------|
| **kubeadm** | 标准安装，功能完整，生产就绪 | 配置复杂，资源占用较高 | 生产环境，学习完整K8s |
| **K3s** | 轻量级，安装简单，资源占用少 | 功能精简，部分特性受限 | 边缘计算，开发测试 |
| **MicroK8s** | 安装简单，插件丰富，Ubuntu官方 | 依赖snap，在RHEL系列支持有限 | 开发环境，快速原型 |

## 推荐安装顺序

### 🎯 方案一：kubeadm (推荐生产使用)

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

### 🚀 方案二：K3s (推荐快速开始)

```bash
# 1. 运行K3s安装脚本
sudo ./k3s-install.sh

# 2. 验证安装
k3s kubectl get nodes

# 3. 配置kubectl (重新登录后生效)
source ~/.bashrc

# 4. 部署测试应用
./k8s-test-app.sh
```

### 🔧 方案三：MicroK8s

```bash
# 1. 运行MicroK8s安装脚本
sudo ./microk8s-install.sh

# 2. 重新登录以应用组权限
exit && ssh [重新连接]

# 3. 验证安装
microk8s status
microk8s kubectl get nodes

# 4. 启用更多插件
microk8s enable ingress metallb
```

## 安装后验证步骤

1. **检查节点状态**
   ```bash
   kubectl get nodes
   # 状态应该为 Ready
   ```

2. **检查系统Pods**
   ```bash
   kubectl get pods -A
   # 所有系统pods应该为 Running 状态
   ```

3. **部署测试应用**
   ```bash
   ./k8s-test-app.sh
   # 访问返回的URL验证nginx服务
   ```

## 常见问题解决

### 1. Pod无法启动
```bash
# 查看Pod详情
kubectl describe pod [pod-name]

# 查看日志
kubectl logs [pod-name]
```

### 2. 网络问题
```bash
# 重启网络插件 (kubeadm方案)
kubectl delete pods -n kube-system -l app=flannel

# 检查网络配置
kubectl get pods -n kube-system
```

### 3. 服务无法访问
```bash
# 检查服务
kubectl get svc

# 检查防火墙
systemctl status firewalld
```

## 性能优化建议

1. **资源限制配置**
   ```yaml
   resources:
     requests:
       memory: "64Mi"
       cpu: "250m"
     limits:
       memory: "128Mi"
       cpu: "500m"
   ```

2. **存储优化**
   - 使用本地存储类
   - 配置合适的存储驱动

3. **监控配置**
   ```bash
   # 安装metrics-server (kubeadm)
   kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
   
   # 启用监控 (K3s)
   k3s kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
   
   # 启用监控 (MicroK8s)
   microk8s enable metrics-server
   ```

## 卸载方法

### kubeadm卸载
```bash
kubeadm reset --force
yum remove -y kubelet kubeadm kubectl
yum remove -y containerd.io
rm -rf /etc/kubernetes/
rm -rf ~/.kube/
```

### K3s卸载
```bash
/usr/local/bin/k3s-uninstall.sh
```

### MicroK8s卸载
```bash
snap remove microk8s
```

## 下一步建议

1. **学习kubectl基础命令**
2. **部署实际应用**
3. **配置持久化存储**
4. **设置Ingress控制器**
5. **配置监控和日志**

---
*安装过程中如有问题，请查看对应的日志文件或联系管理员*# Alibaba Cloud Linux 3 单节点Kubernetes安装指南
