# K8S - 数据存储

### 基本存储方式

##### EmptyDir   临时存储 

EmptyDir是最基础的Volume类型，一个EmptyDir就是Host上的一个空目录。

EmptyDir是在Pod被分配到Node时创建的，它的初始内容为空，并且无须指定宿主机上对应的目录文件，因为kubernetes会自动分配一个目录，当Pod销毁时，EmptyDir中的数据也会被永久删除。 

##### HostPath  持久存储  

emptyDir中数据不会被持久化，它会随着Pod的结束而销毁，如果想简单的将数据持久化到主机中，可以选择HostPath。

HostPath就是将Node主机中一个实际目录挂在到Pod中，以供容器使用，这样的设计就可以保证Pod销毁了，但是数据依据可以存在于Node主机上。

#####   NFS 网络存储

HostPath可以解决数据持久化的问题，但是一旦Node节点故障了，Pod如果转移到了别的节点，又会出现问题了，此时需要准备单独的网络存储系统，比较常用的用NFS、CIFS。

NFS是一个网络文件存储系统，可以搭建一台NFS服务器，然后将Pod中的存储直接连接到NFS系统上，这样的话，无论Pod在节点上怎么转移，只要Node跟NFS的对接没问题，数据就可以成功访问。







### 高级存储

在 Kubernetes (K8S) 中，**PersistentVolume (PV)** 和 **PersistentVolumeClaim (PVC)** 是用于管理存储资源的核心概念

它们帮助用户抽象底层存储细节，提供了一种灵活且可扩展的存储管理方式。

#### 1. PV
**PersistentVolume (PV)** 是集群中的一块存储资源，由管理员预先配置或通过 StorageClass 动态创建。PV 独立于 Pod 的生命周期，即使 Pod 被删除，PV 中的数据仍然保留。

##### PV 的特点：

- **集群级别资源**：PV 是集群级别的资源，不属于任何命名空间。
- **存储后端**：PV 可以基于多种存储后端，如 NFS、iSCSI、云存储（如 AWS EBS、GCP Persistent Disk）等。
- **静态或动态配置**：PV 可以手动创建（静态配置），也可以通过 StorageClass 动态创建。
- **访问模式**：PV 支持不同的访问模式，如 `ReadWriteOnce`（单个节点读写）、`ReadOnlyMany`（多个节点只读）、`ReadWriteMany`（多个节点读写）。

##### PV 示例：
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: example-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/data
```
- `capacity`：定义存储容量。
- `accessModes`：定义访问模式。
- `persistentVolumeReclaimPolicy`：定义 PV 回收策略，如 `Retain`（保留数据）、`Delete`（删除数据）、`Recycle`（废弃，已弃用）。
- `storageClassName`：指定 PV 的存储类名称。
- `hostPath`：指定存储路径（仅用于测试环境）。

---

#### 2. PVC
**PersistentVolmeClaim (PVC)** 是用户对存储资源的请求。PVC 会绑定到合适的 PV，从而为 Pod 提供存储。

##### PVC 的特点：

- **命名空间级别资源**：PVC 属于特定的命名空间。
- **动态绑定**：PVC 可以根据请求的存储大小和访问模式自动绑定到合适的 PV。
- **存储类支持**：PVC 可以通过 `storageClassName` 指定所需的存储类，从而动态创建 PV。

##### PVC 示例：

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: example-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: manual
```
- `accessModes`：定义所需的访问模式。
- `resources.requests.storage`：定义所需的存储大小。
- `storageClassName`：指定所需的存储类名称。

---

#### 3. PV 和 PVC 的关系
- **绑定**：PVC 会根据其请求的存储大小、访问模式和存储类，绑定到合适的 PV。
- **生命周期**：
  - PV 和 PVC 的生命周期是独立的。
  - 当 PVC 被删除时，PV 的回收策略（如 `Retain` 或 `Delete`）决定了 PV 的后续处理方式。
- **动态供应**：如果 PVC 指定了 `storageClassName`，并且集群中配置了相应的 StorageClass，Kubernetes 会自动创建 PV 并绑定到 PVC。

---

#### 4. StorageClass
**StorageClass** 是用于动态创建 PV 的模板。它定义了存储后端的类型、参数和回收策略。

#### StorageClass 示例：
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Delete
volumeBindingMode: Immediate
```
- `provisioner`：指定存储后端的驱动。
- `parameters`：定义存储后端的参数。
- `reclaimPolicy`：定义 PV 的回收策略。
- `volumeBindingMode`：定义 PV 的绑定模式（如 `Immediate` 或 `WaitForFirstConsumer`）。

---

#### 5. 使用场景
- **有状态应用**：如数据库（MySQL、PostgreSQL）需要持久化存储。
- **共享存储**：如 NFS 或云存储，支持多 Pod 共享数据。
- **动态存储**：通过 StorageClass 动态创建 PV，适合需要频繁创建和删除存储的场景。



#### 6.生命周期

PVC和PV是一一对应的，PV和PVC之间的相互作用遵循以下生命周期：

（1）资源供应：管理员手动创建底层存储和PV。

（2）资源绑定：用户创建PVC，kubernetes负责根据PVC的声明去寻找PV，并绑定在用户定义好PVC之后，系统将根据PVC对存储资源的请求在已存在的PV中选择一个满足条件的

A.一旦找到，就将该PV与用户定义的PVC进行绑定，用户的应用就可以使用这个PVC了

B.如果找不到，PVC则会无限期处于Pending状态，直到等到系统管理员创建了一个符合其要求的PV，PV一旦绑定到某个PVC上，就会被这个PVC独占，不能再与其他PVC进行绑定了

（3）资源使用：用户可在pod中像volume一样使用pvc													

Pod使用Volume的定义，将PVC挂载到容器内的某个路径进行使用。

（4）资源释放：用户删除pvc来释放pv

当存储资源使用完毕后，用户可以删除PVC，与该PVC绑定的PV将会被标记为“已释放”，但还不能立刻与其他PVC进行绑定。通过之前PVC写入的数据可能还被留在存储设备上，只有在清除之后该PV才能再次使用。

（5）资源回收：kubernetes根据pv设置的回收策略进行资源的回收

对于PV，管理员可以设定回收策略，用于设置与之绑定的PVC释放资源之后如何处理遗留数据的问题。只有PV的存储空间完成回收，才能供新的PVC绑定和使用；

![img](K8S%20-%20%E6%95%B0%E6%8D%AE%E5%AD%98%E5%82%A8.assets/wps1.jpg)

---

#### 6. 总结
- **PV** 是集群中的存储资源，**PVC** 是用户对存储资源的请求。
- **StorageClass** 用于动态创建 PV。
- PV 和 PVC 的绑定使得存储管理更加灵活和自动化，适合各种有状态应用的部署需求。

通过 PV 和 PVC，Kubernetes 提供了一种高效、灵活的存储管理方式，能够满足不同应用场景的需求。





