# SonarQube 

SonarQube 是一个开源的代码质量管理平台，用于持续检查代码的质量和安全性。它支持多种编程语言，并提供详细的报告，帮助开发团队发现并修复代码中的问题。

### 0.SonarQube 的核心功能
1. **代码质量分析**：
   - 检测代码中的 bug、漏洞和坏味道（code smells）。
   - 提供代码复杂度、重复代码、测试覆盖率等指标。

2. **多语言支持**：
   - 支持 20+ 种编程语言，包括 Java、JavaScript、Python、C#、Go、PHP 等。

3. **规则引擎**：
   - 内置数千条代码质量规则，支持自定义规则。
   - 规则分为 Bug、漏洞、坏味道三类。

4. **集成与扩展**：
   - 支持与 GitLab、Jenkins、GitHub 等工具集成。
   - 提供丰富的插件生态系统。

5. **可视化报告**：
   - 提供直观的仪表盘和详细的报告，帮助团队了解代码健康状况.



### 1. 系统准备

- **Java 安装**：SonarQube 依赖 Java 运行环境，需要安装 Java 11 或更高版本。
```bash
sudo apt update
sudo apt install openjdk-17-jdk
java -version  # 验证 Java 安装
```
- **数据库准备（以 MySQL 为例）**
    - 安装 MySQL 服务器：
```bash
sudo apt install mysql-server
```
    - 启动并设置 MySQL 开机自启：
```bash
sudo systemctl start mysql
sudo systemctl enable mysql
```
    - 登录 MySQL 并创建数据库和用户：
```bash
sudo mysql -u root
CREATE DATABASE sonarqube CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER 'sonarqube'@'%' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON sonarqube.* TO 'sonarqube'@'%';
FLUSH PRIVILEGES;
EXIT;
```

### 2. 安装 SonarQube
- **下载 SonarQube**：从 SonarQube 官方网站下载最新版本的社区版压缩包。
```bash
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-<version>.zip
```
将 `<version>` 替换为你要下载的版本号。
- **解压文件**：
```bash
unzip sonarqube-<version>.zip
sudo mv sonarqube-<version> /opt/sonarqube
```
### 3. 配置 SonarQube
- **数据库配置**：编辑 `/opt/sonarqube/conf/sonar.properties` 文件，配置数据库连接信息。
```bash
sudo nano /opt/sonarqube/conf/sonar.properties
```
找到并修改以下配置：
```plaintext
sonar.jdbc.username=sonarqube
sonar.jdbc.password=your_password
sonar.jdbc.url=jdbc:mysql://localhost:3306/sonarqube?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&useConfigs=maxPerformance&useSSL=false
```
- **内存配置**：可以根据服务器的实际内存情况调整 SonarQube 的内存使用。编辑 `/opt/sonarqube/bin/linux-x86-64/sonar.sh` 文件。
```bash
sudo nano /opt/sonarqube/bin/linux-x86-64/sonar.sh
```
修改 `WRAPPER_OPTS` 中的内存参数，例如：
```plaintext
WRAPPER_OPTS="-Xms512m -Xmx1024m"
```
### 4. 创建 SonarQube 用户
为了安全起见，不建议使用 root 用户运行 SonarQube，需要创建一个新用户。
```bash
sudo useradd -r sonarqube -s /bin/false
sudo chown -R sonarqube:sonarqube /opt/sonarqube
```
### 5. 配置 SonarQube 服务
创建一个 systemd 服务文件来管理 SonarQube。
```bash
sudo nano /etc/systemd/system/sonarqube.service
```
添加以下内容：
```plaintext
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=sonarqube
Group=sonarqube
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
```
重新加载 systemd 管理器配置：
```bash
sudo systemctl daemon-reload
```
启动 SonarQube 服务并设置开机自启：
```bash
sudo systemctl start sonarqube
sudo systemctl enable sonarqube
```
### 6. 配置反向代理
可以使用 Nginx 作为反向代理，将 SonarQube 服务暴露到公网。
- **安装 Nginx**：
```bash
sudo apt install nginx
```
- **配置 Nginx**：创建一个新的 Nginx 配置文件。
```bash
sudo nano /etc/nginx/sites-available/sonarqube
```
添加以下内容：
```plaintext
server {
    listen 80;
    server_name your_domain_or_ip;

    access_log /var/log/nginx/sonar.access.log;
    error_log /var/log/nginx/sonar.error.log;

    location / {
        proxy_pass http://127.0.0.1:9000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
将 `your_domain_or_ip` 替换为你的域名或服务器 IP 地址。
创建软链接并重启 Nginx：
```bash
sudo ln -s /etc/nginx/sites-available/sonarqube /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```
### 7. 访问 SonarQube
打开浏览器，访问 `http://your_domain_or_ip`（如果配置了反向代理）或 `http://your_server_ip:9000`，使用默认用户名 `admin` 和密码 `admin` 登录 SonarQube 控制台。登录后，系统会提示你修改密码。

![img](file:///C:\Users\ADMINI~1\AppData\Local\Temp\ksohtml10796\wps1.jpg)

### 8. 安装 SonarScanner（用于代码分析）
- **下载 SonarScanner**：从 SonarQube 官方网站下载 SonarScanner。
```bash
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-<version>.zip
```
将 `<version>` 替换为你要下载的版本号。
- **解压文件**：
```bash
unzip sonar-scanner-cli-<version>.zip
sudo mv sonar-scanner-<version> /opt/sonar-scanner
```
- **配置 SonarScanner**：编辑 `/opt/sonar-scanner/conf/sonar-scanner.properties` 文件，配置 SonarQube 服务器地址。
```bash
sudo nano /opt/sonar-scanner/conf/sonar-scanner.properties
```
修改以下配置：
```plaintext
sonar.host.url=http://your_domain_or_ip
```
将 `your_domain_or_ip` 替换为你的 SonarQube 服务器地址。
- **添加环境变量**：编辑 `~/.bashrc` 文件，添加 SonarScanner 到环境变量。
```bash
nano ~/.bashrc
```
在文件末尾添加以下内容：
```plaintext
export PATH=$PATH:/opt/sonar-scanner/bin
```
使环境变量生效：
```bash
source ~/.bashrc
```

通过以上步骤，你就完成了 SonarQube 的安装、配置以及 SonarScanner 的设置，可以开始对代码进行质量分析了。 



### 9.在jenkins中配置sonarqube插件

![img](file:///C:\Users\ADMINI~1\AppData\Local\Temp\ksohtml10796\wps2.jpg)





### 10.与 GitLab CI/CD 集成

1. 在 GitLab 项目 → Settings → CI/CD → Variables 中添加 SonarQube 的 Token 和 URL：

   - `SONAR_HOST_URL`：SonarQube 服务器地址。
   - `SONAR_TOKEN`：SonarQube 的认证 Token。

2. 在 `.gitlab-ci.yml` 中添加 SonarQube 分析任务：

   ```yaml
   sonarqube-check:
     stage: test
     image: sonarsource/sonar-scanner-cli:latest
     script:
       - sonar-scanner
         -Dsonar.projectKey=my-project
         -Dsonar.sources=.
         -Dsonar.host.url=$SONAR_HOST_URL
         -Dsonar.login=$SONAR_TOKEN
   ```

