#!/bin/bash

# Kubernetes Dashboard 安装脚本 (国内镜像版本)
# 适用于 Alibaba Cloud Linux 3 + kubeadm 单节点集群

set -e

echo "=== Kubernetes Dashboard 安装开始 (国内镜像版本) ==="

# 检查kubectl连接
echo "1. 检查集群连接..."
if ! kubectl cluster-info &>/dev/null; then
    echo "❌ 错误：无法连接到Kubernetes集群"
    echo "请确保kubectl已正确配置"
    exit 1
fi

echo "✅ 集群连接正常"

# 删除之前的安装（如果存在）
echo "2. 清理之前的安装..."
kubectl delete namespace kubernetes-dashboard --ignore-not-found=true
sleep 10

# 创建Dashboard配置目录
echo "3. 创建配置目录..."
mkdir -p /opt/k8s-dashboard
cd /opt/k8s-dashboard

# 部署Dashboard
echo "4. 部署Kubernetes Dashboard (使用阿里云镜像)..."

# 创建Dashboard部署文件 - 使用阿里云镜像
cat <<EOF > dashboard-deployment-cn.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: kubernetes-dashboard

---

apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard

---

kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 30443
  selector:
    k8s-app: kubernetes-dashboard
  type: NodePort

---

apiVersion: v1
kind: Secret
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-certs
  namespace: kubernetes-dashboard
type: Opaque

---

apiVersion: v1
kind: Secret
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-csrf
  namespace: kubernetes-dashboard
type: Opaque
data:
  csrf: ""

---

apiVersion: v1
kind: Secret
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-key-holder
  namespace: kubernetes-dashboard
type: Opaque

---

kind: ConfigMap
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-settings
  namespace: kubernetes-dashboard

---

kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
rules:
  - apiGroups: [""]
    resources: ["secrets"]
    resourceNames: ["kubernetes-dashboard-key-holder", "kubernetes-dashboard-certs", "kubernetes-dashboard-csrf"]
    verbs: ["get", "update", "delete"]
  - apiGroups: [""]
    resources: ["configmaps"]
    resourceNames: ["kubernetes-dashboard-settings"]
    verbs: ["get", "update"]
  - apiGroups: [""]
    resources: ["services"]
    resourceNames: ["heapster", "dashboard-metrics-scraper"]
    verbs: ["proxy"]
  - apiGroups: [""]
    resources: ["services/proxy"]
    resourceNames: ["heapster", "http:heapster:", "https:heapster:", "dashboard-metrics-scraper", "http:dashboard-metrics-scraper"]
    verbs: ["get"]

---

kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
rules:
  - apiGroups: ["metrics.k8s.io"]
    resources: ["pods", "nodes"]
    verbs: ["get", "list"]

---

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: kubernetes-dashboard
subjects:
  - kind: ServiceAccount
    name: kubernetes-dashboard
    namespace: kubernetes-dashboard

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kubernetes-dashboard
subjects:
  - kind: ServiceAccount
    name: kubernetes-dashboard
    namespace: kubernetes-dashboard

---

kind: Deployment
apiVersion: apps/v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      k8s-app: kubernetes-dashboard
  template:
    metadata:
      labels:
        k8s-app: kubernetes-dashboard
    spec:
      securityContext:
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: kubernetes-dashboard
          image: registry.aliyuncs.com/google_containers/dashboard:v2.7.0
          imagePullPolicy: Always
          ports:
            - containerPort: 8443
              protocol: TCP
          args:
            - --auto-generate-certificates
            - --namespace=kubernetes-dashboard
            - --enable-skip-login
            - --disable-settings-authorizer
          volumeMounts:
            - name: kubernetes-dashboard-certs
              mountPath: /certs
            - mountPath: /tmp
              name: tmp-volume
          livenessProbe:
            httpGet:
              scheme: HTTPS
              path: /
              port: 8443
            initialDelaySeconds: 30
            timeoutSeconds: 30
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            runAsUser: 1001
            runAsGroup: 2001
          resources:
            requests:
              cpu: 100m
              memory: 200Mi
            limits:
              cpu: 200m
              memory: 400Mi
      volumes:
        - name: kubernetes-dashboard-certs
          secret:
            secretName: kubernetes-dashboard-certs
        - name: tmp-volume
          emptyDir: {}
      serviceAccountName: kubernetes-dashboard
      nodeSelector:
        "kubernetes.io/os": linux
      tolerations:
        - key: node-role.kubernetes.io/master
          effect: NoSchedule
        - key: node-role.kubernetes.io/control-plane
          effect: NoSchedule

---

kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: dashboard-metrics-scraper
  name: dashboard-metrics-scraper
  namespace: kubernetes-dashboard
spec:
  ports:
    - port: 8000
      targetPort: 8000
  selector:
    k8s-app: dashboard-metrics-scraper

---

kind: Deployment
apiVersion: apps/v1
metadata:
  labels:
    k8s-app: dashboard-metrics-scraper
  name: dashboard-metrics-scraper
  namespace: kubernetes-dashboard
