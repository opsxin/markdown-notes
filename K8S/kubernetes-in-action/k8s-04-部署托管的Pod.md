# 部署托管的 Pod

1. 存活探针(liveness probe) ：检查容器是否还在运行，探测失败， Kubemetes 将定期执行探针并重新启动容器。

   - HTTP GET 探针对容器的 IP 地址（你指定的端口和路径）执行 HTTP GET 请求。
   - TCP 套接字探针尝试与容器指定端口建立 TCP 连接。
   - Exec 探针在容器内执行任意命令，并检查命令的退出状态码。如果状态码是 0, 则探测成功，所有其他状态码都被认为失败。

2. 显示前一个容器的日志

   ```bash
   kubectl logs <Pod-Name> --previous
   ```

3. 当容器被强行终止时，会**创建一个全新的容器----而不是重启原来的容器。**

4. 务必设置一个**探针初始延迟**来说明应用程序的启动时间。

5. 退出代码 137 表示进程被外部信号终止， 退出代码为 128+9 (SIGKILL)。
   退出代码 143 对应于 128+15 (SIGTERM)。

6. 如果你在容器中运行Java应用程序， 请确保使用 HTTP GET 存活探针，而不是启动全新 JVM 以荻取存活信息的 Exec 探针。任何基于 JVM 或类似的应用程序也是如此， 它们的启动过程需要大量的计算资源。

7. Kubernetes会在容器崩溃或其存活探针失败时， 重启容器，这项任务由承载 pod 的节点上的 Kubelet 执行。

8. ReplicationController 是一种 Kubemetes 资源，确保它的 pod **始终保持运行**状态。

9. ReplicationController 有三个主要部分

   - label selector (标签选择器）， 用于确定 ReplicationController 作用域中有哪些 pod
   - replica count (副本个数）， 指定应运行的 pod 数量
   - pod template (pod模板）， 用于创建新的 pod 副本

10. 更改标签选择器和 pod 模板对现有 pod 没有影响。更改标签选择器会使现有的 pod 脱离ReplicationController 的范围， 因此控制器会停止关注它们。

11. 定义 ReplicationController 时不要指定 pod 选择器，让 Kubemetes 从 pod 模板中提取它。

    ```yaml
    # Pod选择器
    spec:
      selector:
        app: kubia
    ```

12. 获取 ReplicationController

    ```bash
    kubectl get rc
    # rc 是 ReplicationController 的缩写
    ```

13. 显示 rc 详情

    ```bash
    kubectl describe rc <RC-Name>
    ```

14. 编辑 Pod 模板

    ```bash
    kubectl edit rc <RC-Name>
    ```

15. 删除 RC

    ```bash
    kubectl delete rc <RC-Name> --cascade=false
    ```

16. ReplicationController ：标签选择器**只允许包含某个标签**的匹配pod。
    ReplicaSet ：选择器允许匹配缺少某个标签的 pod, 或包含特定标签名的 pod。

17. apiVersion 属性指定的两件事情：

    1. API 组（在这种情况下是 apps)
    2. 实际的 API 版本(v1beta2)

18. 显示 ReplicaSet

    ```bash
    kubectl get rs
    kubectl describe rs [RS-Name]
    ```

19. matchExpressions

    - In : Label 的值必须与其中一个指定的 values 匹配。
    - Notln : Label 的值与任何指定的 values 不匹配。
    - Exists : pod 必须包含一个指定名称的标签（值不重要）。使用此运算符时，不应指定values字段。
    - DoesNotExist : pod 不得包含有指定名称的标签。values 属性不得指定。

20. 如果指定多个表达式，则所有这些表达式都**必须为 true **才能使选择器与 pod 匹配。

    如果同时指定 matchLabels 和 matchExpressions, 则所有标签都**必须匹配**，并且所有表达式必须计算为 true 以使该 pod 与选择器匹配。

21. DaemonSet 在每个节点上只运行一个 pod 副本。

22. 节点可以被设置为不可调度， 防止 pod 被部署到节点上。DaemonSet 会将 pod 部署到这些节点上，因为无法调度的属性只会被调度器使用，而 DaemonSet 管理的 pod 完全绕过调度器。

23. Job：运行完成工作后就终止任务。completions 指定次数，parallelism 指定并行任务。

24. 小结：

    1. 使用存活探针，让 Kubemetes 在容器不健康的情况下立即重启它（应用程
       序定义了健康的条件）。
    2. 不应该直接创建 pod , 因为如果它们被错误地删除，或正在运行的节点异常，或者它们从节点中被删除时， 它们将不会被重新创建。
    3. ReplicationController 始终保持所需数量的 pod 副本正在运行。
    4. 水平缩放（Scale） pod 与在 ReplicationController 上更改所需的副本个数一样简单。
    5. pod 不属于 ReplicationController, 如有必要可以在它们之间移动。
    6. ReplicationController 将从 pod 模板创建新的 pod。更改模板对现有的 pod 没有影响。
    7. ReplicationController 应该替换为 ReplicaSet 和 Deployment, 它们提供相同的能力， 但具有额外的强大功能。
    8. ReplicationController 和 ReplicaSet 将 pod 安排到随机集群节点， 而 DaemonSet 确保每个节点都运行一个 DaemonSet 中定义的 pod 实例。
    9. 执行批处理任务（batch）的 pod 应通过 Kubernetes Job 资源创建， 而不是直接或通过ReplicationController 或类似对象创建。
    10. 需要在未来某个时候运行的 Job 可以通过 CronJob 资源创建。
