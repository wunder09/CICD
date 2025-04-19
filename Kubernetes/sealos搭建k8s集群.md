# sealos搭建k8s集群

sealos是一个简单高效的Kubernetes集群部署工具，支持快速部署高可用的K8s集群。

## 前置要求

1. 准备至少2台Linux服务器（1台master，1台node）
2. 所有节点需要：
   - 2GB+内存
   - 2核+CPU
   - 网络互通
   - SSH免密登录配置

## 安装步骤

### 1. 下载sealos

在主节点执行：

```bash
wget https://github.com/labring/sealos/releases/download/v4.3.0/sealos_4.3.0_linux_amd64.tar.gz
tar -zxvf sealos_4.3.0_linux_amd64.tar.gz sealos
chmod +x sealos && mv sealos /usr/bin
```

### 2. 免密确认

在目标节点上检查 `/etc/ssh/sshd_config`：

```bash
vi /etc/ssh/sshd_config
```

确认以下配置：  

```bash
// ubuntu系统  
PermitRootLogin yes   # 允许 root 登录
PasswordAuthentication yes  # 如果未配免密，需临时开启密码登录
```

重启 SSH 服务：

```
systemctl restart sshd
```

### 3. 准备Kubernetes镜像

```bash
# 直接拉取可能失败
sealos pull labring/kubernetes:v1.25.0
sealos pull labring/helm:v3.8.2
sealos pull labring/calico:v3.24.1


# 使用 sealos.hub 国内镜像源
sealos pull registry.cn-shanghai.aliyuncs.com/labring/kubernetes:v1.25.0
sealos pull registry.cn-shanghai.aliyuncs.com/labring/calico:v3.24.1
```

### 4. 安装集群

```bash
sealos run labring/kubernetes:v1.25.0 \
    --masters 192.168.0.1 \
    --nodes 192.168.0.2,192.168.0.3 \
    -p [your-ssh-password]
```

参数说明：
- `--masters`: master节点IP
- `--nodes`: node节点IP列表
- `-p`: SSH登录密码（如果配置了免密可不加）

### 5. 验证安装

```bash
kubectl get nodes
```

应该能看到所有节点状态为Ready。



## 可选组件安装

### 安装网络插件（如果未自动安装）

```bash
sealos run labring/calico:v3.24.1
```

### 安装Ingress Controller

```bash
sealos run labring/ingress-nginx:v1.5.1
```

## 其他方案

```
wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml 
# 使用阿里云镜像源下载flannel插件
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

## 管理集群

- 添加节点：
  ```bash
  sealos add --nodes 192.168.0.4,192.168.0.5
  ```

- 删除节点：
  ```bash
  sealos delete --nodes 192.168.0.4,192.168.0.5
  ```

- 清理集群：
  ```bash
  sealos reset
  ```

## 注意事项

1. 确保所有节点时间同步
2. 确保防火墙/安全组放行所需端口
3. 生产环境建议使用更高版本的Kubernetes
4. 可以使用`sealos images`查看可用镜像列表

sealos极大简化了K8s集群的部署过程，适合快速搭建测试或生产环境。