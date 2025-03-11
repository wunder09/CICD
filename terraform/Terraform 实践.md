# Terraform 实践



在云计算环境中搭建一个基本的网络架构并部署Ubuntu服务器：
1. **Create vpc**：创建虚拟私有云（VPC），这是一个隔离的虚拟网络环境，可自定义网络配置，如IP地址范围、子网划分等。
2. **Create Internet Gateway**：创建互联网网关，它是VPC与公共互联网之间的桥梁，允许VPC内的资源访问互联网，也能让外部网络访问VPC内开放的资源。
3. **Create Custom Route Table**：创建自定义路由表，用于定义网络流量的转发规则，比如指定哪些流量通过互联网网关流出VPC。
4. **Create a Subnet with Route Tables**：创建子网并关联路由表。子网是VPC内的一个细分网络，关联路由表后可以控制子网内的流量走向。
5. **Associate subnet with Route Tables**：将子网与路由表关联起来，确保子网内的流量按照预设的路由规则进行转发。 
6. **Create Security Group to allow port 22,80,443**：创建安全组并允许端口22（SSH服务，用于远程登录服务器）、80（HTTP服务）和443（HTTPS服务）的流量通过，这是为了后续服务器的访问和服务运行做准备。 
7. **Create a network interface with an ip in the subnet that was created in step 4**：在步骤4创建的子网中创建一个网络接口并分配IP地址，网络接口是实例连接到网络的组件。
8. **Assign an elastic IP to the network interface created in step 7**：为步骤7创建的网络接口分配一个弹性IP，弹性IP是一个静态的公网IP地址，便于外部稳定地访问VPC内的资源。 
9. **Create Ubuntu server and install/enable apache2** ：创建Ubuntu服务器实例，并在上面安装和启用Apache2 web服务器，这样就可以搭建一个基本的网站服务环境。 



```yaml
# 配置AWS提供程序
provider "aws" {
  region = "us - west - 2"  # 替换为你想要的区域
}

# 1. 创建VPC
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "example-web-vpc"
  }
}

# 2. 创建互联网网关
resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id
  tags = {
    Name = "example-web-igw"
  }
}

# 3. 创建自定义路由表
resource "aws_route_table" "example_route_table" {
  vpc_id = aws_vpc.example_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }
  tags = {
    Name = "example-web-route-table"
  }
}

# 4. 创建子网
resource "aws_subnet" "example_subnet" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us - west - 2a"  # 替换为合适的可用区
  tags = {
    Name = "example-web-subnet"
  }
}

# 5. 将子网与路由表关联
resource "aws_route_table_association" "example_association" {
  subnet_id      = aws_subnet.example_subnet.id
  route_table_id = aws_route_table.example_route_table.id
}

# 6. 创建安全组
resource "aws_security_group" "example_sg" {
  vpc_id = aws_vpc.example_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "example-web-sg"
  }
}

# 7. 创建网络接口
resource "aws_network_interface" "example_nic" {
  subnet_id   = aws_subnet.example_subnet.id
  security_groups = [aws_security_group.example_sg.id]
  tags = {
    Name = "example-web-nic"
  }
}

# 8. 分配弹性IP
resource "aws_eip" "example_eip" {
  network_interface = aws_network_interface.example_nic.id
  tags = {
    Name = "example-web-eip"
  }
}

# 9. 创建Ubuntu服务器并安装Apache2
resource "aws_instance" "example_server" {
  ami           = "ami - 0c94855ba95c71c99"  # 替换为合适的Ubuntu AMI ID
  instance_type = "t2.micro"
  network_interface_ids = [aws_network_interface.example_nic.id]
  user_data = <<-EOF
              #!/bin/bash
              apt - get update
              apt - get install - y apache2
              systemctl start apache2
              systemctl enable apache2
              EOF
  tags = {
    Name = "example-web-server"
  }
}
```

使用说明：
1. 安装Terraform工具，并配置好相应云平台（这里是AWS）的访问凭证。
2. 将上述代码保存为`.tf`文件（例如`web_server_setup.tf`）。
3. 在该文件所在目录，打开命令行，运行`terraform init`初始化工作目录。
4. 运行`terraform plan`查看资源创建计划。
5. 确认无误后，运行`terraform apply`并输入`yes`确认创建资源。 







