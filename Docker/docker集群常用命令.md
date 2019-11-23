# docker集群常用命令

[TOC]

## docker swarm^1^

### 要求

一个 Swarm 集群至少需要一个 Manager 节点，如果有多个，则推选一个为 Leader；Worker 可以有零个至多个。

### 集群的创建与销毁

- 创建 Manager

  ```bash
  docker swarm init --advertise-addr xxx.xxx.xxx.xxx
  ```

- 创建 Worker

  ```bash
  docker swarm join -token ******
  ```

- 查看 token

  ```bash
  docker swarm join-token manager/woker
  ```

- 查看 node

  ```bash
  doker node ls
  ```

- worker 离开集群

  ```bash
  docker swarm leave
  ```

- Manager 离开集群

  ```bash
  docker swarm leave --force
  ```

### 节点管理

1. **AVAILABILITY** 的三种状态

   - ==Active==：调度器能够将任务安排到这个节点
   - ==Pause==：调度器不能将新的任务安排到这个节点，但是已有的任务会继续运行
   - ==Drain==：调度器不能安排新的任务到这个节点，同时这个节点以运行的任务将被停止，分配到其他的节点上

2. **MANAGER STAUTS** 的状态

   - ==Leader==：主要管理者节点
   - ==Reachable==：如果 Leader 节点不可用，则这这些节点有资格选举为新的 Leader
   - ==Unavailable==：该节点不能和其他 Manager 节点产生任何联系，
这种情况下，应该添加一个新的 Manager 节点到集群，或者将一个 Worker 节点提升为 Manager 节点

3. 检查节点的详细信息

   ```bash
   docker node inspect <node-id> --pretty
   ```

4. 变更节点可用性

   ```bash
   docker node update --availability <status> <node>
   ```

5. 升级降级节点

   ```bash
   1. 升级
   docker node promote <node>
   2. 降级
   docker node demote <node>
   ```

6. **Service** 部署

   1. 创建服务

      ```bash
      docker service create --name <name> <image>
      ```

   2. 查看服务

      ```bash
      docker service ls
      ```

   3. 更新服务

      ```bash
      docker service update --publish-add 8080:80 <name>
      ```

   4. 回滚服务

      ```bash
      docker service rollback <name>
      ```

   5. 扩容服务

      ```bash
      docker service scale <name>=<int num>
      ```

   6. 移除服务

      ```bash
      docker service remove <name>
      ```

   7. 列出服务

      ```bash
      docker service ls
      docker service ps <name>
      docker service inspect <name>
      ```

7. **Service** 存储

   1. 数据卷挂载

      ```bash
      docker service create \
      --mount type=volume,src=<volume-name>, dst=<container-path> \
      --name <name> \
      <image>
      ```

   2. 数据卷创建

      ```bash
      docker volume create <volume-name>
      ```

   3. 数据卷详细信息

      ```bash
      docker volume inspect <volume-name>
      ```

   4. 删除数据卷

      ```bash
      docker volume rm <volume-name>
      ```

   5. 批量删除未挂载数据卷

      ```bash
      docker volume prune
      ```

8. **Docker Stack**

   1. 部署 stack

      ```bash
      docker stack deploy [option] STACK
      ps: docker stack deploy -c compose.yaml <name>
      ```

   2. 列出 Stack

      ```bash
      docker stack ls
      ```

   3. 服务列表

      ``` bas
      docker stack services <stack-name>
      ```

   4. 任务列表

      ```bash
      docekr stack ps <stack-name>
      ```

   5. 更新 stack

      ```bash
      # 重新部署即可
      docker stack deploy [option] STACK
      ```

   6. 删除 stack

      ```bash
      docker stack rm <stack-name>
      ```

## kubernetes

1. 集群的创建与加入

   1. 初始化集群主节点

      ```bash
      kubeadm init --apiserver-advertise-address $(hostname -i)
      ```

   2. 初始化集群网络

      ```bash
      kubectl apply -n kube-system -f \
       "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 |tr -d '\n')"
      ```

   3. 加入集群

      ```bash
      kubeadm join xxx.xxx.xxx.xxx:x --token ****** --discovery-token-ca-cert-hash ******  
      ```

   4. 查看节点

      ```bash
      kubectl get nodes
      kubectl get nodes -o wide
      ```

2. 获取一些信息（get）

   ```bash
   1. replication-control
   kubectl get rc
   2. replicas-set
   kubectl get rs
   3. deployment
   kubectl get deploy
   4. service
   kuctl get svc
   5. namespace
   kuberctl get namespace
   6. pod
   kubectl get pod <po-name>
   ```

3. 获取详细信息（describe）

   ```bash
   1. pod
   kubectl describe po <po-name>
   2. service
   kubectl describe svc
   ```

4. 创建 Pod

   ```bash
   kubectl run NAME --image=image [--env="key=value"] [--port=port] [--replicas=replicas] [--dry-run=bool] [--overrides=inline-json] [--command] -- [COMMAND] [args...]
   ps: kubectl run nginx --image=nginx --port=80
   ```

5. 删除 Pod

   ```bash
   kubectl delete deployment <deploy-name>
   ```

6. **kubectl create**

   ```bash
   kubectl create -f <name.yaml>
   ```

7. **kubectl delete**

   ```bash
   kubectl delete -f <name.yaml>
   kubectl delete po <pod-name>
   kubectl delete po -lapp=nginx-2
   ```

8. **kubectl apply**

   ```bash
   kubectl apply -f <name.yaml>
   ```

9. **kubectl logs**

   ```bash
   kubectl logs <pod-name>
   ```

10. **rolling-update**

    ```bash
    1. 更新
    kubectl rolling-update <name> -f <name.yaml>
    2. 回滚
    kubectl rolling-update <name> —rollback
    ```

11. **kubectl scale**

    ```bash
    kubectl scale rs <name> —replicas=<int>
    kubectl autoscale rc <name> --min=1 --max=4
    ```

12. **kubectl exec**

    ```bash
    kubectl exec <po-name> [cmd]
    ```

> 1. [Docker Swarm 系列教程](http://www.spring4all.com/article/1254)
