

# Ansible部署Kubernetes 集群

### 1. 环境准备
确保所有节点（1 个主节点，2 个从节点）满足以下条件：
- 操作系统：Ubuntu 20.04 或 CentOS 7/8
- 所有节点之间可以互相 SSH 访问
- 所有节点的 hostname 已经正确设置
- 所有节点的防火墙已经正确配置，允许必要的端口通信

### 2. 安装 Ansible
在控制节点（可以是你的本地机器或某个管理节点）上安装 Ansible：

```bash
sudo apt-get update
sudo apt-get install -y ansible
```

### 3. 创建 Ansible 目录结构
创建一个目录来存放 Ansible 的 playbook 和 inventory 文件：

```bash
mkdir -p ~/k8s-ansible/{group_vars,roles}
cd ~/k8s-ansible
```

### 4. 创建 Inventory 文件
在 `~/k8s-ansible` 目录下创建一个 `inventory` 文件，定义你的主节点和从节点：

```ini
[master]
master-node ansible_host=<master-node-ip>

[workers]
worker-node-1 ansible_host=<worker-node-1-ip>
worker-node-2 ansible_host=<worker-node-2-ip>

[kube-cluster:children]
master
workers
```

### 5. 创建 Group Variables
在 `group_vars` 目录下创建 `all.yml` 文件，定义全局变量：

```yaml
---
ansible_user: <your-ssh-user>
ansible_ssh_private_key_file: <path-to-your-ssh-private-key>

kube_version: "1.23.0"
pod_network_cidr: "10.244.0.0/16"
service_cidr: "10.96.0.0/12"
```

### 6. 创建 Playbook
在 `~/k8s-ansible` 目录下创建一个 `site.yml` 文件，定义整个部署过程：

```yaml
---
- hosts: kube-cluster
  become: yes
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
      when: ansible_os_family == "Debian"

    - name: Install dependencies
      apt:
        name:
          - apt-transport-https
          - ca-certificates
          - curl
          - software-properties-common
        state: present
      when: ansible_os_family == "Debian"

    - name: Add Docker GPG key
      apt_key:
        url: https://download.docker.com/linux/ubuntu/gpg
        state: present
      when: ansible_os_family == "Debian"

    - name: Add Docker repository
      apt_repository:
        repo: deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable
        state: present
      when: ansible_os_family == "Debian"

    - name: Install Docker
      apt:
        name: docker-ce
        state: present
      when: ansible_os_family == "Debian"

    - name: Start and enable Docker
      service:
        name: docker
        state: started
        enabled: yes

    - name: Add Kubernetes GPG key
      apt_key:
        url: https://packages.cloud.google.com/apt/doc/apt-key.gpg
        state: present
      when: ansible_os_family == "Debian"

    - name: Add Kubernetes repository
      apt_repository:
        repo: deb https://apt.kubernetes.io/ kubernetes-xenial main
        state: present
      when: ansible_os_family == "Debian"

    - name: Install kubeadm, kubelet, and kubectl
      apt:
        name:
          - kubeadm={{ kube_version }}-00
          - kubelet={{ kube_version }}-00
          - kubectl={{ kube_version }}-00
        state: present
      when: ansible_os_family == "Debian"

    - name: Disable swap
      shell: |
        swapoff -a
        sed -i '/swap/d' /etc/fstab
      args:
        executable: /bin/bash

- hosts: master
  become: yes
  tasks:
    - name: Initialize Kubernetes cluster
      shell: kubeadm init --pod-network-cidr={{ pod_network_cidr }} --service-cidr={{ service_cidr }}
      args:
        executable: /bin/bash

    - name: Copy kubeconfig to user's home directory
      copy:
        src: /etc/kubernetes/admin.conf
        dest: ~/.kube/config
        remote_src: yes
        owner: "{{ ansible_user }}"
        group: "{{ ansible_user }}"

    - name: Deploy Flannel network
      shell: kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
      args:
        executable: /bin/bash

- hosts: workers
  become: yes
  tasks:
    - name: Join worker nodes to the cluster
      shell: "kubeadm join {{ hostvars['master-node']['stdout'] }} --token <token> --discovery-token-ca-cert-hash sha256:<hash>"
      args:
        executable: /bin/bash
```

### 7. 执行 Playbook
运行以下命令来执行 playbook：

```bash
ansible-playbook -i inventory site.yml
```

