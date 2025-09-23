# 推送镜像到ACR

创建新目录，放入push_img.sh，

执行脚本会在新目录中创建build_workspace目录，用于存放源代码。



参数介绍：

```bash
GIT_REPO_URL="git@codeup.aliyun.com:68afbca3725067d38cf126d1/jiaozi/Jiaozi_Portable.git"
GIT_BRANCH="master" 
WORK_DIR="./build_workspace"

需要手动修改下载地址与分支
```

使用说明：

```bash
参数:
  DOCKER_TAG    镜像标签（可选，默认: latest）

示例:
  ./push_img.sh              # 使用latest标签
  ./push_img.sh 2.0.1        # 使用自定义标签 2.0.1，不推送latest
  ./push_img.sh v1.5.0-beta  # 使用自定义标签 v1.5.0-beta，不推送latest
```



执行完后可以手动选择删除本地镜像



**生产环境建议使用固定版本号，不使用latest。**

**如果使用了固定版本号，要修改pod拉取镜像源。**



```bash
==================== 构建完成 ====================
pod配置示例:
spec:
  containers:
  - name: jiaozi_protable
    image: registry.cn-hangzhou.aliyuncs.com/jiaoziera/jiaozi_protable:latest
```



