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