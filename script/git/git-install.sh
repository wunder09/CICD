#!/bin/bash

# 阿里云Linux Git安装脚本
# 适用于 Alibaba Cloud Linux 2/3

set -e

echo "===== 阿里云Linux Git安装脚本 ====="

# 检查Git是否已安装
if command -v git >/dev/null 2>&1; then
    echo "Git已安装: $(git --version)"
    read -p "是否要更新Git? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "安装取消"
        exit 0
    fi
fi

# 更新yum包索引
echo "更新yum包索引..."
# 使用 --skip-broken 跳过有冲突的包
sudo yum update -y --skip-broken || {
    echo "警告: yum update遇到包冲突，继续安装Git..."
}

# 安装Git
echo "安装Git..."
sudo yum install -y git

# 验证安装
if command -v git >/dev/null 2>&1; then
    echo "✅ Git安装成功: $(git --version)"
    echo "安装路径: $(which git)"
else
    echo "❌ Git安装失败"
    exit 1
fi

# 可选配置
read -p "是否配置Git用户信息? (y/N): " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "用户名: " username
    read -p "邮箱: " email
    
    if [[ -n "$username" ]]; then
        git config --global user.name "$username"
        echo "✅ 用户名设置完成"
    fi
    
    if [[ -n "$email" ]]; then
        git config --global user.email "$email"
        echo "✅ 邮箱设置完成"
    fi
fi

echo "🎉 Git安装完成！"