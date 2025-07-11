# 快速搭建K3S+argo CD



## K3S

#### **步骤1：安装k3s**
```bash
# 一键安装（默认使用containerd）
curl -sfL https://get.k3s.io | sh -

# 检查节点状态
sudo kubectl get nodes
```

#### **步骤2：启用常用插件**
```bash
# 启用Dashboard（Web界面）
sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# 创建访问令牌
sudo kubectl create token admin-user --duration=8760h -n kubernetes-dashboard
```

#### **步骤3：访问集群**
```bash
# 获取Dashboard访问地址（需端口转发）
sudo kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 8080:443
```
访问 `https://localhost:8080` 使用令牌登录。





## ArgoCD 

### 步骤1：安装 Argo CD

Argo CD 将安装在 K3s 集群的 `argocd` 命名空间中。

```bash
# 创建 argocd 命名空间
kubectl create namespace argocd

# 应用 Argo CD 官方安装清单 (安装核心组件)
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

**等待 Argo CD Pod 就绪：**

```bash
kubectl get pods -n argocd --watch
# 等待所有 Pod 状态变为 Running (可能需要几分钟下载镜像)
```

### 步骤2. 访问 Argo CD UI

在单节点学习环境中，有几种简单方式访问 Argo CD UI：

#### 方法 1: Port-forward 

```bash
# 将本地的 8080 端口转发到 Argo CD Server 服务的 443 端口
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

#### 方法 2: NodePort 

```bash
# 修改 argocd-server 服务的类型为 NodePort
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

# 获取分配给 argocd-server 服务的 NodePort 端口号 (查找 443 端口映射的 NodePort, 通常在 30000-32767 范围内)
kubectl get svc argocd-server -n argocd
# 输出示例：
# NAME            TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
# argocd-server   NodePort   10.43.xxx.xxx   <none>        80:3xxxx/TCP,443:3yyyy/TCP   5m
# 记录 443 对应的 NodePort (例如 3yyyy)
```

**获取初始管理员密码 (所有方法都需要):**

```bash
# 获取初始密码 (用户名是 `admin`)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

### 步骤3：部署示例应用

验证 Argo CD 工作是否正常的最佳方式就是用它部署一个应用。

1.  **在 Argo CD UI 中创建应用:**
    * 点击 "+ NEW APP"
    
    * **Application Name:** `guestbook`
    
    * **Project:** `default`
    
    * **SYNC POLICY:** `Manual` (第一次手动同步)
    
    * **Repository URL:** `https://github.com/argoproj/argocd-example-apps.git`
    
    * **Path:** `guestbook`
    
    * **Cluster URL:** `https://kubernetes.default.svc` (指向同一个集群)
    
    * **Namespace:** `default`
    
    * 点击 "CREATE"
    
      ![](ECS%E5%BF%AB%E9%80%9F%E6%90%AD%E5%BB%BAK3S+argo%20CD.assets/image-20250711154139086.png)
2.  **同步应用:**
    
    *   在 `guestbook` 应用卡片上点击 "SYNC"。
    *   在弹出窗口中，保留默认选项（同步整个应用），点击 "SYNCHRONIZE"。
    *   ![](ECS%E5%BF%AB%E9%80%9F%E6%90%AD%E5%BB%BAK3S+argo%20CD.assets/image-20250711155308783.png)
3.  **查看结果:**
    *   Argo CD 会开始同步过程。在 UI 中可以看到状态变化（Progressing -> Healthy/Synced）。
    *   同步完成后，应用状态应变为绿色（Healthy）和 Synced。
    *   你可以查看应用的资源（Deployment, Service, Pod 等）。

**暴露并访问 Guestbook 应用 (类似 Argo CD 暴露方法):**

*   使用 `kubectl port-forward` 临时访问：
    ```bash
    kubectl port-forward svc/guestbook-ui -n default 8081:80
    ```
    访问 `http://localhost:8081`
*   修改 `guestbook-ui` 服务为 `NodePort`：
    ```bash
    kubectl patch svc guestbook-ui -n default -p '{"spec": {"type": "NodePort"}}'
    kubectl get svc guestbook-ui -n default # 查找 NodePort
    ```
    访问 `http://<你的服务器公网IP>:<NodePort>`
*   创建 Ingress (需要已安装 Ingress 控制器)。

**清理示例应用 (可选):**

在 Argo CD UI 中删除 `guestbook` 应用即可（会删除所有部署的资源）。







![image-20250711155259117](ECS%E5%BF%AB%E9%80%9F%E6%90%AD%E5%BB%BAK3S+argo%20CD.assets/image-20250711155259117.png)




