# Nginx Ingress Controller 安装总结

## ✅ 安装状态

**🎉 Nginx Ingress Controller 已成功安装并运行！**

- **版本**: nginx-ingress-controller:v1.8.1
- **镜像源**: 阿里云国内镜像 (registry.cn-hangzhou.aliyuncs.com)
- **部署状态**: 正常运行
- **访问方式**: NodePort

## 📋 安装详情

### 部署信息
```bash
# 检查Ingress Controller状态
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
kubectl get ingressclass
```

### 访问信息
- **节点IP**: 172.21.165.222
- **HTTP端口**: 31136
- **HTTPS端口**: 31829
- **访问地址**: 
  - HTTP: http://172.21.165.222:31136
  - HTTPS: https://172.21.165.222:31829

### 验证测试
```bash
# 测试Ingress控制器响应
curl -I http://172.21.165.222:31136/
# 预期输出: HTTP/1.1 404 Not Found (正常，表示控制器工作)
```

## 🚀 使用指南

### 1. 基本Ingress配置

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx  # 使用nginx IngressClass
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: your-service
            port:
              number: 80
```

### 2. 创建测试应用

```bash
# 创建一个简单的Web服务
kubectl create deployment hello-world --image=k8s.gcr.io/echoserver:1.4
kubectl expose deployment hello-world --port=8080 --target-port=8080

# 创建Ingress规则
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-world-ingress
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /hello
        pathType: Prefix
        backend:
          service:
            name: hello-world
            port:
              number: 8080
EOF

# 测试访问
curl http://172.21.165.222:31136/hello
```

### 3. 常用注解

```yaml
metadata:
  annotations:
    # 重写目标路径
    nginx.ingress.kubernetes.io/rewrite-target: /
    
    # SSL重定向
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    
    # 限制请求大小
    nginx.ingress.kubernetes.io/proxy-body-size: "8m"
    
    # 设置后端协议
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    
    # 认证配置
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
```

## 🔧 常用命令

```bash
# 查看Ingress控制器日志
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# 查看所有Ingress规则
kubectl get ingress --all-namespaces

# 查看IngressClass
kubectl get ingressclass

# 重启Ingress控制器
kubectl rollout restart deployment/ingress-nginx-controller -n ingress-nginx

# 查看Ingress控制器配置
kubectl get configmap ingress-nginx-controller -n ingress-nginx -o yaml
```

## 📝 重要注意事项

1. **端口说明**:
   - HTTP: 31136 (自动分配)
   - HTTPS: 31829 (自动分配) 

2. **IngressClass**:
   - 使用 `nginx` 作为IngressClass名称
   - 推荐使用 `spec.ingressClassName: nginx` 而不是注解

3. **国内镜像**:
   - 控制器镜像: registry.cn-hangzhou.aliyuncs.com/google_containers/nginx-ingress-controller:v1.8.1
   - Webhook镜像: registry.cn-hangzhou.aliyuncs.com/google_containers/kube-webhook-certgen:v20230407


## 🎯 下一步

1. **部署应用**: 创建你的应用并暴露为Service
2. **配置Ingress**: 为应用创建Ingress规则
3. **域名配置**: 配置DNS或hosts文件指向节点IP
4. **SSL证书**: 可选择配置HTTPS证书

## 📚 相关文件

- 安装脚本: `ingress-nginx-simple-cn.sh`
- 测试应用: ingress-test-app.sh
- 测试配置: `test-ingress-app.yaml`

---

**✅ Nginx Ingress Controller 已成功安装并可以使用！**