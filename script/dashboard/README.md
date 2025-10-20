# Kubernetes Dashboard 安装与使用教程

##  快速安装

### 1. 运行安装脚本

```bash
# 执行一键安装脚本
sudo /opt/k8s-dashboard-install.sh
```

### 2. 获取访问信息

```bash
# 使用便捷脚本获取访问信息
/opt/dashboard-token.sh
```



##  安装内容

安装脚本将部署以下组件：

- **Dashboard主程序** (kubernetesui/dashboard:v2.7.0)
- **Metrics收集器** (kubernetesui/metrics-scraper:v1.0.8)
- **管理员用户** (admin-user ServiceAccount)
- **RBAC权限配置**
- **NodePort服务** (端口30443)



##  维护操作

### 1. 检查Dashboard状态

```bash
# 查看Pod状态
kubectl get pods -n kubernetes-dashboard

# 查看服务状态
kubectl get svc -n kubernetes-dashboard

# 查看详细信息
kubectl describe deployment kubernetes-dashboard -n kubernetes-dashboard
```

### 2. 重启Dashboard

```bash
# 重启Dashboard
kubectl rollout restart deployment kubernetes-dashboard -n kubernetes-dashboard

# 等待重启完成
kubectl rollout status deployment kubernetes-dashboard -n kubernetes-dashboard
```

### 3. 更新Dashboard

```bash
# 查看当前版本
kubectl get deployment kubernetes-dashboard -n kubernetes-dashboard -o jsonpath='{.spec.template.spec.containers[0].image}'

# 更新到新版本（示例）
kubectl set image deployment/kubernetes-dashboard kubernetes-dashboard=kubernetesui/dashboard:v2.7.0 -n kubernetes-dashboard
```

### 4. 备份配置

```bash
# 备份Dashboard配置
kubectl get all,configmap,secret -n kubernetes-dashboard -o yaml > dashboard-backup.yaml
```



##  常用命令速查

```bash
# 获取访问信息和Token
/opt/dashboard-token.sh

# 检查Dashboard状态
kubectl get pods -n kubernetes-dashboard

# 重启Dashboard
kubectl rollout restart deployment kubernetes-dashboard -n kubernetes-dashboard

# 获取新Token
kubectl -n kubernetes-dashboard create token admin-user

# 查看Dashboard日志
kubectl logs -f deployment/kubernetes-dashboard -n kubernetes-dashboard

# 删除Dashboard
kubectl delete namespace kubernetes-dashboard
```
