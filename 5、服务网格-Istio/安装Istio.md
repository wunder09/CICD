# Istio 是什么？

Istio 是一种开源服务网格，可透明地分层到现有的分布式应用程序上。 Istio 的强大功能提供了一种统一且更高效的方式来保护、连接和监控服务。 Istio 是实现负载均衡、服务到服务身份验证和监控的途径 - 几乎无需更改服务代码。



## 下载 Istio

1. 转到 [Istio 发布](https://github.com/istio/istio/releases/tag/1.25.1)页面，下载适用于您操作系统的安装文件， 或[自动下载并获取最新版本](https://istio.io/latest/zh/docs/setup/additional-setup/download-istio-release)（Linux 或 macOS）：

   ```
   $ curl -L https://istio.io/downloadIstio | sh -
   ```

2. 转到 Istio 包目录。例如，如果包是 `istio-1.25.1`：

   ```
   $ cd istio-1.25.1
   ```

   安装目录包含：

   - `samples/` 目录下的示例应用
   - `bin/` 目录下的 [`istioctl`](https://istio.io/latest/zh/docs/reference/commands/istioctl) 客户端可执行文件。

3. 将 `istioctl` 客户端添加到路径（Linux 或 macOS）：

   ```
   $ export PATH=$PWD/bin:$PATH
   ```



## 安装 Istio



![image-20250413135233828](C:%5CUsers%5CAdministrator%5CDesktop%5CCICD%5C%E6%9C%8D%E5%8A%A1%E7%BD%91%E6%A0%BC-Istio%5Cimg%5Cimage-20250413135233828.png)