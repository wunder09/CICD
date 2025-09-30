#!/bin/bash

# Ingress Controller 测试脚本
# 创建测试应用并配置 Ingress 规则

echo "=== 开始部署 Ingress 测试应用 ==="

# 1. 创建测试应用
echo "1. 创建测试应用..."
kubectl create deployment test-nginx --image=nginx:latest || echo "部署已存在"
kubectl expose deployment test-nginx --port=80 --type=ClusterIP || echo "服务已存在"

# 2. 创建第二个测试应用
echo "2. 创建第二个测试应用..."
kubectl create deployment test-httpd --image=httpd:latest || echo "部署已存在"
kubectl expose deployment test-httpd --port=80 --type=ClusterIP || echo "服务已存在"

# 3. 创建Ingress规则
echo "3. 创建 Ingress 规则..."
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: nginx.test.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: test-nginx
            port:
              number: 80
  - host: httpd.test.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: test-httpd
            port:
              number: 80
  - http:
      paths:
      - path: /nginx
        pathType: Prefix
        backend:
          service:
            name: test-nginx
            port:
              number: 80
      - path: /httpd
        pathType: Prefix
        backend:
          service:
            name: test-httpd
            port:
              number: 80
EOF

# 4. 等待应用启动
echo "4. 等待应用启动..."
kubectl wait --for=condition=ready pod --selector=app=test-nginx --timeout=120s
kubectl wait --for=condition=ready pod --selector=app=test-httpd --timeout=120s

echo "✅ 应用部署完成！"

# 5. 显示访问信息
echo ""
echo "📋 部署状态："
kubectl get deployment test-nginx test-httpd
echo ""
kubectl get svc test-nginx test-httpd
echo ""
kubectl get ingress test-ingress

# 6. 获取访问信息
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
HTTP_PORT=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.ports[0].nodePort}')

echo ""
echo "🌐 访问测试："
echo "节点IP: $NODE_IP"
echo "HTTP端口: $HTTP_PORT"
echo ""
echo "测试命令："
echo "# 通过路径访问："
echo "curl http://$NODE_IP:$HTTP_PORT/nginx"
echo "curl http://$NODE_IP:$HTTP_PORT/httpd"
echo ""
echo "# 通过Host访问（需要配置hosts或使用-H参数）："
echo "curl -H 'Host: nginx.test.local' http://$NODE_IP:$HTTP_PORT/"
echo "curl -H 'Host: httpd.test.local' http://$NODE_IP:$HTTP_PORT/"
echo ""
echo "# 配置 /etc/hosts 文件（可选）："
echo "echo '$NODE_IP nginx.test.local' >> /etc/hosts"
echo "echo '$NODE_IP httpd.test.local' >> /etc/hosts"

echo ""
echo "=== 测试应用部署完成！ ==="