```yaml
provider "aws" {
  region = "us-east-1"
  access_key = "ACCESS_KEY"
  secret_key = "SECRET_KEY"
}

resource "aws_instance" "my-first-ec2" {
 ami = "ami-0c55b159cbfafe1f0"
 instance_type = "t2.micro"
}
```



![image-20250220192921207](C:%5CUsers%5CAdministrator%5CDesktop%5Ctereaform.assets%5Cimage-20250220192921207.png)

![image-20250220193218248](C:%5CUsers%5CAdministrator%5CDesktop%5Ctereaform.assets%5Cimage-20250220193218248.png)





### Modify Resources

如果对上述代码重执行，不会重新创建EC2实例。



![image-20250220193548232](C:%5CUsers%5CAdministrator%5CDesktop%5Ctereaform.assets%5Cimage-20250220193548232.png)





做修改添加tags

![image-20250220194105015](C:%5CUsers%5CAdministrator%5CDesktop%5Ctereaform.assets%5Cimage-20250220194105015.png)

![image-20250220194024220](C:%5CUsers%5CAdministrator%5CDesktop%5Ctereaform.assets%5Cimage-20250220194024220.png)







### Delete Resources

![image-20250220194230898](C:%5CUsers%5CAdministrator%5CDesktop%5Ctereaform.assets%5Cimage-20250220194230898.png)

或者可以将该部分代码注释，并再次apply  也可以销毁实例。





### Reference Resources 

- **VPC**
  VPC 是云计算服务提供商提供的一种虚拟网络隔离环境，它为用户模拟了传统的企业级数据中心网络。用户可以完全掌控这个虚拟网络，包括选择 IP 地址范围、配置路由表和网络网关等，使得用户的云资源能够在一个相对独立和安全的网络空间中运行。
- **子网**
  子网是 VPC 内的一个网络分区，它是将 VPC 的 IP 地址范围进一步细分得到的更小的地址块。子网可以根据不同的用途、安全需求或业务功能进行划分，比如可以将 Web 服务器、数据库服务器分别放置在不同的子网中。



`Terraform VPC` 指的是使用 Terraform 来创建、配置和管理虚拟专用云（VPC）资源。通过编写 Terraform 配置文件，用户可以以代码的方式描述 VPC 的各种属性和关联资源，实现 VPC 资源的自动化部署和版本控制。

![image-20250220195433086](C:%5CUsers%5CAdministrator%5CDesktop%5Ctereaform.assets%5Cimage-20250220195433086.png)



[aws_subnet | Resources | hashicorp/aws | Terraform | Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)





### Terraform Files 





### Practice Project 

![image-20250220202635286](C:%5CUsers%5CAdministrator%5CDesktop%5Ctereaform.assets%5Cimage-20250220202635286.png)

![image-20250220202410241](C:%5CUsers%5CAdministrator%5CDesktop%5Ctereaform.assets%5Cimage-20250220202410241.png)

![image-20250220202456606](C:%5CUsers%5CAdministrator%5CDesktop%5Ctereaform.assets%5Cimage-20250220202456606.png)

![image-20250220202915250](C:%5CUsers%5CAdministrator%5CDesktop%5Ctereaform.assets%5Cimage-20250220202915250.png)



terraform aws security group

terraform aws network interface

![image-20250220203758348](C:%5CUsers%5CAdministrator%5CDesktop%5Ctereaform.assets%5Cimage-20250220203758348.png)

terraform aws eip

![image-20250220204654384](C:%5CUsers%5CAdministrator%5CDesktop%5Ctereaform.assets%5Cimage-20250220204654384.png)



![image-20250220204537264](C:%5CUsers%5CAdministrator%5CDesktop%5Ctereaform.assets%5Cimage-20250220204537264.png)

![image-20250220204617827](C:%5CUsers%5CAdministrator%5CDesktop%5Ctereaform.assets%5Cimage-20250220204617827.png)

### Terraform Commands 

### Terraform Output 

### Target Resources

### Variables 