#!/bin/bash

# 定义默认参数
DEFAULT_KEY_PATH="$HOME/.ssh/id_rsa"
DEFAULT_COMMENT="code_access@$(hostname)"

# 显示帮助信息
show_help() {
    echo "生成SSH密钥对，用于从远程仓库下载代码"
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  -p, --path      密钥文件路径（默认: $DEFAULT_KEY_PATH）"
    echo "  -c, --comment   密钥注释（默认: $DEFAULT_COMMENT）"
    echo "  -h, --help      显示帮助信息"
    echo
    echo "示例:"
    echo "  $0 -p ~/.ssh/github_key -c mygithub@example.com"
}

# 解析命令行参数
KEY_PATH="$DEFAULT_KEY_PATH"
COMMENT="$DEFAULT_COMMENT"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--path)
            KEY_PATH="$2"
            shift 2
            ;;
        -c|--comment)
            COMMENT="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "错误: 未知选项 $1"
            show_help
            exit 1
            ;;
    esac
done

# 检查密钥是否已存在
if [[ -f "$KEY_PATH" || -f "$KEY_PATH.pub" ]]; then
    echo "错误: 密钥文件已存在:"
    [[ -f "$KEY_PATH" ]] && echo "  $KEY_PATH"
    [[ -f "$KEY_PATH.pub" ]] && echo "  $KEY_PATH.pub"
    echo "请选择不同的路径或删除现有文件后重试"
    exit 1
fi

# 创建目录（如果不存在）
KEY_DIR=$(dirname "$KEY_PATH")
if [[ ! -d "$KEY_DIR" ]]; then
    echo "创建目录: $KEY_DIR"
    mkdir -p "$KEY_DIR" || {
        echo "错误: 无法创建目录 $KEY_DIR"
        exit 1
    }
fi

# 生成SSH密钥
echo "正在生成SSH密钥对..."
ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N "" -C "$COMMENT"

# 检查生成结果
if [[ -f "$KEY_PATH" && -f "$KEY_PATH.pub" ]]; then
    echo "密钥生成成功:"
    echo "  私钥: $KEY_PATH"
    echo "  公钥: $KEY_PATH.pub"
    
    # 设置文件权限（仅当前用户可读写）
    chmod 600 "$KEY_PATH"
    chmod 644 "$KEY_PATH.pub"
    echo "已设置正确的文件权限"
    
    # 显示公钥内容
    echo -e "\n公钥内容如下（可直接复制到代码仓库）:"
    cat "$KEY_PATH.pub"
    
    # 使用说明
    echo -e "\n使用说明:"
    echo "1. 将上述公钥内容添加到你的代码仓库（GitHub/GitLab等）的SSH密钥设置中"
    echo "2. 之后可以使用SSH协议克隆仓库，例如:"
    echo "   git clone git@github.com:用户名/仓库名.git"
else
    echo "错误: 密钥生成失败"
    exit 1
fi
    