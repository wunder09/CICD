## DevOps 生命周期的 7 个关键阶段

DevOps 生命周期的 7 个关键阶段，也称为 DevOps 的 7 个 C，是一组相互关联的阶段，它们在连续循环中协同工作，以帮助您快速开发、测试和部署应用程序。以下是 DevOps 生命周期的关键阶段：

### 1. 持续发展

此阶段是关于规划和编码软件应用程序。开发人员规划软件并将整个开发过程分解为更小的周期，从而为整体软件开发目标增加价值。

<img src="DevOps%20%E7%94%9F%E5%91%BD%E5%91%A8%E6%9C%9F%E7%9A%84%207%20%E4%B8%AA%E5%85%B3%E9%94%AE%E9%98%B6%E6%AE%B5.assets/continuous-development-xbxj3.png" alt="持续开发" style="zoom:50%;" />

通过遵循此流程，DevOps 团队可以轻松地向其他利益相关者规划**软件开发生命周期 （SLDC）** 的期望、责任和时间表。此外，由于开发团队、测试人员和其他利益相关者逐个构建软件，因此开发过程很快，大规模风险最小，并且该过程可以轻松适应不断变化的需求和业务需求。

**用于持续开发的工具**

1. **规划：**DevOps 团队使用 Jira、Linear 和 ClickUp 等项目管理工具来帮助团队规划、跟踪和发布软件。
2. **编码**：DevOps 团队可以使用 Git 等版本控制系统、Visual Studio Code 等编辑器以及 Tuple 等配对编程工具，以便在构建软件时与其他开发团队有效协作。

### 2. 持续集成 （CI）

编写代码并将其存储在共享存储库中后，DevOps 团队可以在存储库上设置 CI 管道，以便在开发人员提交对源代码的更改时，他们可以执行以下作：

- 检测对现有代码的更改并启动单元测试、集成测试和构建过程等作。
- 执行代码质量分析。
- 生成部署构件。

<img src="DevOps%20%E7%94%9F%E5%91%BD%E5%91%A8%E6%9C%9F%E7%9A%84%207%20%E4%B8%AA%E5%85%B3%E9%94%AE%E9%98%B6%E6%AE%B5.assets/continuous-integration-b4lef.png" alt="持续集成" style="zoom:50%;" />

这一点尤其重要，因为开发团队将继续将更新推送到源代码中，以构建新功能、修复错误、执行代码改进和重构。

**使用的工具**