### 8. 验证集群
在主节点上运行以下命令来验证集群状态：

```bash
kubectl get nodes
```

你应该看到主节点和两个从节点都处于 `Ready` 状态。

![image-20250316142530059](ansible%E5%AE%89%E8%A3%85k8s%E9%9B%86%E7%BE%A4%20-%20%E5%89%AF%E6%9C%AC.assets/image-20250316142530059.png)

### 9. 部署应用
现在你可以使用 `kubectl` 部署应用了。例如，部署一个简单的 Nginx 应用：

```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
```

### 10. 访问应用
获取服务的 NodePort 并访问：

```bash
kubectl get svc nginx
```

通过 `http://<node-ip>:<node-port>` 访问 Nginx。





### 遇到的问题：

#### 主机之间无法通信

修改 /etc/hosts 配置即可。![image-20250316141915419](ansible%E5%AE%89%E8%A3%85k8s%E9%9B%86%E7%BE%A4%20-%20%E5%89%AF%E6%9C%AC.assets/image-20250316141915419.png)

#### containerd未启用或者版本不适配

```bash
[root@master ansible]# kubeadm init --config=/opt/ansible/kubeadm-config.yaml
[init] Using Kubernetes version: v1.28.2
[preflight] Running pre-flight checks
error execution phase preflight: [preflight] Some fatal errors occurred:
        [ERROR CRI]: container runtime is not running: output: time="2025-03-16T13:28:31+08:00" level=fatal msg="validate service connection: CRI v1 runtime API is not implemented for endpoint \"unix:///var/run/containerd/containerd.sock\": rpc error: code = Unimplemented desc = unknown service runtime.v1.RuntimeService"
, error: exit status 1
```

这个错误表明 `kubeadm` 在预检阶段无法连接到容器运行时（CRI，Container Runtime Interface），具体原因是 `containerd` 未正确配置或未实现 CRI v1 接口。

方法 ：启用 `containerd` 的 CRI 插件

`containerd` 默认情况下可能未启用 CRI 插件，需要手动启用。

1. **编辑 `containerd` 配置文件**：

   - 打开 `/etc/containerd/config.toml` 文件：

     ```
     vi /etc/containerd/config.toml
     ```

   - 确保文件中包含以下内容：

     ```
     version = 2
     [plugins."io.containerd.grpc.v1.cri"]
       sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.9"
     ```

   - 如果文件不存在或为空，可以使用以下命令生成默认配置：

     ```
     containerd config default > /etc/containerd/config.toml
     ```

2. **启用 CRI 插件**：

   - 在 `config.toml` 文件中，确保 `disabled_plugins` 中没有 `cri`。例如：

     ```
     disabled_plugins = []
     ```

   - 如果 `disabled_plugins` 包含 `cri`，将其移除。

3. **重启 `containerd` 服务**：

   - 修改配置文件后，重启 `containerd` 服务以使配置生效：

     ```
     systemctl restart containerd
     ```

4. **验证 `containerd` 是否支持 CRI**：

   - 运行以下命令，检查 `containerd` 是否支持 CRI：

     ```
     ctr version
     ```

   - 如果输出中包含 `RuntimeName: containerd`，说明 CRI 插件已启用。



#### 缺少配置文件

`kubeadm-config.yaml` 是一个自定义的配置文件，用于在初始化 Kubernetes 集群时指定配置参数。

这个文件需要你手动创建，并放置在 Master 节点的某个路径下（例如 `/root/kubeadm-config.yaml`）。

以下是创建和使用 `kubeadm-config.yaml` 的详细步骤：

---

