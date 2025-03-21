# K8S -pod



Kubernetes（K8S）中的Pod是Kubernetes中最小的、可部署的和可管理的计算单元，以下是关于它的详细介绍：

## 定义与概念
- Pod是一组紧密相关的容器的集合，这些容器共享网络、存储等资源，它们通常是为了实现同一个业务功能而协同工作。
- 可以将Pod看作是一个“逻辑主机”，其中的容器就像是在这台主机上运行的不同进程。

### 特点
- **共享网络命名空间**：Pod中的所有容器都共享同一个网络命名空间，它们可以通过localhost进行高效通信，并且每个Pod都有一个唯一的IP地址，使得Pod内的容器能够以固定的IP和端口进行相互访问。
- **共享存储卷**：Pod可以定义共享的存储卷（Volume），这些存储卷可以被Pod中的多个容器挂载和访问，方便容器之间共享数据。
- **生命周期一致性**：Pod中的容器具有相同的生命周期，当Pod被创建时，其中的所有容器都会被启动；当Pod被删除或终止时，其中的所有容器也会被停止和销毁。

### 作用与用途
- **封装应用组件**：将一个复杂应用拆分成多个微服务，每个微服务作为一个容器，将这些容器组合在一个Pod中，便于管理和维护。例如，一个Web应用可能由后端数据库容器和前端Web服务器容器组成，它们可以放在同一个Pod中。
- **实现紧密协作**：对于一些需要紧密协作的容器，如日志收集器和日志处理程序，将它们放在同一个Pod中，可以确保它们之间的通信高效、可靠，并且能够方便地共享数据和配置。
- **提高资源利用率**：多个容器共享Pod的资源，如CPU、内存等，可以根据容器的实际需求灵活分配资源，提高资源的整体利用率。

### 资源管理
- **资源请求与限制**：可以为Pod中的每个容器定义CPU和内存的请求（Requests）和限制（Limits）。请求表示容器正常运行所需的资源量，限制则表示容器最多能使用的资源量，防止某个容器过度占用资源影响其他容器的运行。
- **调度与分配**：Kubernetes的调度器会根据集群中节点的资源情况和Pod的资源需求，将Pod调度到合适的节点上运行，确保集群资源的合理分配和利用。

### 状态与生命周期
- **状态**：Pod有多种状态，如Pending（挂起）、Running（运行中）、Succeeded（成功）、Failed（失败）等。Pending表示Pod已经被创建，但还没有被调度到节点上或者正在下载容器镜像等；Running表示Pod已经被调度到节点上并且容器正在运行；Succeeded表示Pod中的所有容器都已经成功执行完毕；Failed表示Pod中的容器执行失败。
- **生命周期钩子**：Pod中的容器可以定义生命周期钩子函数，如PostStart和PreStop。PostStart钩子在容器启动后立即执行，可以用于进行一些初始化操作；PreStop钩子在容器被终止之前执行，可用于进行一些清理工作，如保存数据、关闭连接等。

### 与其他K8S对象的关系
- **ReplicaSet和Deployment**：通常不会直接创建单个Pod，而是通过ReplicaSet或Deployment等对象来管理Pod的副本数量和生命周期。ReplicaSet确保指定数量的Pod副本始终处于运行状态，Deployment则在此基础上提供了更高级的部署和升级策略，如滚动升级、回滚等。
- **Service**：Service用于为一组Pod提供统一的访问入口，它可以将外部流量路由到后端的Pod上，实现负载均衡和服务发现功能。





## pod 资源清单

Pod 的资源清单是一个 YAML 或 JSON 格式的文件，用于定义 Pod 的配置信息。

### 基本结构

- **apiVersion**：指定使用的 Kubernetes API 版本。
- **kind**：指定资源的类型，这里是 `Pod`。
- **metadata**：包含 Pod 的元数据，如名称、标签等。
- **spec**：定义 Pod 的详细配置，包括容器、存储卷、重启策略等。

eg：

```yaml
apiVersion: v1
kind: Pod
metadata:
  # Pod的名称，在命名空间内必须唯一
  name: myapp-pod
  # 为Pod添加标签，方便后续的选择和管理
  labels:
    app: myapp
    tier: frontend
spec:
  containers:
    # 定义容器的详细信息，可包含多个容器
  - name: myapp-container
    # 容器使用的镜像
    image: nginx:1.14.2
    # 容器启动时执行的命令，可选
    command: ['sh', '-c', 'echo Hello Kubernetes! && sleep 3600']
    # 容器的端口信息
    ports:
    - containerPort: 80
    # 容器的资源请求和限制
    resources:
      requests:
        # CPU请求量，这里表示请求0.25个CPU核心
        cpu: "250m"
        # 内存请求量，这里表示请求64MiB内存
        memory: "64Mi"
      limits:
        # CPU使用上限，这里表示最多使用0.5个CPU核心
        cpu: "500m"
        # 内存使用上限，这里表示最多使用128MiB内存
        memory: "128Mi"
  # Pod的重启策略，可选值为Always、OnFailure、Never
  restartPolicy: Always
  # 定义共享存储卷，可选
  volumes:
  - name: myapp-volume
    emptyDir: {}
```





