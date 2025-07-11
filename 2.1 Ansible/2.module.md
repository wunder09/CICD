# module

Ansible 是一种强大的自动化工具，通过模块（Modules）来实现对各种系统和服务的配置管理、部署和编排。

Ansible 模块是 Ansible 的核心组件，每个模块负责执行特定的任务。以下是一些常用的 Ansible 模块及其功能介绍：

---

### **1. 核心模块**
这些模块是 Ansible 中最常用的基础模块。

#### **`yum` / `apt`**
- **功能**: 管理包（安装、卸载、更新）。
- **`yum`**: 用于基于 Red Hat/CentOS 的系统。
- **`apt`**: 用于基于 Debian/Ubuntu 的系统。
- **示例**:
  ```yaml
  - name: Install Apache
    yum:
      name: httpd
      state: present
  ```

#### **`copy`**
- **功能**: 将文件从控制机复制到目标主机。
- **示例**:
  ```yaml
  - name: Copy a file to the remote server
    copy:
      src: /path/to/local/file
      dest: /path/to/remote/file
      owner: root
      group: root
      mode: '0644'
  ```

#### **`file`**
- **功能**: 管理文件和目录（创建、删除、设置权限等）。
- **示例**:
  ```yaml
  - name: Create a directory
    file:
      path: /path/to/directory
      state: directory
      mode: '0755'
  ```

#### **`service`**
- **功能**: 管理服务（启动、停止、重启、启用开机启动等）。
- **示例**:
  ```yaml
  - name: Start and enable Apache service
    service:
      name: httpd
      state: started
      enabled: yes
  ```

#### **`command` / `shell`**
- **功能**: 在目标主机上执行命令。
- **`command`**: 直接执行命令，不支持管道、重定向等。
- **`shell`**: 支持完整的 Shell 功能（管道、重定向等）。
- **示例**:
  ```yaml
  - name: Run a command
    command: ls -l /tmp
  ```

#### **`user`**
- **功能**: 管理用户（创建、删除、修改用户属性）。
- **示例**:
  ```yaml
  - name: Create a user
    user:
      name: testuser
      state: present
      shell: /bin/bash
  ```

#### **`cron`**
- **功能**: 管理定时任务。
- **示例**:
  ```yaml
  - name: Add a cron job
    cron:
      name: "Backup"
      job: "/opt/backup.sh"
      minute: "0"
      hour: "2"
  ```

---

### **2. 文件管理模块**
这些模块用于处理文件和目录。

#### **`lineinfile`**
- **功能**: 在文件中插入、替换或删除一行。
- **示例**:
  ```yaml
  - name: Ensure a line exists in a file
    lineinfile:
      path: /etc/ssh/sshd_config
      line: "PermitRootLogin no"
      state: present
  ```

#### **`blockinfile`**
- **功能**: 在文件中插入、替换或删除多行文本块。
- **示例**:
  ```yaml
  - name: Add a block of text to a file
    blockinfile:
      path: /etc/nginx/nginx.conf
      block: |
        server {
          listen 80;
          server_name example.com;
        }
  ```

#### **`unarchive`**
- **功能**: 解压文件（支持 tar、zip 等格式）。
- **示例**:
  ```yaml
  - name: Extract a tar file
    unarchive:
      src: /path/to/file.tar.gz
      dest: /path/to/destination
      remote_src: yes
  ```

---

### **3. 网络模块**
这些模块用于管理网络配置和服务。

#### **`uri`**
- **功能**: 发送 HTTP/HTTPS 请求。
- **示例**:
  ```yaml
  - name: Check if a website is reachable
    uri:
      url: http://example.com
      method: GET
  ```

#### **`get_url`**
- **功能**: 从 URL 下载文件。
- **示例**:
  ```yaml
  - name: Download a file
    get_url:
      url: http://example.com/file.tar.gz
      dest: /path/to/destination
  ```

#### **`nmcli`**
- **功能**: 管理网络连接（适用于使用 NetworkManager 的系统）。
- **示例**:
  ```yaml
  - name: Add a network connection
    nmcli:
      conn_name: eth0
      ifname: eth0
      type: ethernet
      ip4: 192.168.1.100/24
      gw4: 192.168.1.1
      state: present
  ```

---

### **4. 云服务模块**
这些模块用于管理云服务（如 AWS、Azure、GCP 等）。

#### **`ec2`**
- **功能**: 管理 AWS EC2 实例。
- **示例**:
  ```yaml
  - name: Launch an EC2 instance
    ec2:
      key_name: mykey
      instance_type: t2.micro
      image: ami-0c55b159cbfafe1f0
      wait: yes
      count: 1
      region: us-east-1
  ```

#### **`s3`**
- **功能**: 管理 AWS S3 存储桶和对象。
- **示例**:
  ```yaml
  - name: Upload a file to S3
    aws_s3:
      bucket: mybucket
      object: /path/to/file
      src: /path/to/local/file
      mode: put
  ```

---

### **5. 数据库模块**
这些模块用于管理数据库。

#### **`mysql_db`**
- **功能**: 管理 MySQL 数据库。
- **示例**:
  ```yaml
  - name: Create a MySQL database
    mysql_db:
      name: mydb
      state: present
  ```

#### **`postgresql_db`**
- **功能**: 管理 PostgreSQL 数据库。
- **示例**:
  ```yaml
  - name: Create a PostgreSQL database
    postgresql_db:
      name: mydb
      state: present
  ```

---

### **6. 容器模块**
这些模块用于管理容器化环境。

#### **`docker_container`**
- **功能**: 管理 Docker 容器。
- **示例**:
  ```yaml
  - name: Start a Docker container  # 任务的名称，用于描述该任务的作用，方便在执行时识别
    docker_container:  # 使用 Ansible 的 docker_container 模块来管理 Docker 容器
      name: mycontainer  # 指定要创建或管理的 Docker 容器的名称为 mycontainer
      image: nginx  # 指定容器所使用的 Docker 镜像为 nginx
      state: started  # 指定容器的状态为启动状态。这意味着如果容器不存在，Ansible 会创建并启动它；如果容器已存在但处于停止状态，Ansible 会将其启动
  ```

#### **`k8s`**
- **功能**: 管理 Kubernetes 资源。
- **示例**:
  ```yaml
  - name: Create a Kubernetes deployment
    k8s:
      state: present
      definition:
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: nginx-deployment
        spec:
          replicas: 3
          template:
            metadata:
              labels:
                app: nginx
            spec:
              containers:
                - name: nginx
                  image: nginx:1.14.2
  ```

