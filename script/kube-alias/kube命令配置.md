

# 常用 kubectl 命令速查表

## 集群与配置
```bash
kubectl cluster-info                # 查看集群信息
kubectl config view                 # 查看 kubeconfig 配置
kubectl config get-contexts         # 列出所有上下文
kubectl config use-context <name>   # 切换上下文
```

## 查看资源
```bash
kubectl get pods -A                 # 查看所有命名空间的 Pod
kubectl get pods -n <ns>            # 查看指定命名空间 Pod
kubectl get services -A             # 查看所有服务
kubectl get deployments -A          # 查看所有 Deployment
kubectl get nodes                   # 查看节点
kubectl get events -n <ns>          # 查看事件
```

## 详细信息与日志
```bash
kubectl describe pod <pod-name> -n <ns>    # 查看 Pod 详情
kubectl logs <pod-name> -n <ns>            # 查看 Pod 日志
kubectl logs -f <pod-name> -n <ns>         # 实时查看日志
kubectl exec -it <pod-name> -n <ns> -- sh  # 进入 Pod 终端
```

## 创建与修改资源
```bash
kubectl apply -f <yaml-file>        # 应用 YAML 配置
kubectl create -f <yaml-file>       # 创建资源
kubectl delete pod <pod-name> -n <ns>      # 删除 Pod
kubectl delete -f <yaml-file>       # 删除 YAML 中定义的资源
kubectl edit deployment <name> -n <ns>     # 编辑 Deployment
```

## 缩放与滚动更新
```bash
kubectl scale deployment <name> --replicas=3 -n <ns>   # 调整副本数
kubectl rollout restart deployment <name> -n <ns>      # 重启 Deployment
kubectl rollout status deployment <name> -n <ns>       # 查看滚动更新状态
```

## 命名空间与标签
```bash
kubectl create ns <ns>               # 创建命名空间
kubectl label pod <pod-name> env=prod -n <ns>  # 添加标签
kubectl get pods -l env=prod         # 按标签筛选
```

---

# 推荐 alias 配置
可以把这些加到 `~/.bashrc` 或 `~/.zshrc` 里：

```bash
# 基础简写
alias k='kubectl'
alias ka='kubectl apply -f'
alias kc='kubectl create'
alias kd='kubectl delete'
alias kg='kubectl get'
alias kga='kubectl get all'
alias kdesc='kubectl describe'

# 常用组合
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'

# 日志与执行
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias ke='kubectl exec -it'

# 命名空间切换
alias kns='kubectl config set-context --current --namespace'
```

---



# 安装kubecolor 插件



## 添加alias脚本

```bash
#!/bin/bash

# 检测当前使用的 Shell
if [ -n "$ZSH_VERSION" ]; then
  RC_FILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
  RC_FILE="$HOME/.bashrc"
else
  echo "未检测到 bash 或 zsh，脚本退出。"
  exit 1
fi

echo "即将把 kubectl alias 添加到 $RC_FILE"

# 定义要添加的 alias
cat >> "$RC_FILE" <<'EOF'

# kubectl 常用 alias
alias k='kubectl'
alias ka='kubectl apply -f'
alias kc='kubectl create'
alias kd='kubectl delete'
alias kg='kubectl get'
alias kga='kubectl get all'
alias kdesc='kubectl describe'

alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'

alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias ke='kubectl exec -it'

alias kns='kubectl config set-context --current --namespace'
EOF

echo "Alias 已添加到 $RC_FILE"
echo "执行 source $RC_FILE 使配置生效"
```

### 使用方法
1. 把上面的脚本保存为 `add_kube_aliases.sh`
2. 执行：
   ```bash
   chmod +x add_kube_aliases.sh
   ./add_kube_aliases.sh
   ```
3. 让配置生效：
   ```bash
   source ~/.bashrc   # 如果你用 bash
   # 或
   source ~/.zshrc    # 如果你用 zsh
   ```

这个脚本会自动检测你用的是 bash 还是 zsh，然后写入对应的配置文件，不会覆盖已有内容，只会追加。  

要不要我帮你再加上**自动 source**，这样执行完脚本就能直接用新 alias？这样你就不用手动 source 了。