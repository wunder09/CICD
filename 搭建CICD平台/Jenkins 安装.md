# Jenkins 安装

### 配置java环境

### 安装jenkins

​    0.[Jenkins](https://www.jenkins.io/)

1. #### 添加 Jenkins 官方仓库：

   ```bash
   sudo wget -O /etc/yum.repos.d/jenkins.repo \
       https://pkg.jenkins.io/redhat-stable/jenkins.repo
   sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
   ```

2. #### 安装 Jenkins：

   ```bash
   sudo yum install jenkins
   ```

### 启动jenkins服务

```bash
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

###  **访问 Jenkins**

1. 打开浏览器，访问 `http://<服务器IP>:8080`。

2. 首次访问时，需要输入初始管理员密码。密码可以在以下文件中找到：

   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

3. 输入密码后，按照提示完成 Jenkins 的初始配置。



### 配置

初始的插件管理，可以不选，在构建的时候按需安装。

![img](Jenkins%20%E5%AE%89%E8%A3%85.assets/wps1.jpg)



### 进入

![img](Jenkins%20%E5%AE%89%E8%A3%85.assets/wps2-1741013298695.jpg)



### 插件管理

Jenkins国外官方插件地址下载速度非常慢，所以可以修改为国内插件地址：

Jenkins->Manage Jenkins->Manage Plugins，点击Available

修改后要重启jenkins http://{ip}/restart

![img](Jenkins%20%E5%AE%89%E8%A3%85.assets/wps3.jpg)

### Jenkins凭证管理

凭据可以用来存储需要密文保护的数据库密码、Gitlab密码信息、Docker私有仓库密码等，以便Jenkins可以和这些第三方的应用进行交互。

要在Jenkins使用凭证管理功能，需要安装Credentials Binding插件

![img](Jenkins%20%E5%AE%89%E8%A3%85.assets/wps6.jpg)

安装插件后，左边多了 "凭证"菜单，在这里管理所有凭证

![img](Jenkins%20%E5%AE%89%E8%A3%85.assets/wps7.jpg)

可以添加的凭证有 5种：

![img](Jenkins%20%E5%AE%89%E8%A3%85.assets/wps8.jpg) 

Username with password ：用户名和密码

SSH Username with private key ： 使用SSH用户和密钥

Secret file ：需要保密的文本文件，使用时Jenkins会将文件复制到一个临时目录中，再将文件路径设置到一个变量中，等构建结束后，所复制的Secret file就会被删除。

Secret text ：需要保存的一个加密的文本串，如钉钉机器人或Github的api token

Certificate ：通过上传证书文件的方式



### Git插件与工具

为了让Jenkins支持从Gitlab拉取源码，需要安装Git插件以及在ECS上安装Git工具。 

![img](Jenkins%20%E5%AE%89%E8%A3%85.assets/wps9.jpg)





到此，jenkins安装与常用插件已经准备就绪。