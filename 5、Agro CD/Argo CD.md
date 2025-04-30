# Argo CD 

Argo CD 是一个基于 Kubernetes 的 **声明式 GitOps 持续交付工具**，专注于自动化部署和管理 Kubernetes 应用。与 Jenkins 和 GitLab CI 不同，Argo CD 主要关注 **持续部署（CD）** 而非持续集成（CI），并且采用 **GitOps 模式**，即 Git 仓库作为唯一可信源（Source of Truth）。

---

## **1. Argo CD 的核心概念**
### **（1）GitOps 工作流**
- **Git 作为唯一可信源**：所有 Kubernetes 资源配置（如 Deployment、Service）都存储在 Git 仓库中，任何变更必须通过 Git 提交触发。
- **自动同步**：Argo CD 持续监控 Git 仓库，检测变更并自动同步到 Kubernetes 集群，确保集群状态与 Git 定义一致。
- **审计与回滚**：所有变更可追溯，并可回滚到任意 Git 提交版本。

### **（2）声明式管理**
- 开发者只需在 Git 中定义应用的期望状态（如 YAML 文件），Argo CD 负责将集群状态调整至目标状态，减少人为错误。
- 支持多种 Kubernetes 清单格式：
  - Kustomize
  - Helm Charts
  - Jsonnet
  - 原生 YAML/JSON。

---

## **2. Argo CD vs. Jenkins/GitLab CI**
| **功能**            | **Argo CD**                       | **Jenkins/GitLab CI**           |
| ------------------- | --------------------------------- | ------------------------------- |
| **核心目标**        | 持续部署（CD）                    | 持续集成（CI）+ 部分 CD         |
| **GitOps 支持**     | 原生支持，Git 是唯一可信源        | 需插件或自定义脚本实现          |
| **部署方式**        | 声明式，自动同步 Git 变更         | 命令式，依赖 Pipeline 脚本      |
| **Kubernetes 优化** | 专为 K8s 设计，内置健康检查、回滚 | 通用 CI/CD，需额外配置          |
| **多集群管理**      | 支持多集群部署                    | 需手动配置或使用插件            |
| **可观测性**        | 内置 Web UI 展示应用状态和差异    | 依赖第三方工具（如 Prometheus） |

> **适用场景**：  
> - **Argo CD**：适合 Kubernetes 环境，强调 GitOps 和自动化部署。  
> - **Jenkins/GitLab CI**：适合复杂 CI 流程，如代码构建、测试、打包，但需额外工具（如 Helm、Kubectl）实现 CD。

---

## **3. Argo CD 核心架构**
Argo CD 由三个主要组件构成：
1. **API Server**：提供 REST/gRPC 接口，供 Web UI 和 CLI 调用。
2. **Repository Server**：缓存 Git 仓库中的 Kubernetes 清单，并生成最终资源定义。
3. **Application Controller**：持续监控集群状态，对比 Git 定义，执行同步或回滚。

---

## **4. 关键功能**
- **自动漂移修复**：如果集群状态被人为修改（如 `kubectl edit`），Argo CD 可自动修复至 Git 定义的状态。
- **多环境管理**：支持不同环境（Dev/Staging/Prod）的差异化配置。
- **SSO & RBAC**：集成 OIDC、LDAP、GitHub 等，支持细粒度权限控制。
- **高级部署策略**：支持蓝绿部署、金丝雀发布（通过 `PreSync`/`PostSync` 钩子）。
- **Prometheus 监控**：提供应用健康指标和告警。

---

## **5. 快速入门示例**
### **（1）安装 Argo CD**
```sh
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
### **（2）访问 Web UI**
```sh
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
访问 `https://localhost:8080`，默认用户 `admin`，密码通过以下命令获取：
```sh
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

### **（3）部署一个应用**
1. **在 Git 仓库中存放 Kubernetes 清单**（如 `nginx-deployment.yaml`）。
2. **创建 Argo CD Application**：
   ```yaml
   apiVersion: argoproj.io/v1alpha1
   kind: Application
   metadata:
     name: nginx-app
     namespace: argocd
   spec:
     source:
       repoURL: "https://github.com/your-repo.git"
       targetRevision: main
       path: "k8s-manifests/"
     destination:
       server: "https://kubernetes.default.svc"
       namespace: default
     syncPolicy:
       automated:  # 自动同步 Git 变更
         prune: true  # 删除 Git 中已移除的资源
   ```
3. **应用配置**：
   ```sh
   kubectl apply -f argo-app.yaml
   ```
   随后可在 UI 中查看同步状态。

---

## **6. 总结**
- **Argo CD 优势**：自动化、GitOps、Kubernetes 原生、多集群支持。  
- **适用场景**：微服务、云原生环境，尤其适合需要严格审计和自动化部署的团队。  
- **与 Jenkins/GitLab CI 结合**：可搭配使用，如 Jenkins 负责 CI（构建镜像），Argo CD 负责 CD（部署到 K8s）。

参考文档  : [Argo CD 官方文档](https://argo-cd.readthedocs.io/) 

