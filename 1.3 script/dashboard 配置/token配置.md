# Dashboard 长期token

##  文件说明

### 配置文件
- **dashboard-admin.yaml** - ServiceAccount和ClusterRoleBinding配置
- **dashboard-admin-secret.yaml** - 长期有效Secret配置

### 脚本文件
- **deploy-admin-token.sh** - 一键部署长期有效管理员token（推荐）
- **get-admin-token.sh** - 获取已创建的长期有效token
- **access-dashboard.sh** - Dashboard访问方式选择脚本





##  快速开始

### 1. 部署长期有效管理员Token
```bash
./deploy-admin-token.sh
```

### 2. 访问Dashboard
```bash
#   已在部署文件里修改 
#  现在使用访问https://114.55.97.189:30443
./access-dashboard.sh
```

### 3. 重新获取Token
```bash
./get-admin-token.sh
```



##  访问方式

### 方法1: kubectl proxy
```bash
kubectl proxy
# 访问: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

### 方法2: 端口转发
```bash
kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8443:443
# 访问: https://localhost:8443
```

##  管理命令

```bash
# 查看Secret状态
kubectl -n kube-system get secret dashboard-admin-token

# 查看ServiceAccount
kubectl -n kube-system get sa dashboard-admin

# 删除配置
kubectl delete -f dashboard-admin.yaml -f dashboard-admin-secret.yaml
```

##  使用流程

1. 运行 `./deploy-admin-token.sh` 创建长期有效token
2. 运行 `./access-dashboard.sh` 选择访问方式
3. 在Dashboard中选择"Token"登录方式
4. 粘贴token进行登录
5. 享受超级管理员权限！