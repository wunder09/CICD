# 配置ES集群 

### 前提条件

- 确保每个节点上已安装相同版本的 Elasticsearch。
- 各节点之间网络互通，能够互相访问。



#### 步骤一：修改 Elasticsearch 配置文件

在每个节点上编辑 `/etc/elasticsearch/elasticsearch.yml` 文件，进行如下配置：

```yaml
# 集群名称，所有节点的集群名称必须一致
cluster.name: my-es-cluster
# 启用跨域请求，方便后续调试和监控
http.cors.enabled: true
http.cors.allow-origin: "*"
```

#### 节点特定配置

每个节点需要根据自身情况进行以下不同的配置：

```yaml
# 节点名称，用于标识该节点
node.name: node-1
# 节点角色，这里设置为可以作为主节点和数据节点
node.roles: [ master, data ]
# 节点监听的网络地址，0.0.0.0 表示监听所有可用的网络接口
network.host: 0.0.0.0
# 节点对外提供服务的端口
http.port: 9200
# 用于集群内部通信的端口
transport.port: 9300
# 用于集群发现的初始节点列表，这里填写各节点的 IP 地址和传输端口
discovery.seed_hosts: ["192.168.1.100:9300", "192.168.1.101:9300", "192.168.1.102:9300"]
# 初始的主节点列表，这里指定了所有可能成为主节点的节点名称
cluster.initial_master_nodes: ["node-1", "node-2"]
```



#### 步骤二：启动 Elasticsearch 服务

在每个节点上执行以下命令启动 Elasticsearch 服务：

```bash
sudo systemctl start elasticsearch
```



#### 步骤三：验证集群状态

可以使用以下命令来验证集群是否正常工作：

```bash
curl -u elastic -X GET "localhost:9200/_cluster/health?pretty"
```

![image-20250311230207947](C:%5CUsers%5CAdministrator%5CAppData%5CRoaming%5CTypora%5Ctypora-user-images%5Cimage-20250311230207947.png)