#!/bin/bash
# 执行该脚本用于下载代码、构建镜像并推送到ACR个人版
#  使用了个人ACR账号

set -e  # 遇到错误立即退出

# ==================== 配置信息 ====================
# Git仓库信息
GIT_REPO_URL="git@codeup.aliyun.com:68afbca3725067d38cf126d1/jiaozi/Jiaozi_Portable.git"
GIT_BRANCH="master"  # 使用master分支
WORK_DIR="./build_workspace"

# Docker认证信息
DOCKER_USERNAME=""
DOCKER_PASSWORD=""

# ACR镜像信息
ACR_REGISTRY="registry.cn-hangzhou.aliyuncs.com"
ACR_NAMESPACE="jiaoziera"
IMAGE_NAME="jiaozi_protable"
DEFAULT_DOCKER_TAG="latest"
DOCKERFILE_PATH="./Dockerfile"  # Dockerfile相对于代码根目录的路径

# ==================== 函数定义 ====================
log_info() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

cleanup() {
    log_info "清理临时文件..."
    if [ -d "$WORK_DIR" ]; then
        rm -rf "$WORK_DIR"
    fi
}

# 设置错误处理
trap cleanup EXIT

# ==================== 参数处理 ====================
# 获取命令行参数中的Docker标签
USER_PROVIDED_TAG="$1"
if [ -n "$USER_PROVIDED_TAG" ]; then
    DOCKER_TAG="$USER_PROVIDED_TAG"
    USE_LATEST=false
else
    DOCKER_TAG="latest"
    USE_LATEST=true
fi

# ==================== 主要流程 ====================
log_info "开始构建和推送镜像流程"
log_info "使用Docker标签: $DOCKER_TAG"

# 1. 清理并创建工作目录
log_info "准备工作目录: $WORK_DIR"
if [ -d "$WORK_DIR" ]; then
    rm -rf "$WORK_DIR"
fi
mkdir -p "$WORK_DIR"

# 2. 下载代码
log_info "从Git仓库下载代码: $GIT_REPO_URL"
log_info "使用SSH方式克隆仓库..."
if ! git clone -b "$GIT_BRANCH" "$GIT_REPO_URL" "$WORK_DIR"; then
    log_error "Git克隆失败，请检查"
    # log_error "1. SSH密钥是否正确配置"
    # log_error "2. 仓库访问权限是否正常"
    # log_error "3. 网络连接是否正常"
    exit 1
fi

# 3. 检查Dockerfile是否存在
DOCKERFILE_FULL_PATH="$WORK_DIR/$DOCKERFILE_PATH"
if [ ! -f "$DOCKERFILE_FULL_PATH" ]; then
    log_error "Dockerfile不存在: $DOCKERFILE_FULL_PATH"
    exit 1
fi
log_info "找到Dockerfile: $DOCKERFILE_FULL_PATH"

# 4. 登录ACR
log_info "登录阿里云容器镜像服务ACR"
if ! echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin "$ACR_REGISTRY"; then
    log_error "Docker登录失败"
    exit 1
fi

# 5. 构建镜像
FULL_IMAGE_NAME="$ACR_REGISTRY/$ACR_NAMESPACE/$IMAGE_NAME:$DOCKER_TAG"

log_info "开始构建镜像: $FULL_IMAGE_NAME"
cd "$WORK_DIR"
if ! docker build -f "$DOCKERFILE_PATH" -t "$FULL_IMAGE_NAME" .; then
    log_error "镜像构建失败"
    exit 1
fi

# 6. 获取镜像ID
IMAGE_ID=$(docker images --format "table {{.Repository}}:{{.Tag}}\t{{.ID}}" | grep "$FULL_IMAGE_NAME" | awk '{print $2}')
if [ -z "$IMAGE_ID" ]; then
    log_error "无法获取镜像ID"
    exit 1
fi

log_info "镜像构建成功!"
log_info "镜像ID: $IMAGE_ID"
log_info "镜像标签: $FULL_IMAGE_NAME"

# 7. 推送镜像
log_info "推送镜像到ACR: $FULL_IMAGE_NAME"
if ! docker push "$FULL_IMAGE_NAME"; then
    log_error "推送镜像失败"
    exit 1
fi

# 8. 输出K8s配置所需信息
echo ""
echo "==================== 构建完成 ===================="
# echo "镜像ID: $IMAGE_ID"
# echo "镜像标签: $FULL_IMAGE_NAME"
# if [ "$USE_LATEST" = true ]; then
#     echo "使用默认latest标签"
# else
#     echo "使用自定义标签: $DOCKER_TAG"
# fi
# echo ""
echo "pod配置示例:"
echo "spec:"
echo "  containers:"
echo "  - name: $IMAGE_NAME"
echo "    image: $FULL_IMAGE_NAME"
echo ""
# echo "如果使用私有仓库，请确保配置imagePullSecrets:"
# echo "imagePullSecrets:"
# echo "- name: acr-secret"
echo "================================================="

# 9. 清理本地镜像（可选）
read -p "是否删除本地构建的镜像? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "删除本地镜像"
    docker rmi "$FULL_IMAGE_NAME" 2>/dev/null || true
    log_info "本地镜像已删除"
else
    log_info "保留本地镜像"
fi

log_info "脚本执行完成!"
