> `Operator` 是由 [CoreOS](https://coreos.com/) 公司开发的，用来扩展 Kubernetes API，特定的应用程序控制器，它用来创建、配置和管理复杂的有状态应用，如数据库、缓存和监控系统。
>
> `Operator`基于 Kubernetes 的资源和控制器概念之上构建，但同时又包含了应用程序特定的一些专业知识，比如创建一个数据库的`Operator`，则必须对创建的数据库的各种运维方式非常了解，创建`Operator`的关键是`CRD`（自定义资源）的设计。
>
> > `CRD`是对 Kubernetes API 的扩展，Kubernetes 中的每个资源都是一个 API 对象的集合，例如我们在YAML文件里定义的那些`spec`都是对 Kubernetes 中的资源对象的定义，所有的自定义资源可以跟 Kubernetes 中内建的资源一样使用 kubectl 操作。
>
> `Operator`的核心实现就是基于 Kubernetes 的以下两个概念：
>
> - 资源：对象的状态定义
> - 控制器：观测、分析和行动，以调节资源的分布

![Prometheus operator](prometheus-operator.png)

> `prometheus`这种资源对象就是作为`Prometheus Server`存在；
>
> `ServiceMonitor`就是`exporter`的各种抽象，`exporter`是用来提供专门提供`metrics`数据接口的工具，`Prometheus`就是通过`ServiceMonitor`提供的`metrics`数据接口去 pull 数据的；
>
> `alertmanager`对应的`AlertManager`的抽象；
>
> `PrometheusRule`是用来被`Prometheus`实例使用的报警规则文件。

##### 部署和使用

