Kubernetes 是谷歌开源的容器集群管理系统，是 Google 多年大规模容器管理技术 Borg 的开源版本，主要功能包括：

- 基于容器的应用部署、维护和滚动升级
- 负载均衡和服务发现
- 跨机器和跨地区的集群调度
- 自动伸缩
- 无状态服务和有状态服务
- 广泛的 Volume 支持
- 插件机制保证扩展性

Kubernetes 发展非常迅速，已经成为容器编排领域的领导者。

## Kubernetes 是一个平台

Kubernetes 提供了很多的功能，它可以简化应用程序的工作流，加快开发速度。通常，一个成功的应用编排系统需要有较强的自动化能力，这也是为什么 Kubernetes 被设计作为构建组件和工具的生态系统平台，以便更轻松地部署、扩展和管理应用程序。

用户可以使用 Label 以自己的方式组织管理资源，还可以使用 Annotation 来自定义资源的描述信息，比如为管理工具提供状态检查等。

此外，Kubernetes 控制器也是构建在跟开发人员和用户使用的相同的 API 之上。用户还可以编写自己的控制器和调度器，也可以通过各种插件机制扩展系统的功能。

这种设计使得可以方便地在 Kubernetes 之上构建各种应用系统。

## 核心组件

Kubernetes 主要由以下几个核心组件组成：

- etcd 保存了整个集群的状态；

- apiserver 提供了资源操作的唯一入口，并提供认证、授权、访问控制、API 注册和发现等机制；

- controller manager 负责维护集群的状态，比如故障检测、自动扩展、滚动更新等；

- scheduler 负责资源的调度，按照预定的调度策略将 Pod 调度到相应的机器上；

- kubelet 负责维护容器的生命周期，同时也负责 Volume（CVI）和网络（CNI）的管理；

- Container runtime 负责镜像管理以及 Pod 和容器的真正运行（CRI）；

- kube-proxy 负责为 Service 提供 cluster 内部的服务发现和负载均衡

  ![架构](architecture.png)



> [Kubernetes 简介](https://github.com/feiskyer/kubernetes-handbook/blob/master/introduction/index.md)