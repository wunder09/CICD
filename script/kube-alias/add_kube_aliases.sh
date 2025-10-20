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
