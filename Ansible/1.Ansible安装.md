# Ansible

ansible是一种由Python开发的自动化运维工具，集合了众多运维工具（puppet、cfengine、chef、func、fabric）的优点，实现了批量系统配置、批量程序部署、批量运行命令等功能。ansible是基于模块工作的，本身没有批量部署的能力。真正具有批量部署的是ansible所运行的模块，ansible只是提供一种框架。



### 安装前准备
在安装 Ansible 之前，需要确保满足以下条件：
- 控制节点（运行 Ansible 的机器）：建议使用类 Unix 系统，如 Linux 或 macOS。
- 被管理节点：可以是任何支持 SSH 协议的系统，包括 Linux、Windows（需安装 OpenSSH 服务器）、macOS 等。
- 网络连接：控制节点和被管理节点之间需要能够通过 SSH 进行通信。

### 安装 Ansible

##### CentOS 系统
1. **启用 EPEL 存储库**
```bash
sudo yum install epel-release
```
2. **安装 Ansible**
```bash
sudo yum install ansible
```
3. **验证安装**
```bash
ansible --version
```

### 部署 Ansible

#### 配置 Ansible
Ansible 的主要配置文件是 `/etc/ansible/ansible.cfg`，但通常建议在用户目录下创建自己的配置文件，避免修改系统级配置。以下是基本的配置步骤：
1. **创建配置文件**
在用户目录下创建一个 `.ansible.cfg` 文件：
```bash
touch ~/.ansible.cfg
```
2. **编辑配置文件**
可以使用文本编辑器（如 `vim` 或 `nano`）打开该文件，并添加以下基本配置：
```ini
[defaults]
inventory = ~/ansible/inventory
remote_user = your_remote_user
```
- `inventory`：指定 Ansible 的主机清单文件路径。
- `remote_user`：指定连接到被管理节点时使用的用户名。

#### 创建主机清单文件
主机清单文件用于指定 Ansible 要管理的节点信息。可以按照以下步骤创建和配置主机清单文件：
1. **创建主机清单目录和文件**
```bash
mkdir ~/ansible
touch ~/ansible/inventory
```
2. **编辑主机清单文件**
打开 `~/ansible/inventory` 文件，并添加被管理节点的信息。例如：
```ini
[web_servers]
192.168.1.100
192.168.1.101

[db_servers]
192.168.1.102
```
上述示例中，定义了两个主机组：`web_servers` 和 `db_servers`，并分别列出了属于这些组的主机 IP 地址。

#### 配置 SSH 密钥认证（可选但推荐）
为了避免每次连接被管理节点时都输入密码，可以配置 SSH 密钥认证。以下是基本步骤：
1. **生成 SSH 密钥对**
在控制节点上运行以下命令生成 SSH 密钥对：
```bash
ssh-keygen -t rsa
```
按照提示操作，生成的密钥对默认存储在 `~/.ssh` 目录下。
2. **将公钥复制到被管理节点**
使用 `ssh-copy-id` 命令将公钥复制到被管理节点：
```bash
ssh-copy-id your_remote_user@192.168.1.100
```
重复此步骤，将公钥复制到所有需要管理的节点。

### 测试 Ansible 部署
完成上述安装和配置后，可以使用以下命令测试 Ansible 是否能够正常连接到被管理节点：
```bash
ansible all -m ping
```
- `all`：表示对主机清单中的所有节点执行操作。
- `-m ping`：指定使用 `ping` 模块进行测试。

如果一切配置正确，Ansible 将尝试连接到所有节点并返回类似以下的结果：
```
192.168.1.100 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
192.168.1.101 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
...
```
这表明 Ansible 已经成功连接到被管理节点。

通过以上步骤，你已经完成了 Ansible 的安装与部署，可以开始使用 Ansible 进行自动化运维任务了。 





