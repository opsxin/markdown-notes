1. pod 是逻辑主机， 其行为与非容器世界中的物理主机或虚拟机非常相似。此外， 运行在同一个pod 中的进程与运行在同一物理机或虚拟机上的进程相似， 只是每个进程都封装在一个容器之中。

2. pod 定义由这么几个部分组成： 首先是 YAML 中使用的 Kubemetes API 版本和 YAML 描述的资源类型；其次是几乎在所有 Kubemetes 资源中都可以找到的三大重要部分： 

   - metadata 包括名称、命名空间、标签和关于该容器的其他信息。
   - spec 包含pod 内容的实际说明， 例如 pod 的容器、卷和其他数据。
   - status 包含运行中的 pod 的当前信息，例如 pod 所处的条件、每个容器的描述和状态，以及内部 IP 和其他基本信息。

3. API 对象字段

   ```bash
   kubectl explain pods
   kubectl explain pods.spec
   ```

4. 通过 YAML 创建 Pod

   ```bash
   kubectl create -f <YAML-NAME>
   ```

5. 获取完整 Pod 定义

   ```bash
   kubectl get po <Pod-NAME> -o yaml
   ```

6. 查看日志

   ```bash
   zkubectl logs &lt;Pod-NAME&gt;
   
   # 如果有多个容器，需要指定容器名字
   kubectl logs <Pod-Name> -c <Contain-Name>
   ```

7. 端口转发
   
   ```bash
   kubectl port-forward <Pod-Name> <out-port>:<inter-port>
   ```
   
8. 全丝雀发布：在部署新版本时， 先只让一小部分用户体验新版本以观察新版本的表现， 然后再向所有用户进行推广，这样可以防止暴露有问题的版本给过多的用户。

9. 显示标签（label）

   ```bash
   kubectl get pod --show-labels
   
   # 单独列显示label
   kubectl get pod -L <label-key>,<label-key>
   ```

10. 修改标签

    ```bash
    kubectl label po <pod-name> <label-key>=<label-value>
    
    # 在更改现有标签时， 需要使用--overwrite选项。
    kubectl label po <pod-name> <label-key>=<label-value> --overwrite
    ```

11. 标签选择器根据资源的以下条件来选择资源：

    - 包含（或不包含）使用特定键的标签
    - 包含具有特定键和值的标签
    - 包含具有特定键的标签， 但其值与我们指定的不同

12. 根据标签列出pod

    ```bash
    kubectl get pod -l <label-key>[=<label-value>]
    
    # !:取反，in，notin，
    ```

13. node 也可以添加标签

    ```bash
    kubectl label node node1 gpu=true
    kubectl get nodes -1 gpu=true
    
    # 在 yaml 中说明使用此节点
    #spec： 
    #  nodeSelector:
    #  	gpu: "true"
    ```

14. 添加或修改注解

    ```bash
    kubect1 annotate pod <pod-name> <annotate-key>=<annotate-value>
    ```

15. 命名空间：为对象名称提供了一个作用域。将包含大量组件的复杂系统拆分为更小的不同组，这些不同组也可以用于在多租户环境中分配资源，将资源分配为生产、开发和 QA 环境，或者以其他任何你需要的方式分配资源。除了**隔离资源**，命名空间还可用于仅允许某些用户访问某些特定资源，甚至**限制**单个用户可用的计算资源数量。

16. 获取命名空间

    ```bash
    kubectl get ns
    kubectl get po --namespace kube-system
    ```

17. 创建命名空间

    ```bash
    kubectl create namespace <ns-name>
    ```

18. 移除和停止 pod

    ```bash
    # 按照名称
    kubectl delete pod <Pod-Name>
    
    # 按照标签
    kubectl delete pod -l <label-key>=<label-volue>
    
    # 按照命名空间
    kubectl delete ns <NS-Name>
    
    # 删除此NS下所有Pod
    kubectl delete pod --all
    
    # 删除RC和Pod
    kubectl delete all -all
    ```

19. 小结

    - 使用标签来组织pod, 并且一次在多个pod 上执行操作。
    - 使用节点标签将 pod 只调度到提供某些指定特性的节点上。
    - 注解允许人们、工具或库将更大的数据块附加到pod。
    - 命名空间可用于允许不同团队使用同一集群， 就像它们使用单独的 Kubemetes 集群一样。
    - 使用kubectl explain 命令快速查看任何 Kubernetes 资源的信息。