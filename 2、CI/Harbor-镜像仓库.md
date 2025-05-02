# Harbor

Harbor （港口，港湾）是一个用于存储和分发Docker镜像的企业级Registry服务器。

除了Harbor这个私有镜像仓库之外，还有Docker官方提供的Registry。相对Registry，Harbor具有很多优势：

1. 提供分层传输机制，优化网络传输 Docker镜像是是分层的，而如果每次传输都使用全量文件(所以用FTP的方式并不适合)，显然不经济。必须提供识别分层传输的机制，以层的UUID为标识，确定传输的对象。

2. 提供WEB界面，优化用户体验 只用镜像的名字来进行上传下载显然很不方便，需要有一个用户界面可以支持登陆、搜索功能，包括区分公有、私有镜像。

3. 支持水平扩展集群 当有用户对镜像的上传下载操作集中在某服务器，需要对相应的访问压力作分解。

4. 良好的安全机制 企业中的开发团队有很多不同的职位，对于不同的职位人员，分配不同的权限，具有更好的安全性。



### **1.Harbor安装**

需要从Harbor的官方GitHub仓库下载最新版本的Harbor离线安装包。
```bash
# 下载Harbor离线安装包
wget https://github.com/goharbor/harbor/releases/download/v2.9.0/harbor-offline-installer-v2.9.0.tgz
# 解压安装包
tar xvf harbor-offline-installer-v2.9.0.tgz
cd harbor
# 复制示例配置文件
cp harbor.yml.tmpl harbor.yml
# 编辑配置文件
nano harbor.yml
```

在 `harbor.yml` 里，你要对 `hostname` 字段进行修改，使其指向你的Harbor服务器地址。同时，你还可以按需调整其他配置项。

![img](Harbor-%E9%95%9C%E5%83%8F%E4%BB%93%E5%BA%93.assets/wps18.jpg)

### 2、安装并启动Harbor
运行安装脚本，Harbor就会被安装并启动。
```bash
# 执行安装脚本
sudo ./install.sh
```



### 3、访问Harbor

默认账户密码：admin/Harbor12345

![img](Harbor-%E9%95%9C%E5%83%8F%E4%BB%93%E5%BA%93.assets/wps4.jpg) 

### **4、在Harbor创建用户和项目**

##### 1）创建项目

Harbor的项目分为公开和私有的：

公开项目：所有用户都可以访问，通常存放公共的镜像，默认有一个library公开项目。

私有项目：只有授权用户才可以访问，通常存放项目本身的镜像。

我们可以为微服务项目创建一个新的项目：



![img](Harbor-%E9%95%9C%E5%83%8F%E4%BB%93%E5%BA%93.assets/wps6.jpg)

##### 2）创建用户

![img](Harbor-%E9%95%9C%E5%83%8F%E4%BB%93%E5%BA%93.assets/wps7.jpg)





##### 3）给私有项目分配用户

![img](Harbor-%E9%95%9C%E5%83%8F%E4%BB%93%E5%BA%93.assets/wps9.jpg)

![img](Harbor-%E9%95%9C%E5%83%8F%E4%BB%93%E5%BA%93.assets/wps10.jpg)

![img](Harbor-%E9%95%9C%E5%83%8F%E4%BB%93%E5%BA%93.assets/wps11.jpg)

![img](Harbor-%E9%95%9C%E5%83%8F%E4%BB%93%E5%BA%93.assets/wps12.jpg)

##### 4 ）以新用户登录Harbor

![img](Harbor-%E9%95%9C%E5%83%8F%E4%BB%93%E5%BA%93.assets/wps13.jpg)



### **4.把镜像上传到Harbor**

1）给镜像打上标签

```bash
docker tag <source-image> <harbor-url>/<project-name>/<destination-image>
```

2）推送镜像

```bash
docker push <harbor-url>/<project-name>/<image-name>
```

### **5.从Harbor下载镜像**

需求：在harbor服务器完成从Harbor下载镜像

1）安装Docker，并启动Docker（已经完成）

2）修改Docker配置

```bash
vi /etc/docker/daemon.json

{
"registry-mirrors": ["https://qee8rhft.mirror.aliyuncs.com"],
 "insecure-registries": ["xxxx"]  
}
```

3）先登录，再从Harbor下载镜像

```bash
docker login -u 用户名 -p 密码 ip
docker pull <harbor-url>/<project-name>/<image-name>
```

