# K8S - service

在kubernetes中，pod是应用程序的载体，我们可以通过pod的ip来访问应用程序，但是pod的ip地址不是固定的，这也就意味着不方便直接采用pod的ip对服务进行访问。

为了解决这个问题，kubernetes提供了Service资源，Service会对提供同一个服务的多个pod进行聚合，并且提供一个统一的入口地址。通过访问Service的入口地址就能访问到后面的pod服务。





![wps1](C:%5CUsers%5CAdministrator%5CDesktop%5Ccommit%5CKubernetes%5CK8S%20-%20service%5Cwps1.jpg)





### **Service 的核心功能**
1. **服务发现**  
   - Service 为 Pod 提供了一个固定的虚拟 IP（ClusterIP）和 DNS 名称，即使 Pod 的 IP 发生变化，客户端也可以通过 Service 访问 Pod。
   - Kubernetes 会自动为 Service 创建 DNS 记录，格式为：`<service-name>.<namespace>.svc.cluster.local`。

2. **负载均衡**  
   - Service 可以将流量均匀地分发到后端的多个 Pod 上，实现负载均衡。
   - 支持多种负载均衡策略（如轮询、会话保持等）。

3. **稳定的网络端点**  
   - Pod 是动态的，可能会被销毁、重建或扩展，IP 地址也会随之变化。Service 提供了一个稳定的访问入口，屏蔽了 Pod 的变化。

4. **支持多种访问模式**  
   - Service 支持多种类型（ClusterIP、NodePort、LoadBalancer、ExternalName），适应不同的使用场景。

---

### **Service 的类型**
Kubernetes 提供了以下几种 Service 类型：

1. **ClusterIP（默认类型）**  
   - 为 Service 分配一个集群内部的虚拟 IP（ClusterIP），只能在集群内部访问。
   - 适用于集群内部的服务通信。

2. **NodePort**  
   - 在 ClusterIP 的基础上，在每个节点的指定端口上暴露 Service。
   - 外部客户端可以通过 `<NodeIP>:<NodePort>` 访问 Service。
   - 适用于开发测试或需要外部访问的场景。

3. **LoadBalancer**  
   - 在 NodePort 的基础上，通过云服务商（如 AWS、阿里云等）的负载均衡器暴露 Service。
   - 适用于生产环境，提供外部访问。

4. **ExternalName**  
   - 将 Service 映射到一个外部域名（如数据库服务），而不是 Pod。	
   - 适用于将集群内部服务与外部服务集成。

---

### **Service 的工作原理**
1. **Selector 和 Label**  
   - Service 通过 `selector` 字段选择一组 Pod，这些 Pod 通过 `label` 标识。
   - 例如：
     ```yaml
     selector:
       app: my-app
     ```
     会选择所有带有 `app=my-app` 标签的 Pod。

2. **Endpoints**  
   - Kubernetes 会自动创建与 Service 同名的 `Endpoints` 对象，用于存储后端 Pod 的 IP 和端口。
   - 当 Pod 发生变化时，`Endpoints` 会自动更新。

3. **kube-proxy**  
   - 每个节点上的 `kube-proxy` 组件负责实现 Service 的负载均衡功能。
   - 它通过 iptables 或 IPVS 将流量转发到后端 Pod。

---

### **Service 的 YAML 示例**
以下是一个简单的 Service 定义：
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: ClusterIP
  selector:
    app: my-app
  ports:
    - protocol: TCP
      port: 80       # Service 暴露的端口
      targetPort: 80 # Pod 的端口
```

---

### **Service 的典型使用场景**
1. **微服务架构**  
   - 通过 Service 实现服务之间的通信。
2. **外部访问**  
   - 使用 NodePort 或 LoadBalancer 暴露服务给外部用户。
3. **数据库访问**  
   - 使用 ExternalName 将应用连接到外部数据库。
4. **负载均衡**  
   - 通过 Service 将流量分发到多个 Pod，提升应用的可用性和性能。

---

总结来说，Kubernetes 的 Service 是集群中实现服务发现、负载均衡和稳定网络访问的核心组件，为应用提供了灵活且可靠的网络通信能力。