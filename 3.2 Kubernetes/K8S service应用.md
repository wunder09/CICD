# K8S  service

在 Kubernetes (k8s) 中，Service 是用于暴露 Pod 网络服务的抽象层，它提供了固定访问点并实现了 Pod 的负载均衡。Service 主要有以下几种类型，每种类型适用于不同的场景：




### 1. ClusterIP（默认类型）
- **功能**：在集群内部分配一个唯一的虚拟 IP 地址（仅集群内可见），用于集群内部Pod之间的通信。
- **适用场景**：仅需集群内部访问的服务，如数据库、内部API等。
- **使用示例**：
  ```yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: my-clusterip-service
  spec:
    selector:
      app: my-app  # 匹配标签为app=my-app的Pod
    ports:
    - port: 80    # Service暴露的端口
      targetPort: 8080  # 转发到Pod的端口
    type: ClusterIP  # 可省略（默认类型）
  ```


### 2. NodePort
- **功能**：在每个节点上开放一个静态端口（30000-32767范围），将外部流量通过节点端口转发到Service，再路由到Pod。
- **适用场景**：需要从集群外部临时访问服务（如开发测试环境）。
- **使用示例**：
  ```yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: my-nodeport-service
  spec:
    selector:
      app: my-app
    ports:
    - port: 80        # Service内部端口
      targetPort: 8080  # Pod端口
      nodePort: 30080   # 节点开放的端口（可选，不指定则随机分配）
    type: NodePort
  ```
  - 访问方式：`节点IP:30080`


### 3. LoadBalancer
- **功能**：借助云服务商（如AWS、GCP、Azure）的负载均衡器，自动分配一个公网IP，将外部流量转发到Service。
- **适用场景**：生产环境中需要向公网暴露服务，且依赖云厂商的负载均衡服务。
- **使用示例**：
  ```yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: my-loadbalancer-service
  spec:
    selector:
      app: my-app
    ports:
    - port: 80
      targetPort: 8080
    type: LoadBalancer
  ```
  - 访问方式：通过云厂商分配的负载均衡器公网IP访问。


### 总结
- 内部通信：优先使用 `ClusterIP` 或 `Headless Service`。
- 临时外部访问：使用 `NodePort`。
- 生产环境公网暴露（云环境）：使用 `LoadBalancer`。
- 访问外部服务：使用 `ExternalName`。

根据服务的暴露范围和场景选择合适的Service类型，可以高效管理Kubernetes集群内的网络通信。





在实现外部访问的时候遇到了一些问题：

当前服务还是K8S单节点，没有必要使用云厂商的负载均衡。

单节点 K8s 中没有多节点负载均衡的条件，因此：

1. **ClusterIP**：仅提供集群内部访问的虚拟 IP，外部无法直接访问。
2. **Ingress 控制器**：作为集群的 “入口网关”，部署在节点上并暴露端口（通常是 80/443），外部流量通过节点 IP: 端口 进入 Ingress 控制器，再由其根据规则转发到对应 ClusterIP Service。



## 遇到的问题

ingress控制器暴露的是内网ip而且无法修改，我在dns解析了公网ip，有什么方法可以将它们联系起来？



当 Ingress 控制器只能暴露内网 IP，而你需要通过公网 IP 访问时，可以通过以下几种方式将公网 IP（已做 DNS 解析）与内网的 Ingress 控制器关联起来，核心思路是**在公网 IP 和 Ingress 控制器之间建立流量转发通道**：

**方法一：利用云服务商的 "端口转发" 功能（推荐）**

几乎所有云服务商（如阿里云、腾讯云、AWS 等）都提供 **"端口转发" 或 "NAT 网关"** 功能，可直接将公网 IP 的端口映射到内网 Ingress 控制器的 IP:端口。

#### 操作步骤：
1. **确认 Ingress 控制器的内网 IP 和端口**  
   假设 Ingress 控制器在集群内的内网 IP 为 `10.0.0.10`，暴露的 HTTP 端口为 `80`（或 NodePort 如 `32080`）。

2. **在云控制台配置端口转发**  
   - 进入云服务器的 "网络控制台"（如阿里云的 ECS 安全组、腾讯云的负载均衡）。  
   - 添加转发规则：  
     `公网 IP:80 → 内网 IP:80`（或对应 NodePort，如 `10.0.0.10:32080`）  
     `公网 IP:443 → 内网 IP:443`（如需 HTTPS）。

3. **验证**  
   此时通过 DNS 解析到公网 IP 的域名（如 `example.com`），即可直接访问 `http://example.com` 或 `https://example.com`，流量会自动转发到内网 Ingress 控制器。

**方法二：在节点上部署反向代理（适用于无云服务转发功能）**

若云服务商不支持端口转发，可在单节点（或另一个有公网 IP 的服务器）上部署 Nginx 作为反向代理，将公网流量转发到内网 Ingress 控制器。

#### 操作步骤
1. **在有公网 IP 的节点上安装 Nginx**  
   ```bash
   # 以 Ubuntu 为例
   sudo apt update && sudo apt install nginx
   ```

2. **配置 Nginx 反向代理**  
   创建配置文件 `/etc/nginx/conf.d/ingress-proxy.conf`：  
   ```nginx
   server {
       listen 80;
       server_name example.com;  # 你的域名（已解析到公网 IP）

       # 将所有流量转发到内网 Ingress 控制器
       location / {
           proxy_pass http://10.0.0.10:80;  # 内网 Ingress 控制器的 IP:端口
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }

   # 如需 HTTPS，添加 443 端口配置（需提前准备证书）
   server {
       listen 443 ssl;
       server_name example.com;

       ssl_certificate /path/to/cert.pem;   # 证书路径
       ssl_certificate_key /path/to/key.pem; # 私钥路径

       location / {
           proxy_pass http://10.0.0.10:443;  # 内网 Ingress 控制器的 HTTPS 端口
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

3. **重启 Nginx 生效**  
   ```bash
   sudo nginx -t  # 验证配置
   sudo systemctl restart nginx
   ```

4. **开放防火墙端口**  
   确保节点开放 80/443 端口，允许外部访问：  
   ```bash
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   ```

**方法三：使用 SSH 隧道临时转发（仅测试场景）**

如果只是临时测试，可通过 SSH 隧道将本地端口转发到内网 Ingress 控制器（需在有公网 IP 的节点上操作）：  
```bash
# 将本地 80 端口转发到内网 Ingress 控制器的 80 端口
ssh -N -L 0.0.0.0:80:10.0.0.10:80 root@localhost
```
- `0.0.0.0:80`：监听公网 IP 的 80 端口  
- `10.0.0.10:80`：内网 Ingress 控制器的 IP:端口  
- 此方法适合临时调试，生产环境不推荐（隧道不稳定）。


### 关键配置验证
1. **确认 DNS 解析正确**：  
   通过 `nslookup example.com` 检查域名是否指向你的公网 IP。

2. **检查流量链路**：  
   公网请求 → 公网 IP:80/443 →（转发）→ 内网 Ingress 控制器 IP:端口 → Ingress 规则 → ClusterIP Service → Pod。

3. **排查防火墙**：  
   确保云服务器安全组、节点防火墙均开放 80/443 端口，且允许外部访问。


通过以上方法，即可将 DNS 解析的公网 IP 与内网 Ingress 控制器关联，实现外部通过域名访问集群内服务。生产环境优先选择**方法一（云服务端口转发）**，配置简单且稳定性高。