## 生命周期阶段
Pod 在其整个生命周期中会经历多个阶段，这些阶段反映了 Pod 当前的状态。

#### 1.1 Pending（挂起）
- **描述**：当你创建一个 Pod 时，它首先进入 Pending 状态。此时，Kubernetes 已经接收到创建 Pod 的请求，但还没有完成以下步骤：
    - 调度 Pod 到合适的节点上。
    - 为 Pod 拉取所需的容器镜像。
- **可能的原因**：
    - 集群中没有可用的节点满足 Pod 的资源请求。
    - 镜像拉取策略设置不合理，导致镜像拉取失败。

#### 1.2 Running（运行中）
- **描述**：当 Pod 被成功调度到一个节点上，并且所有容器都已经被创建并启动后，Pod 进入 Running 状态。此时，Pod 中的容器正在正常运行。
- **特点**：
    - 容器可能处于不同的状态，如正在运行、正在重启等。
    - Pod 可以开始处理用户请求。

#### 1.3 Succeeded（成功）
- **描述**：当 Pod 中的所有容器都正常终止（退出码为 0），并且不会再重启时，Pod 进入 Succeeded 状态。这种情况通常出现在运行一次性任务的 Pod 中，例如批处理作业。
- **示例**：一个执行数据备份任务的 Pod，任务完成后容器正常退出，Pod 进入 Succeeded 状态。

#### 1.4 Failed（失败）
- **描述**：当 Pod 中的至少一个容器以非零退出码终止，并且不会再重启时，Pod 进入 Failed 状态。这表示 Pod 中的任务没有成功完成。
- **可能的原因**：
    - 容器内部出现错误，如代码逻辑错误、依赖缺失等。
    - 资源不足，导致容器无法正常运行。

#### 1.5 Unknown（未知）
- **描述**：当 Kubernetes 无法获取 Pod 的状态信息时，Pod 进入 Unknown 状态。这种情况通常是由于节点与控制平面之间的通信问题导致的。
- **可能的原因**：
    - 节点网络故障。
    - kubelet 服务在节点上出现问题。

### 2. Pod 生命周期中的事件
在 Pod 的生命周期中，会发生一些重要的事件，这些事件可以帮助你了解 Pod 的状态变化和故障原因。

#### 2.1 容器创建事件
- **描述**：当 Kubernetes 开始在节点上创建 Pod 中的容器时，会触发容器创建事件。这通常发生在 Pod 被调度到节点上之后。
- **查看方法**：可以使用 `kubectl describe pod <pod-name>` 命令查看 Pod 的事件信息，其中包含容器创建的相关事件。

#### 2.2 容器启动事件
- **描述**：当容器成功启动后，会触发容器启动事件。这表示容器已经开始运行。
- **查看方法**：同样可以使用 `kubectl describe pod <pod-name>` 命令查看容器启动事件。

#### 2.3 容器终止事件
- **描述**：当容器以某种方式终止时，会触发容器终止事件。终止原因可以是正常退出、异常退出等。
- **查看方法**：使用 `kubectl describe pod <pod-name>` 命令查看容器终止事件，其中会包含退出码和终止原因。

### 3. Pod 生命周期中的钩子（Hooks）
Kubernetes 提供了两种类型的钩子，允许你在容器的生命周期中特定的时间点执行自定义操作。

#### 3.1 PostStart 钩子
- **描述**：PostStart 钩子在容器创建完成后立即执行，但不保证在容器的 `ENTRYPOINT` 执行之前完成。
- **用途**：可以用于初始化容器环境、配置应用程序等。
- **示例**：
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: nginx
    lifecycle:
      postStart:
        exec:
          command: ["/bin/sh", "-c", "echo 'PostStart hook executed'"]
```

#### 3.2 PreStop 钩子
- **描述**：PreStop 钩子在容器终止之前执行，通常用于优雅地关闭应用程序、释放资源等。
- **用途**：确保应用程序在容器终止前有机会完成正在进行的任务，避免数据丢失。
- **示例**：
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: nginx
    lifecycle:
      preStop:
        exec:
          command: ["/bin/sh", "-c", "nginx -s quit"]
```

### 4. Pod 重启策略
Kubernetes 提供了三种重启策略，用于控制 Pod 中的容器在终止后是否重启。

#### 4.1 Always
- **描述**：无论容器以何种方式终止（正常退出或异常退出），Kubernetes 都会自动重启容器。这是默认的重启策略。
- **适用场景**：适用于需要始终保持运行状态的应用程序，如 Web 服务器。

#### 4.2 OnFailure
- **描述**：只有当容器以非零退出码终止时，Kubernetes 才会重启容器。如果容器正常退出（退出码为 0），则不会重启。
- **适用场景**：适用于一次性任务或批处理作业，任务成功完成后不需要重启。

#### 4.3 Never
- **描述**：无论容器以何种方式终止，Kubernetes 都不会重启容器。
- **适用场景**：适用于不需要重启的应用程序，如执行一次即结束的脚本。

