# README

介绍了一些Devops 常用的技术。

使用云资源搭建CICD实现项目的自动化构建，测试，部署，监控。

## Docker  容器技术

1. 整理了常用的docker命令。
2. 总结了dockerfile资源清单。

3. 搭建docker私有仓库。



## K8S   容器资源编排

0. 常用命令 &  遇到的问题
1. 理解了k8S最基本的单位pod   认识生命周期与调度策略
2. 如何管理pod？  -- pod控制器
3. K8S 如何进行数据存储？
4. Service资源： 容器的端口服务。
5. ingress 外部访问集群的api对象
6. 理解HPA 

##### 其他内容

1. sealos搭建k8s集群    （大规模）

2. 总结了常用的kubectl命令

3. 遇到的一些问题及解决方法

4. 快速生成kubernetes-yaml文件----yaml生成器

5. YAML名词解释

6. pod故障归类与排查 & 生命周期

   

## Prometheus  监控系统

1. Prometheus 的安装与监控节点。

2. 如何用Grafana 显示所监控的数据？

3. Prometheus  进阶用法

   

## ELK 日志分析

1. ELK的简介。

2. 安装ELK以及配置ES集群。

   


## Terraform   云资源编排

1. 介绍了IAC，了解基础设施即代码的意义
2. 如何在本地安装Terraform，实现云资源的使用与高效部署。
3. Module  资源封装 ，提高资源编排的效率。
4. Provider   - 抽象基础设施平台的 API 
5. 了解基础设施的资源与状态。
6.  使用terraform操作docker以及比较。
7. terraform 与阿里云实践。




## Gitlab   代码托管

1. 了解代码托管和协作平台Gitlab。

2. Gitlab runner   运行 CI/CD 作业的代理。

3. 阿里云ECS 配置ECS 。

   

## SonarQube   代码质量检查

1. 介绍了SonarQube 的核心功能：代码质量分析

2. 如何安装与配置SonarQube.

3. SonarQube 与CI/CD 工具集成。

   

## jenkins   广泛使用的CICD工具

1. jenkins 的安装与部署。

2. 如何配置用户，与其他工具的凭证管理，其他插件。

3. 与GitlabCI 比较如何？


## istio

1. 安装istio