#!/bin/bash

# 简化版 Nginx Ingress Controller 安装脚本 - 使用国内镜像
# 适用于 Kubernetes v1.28.2
# 日期：2025-09-13

set -e

echo "=== 开始安装 Nginx Ingress Controller (国内镜像版本) ==="

# 检查kubectl是否可用
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl 未找到，请先安装 Kubernetes"
    exit 1
fi

# 检查集群连接
echo "1. 检查集群状态..."
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ 无法连接到 Kubernetes 集群"
    exit 1
fi

echo "✅ 集群连接正常"

# 2. 下载官方配置并修改镜像地址
echo "2. 下载并配置 Ingress Controller..."

# 下载官方配置文件
curl -L https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/baremetal/deploy.yaml -o /tmp/ingress-nginx-original.yaml

# 使用国内镜像地址替换
sed 's|registry.k8s.io/ingress-nginx/controller:.*|registry.cn-hangzhou.aliyuncs.com/google_containers/nginx-ingress-controller:v1.8.1|g' /tmp/ingress-nginx-original.yaml > /tmp/ingress-nginx-cn.yaml
sed -i 's|registry.k8s.io/ingress-nginx/kube-webhook-certgen:.*|registry.cn-hangzhou.aliyuncs.com/google_containers/kube-webhook-certgen:v20230407|g' /tmp/ingress-nginx-cn.yaml

# 修改NodePort端口避免冲突
sed -i 's/nodePort: 30443/nodePort: 30444/g' /tmp/ingress-nginx-cn.yaml

echo "✅ 配置文件准备完成"

# 3. 部署Ingress Controller
echo "3. 部署 Nginx Ingress Controller..."
kubectl apply -f /tmp/ingress-nginx-cn.yaml

# 4. 等待部署完成
echo "4. 等待 Ingress Controller 部署完成..."

# 等待所有pod就绪
echo "正在等待 Pods 启动..."
for i in {1..60}; do
    if kubectl get pods -n ingress-nginx --field-selector=status.phase=Running 2>/dev/null | grep -q ingress-nginx-controller; then
        echo "✅ Ingress Controller Pod 已启动"
        break
    fi
    echo "等待中... ($i/60)"
    sleep 5
done

# 等待deployment就绪
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

echo "✅ Nginx Ingress Controller 部署成功！"

# 5. 验证安装
echo "5. 验证安装..."
echo ""
echo "📋 Ingress Controller 信息："
kubectl get pods -n ingress-nginx
echo ""
kubectl get svc -n ingress-nginx
echo ""

# 获取NodePort端口
HTTP_PORT=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.ports[0].nodePort}')
HTTPS_PORT=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.ports[1].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

echo "🌐 访问信息："
echo "HTTP 端口: $HTTP_PORT"
echo "HTTPS 端口: $HTTPS_PORT (注意：Dashboard使用30443)"
echo "节点 IP: $NODE_IP"
echo ""
echo "访问地址："
echo "HTTP:  http://$NODE_IP:$HTTP_PORT"
echo "HTTPS: https://$NODE_IP:$HTTPS_PORT"

echo ""
echo "=== Nginx Ingress Controller 安装完成! ==="
echo ""
echo "📚 使用说明："
echo "1. 创建 Ingress 资源来暴露服务"
echo "2. 使用 IngressClass 'nginx'"
echo "3. 通过 NodePort 访问: HTTP($HTTP_PORT) 和 HTTPS($HTTPS_PORT)"
echo ""
echo "💡 示例应用部署:"
echo "kubectl create deployment test-app --image=nginx"
echo "kubectl expose deployment test-app --port=80"
echo ""
echo "然后创建 Ingress:"
cat <<'EXAMPLE'
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: test.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: test-app
            port:
              number: 80
EOF
EXAMPLE

# 清理临时文件
rm -f /tmp/ingress-nginx-original.yaml /tmp/ingress-nginx-cn.yaml

echo ""
echo "🎉 安装脚本执行完成！"