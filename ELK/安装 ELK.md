# 在 Ubuntu 系统中安装 ELK

### 系统架构

![image-20250311224606430](C:%5CUsers%5CAdministrator%5CAppData%5CRoaming%5CTypora%5Ctypora-user-images%5Cimage-20250311224606430.png)

### 安装 Elasticsearch

0. **默认已安装JDK环境**

1. **导入 Elasticsearch 的 GPG 密钥**
    
    ```bash
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
    ```
此命令用于下载并导入 Elasticsearch 的 GPG 密钥，确保下载的软件包来源可信。
    
2. **添加 Elasticsearch 软件源**
    ```bash
    echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
    ```
    这一步将 Elasticsearch 8.x 版本的软件源添加到系统的软件源列表中。

3. **更新软件包列表**
    ```bash
    sudo apt-get update
    ```
    更新软件包列表，使系统能够识别新添加的 Elasticsearch 软件源。

4. **安装 Elasticsearch**
    ```bash
    sudo apt-get install elasticsearch
    ```
    执行该命令安装 Elasticsearch。

5. **配置 Elasticsearch**
    编辑 `/etc/elasticsearch/elasticsearch.yml` 文件，根据需要进行配置，例如可以修改以下参数：
    ```yaml
    cluster.name: my-application
    node.name: node-1
    network.host: 0.0.0.0
    discovery.seed_hosts: ["127.0.0.1"]
    cluster.initial_master_nodes: ["node-1"]
    ```
    - `cluster.name`：集群的名称。
    - `node.name`：节点的名称。
    - `network.host`：设置 Elasticsearch 监听的网络地址，`0.0.0.0` 表示监听所有可用的网络接口。
    - `discovery.seed_hosts`：指定用于集群发现的初始节点列表。
    - `cluster.initial_master_nodes`：指定初始的主节点。

6. **启动并设置开机自启**
    ```bash
    sudo systemctl start elasticsearch
    sudo systemctl enable elasticsearch
    ```
    启动 Elasticsearch 服务，并设置为开机自启。

7. **验证安装**
    ```bash
    curl -u elastic https://localhost:9200
    ```
    首次运行此命令时，系统会提示输入 `elastic` 用户的密码，密码可以在 `/var/log/elasticsearch/elasticsearch-xxxx.log` 文件中找到初始密码。输入密码后，如果能看到 Elasticsearch 的相关信息，则说明安装成功。
    
    
    
8. **验证端口及监听地址 netstat -ntpl**

    ![img](file:///C:\Users\ADMINI~1\AppData\Local\Temp\ksohtml11548\wps1.jpg) 

    **通过浏览器访问ES**

    ![img](file:///C:\Users\ADMINI~1\AppData\Local\Temp\ksohtml11548\wps2.jpg) 

    

### 安装 Kibana
1. **安装 Kibana**
    ```bash
    sudo apt-get install kibana
    ```
    执行该命令安装 Kibana。

2. **配置 Kibana**
    编辑 `/etc/kibana/kibana.yml` 文件，配置如下：
    ```yaml
    server.host: "0.0.0.0"
    elasticsearch.hosts: ["https://localhost:9200"]
    elasticsearch.username: "kibana_system"
    elasticsearch.password: "your_password"
    ```
    - `server.host`：设置 Kibana 监听的网络地址，`0.0.0.0` 表示监听所有可用的网络接口。
    
    - `elasticsearch.hosts`：指定 Elasticsearch 的地址。

    - `elasticsearch.username` 和 `elasticsearch.password`：设置连接 Elasticsearch 的用户名和密码，`kibana_system` 是 Kibana 连接 Elasticsearch 的默认用户。
    
      
    
3. **启动并设置开机自启**
    ```bash
    sudo systemctl start kibana
    sudo systemctl enable kibana
    ```
    启动 Kibana 服务，并设置为开机自启。

    
    
4. **验证安装**
    在浏览器中访问 `http://your_server_ip:5601`，如果能看到 Kibana 的登录界面，则说明安装成功。

![image-20250311230620366](%E5%AE%89%E8%A3%85%20ELK.assets/image-20250311230620366.png)

### 安装 Logstash
1. **安装 Logstash**
    ```bash
    sudo apt-get install logstash
    ```
    执行该命令安装 Logstash。

2. **配置 Logstash**
    在 `/etc/logstash/conf.d` 目录下创建一个配置文件，例如 `example.conf`，内容如下：
    ```conf
    input {
        file {
            path => "/var/log/syslog"
            start_position => "beginning"
        }
    }
    filter {
        grok {
            match => { "message" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?: %{GREEDYDATA:syslog_message}" }
        }
    }
    output {
        elasticsearch {
            hosts => ["https://localhost:9200"]
            user => "elastic"
            password => "your_password"
            index => "logstash-%{+YYYY.MM.dd}"
        }
    }
    ```
    - `input`：定义日志的输入源，这里以系统日志 `/var/log/syslog` 为例。
    - `filter`：对日志进行过滤和解析，使用 `grok` 插件将日志内容解析为结构化数据。
    - `output`：将处理后的日志输出到 Elasticsearch，指定 Elasticsearch 的地址、用户名、密码和索引名称。

3. **启动并设置开机自启**
    ```bash
    sudo systemctl start logstash
    sudo systemctl enable logstash
    ```
    启动 Logstash 服务，并设置为开机自启。

    
    
4. **验证安装**
    可以在 Kibana 的 Dev Tools 中执行查询语句，查看 Logstash 是否成功将日志数据写入 Elasticsearch：
    ```json
    GET logstash-*/_search
    ```
    如果能看到相关的日志数据，则说明 Logstash 安装和配置成功。

通过以上步骤，你就可以在 Ubuntu 系统中成功安装并配置 ELK 堆栈。