spec:
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      k8s-app: dashboard-metrics-scraper
  template:
    metadata:
      labels:
        k8s-app: dashboard-metrics-scraper
    spec:
      securityContext:
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: dashboard-metrics-scraper
          image: registry.aliyuncs.com/google_containers/metrics-scraper:v1.0.8
          ports:
            - containerPort: 8000
              protocol: TCP
          livenessProbe:
            httpGet:
              scheme: HTTP
              path: /
              port: 8000
            initialDelaySeconds: 30
            timeoutSeconds: 30
          volumeMounts:
          - mountPath: /tmp
            name: tmp-volume
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            runAsUser: 1001
            runAsGroup: 2001
          resources:
            requests:
              cpu: 50m
              memory: 100Mi
            limits:
              cpu: 100m
              memory: 200Mi
      serviceAccountName: kubernetes-dashboard
      nodeSelector:
        "kubernetes.io/os": linux
      tolerations:
        - key: node-role.kubernetes.io/master
          effect: NoSchedule
        - key: node-role.kubernetes.io/control-plane
          effect: NoSchedule
      volumes:
        - name: tmp-volume
          emptyDir: {}
EOF

# 部署Dashboard
echo "正在部署Dashboard组件..."
kubectl apply -f dashboard-deployment-cn.yaml

# 创建管理员用户
echo "5. 创建管理员用户..."
cat <<EOF > dashboard-admin.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

kubectl apply -f dashboard-admin.yaml

# 等待部署完成
echo "6. 等待Dashboard部署完成..."
echo "等待Pod启动..."

# 等待namespace创建完成
sleep 5

# 分别等待两个部署
echo "等待Dashboard主程序启动..."
kubectl wait --for=condition=available deployment/kubernetes-dashboard -n kubernetes-dashboard --timeout=300s

echo "等待Metrics Scraper启动..."
kubectl wait --for=condition=available deployment/dashboard-metrics-scraper -n kubernetes-dashboard --timeout=300s

# 获取访问信息
echo "7. 获取访问信息..."
sleep 5

NODE_IP=$(hostname -I | awk '{print $1}')
NODE_PORT=$(kubectl get service kubernetes-dashboard -n kubernetes-dashboard -o jsonpath='{.spec.ports[0].nodePort}')

echo ""
echo "=== Dashboard 安装完成 ==="
echo ""
echo "🎉 Kubernetes Dashboard 已成功安装！"
echo ""
echo "📋 访问信息："
echo "  🌐 访问地址: https://${NODE_IP}:${NODE_PORT}"
echo "  🔑 认证方式: Token"
echo ""
echo "🔐 获取管理员Token："
echo "kubectl -n kubernetes-dashboard create token admin-user"
echo ""
echo "📝 常用命令："
echo "  查看Dashboard状态: kubectl get pods -n kubernetes-dashboard"
echo "  查看服务状态: kubectl get svc -n kubernetes-dashboard"
echo "  重启Dashboard: kubectl rollout restart deployment kubernetes-dashboard -n kubernetes-dashboard"
echo ""
echo "⚠️  重要提示："
echo "  - 首次访问需要忽略SSL证书警告"
echo "  - 选择'令牌'方式登录"
echo "  - 使用上面的命令获取Token"
echo "  - 为了安全，Token会定期过期"
echo ""

# 更新便捷访问脚本
cat <<'EOF' > /opt/dashboard-token.sh
#!/bin/bash
echo "=== Kubernetes Dashboard 访问信息 ==="
NODE_IP=$(hostname -I | awk '{print $1}')
NODE_PORT=$(kubectl get service kubernetes-dashboard -n kubernetes-dashboard -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)

if [ -z "$NODE_PORT" ]; then
    echo "❌ Dashboard服务未找到，请先安装Dashboard"
    exit 1
fi

echo ""
echo "🌐 访问地址: https://${NODE_IP}:${NODE_PORT}"
echo ""
echo "🔑 管理员Token:"
kubectl -n kubernetes-dashboard create token admin-user 2>/dev/null || echo "❌ 无法获取Token，请检查admin-user是否存在"
echo ""
echo "📋 使用说明:"
echo "1. 在浏览器中访问上述地址"
echo "2. 忽略SSL证书警告"
echo "3. 选择'令牌'登录方式"
echo "4. 复制上面的Token并粘贴"
echo "5. 点击'登录'"
echo ""
echo "🔄 其他有用命令:"
echo "  查看Pod状态: kubectl get pods -n kubernetes-dashboard"
echo "  重启Dashboard: kubectl rollout restart deployment kubernetes-dashboard -n kubernetes-dashboard"
EOF

chmod +x /opt/dashboard-token.sh

echo "💡 已创建便捷脚本: /opt/dashboard-token.sh"
echo "   运行此脚本可随时获取访问信息和Token"
echo ""
echo "安装脚本执行完成！"