以下是一个指定重启策略的 Pod 示例：
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  restartPolicy: OnFailure
  containers:
  - name: my-container
    image: nginx
```





## pod的调度方式

- **概述**：Kubernetes 调度器是一个控制平面组件，负责监听新创建且未调度的 Pod，并根据一系列规则和算法为其选择合适的节点。
- 工作流程
  - **过滤阶段（Predicates）**：调度器首先根据节点的资源可用性、硬件兼容性等条件过滤掉不满足 Pod 要求的节点，筛选出一个可用节点列表。
  - **打分阶段（Priorities）**：对过滤后的节点进行打分，根据节点的资源使用情况、拓扑结构等因素，为每个节点分配一个分数。
  - **选择节点**：调度器选择分数最高的节点，并将 Pod 绑定到该节点上。

### 四大类调度方式

自动调度：运行在哪个节点上完全由Scheduler经过一系列的算法计算得出

定向调度：NodeName、NodeSelector

亲和性调度：NodeAffinity、PodAffinity、PodAntiAffinity

污点（容忍）调度：Taints、Toleration



#### **1.定向调度**

定向调度，指的是利用在pod上声明nodeName或者nodeSelector，以此将Pod调度到期望的node节点上。注意，这里的调度是强制的，这就意味着即使要调度的目标Node不存在，也会向上面进行调度，只不过pod运行失败而已。

- **作用**：通过标签选择器的方式将 Pod 调度到具有特定标签的节点上。
- **使用方法**：在 Pod 定义中添加 `nodeSelector` 字段，指定节点标签。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: nginx
  nodeSelector:
    disktype: ssd
# 这里表示将 Pod 调度到具有 `disktype: ssd` 标签的节点上。
```



#### 2.亲和调度

##### 节点亲和性与反亲和性
- **节点亲和性（Node Affinity）**
    - **作用**：更灵活地控制 Pod 调度到特定节点上，支持软规则和硬规则。
    - **示例**：
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/e2e-az-name
            operator: In
            values:
            - e2e-az1
            - e2e-az2
  containers:
  - name: my-container
    image: nginx
```
表示 Pod 必须调度到具有 `kubernetes.io/e2e-az-name` 标签且值为 `e2e-az1` 或 `e2e-az2` 的节点上。



- **节点反亲和性（Node Anti - Affinity）**
    - **作用**：避免 Pod 调度到某些节点上，同样支持软规则和硬规则。
    - **示例**：
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        preference:
          matchExpressions:
          - key: kubernetes.io/e2e-az-name
            operator: NotIn
            values:
            - e2e-az3
  containers:
  - name: my-container
    image: nginx
```
表示尽量避免将 Pod 调度到具有 `kubernetes.io/e2e-az-name` 标签且值为 `e2e-az3` 的节点上。





##### Pod 亲和性与反亲和性
- **Pod 亲和性（Pod Affinity）**
    - **作用**：使 Pod 倾向于调度到与其他特定 Pod 位于同一拓扑域（如节点、可用区等）的节点上。
    - **示例**：
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - web
        topologyKey: kubernetes.io/hostname
  containers:
  - name: my-container
    image: nginx
```
表示该 Pod 必须调度到与具有 `app: web` 标签的 Pod 在同一节点上。
- **Pod 反亲和性（Pod Anti - Affinity）**
    - **作用**：使 Pod 倾向于调度到与其他特定 Pod 不在同一拓扑域的节点上，常用于避免单点故障。
    - **示例**：
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - web
          topologyKey: kubernetes.io/hostname
  containers:
  - name: my-container
    image: nginx
```
表示尽量将该 Pod 调度到与具有 `app: web` 标签的 Pod 不在同一节点上。





#### 3.污点（Taints）和容忍度（Tolerations）

- **污点（Taints）**
    - **作用**：应用在节点上，防止 Pod 被调度到该节点，除非 Pod 具有相应的容忍度。
    - **设置方法**：使用 `kubectl taint nodes` 命令为节点添加污点。
    - **示例**：`kubectl taint nodes node1 key=value:NoSchedule`
- **容忍度（Tolerations）**
    - **作用**：定义在 Pod 上，允许 Pod 调度到具有特定污点的节点上。
    - **示例**：
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  tolerations:
  - key: "key"
    operator: "Equal"
    value: "value"
    effect: "NoSchedule"
  containers:
  - name: my-container
    image: nginx
```
这个 Pod 可以调度到具有 `key=value:NoSchedule` 污点的节点上。



#### 4.调度优先级和抢占（属于自动调度的一部分）

- **优先级类（PriorityClass）**
  - **作用**：为 Pod 定义优先级，调度器优先调度高优先级的 Pod。
  - **示例**：

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000
globalDefault: false
description: "This priority class should be used for high priority pods."
```

- **抢占（Preemption）**
  - **作用**：当高优先级的 Pod 无法调度时，调度器可以将低优先级的 Pod 从节点上驱逐，为高优先级 Pod 腾出资源。









