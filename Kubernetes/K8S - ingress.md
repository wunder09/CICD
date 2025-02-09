# K8S - ingress

Kubernetes 中的 **Ingress** 是一种用于管理外部访问集群内服务的 API 对象，它通过 HTTP/HTTPS 路由规则将外部流量分发到集群内部的 Service。Ingress 提供了更高级的流量控制能力，例如基于域名、路径的请求路由，TLS 终止等。

---

### **Ingress 的核心功能**
1. **基于域名和路径的路由**  
   - 可以根据请求的域名（Host）和 URL 路径将流量路由到不同的 Service。
   - 例如：
     - `example.com/app1` 路由到 `app1-service`。
     - `example.com/app2` 路由到 `app2-service`。

2. **TLS 终止**  
   - 支持 HTTPS 流量，可以在 Ingress 中配置 TLS 证书，实现加密通信。

3. **负载均衡**  
   - Ingress 控制器（如 Nginx、Traefik）会自动实现负载均衡，将流量分发到后端的多个 Pod。

4. **灵活的流量管理**  
   - 支持基于权重的流量分发、重定向、重写路径等高级功能。

5. **统一入口**  
   - 通过一个统一的入口（IP 或域名）管理多个服务，减少对外暴露的端口数量。

---

### **Ingress 的工作原理**
1. **Ingress 资源**  
   - Ingress 资源是一个 Kubernetes API 对象，定义了路由规则。例如：
     ```yaml
     apiVersion: networking.k8s.io/v1
     kind: Ingress
     metadata:
       name: example-ingress
     spec:
       rules:
         - host: example.com
           http:
             paths:
               - path: /app1
                 pathType: Prefix
                 backend:
                   service:
                     name: app1-service
                     port:
                       number: 80
               - path: /app2
                 pathType: Prefix
                 backend:
                   service:
                     name: app2-service
                     port:
                       number: 80
     ```

2. **Ingress 控制器**  
   - Ingress 控制器是一个独立的组件，负责实现 Ingress 资源中定义的路由规则。
   - 常见的 Ingress 控制器包括：
     - **Nginx Ingress Controller**：基于 Nginx 实现。
     - **Traefik**：支持动态配置和多种协议。
     - **HAProxy Ingress**：高性能负载均衡器。
     - **AWS ALB Ingress Controller**：与 AWS 负载均衡器集成。

3. **流量转发**  
   
   - 当外部请求到达 Ingress 控制器时，控制器会根据 Ingress 资源中定义的路由规则，将请求转发到相应的 Service 和 Pod。

---

### **Ingress 的典型使用场景**
1. **多服务统一入口**  
   - 通过一个域名和端口暴露多个服务，简化外部访问。
2. **基于域名的路由**  
   - 根据不同的域名将流量路由到不同的服务。
3. **HTTPS 支持**  
   - 在 Ingress 中配置 TLS 证书，实现安全的 HTTPS 通信。
4. **路径重写和重定向**  
   - 支持 URL 路径的重写和重定向，满足复杂的路由需求。
5. **灰度发布**  
   - 通过 Ingress 实现基于权重的流量分发，支持灰度发布和 A/B 测试。

---

### **Ingress 的 YAML 示例**
以下是一个完整的 Ingress 示例，包含域名路由和 TLS 配置：
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  tls:
    - hosts:
        - example.com
      secretName: example-tls-secret
  rules:
    - host: example.com
      http:
        paths:
          - path: /app1
            pathType: Prefix
            backend:
              service:
                name: app1-service
                port:
                  number: 80
          - path: /app2
            pathType: Prefix
            backend:
              service:
                name: app2-service
                port:
                  number: 80
```

---

### **Ingress 与 Service 的区别**
| 特性     | Ingress                  | Service                    |
| -------- | ------------------------ | -------------------------- |
| 作用范围 | 提供外部访问的路由规则   | 提供内部服务发现和负载均衡 |
| 协议支持 | 主要支持 HTTP/HTTPS      | 支持 TCP/UDP               |
| 路由能力 | 支持基于域名和路径的路由 | 仅支持简单的负载均衡       |
| 实现方式 | 需要 Ingress 控制器      | 通过 kube-proxy 实现       |
| 适用场景 | 外部访问、复杂路由       | 内部服务通信               |

---

### **Ingress 控制器的部署**
以 Nginx Ingress 控制器为例，部署步骤如下：
1. 安装 Ingress 控制器：
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
   ```
2. 验证安装：
   ```bash
   kubectl get pods -n ingress-nginx
   ```
3. 创建 Ingress 资源：
   
   - 使用前面的 YAML 示例创建 Ingress。

---

总结来说，Ingress 是 Kubernetes 中用于管理外部访问的核心组件，提供了强大的路由和流量管理能力。通过 Ingress 控制器，可以实现灵活的路由规则、TLS 终止和负载均衡，是生产环境中不可或缺的工具。