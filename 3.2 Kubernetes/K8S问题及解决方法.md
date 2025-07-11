# K8S问题及解决方法

## 1.镜像拉取问题

```bash
Failed to pull image "nginx:1.19.10": failed to pull and unpack image "docker.io/library/nginx:1.19.10": failed to resolve reference "docker.io/library/nginx:1.19.10": failed to do request: Head "https://registry-1.docker.io/v2/library/nginx/manifests/1.19.10": dial tcp 108.160.170.39:443: i/o timeout
```

可能存在的原因：

1. 网络连接问题

2. Docker Hub 服务器问题

3. 镜像拉取速率限制

4. 代理配置问题

解决方法

1.  编辑 Docker 的配置文件 `/etc/docker/daemon.json`，添加阿里云镜像源的地址。

```bash
{
  "registry-mirrors": ["https://<your-aliyun-mirror>.mirror.aliyuncs.com"]
}

#检查
docker info
```

2.如果使用 Containerd 作为容器运行时

编辑 Containerd 的配置文件 `/etc/containerd/config.toml`，添加阿里云镜像源的地址。

找到 `[plugins."io.containerd.grpc.v1.cri".registry.mirrors]` 部分，添加以下内容：

```toml
[plugins."io.containerd.grpc.v1.cri".registry.mirrors]
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
    endpoint = ["https://<your-aliyun-mirror>.mirror.aliyuncs.com"]
```

3.手动拉取镜像并导入

如果网络问题无法解决，可以手动在节点上拉取镜像，然后导入到 Kubernetes 中。

```bash
// 使用 Docker 或 Containerd 手动拉取镜像：
docker pull nginx:1.19.10-alpine
// 镜像导入到 Containerd
docker save nginx:1.19.10-alpine -o nginx.tar
ctr -n k8s.io images import nginx.tar
// 检查镜像是否已导入
ctr -n k8s.io images list
```