Jenkins、CircleCI、Travis CI 和 GitHub Actions 是 DevOps 团队用来构建、测试和部署代码更改的一些[自动化工具](https://roadmap.sh/devops/automation-tools)。

### 3. 持续测试

持续测试涉及对开发的代码进行自动化测试，以确保在开发周期的每个步骤中验证更改、捕获缺陷并提供反馈，而无需人工干预。

<img src="DevOps%20%E7%94%9F%E5%91%BD%E5%91%A8%E6%9C%9F%E7%9A%84%207%20%E4%B8%AA%E5%85%B3%E9%94%AE%E9%98%B6%E6%AE%B5.assets/continuous-testing-d90gb.png" alt="持续测试" style="zoom:50%;" />

如果发生错误或错误，代码将返回到上一阶段（集成）以进行更正和可能的修复。自动化测试通过节省时间和资源来改进整体工作流程。

**使用的工具**

Selenium、JUnit、TestNG 和 Cucumber 是 DevOps 团队用来大规模自动化测试的一些自动化测试工具。

### 4. 持续部署 （CD）

在此阶段，已通过所有测试的代码将自动部署到暂存或生产环境。持续部署的总体目标是：

- 缩短开发和部署之间的时间。
- 便于将完成的代码部署到生产服务器。
- 确保开发、测试、暂存和生产环境之间的一致性。

<img src="DevOps%20%E7%94%9F%E5%91%BD%E5%91%A8%E6%9C%9F%E7%9A%84%207%20%E4%B8%AA%E5%85%B3%E9%94%AE%E9%98%B6%E6%AE%B5.assets/continuous-deployment-bprfv.png" alt="持续部署" style="zoom:50%;" />

**使用的工具**

1. **配置工具**：DevOps 团队使用 Ansible、Puppet、Chef 和 SaltStack 等配置管理工具来自动化 IT 基础架构的配置、配置、管理和持续交付。这些工具可帮助 DevOps 团队提高效率，保持跨环境的一致性并减少错误。
2. **容器化和编排工具**：DevOps 团队使用 [Docker](https://roadmap.sh/docker)、Vagrant 和 [Kubernetes](https://roadmap.sh/kubernetes) 等工具来构建和测试应用程序。这些工具可帮助应用程序响应需求（扩展和缩减）并保持跨环境的一致性。

### 5. 持续监控

在这个阶段，您需要密切关注已部署的应用程序，以监控性能、安全性和其他有用数据。它涉及收集指标和其他与应用程序使用相关的数据，以检测系统错误、服务器停机时间、应用程序错误和安全漏洞等问题。此外，它还涉及与运营团队合作，以监控错误并识别不正确的系统行为。

<img src="DevOps%20%E7%94%9F%E5%91%BD%E5%91%A8%E6%9C%9F%E7%9A%84%207%20%E4%B8%AA%E5%85%B3%E9%94%AE%E9%98%B6%E6%AE%B5.assets/continuous-monitoring-cydj0.png" alt="持续监控" style="zoom:50%;" />

持续监控可以提高系统的生产力和可靠性，同时降低 IT 支持成本。在此阶段检测到的任何问题都可以在持续开发阶段及时报告和解决，从而创建一个更高效的反馈循环。

**使用的工具**

Prometheus、Grafana、ELK Stack（Elasticsearch、Logstash、Kibana）和 Datadog 是 DevOps 团队用来持续监控应用程序和基础设施以识别和解决问题的一些工具。

### 6. 持续反馈

持续反馈是指从用户和利益相关者那里收集信息，以了解软件在实际场景中的表现。然后不断分析反馈并用于做出明智的决策并改进整个开发过程。

<img src="DevOps%20%E7%94%9F%E5%91%BD%E5%91%A8%E6%9C%9F%E7%9A%84%207%20%E4%B8%AA%E5%85%B3%E9%94%AE%E9%98%B6%E6%AE%B5.assets/continuous-feedback-eg1tr.png" alt="反馈" style="zoom:50%;" />

**使用的工具**

DevOps 团队使用 Datadog 和 LogRocket 等工具来收集和深入了解用户如何与其产品交互。

### 7. 持续运营

在传统的软件开发过程中，当开发人员想要更新和维护应用程序时，他们可能需要拉取服务器。这种方法会中断开发过程，可能会增加组织成本，并可能导致用户服务中断。

<img src="DevOps%20%E7%94%9F%E5%91%BD%E5%91%A8%E6%9C%9F%E7%9A%84%207%20%E4%B8%AA%E5%85%B3%E9%94%AE%E9%98%B6%E6%AE%B5.assets/continuous-operations-h2yrj.png" alt="持续运营" style="zoom:33%;" />

持续运营可以解决这些挑战等。它确保软件保持可用和运行，同时将停机时间降至最低。此阶段涉及以下任务：

- 执行零停机时间部署。
- 自动化备份和恢复。
- 使用基础设施管理来预置和扩展资源。
- 在多个服务器之间分配流量，以在更新或高流量期间保持性能。
- 实施数据库复制和滚动更新等策略以保持数据可用性。

**使用的工具**

Puppet、Terraform 和 Chef 是 DevOps 团队用来自动化资源预置和确保系统可靠性的一些工具。

DevOps 生命周期是一个持续的过程，涉及开发、集成、测试、部署、监控、反馈和运营。除了它带来的改进之外，您还会注意到组织正在扩展 DevOps 并进一步提升其功能。

让我们探索其中的一些扩展以及它们如何改变开发过程。





摘录自:[DevOps 生命周期的 7 个关键阶段是什么？](http://localhost:3000/devops/lifecycle#7-key-phases-of-the-devops-lifecycle)