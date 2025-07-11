## 三种类型的 Kubernetes 自动扩展器

有三种类型的 K8s 自动缩放程序，每种类型都有不同的用途。他们是：

1. [Horizontal Pod Autoscaler （HPA）：](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)调整*应用程序的副本*数。HPA 根据 CPU 利用率扩展复制控制器、部署、副本集或有状态集中的 Pod 数量。HPA 还可以配置为根据自定义或外部指标做出扩展决策。
2. [Cluster Autoscaler （CA）：](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler#cluster-autoscaler)调整*集群中的节点*数。当节点没有足够的资源来运行 Pod（添加节点）或节点未充分利用时，Cluster Autoscaler 会自动在集群中添加或删除节点，并且其 Pod 可以分配给另一个节点（删除节点）。
3. [Vertical Pod Autoscaler （VPA）：](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler)调整集群中容器*的资源请求*和*限制*（我们将在本文中定义）。