1. **创建 `kubeadm-config.yaml` 文件**

   在 Master 节点上，创建一个名为 `kubeadm-config.yaml` 的文件，并填写以下内容：

   ```yaml
   apiVersion: kubeadm.k8s.io/v1beta3
   kind: InitConfiguration
   localAPIEndpoint:
     advertiseAddress: 192.168.0.10  # 替换为 Master 节点的 IP 地址
     bindPort: 6443
   nodeRegistration:
     criSocket: unix:///var/run/containerd/containerd.sock  # 如果使用 Docker，替换为 `unix:///var/run/docker.sock`
   ---
   apiVersion: kubeadm.k8s.io/v1beta3
   kind: ClusterConfiguration
   kubernetesVersion: v1.28.2  # 指定 Kubernetes 版本
   networking:
     podSubnet: 10.244.0.0/16  # 指定 Pod 网络 CIDR
   imageRepository: registry.aliyuncs.com/google_containers  # 使用阿里云的镜像仓库
   ```

---

3. **使用配置文件初始化集群**

   运行以下命令，使用 `kubeadm-config.yaml` 文件初始化 Kubernetes 集群：

   ```bash
   kubeadm init --config=/root/kubeadm-config.yaml
   ```

---

4. **检查初始化结果**

   - 如果初始化成功，你会看到类似以下的输出：

     ```
     Your Kubernetes control-plane has initialized successfully!

     To start using your cluster, you need to run the following as a regular user:

       mkdir -p $HOME/.kube
       sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
       sudo chown $(id -u):$(id -g) $HOME/.kube/config

     You should now deploy a pod network to the cluster.
     Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
       https://kubernetes.io/docs/concepts/cluster-administration/addons/

     Then you can join any number of worker nodes by running the following on each as root:

     kubeadm join 192.168.0.10:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
     ```

   - 保存输出中的 `kubeadm join` 命令，用于将工作节点加入集群。

![image-20250316133747443](ansible%E5%AE%89%E8%A3%85k8s%E9%9B%86%E7%BE%A4.assets/image-20250316133747443.png)



kubeadm join 192.168.0.110:6443 --token pyibyg.mck702pmbs646arm \
        --discovery-token-ca-cert-hash sha256:62c506da75606fc53bc29e84e4d098d05183b9022c3ff927e67353a453c09fa3

---

5. **配置 `kubectl`**

   在 Master 节点上运行以下命令，配置 `kubectl`：

   ```bash
   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config
   ```

---

6. **部署网络插件**

   部署 Flannel 网络插件：

   ```bash
   kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
   ```

其他方法：

```
wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml 
# 使用阿里云镜像源下载flannel插件
```



7. **验证集群状态**

   运行以下命令，检查集群状态：

   ```bash
   kubectl get nodes
   ```

   如果 Master 节点状态为 `Ready`，说明集群初始化成功。

---

8. **将工作节点加入集群**

   在工作节点上运行 `kubeadm join` 命令，将其加入集群。例如：

   ```bash
   kubeadm join 192.168.0.10:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
   ```

---



#### 路由问题

![image-20250316134009275](ansible%E5%AE%89%E8%A3%85k8s%E9%9B%86%E7%BE%A4.assets/image-20250316134009275.png)

这个错误表明 `kubeadm` 在预检阶段发现 `/proc/sys/net/ipv4/ip_forward` 文件的值未设置为 `1`。这是 Kubernetes 网络配置的一个必要步骤，用于启用 IP 转发功能，以确保 Pod 之间的网络流量能够正确路由。

------

##### 错误原因1

- Kubernetes 需要启用 IP 转发功能，以便 Pod 之间的网络流量能够通过 Linux 内核的路由功能进行转发。

- 如果 `/proc/sys/net/ipv4/ip_forward` 的值未设置为 `1`，Kubernetes 将无法正常工作。

- **永久设置**：
  为了确保系统重启后仍然生效，可以修改系统配置文件。

  - 编辑 `/etc/sysctl.conf` 文件：

    ```
    vi /etc/sysctl.conf
    ```

  - 添加以下内容：

    ```
    net.ipv4.ip_forward = 1
    ```

  - 应用配置：

    ```
    sysctl -p
    ```

- **验证设置**：
  再次检查 `/proc/sys/net/ipv4/ip_forward` 的值，确保已设置为 `1`：

  ```
  cat /proc/sys/net/ipv4/ip_forward
  ```



##### **错误原因2**

- Kubernetes 使用 `bridge-nf-call-iptables` 来控制 Linux 网桥的流量是否经过 iptables 规则。
- 如果该值未设置为 `1`，可能会导致网络流量无法正确路由，从而影响 Pod 之间的通信。

1. **永久设置**：
   为了确保系统重启后仍然生效，可以修改系统配置文件。

   - 编辑 `/etc/sysctl.conf` 文件：

     ```
     vi /etc/sysctl.conf
     ```

   - 添加以下内容：

     ```
     net.bridge.bridge-nf-call-iptables = 1
     net.bridge.bridge-nf-call-ip6tables = 1
     ```

   - 保存并退出编辑器。

     ```
     sysctl -p
     ```

2. **验证设置**：

   ```
   cat /proc/sys/net/bridge/bridge-nf-call-iptables
   ```