#!/bin/bash
# Kubernetes 部署脚本
# 用于部署应用到指定命名空间

set -e  # 遇到错误立即退出

# 初始参数
namespace="jiaozi"

# 函数定义
log_info() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

log_warn() {
    echo "[WARN] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# 主要流程 
log_info "开始 Kubernetes 部署流程"
log_info "目标命名空间: $namespace"

# 检查k8s环境
log_info "检查 Kubernetes 环境..."
if ! command -v kubectl &> /dev/null; then
    log_error "kubectl 命令未找到，请先安装 kubectl"
    exit 1
fi

if ! kubectl cluster-info &> /dev/null; then
    log_error "无法连接到 Kubernetes 集群"
    log_error "请检查 kubeconfig 配置和集群状态"
    exit 1
fi
log_info "Kubernetes 环境检查通过"

# 检查命名空间是否存在
if ! kubectl get namespace "$namespace" &> /dev/null; then
    log_info "命名空间不存在，正在创建: $namespace"
    if ! kubectl create namespace "$namespace"; then
        log_error "创建命名空间失败"
        exit 1
    fi
else
    log_info "命名空间已存在: $namespace"
fi


# 检查 jiaozi-front-deployment
log_info "检查 jiaozi-front-deployment..."
kubectl get pods -n "$namespace" | grep jiaozi-front-deployment || log_warn "未找到 jiaozi-front-deployment Pod"

# 检查是否有部署文件
log_info "检查部署文件..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
K8S_DIR="$(dirname "$SCRIPT_DIR")"

# 查找所有部署文件
DEPLOYMENT_FILES=()
if [ -d "$K8S_DIR/frontend_react_pc" ]; then
    if [ -f "$K8S_DIR/frontend_react_pc/deployment.yaml" ]; then
        DEPLOYMENT_FILES+=("$K8S_DIR/frontend_react_pc/deployment.yaml")
    fi
    if [ -f "$K8S_DIR/frontend_react_pc/mobile-deployment.yaml" ]; then
        DEPLOYMENT_FILES+=("$K8S_DIR/frontend_react_pc/mobile-deployment.yaml")
    fi
fi

if [ -d "$K8S_DIR/backend_django" ] && [ -f "$K8S_DIR/backend_django/deployment.yaml" ]; then
    DEPLOYMENT_FILES+=("$K8S_DIR/backend/deployment.yaml")
fi

if [ ${#DEPLOYMENT_FILES[@]} -eq 0 ]; then
    log_error "未找到任何部署文件"
    exit 1
fi

log_info "找到 ${#DEPLOYMENT_FILES[@]} 个部署文件:"
for file in "${DEPLOYMENT_FILES[@]}"; do
    log_info "  - $file"
done

# 执行部署文件
# log_info "开始执行部署..."
# for deployment_file in "${DEPLOYMENT_FILES[@]}"; do
#     log_info "应用部署文件: $deployment_file"
#     if ! kubectl apply -f "$deployment_file" -n "$namespace"; then
#         log_error "应用部署文件失败: $deployment_file"
#         exit 1
#     fi
# done

log_info "开始执行部署..."
DEPLOYMENT_FILE="/opt/configs/k8s/frontend_react_pc/deployment.yaml"

log_info "应用部署文件: $DEPLOYMENT_FILE"
if ! kubectl apply -f "$DEPLOYMENT_FILE" -n "$namespace"; then
    log_error "应用部署文件失败: $DEPLOYMENT_FILE"
    exit 1
fi

# 应用服务文件
# SERVICE_FILES=()
# if [ -f "$K8S_DIR/services/frontend-pc-service.yaml" ]; then
#     SERVICE_FILES+=("$K8S_DIR/services/frontend-pc-service.yaml")
# fi
# if [ -f "$K8S_DIR/services/frontend-mobile-service.yaml" ]; then
#     SERVICE_FILES+=("$K8S_DIR/services/frontend-mobile-service.yaml")
# fi
# if [ -f "$K8S_DIR/services/backend-service.yaml" ]; then
#     SERVICE_FILES+=("$K8S_DIR/services/backend-service.yaml")
# fi

# for service_file in "${SERVICE_FILES[@]}"; do
#     log_info "应用服务文件: $service_file"
#     if ! kubectl apply -f "$service_file" -n "$namespace"; then
#         log_error "应用服务文件失败: $service_file"
#         exit 1
#     fi
# done

# 等待
log_info "等待部署完成..."
sleep 10  # 等待 Pod 启动

# 获取所有部署名称
DEPLOYMENTS=$(kubectl get deployments -n "$namespace" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || echo "")

if [ -n "$DEPLOYMENTS" ]; then
    for deployment in $DEPLOYMENTS; do
        log_info "等待部署 $deployment 完成..."
        if ! kubectl rollout status deployment/"$deployment" -n "$namespace" --timeout=300s; then
            log_error "部署 $deployment 超时或失败"
            exit 1
        fi
    done
else
    log_warn "未找到任何部署，跳过等待"
fi

# 检查pod状态
log_info "检查最终 Pod 状态..."
echo ""
echo "==================== 部署完成 ===================="
log_info "部署成功完成!"
echo "命名空间: $namespace"
echo ""
echo "Pod 状态:"
kubectl get pods -n "$namespace"
echo ""
echo "服务状态:"
kubectl get services -n "$namespace"
echo ""
echo "部署状态:"
kubectl get deployments -n "$namespace"
echo "================================================="

log_info "脚本执行完成!"

