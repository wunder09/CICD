

# Gitlab

GitLab是一个基于Git的代码托管和协作平台，提供了从代码管理到持续集成/持续部署（CI/CD）的全方位 DevOps功能。

### 阿里云ECS 

阿里云 ECS 是一种弹性可扩展的计算服务，它为用户提供了在云端的虚拟服务器实例，让用户可以像使用本地服务器一样，在云端按需获取和使用计算资源，而无需自己购买和维护物理服务器硬件。用户可以根据自身业务需求，灵活地调整计算资源的配置，如 CPU、内存、存储、网络等，以适应不同的业务负载和需求变化。Root@123

请在安装前确认：

- 操作系统：Linux系统。具体支持的系统说明，请参见[Supported OSes](https://docs.gitlab.com/ee/administration/package_information/supported_os.html)。
- 实例已分配固定公网IP地址或绑定弹性公网IP（EIP）。如您不清楚如何开通公网，请参见[开通公网](https://help.aliyun.com/zh/ecs/user-guide/best-practices-for-configuring-public-bandwidth)。
- 已在安全组内添加入方向规则放行80、443、22端口。具体操作，请参见[添加安全组规则](https://help.aliyun.com/zh/ecs/user-guide/add-a-security-group-rule#concept-sm5-2wz-xdb)。端口说明，请参见[常用端口](https://help.aliyun.com/zh/ecs/user-guide/common-ports)。

首先在阿里云创建云服务器ECS并链接。

![image-20250223194620303](ECS%20_Gitlab.assets/image-20250223194620303.png)

### 安装gitlab 极狐版

极狐GitLab的服务器都在中国境内，网络访问速度更快。

```shell
#安装GitLab所需的依赖包
sudo yum install -y curl python3-policycoreutils openssh-server
#添加GitLab软件包仓库
curl -fsSL https://get.gitlab.cn | sudo /bin/bash
#安装gitlab
sudo EXTERNAL_URL=<GitLab服务器的公网IP地址> yum install -y gitlab-jh
```

![image-20250223195123307](ECS%20_Gitlab.assets/image-20250223195123307.png)

### 安装成功

![image-20250223210917216](ECS%20_Gitlab.assets/image-20250223210917216.png)

```shell
sudo EXTERNAL_URL=<GitLab服务器的公网IP地址> yum install -y gitlab-jh
```

```shell
sudo EXTERNAL_URL=112.124.46.234 yum install -y gitlab-jh
```

这条命令会在安装 GitLab 极狐版时，将 `EXTERNAL_URL` 设置为 `47.98.169.106`，并将其写入 GitLab 的配置文件 `/etc/gitlab/gitlab.rb` 中。GitLab 会使用这个 URL 作为访问地址。

出现此回显表示安装成功，

![image-20250223212033891](ECS%20_Gitlab.assets/image-20250223212033891.png)



### 进入GitLab管理页面

1. 在浏览器输入网址。访问网址： http://${ECS的公网IP} 。
2. 或者使用容器  需要添加访问端口

### 添加安全组访问规则

设置入方向的访问端口，否则访问不到。

![image-20250223213721289](ECS%20_Gitlab.assets/image-20250223213721289.png)



### 首次登陆获取密码

sudo cat /etc/gitlab/initial_root_password

7ppM9Oz8xDDfkUejxUIui8tHB5ursMOeZyM6y79lVdU=

![image-20250223213922271](ECS%20_Gitlab.assets/image-20250223213922271.png)

### 部署成功

![image-20250223214108497](ECS%20_Gitlab.assets/image-20250223214108497.png)

 

### 添加密钥

![image-20250223214652959](ECS%20_Gitlab.assets/image-20250223214652959.png)



在注册 Runner 之前，必须先安装 GitLab Runner。[如何安装 GitLab Runner？](http://121.43.225.123/admin/runners/1/register#)

```bash
# Download the binary for your system
sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.gitlab.cn/latest/binaries/gitlab-runner-linux-amd64

# Give it permission to execute
sudo chmod +x /usr/local/bin/gitlab-runner

# Create a GitLab Runner user
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash

# Install and run as a service
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner start
```

[在 GNU/Linux 上手动安装 GitLab Runner |GitLab 文档](https://docs.gitlab.com/runner/install/linux-manually/)

### RUNNER

在极狐GitLab 中，runners 是运行 CI/CD 作业的代理。

![image-20250223221024476](ECS%20_Gitlab.assets/image-20250223221024476.png)



创建一个 `.gitlab-ci.yml` 文件：

1. 在左侧边栏中，选择 **项目信息 > 详细信息**。

2. 在文件列表上方，选择要提交的分支，点击加号图标，然后选择 **新建文件**：

   [![New file](https://gitlab.cn/docs/jh/ci/quick_start/img/new_file_v13_6.png)](https://gitlab.cn/docs/jh/ci/quick_start/img/new_file_v13_6.png)

### 注册运行程序

![image-20250223222135195](ECS%20_Gitlab.assets/image-20250223222135195.png)



![image-20250223222102420](ECS%20_Gitlab.assets/image-20250223222102420.png)





### 创建文件  `.gitlab-ci.yml`

1. 在左侧边栏中，选择 **项目信息 > 详细信息**。

2. 在文件列表上方，选择要提交的分支，点击加号图标，然后选择 **新建文件**：

   [![New file](ECS%20_Gitlab.assets/new_file_v13_6.png)](https://gitlab.cn/docs/jh/ci/quick_start/img/new_file_v13_6.png)

```yaml
build-job:
  stage: build
  script:

   - echo "Hello, $GITLAB_USER_LOGIN!"

test-job1:
  stage: test
  script:
    - echo "This job tests something"

test-job2:
  stage: test
  script:
    - echo "This job tests something, but takes more time than test-job1."
    - echo "After the echo commands complete, it runs the sleep command for 20 seconds"
    - echo "which simulates a test that runs 20 seconds longer than test-job1"
    - sleep 20

deploy-prod:
  stage: deploy
  script:

   - echo "This job deploys something from the $CI_COMMIT_BRANCH branch."
     environment: production

```

![image-20250225201552745](ECS%20_Gitlab.assets/image-20250225201552745.png)

## 确认电子邮箱

![image-20250224223104823](ECS%20_Gitlab.assets/image-20250224223104823.png)

## **创建项目并托管代码**

### **创建新项目**

1. 在GitLab的主页中，单击页面右侧的**New Project**按钮，然后单击**Create blank project**。

   <img src="ECS%20_Gitlab.assets/p513103.png" alt="ada55" style="zoom: 33%;" />

2. 单击**Create blank project**，设置**Project name**和**Project URL**，然后单击页面底部的**Create project**。本文以mywork项目为例进行说明。

   <img src="ECS%20_Gitlab.assets/p872617.png" alt="image" style="zoom:33%;" />

3. 回到项目页面，复制SSH克隆地址，该地址在进行克隆操作时需要使用。

   <img src="ECS%20_Gitlab.assets/p872659.png" alt="image" style="zoom:33%;" />