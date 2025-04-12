

# Terraform & docker

如下是一段使用 Docker Provider 来自动化地创建和管理 Docker 容器的terraform代码：

```json
# 配置 Terraform 所需的 Docker 提供程序
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}
# 配置 Docker 提供程序
provider "docker" {}
# 定义一个名为 nginx 的 Docker 镜像资源
resource "docker_image" "nginx" {
  name         = "myregistry.example.com/my-nginx:1.21.6"  # 修改为私有镜像仓库地址
  keep_locally = false

  auth {
    username = "myuser"  # 仓库用户名
    password = "mypassword"  # 仓库密码
    server_address = "myregistry.example.com"  # 仓库地址
  }
}
# 定义一个名为 nginx 的 Docker 容器资源
resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "tutorial"

# 配置容器的端口映射
  ports {
    internal = 80
    external = 8000
  }
}
```



它的作用如下：

1. **定义 Terraform 配置**：
   - 指定使用 `kreuzwerker/docker` 这个 Provider，并限制版本为 `~> 3.0.1`（即 3.0.1 及以上，但低于 3.1.0）。

2. **配置 Docker Provider**：
   - 使用默认配置连接到本地 Docker Daemon。

3. **拉取 Docker 镜像**：
   - 从 Docker Hub / 自定义拉取官方的 `nginx` 镜像。

4. **创建 Docker 容器**：
   - 使用拉取的 `nginx` 镜像创建一个名为 `tutorial` 的容器。
   - 将容器内部的 `80` 端口映射到主机的 `8000` 端口。

---

### 与手动运行容器的区别

#### 1. **手动运行容器的命令**

如果你手动运行一个类似的容器，通常会使用以下 Docker 命令：

```bash
docker run -d --name tutorial -p 8000:80 nginx
```

这条命令的作用是：
- 从 Docker Hub 拉取 `nginx` 镜像（如果本地没有）。
- 创建一个名为 `tutorial` 的容器。
- 将容器的 `80` 端口映射到主机的 `8000` 端口。

---

#### 2. **Terraform 与手动运行的区别**

| **特性**       | **Terraform 代码**                                           | **手动运行容器**                                        |
| -------------- | ------------------------------------------------------------ | ------------------------------------------------------- |
| **自动化程度** | 完全自动化，通过代码定义和管理基础设施。                     | 需要手动输入命令，适合临时操作。                        |
| **可重复性**   | 代码可以重复使用，确保每次创建的环境一致。                   | 需要手动记录命令，容易出错或不一致。                    |
| **版本控制**   | 代码可以纳入版本控制系统（如 Git），方便协作和追踪变更。     | 命令无法直接版本控制，依赖文档记录。                    |
| **状态管理**   | Terraform 会维护一个状态文件（`terraform.tfstate`），记录资源的状态。 | 无状态管理，需要手动检查容器状态。                      |
| **依赖管理**   | 自动处理资源依赖（如先拉取镜像再创建容器）。                 | 需要手动确保依赖顺序（如先拉取镜像再运行容器）。        |
| **扩展性**     | 支持复杂的配置（如多个容器、网络、卷等），易于扩展。         | 复杂配置需要编写脚本或多次执行命令。                    |
| **销毁资源**   | 通过 `terraform destroy` 一键销毁所有资源。                  | 需要手动删除容器和镜像（`docker rm` 和 `docker rmi`）。 |
| **跨平台支持** | 支持多种 Provider（如 AWS、Azure、Kubernetes 等），不仅仅是 Docker。 | 仅限于 Docker 命令行工具。                              |
| **错误处理**   | Terraform 提供详细的错误信息和计划预览（`terraform plan`）。 | 需要手动调试错误，缺乏计划预览。                        |

---

### 具体区别示例

#### 1. **镜像拉取**
- **Terraform**：
  - 通过 `docker_image` 资源定义镜像拉取行为。
  - 可以设置 `keep_locally` 参数，控制是否在销毁资源时删除镜像。
- **手动运行**：
  - 使用 `docker pull nginx` 或直接运行容器时自动拉取镜像。
  - 需要手动删除镜像（`docker rmi nginx`）。

#### 2. **容器创建**
- **Terraform**：
  - 通过 `docker_container` 资源定义容器配置。
  - 自动处理资源依赖（如先拉取镜像再创建容器）。
- **手动运行**：
  - 使用 `docker run` 命令创建容器。
  - 需要手动确保镜像已拉取。

#### 3. **端口映射**
- **Terraform**：
  - 在 `docker_container` 资源中通过 `ports` 块定义端口映射。
  - 支持复杂的端口配置（如多个端口映射）。
- **手动运行**：
  - 使用 `-p` 参数指定端口映射。
  - 多个端口映射需要多次使用 `-p` 参数。

#### 4. **资源销毁**
- **Terraform**：
  - 运行 `terraform destroy` 一键销毁所有资源（容器和镜像）。
- **手动运行**：
  - 需要手动删除容器（`docker rm -f tutorial`）和镜像（`docker rmi nginx`）。

---

### 适用场景

#### **Terraform 代码的适用场景**
- 需要自动化、可重复的基础设施管理。
- 需要版本控制和协作。
- 需要管理复杂的基础设施（如多个容器、网络、卷等）。
- 需要跨平台支持（如同时管理 Docker、Kubernetes、云资源）。

#### **手动运行容器的适用场景**
- 临时测试或调试容器。
- 简单的单容器场景。
- 不需要版本控制或自动化。

---

### 总结

- **Terraform 代码**：适合生产环境和复杂场景，提供自动化、可重复、可版本控制的基础设施管理。
- **手动运行容器**：适合临时操作和简单场景，灵活但缺乏自动化和可重复性。





![image-20250322230349250](Terraform%20&%20docker.assets/image-20250322230349250.png)

![image-20250322230922351](Terraform%20&%20docker.assets/image-20250322230922351.png)





修改资源并apply

![image-20250322231355276](Terraform%20&%20docker.assets/image-20250322231355276.png)



摧毁



![image-20250322231802195](Terraform%20&%20docker.assets/image-20250322231802195.png![image-20250322231822975](Terraform%20&%20docker.assets/image-20250322231822975.png)





# 定义输入变量

创建一个名为 with a block 定义新变量的新文件。variables.tf

```
variable "container_name" {
  description = "Value of the name for the Docker container"
  type        = string
  default     = "ExampleNginxContainer"
}
```



```bash
resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
#  在此处修改
- name  = "tutorial"
+ name  = var.container_name
  ports {
    internal = 80
    external = 8080
  }
}
```



![image-20250322232543752](Terraform%20&%20docker.assets/image-20250322232543752.png)