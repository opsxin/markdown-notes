# Compose Version 3 参考

这些主题描述了 Compose 的第 3 个版本。这是当前的最新版本。

[TOC]

## Compose 和 Docker 兼容性

有多种版本的 Compose 格式 - 1，2，2.x 和 3.x，下表是快速浏览。有关每个版本包括什么以及如何升级的详细信息，请[参阅版本和升级](https://docs.docker.com/compose/compose-file/compose-versioning/)。

| **Compose 文件格式 | **Docker Engine 版本** |
| :----------------- | :--------------------- |
| 3.7                | 18.06.0+               |
| 3.6                | 18.02.0+               |
| 3.5                | 17.12.0+               |
| 3.4                | 17.09.0+               |
| 3.3                | 17.06.0+               |
| 3.2                | 17.04.0+               |
| 3.1                | 1.13.1+                |
| 3.0                | 1.13.0+                |
| 2.4                | 17.12.0+               |
| 2.3                | 17.06.0+               |
| 2.2                | 1.13.0+                |
| 2.1                | 1.12.0+                |
| 2.0                | 1.10.0+                |
| 1.0                | 1.9.1。+               |

除了表中显示的 Compose 文件格式版本外，Compose 本身也有发布计划，在[Compose](https://github.com/docker/compose/releases/)查看，但是文件格式版本不一定随每个版本增加。
例如，Compose 文件格式 3.0 最初是在[Compose 版本 1.10.0](https://github.com/docker/compose/releases/tag/1.10.0)引入的，并在随后的发布中逐渐版本化。

## Compose 文件结构和示例

```yaml
version: "3.7"
services:

  redis:
    image: redis:alpine
    ports:
      - "6379"
    networks:
      - frontend
    deploy:
      replicas: 2
      update_config:
        parallelism: 2
        delay: 10s
      restart_policy:
        condition: on-failure

  db:
    image: postgres:9.4
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - backend
    deploy:
      placement:
        constraints: [node.role == manager]

  vote:
    image: dockersamples/examplevotingapp_vote:before
    ports:
      - "5000:80"
    networks:
      - frontend
    depends_on:
      - redis
    deploy:
      replicas: 2
      update_config:
        parallelism: 2
      restart_policy:
        condition: on-failure

  result:
    image: dockersamples/examplevotingapp_result:before
    ports:
      - "5001:80"
    networks:
      - backend
    depends_on:
      - db
    deploy:
      replicas: 1
      update_config:
        parallelism: 2
        delay: 10s
      restart_policy:
        condition: on-failure

  worker:
    image: dockersamples/examplevotingapp_worker
    networks:
      - frontend
      - backend
    deploy:
      mode: replicated
      replicas: 1
      labels: [APP=VOTING]
      restart_policy:
        condition: on-failure
        delay: 10s
        max_attempts: 3
        window: 120s
      placement:
        constraints: [node.role == manager]

  visualizer:
    image: dockersamples/visualizer:stable
    ports:
      - "8080:8080"
    stop_grace_period: 1m30s
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
    deploy:
      placement:
        constraints: [node.role == manager]

networks:
  frontend:
  backend:

volumes:
  db-data:
```

参考页上的主题按照顶级键（top-level）排序，以反映 Compose 文件的结构。
顶级键是配置文件中的一部分，比如`build`，`deploy`，`depends_on`，`networks`等等，支持他们的子主题被列出。
这个映射到的缩进结构是`<key>: <option>: <value>`。

一个很好的起始是阅读[入门](https://docs.docker.com/get-started/)教程，该教程使用版本 3 的 Compose 文件来实现多容器程序，服务定义和集群模式。
在指南中有一些 Compose 文件用法。

- [您的第一个 docker-compose.yml 文件](https://docs.docker.com/get-started/part3/#your-first-docker-composeyml-file)
- [添加新服务和重新部署](https://docs.docker.com/get-started/part5/#add-a-new-service-and-redeploy)

另一个很好的参考是[Docker for Beginners 实验](https://github.com/docker/labs/tree/master/beginner/)主题中
有关[将应用程序部署到Swarm](https://github.com/docker/labs/blob/master/beginner/chapters/votingapp.md)的
投票应用程序示例的 Compose 文件。这也显示在本节可折叠的部分中。

## 服务配置参考（Service）

Compose 文件是一个[YAML](http://yaml.org/)文件，用于定义[服务](https://docs.docker.com/compose/compose-file/#service-configuration-reference)，[网络](https://docs.docker.com/compose/compose-file/#network-configuration-reference)和[卷](https://docs.docker.com/compose/compose-file/#volume-configuration-reference)。
文件的默认路径为`./docker-compose.yml`。

> **提示**：您可以为此文件使用 `.yml`或`.yaml`扩展名。它们都可以工作。

服务定义包含应用于该服务启动的每个容器的配置，就像将命令行参数传递给一样`docker container create`。
同样，网络和卷定义类似于`docker network create`和`docker volume create`。

正如`docker container create`，在 Dockerfile 指定选项，如`CMD`，`EXPOSE`，`VOLUME`，`ENV`，
在默认情况下，你不需要再次指定它们`docker-compose.yml`。

您可以使用类似 Bash 的`${VARIABLE}`语法在配置值中使用环境变量 - 有关完整详细信息，请参见[变量替换](https://docs.docker.com/compose/compose-file/#variable-substitution)。

本节包含版本 3 中的服务定义支持的所有配置选项的列表。

### 构建（build）

在构建时应用的配置选项。

`build` 可以指定为包含构建上下文的字符串：

``` yaml
version: "3.7"
services:
  webapp:
    build: ./dir
```

或者，作为一个具有[上下文](https://docs.docker.com/compose/compose-file/#context)路径的对象，
以及可选的[Dockerfile](https://docs.docker.com/compose/compose-file/#dockerfile)
和[args](https://docs.docker.com/compose/compose-file/#args)：

```yaml
version: "3.7"
services:
  webapp:
    build:
      context: ./dir
      dockerfile: Dockerfile-alternate
      args:
        buildno: 1
```

如果您指定`image`以及`build`，则 Compose 使用`webapp`和可选`tag`作为`image`的名字：

```yaml
build: ./dir
image: webapp:tag
```

这将产生一个名为`webapp`和 Tag 为`tag`的镜像，该镜像从`./dir`构建的。

> **注意**：在以（版本 3） compose 文件以[群集模式部署堆栈](https://docs.docker.com/engine/reference/commandline/stack_deploy/)时，
> 将忽略此选项 。该`docker stack`命令仅接受预构建的图像。

#### 语境（CONTEXT）

指向 Dockerfile 目录的路径，或 git 存储库的 URL。

当提供的值是相对路径时，它将被解释为相对于 Compose 文件的位置。此目录也是发送到 Docker 守护程序的构建上下文。

Compose 用生成的名称构建并标记它，然后使用该镜像。

```yaml
build:
  context: ./dir
```

#### DOCKERFILE

替换 Dockerfile。

Compose 使用一个替换文件进行构建，还必须指定一个构建路径。

```yaml
build:
  context: .
  dockerfile: Dockerfile-alternate
```

#### ARGS

添加构建参数，这些环境变量只能在构建过程中访问。

首先，在 Dockerfile 中指定参数：

```Dockerfile
ARG buildno
ARG gitcommithash

RUN echo "Build number: $buildno"
RUN echo "Based on commit: $gitcommithash"
```

然后在`build`键下指定参数。您可以传递映射或列表：

```yaml
build:
  context: .
  args:
    buildno: 1
    gitcommithash: cdc3b19
build:
  context: .
  args:
    - buildno=1
    - gitcommithash=cdc3b19
```

> **注意**：在 Dockerfile 中，如果您`ARG`在`FROM`指令之前指定，
> `ARG`则在下方的构建指令中不可用`FROM`。
> 如果您需要一个参数在两个地方都可用，请在`FROM`说明中也指定它。
> 有关用法的详细信息，请参阅[ARGS 和 FROM 的交互](https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact)方式。

您可以在指定构建参数时忽略该值，在这种情况下，构建时的值就是运行 Compose 环境中的值。

```yaml
args:
  - buildno
  - gitcommithash
```

> **注**：YAML 布尔值（`true`，`false`，`yes`，`no`，`on`，`off`）必须用引号括起来，这样分析器会将它们解释为字符串。

#### CACHE_FROM

> **注意**：此选项是 v3.2 中的新增功能

用于缓存解析的镜像列表。

```yaml
build:
  context: .
  cache_from:
    - alpine:latest
    - corp/web_app:3.14
```

#### 标签（LABLE）

> **注意**：此选项是 v3.3 中的新增功能

使用 [Docker 标签](https://docs.docker.com/engine/userguide/labels-custom-metadata/)将元数据添加到生成的图像中。您可以使用数组或字典。

我们建议您使用反向 DNS 表示法，以防止您的标签与其他软件使用的标签冲突。

```yaml
build:
  context: .
  labels:
    com.example.description: "Accounting webapp"
    com.example.department: "Finance"
    com.example.label-with-empty-value: ""
build:
  context: .
  labels:
    - "com.example.description=Accounting webapp"
    - "com.example.department=Finance"
    - "com.example.label-with-empty-value"
```

#### SHM_SIZE

> 在[v3.5](https://docs.docker.com/compose/compose-file/compose-versioning/#version-35)文件格式中添加

设置`/dev/shm`此构建容器的分区大小。指定为表示字节数的整数值或表示[字节值](https://docs.docker.com/compose/compose-file/#specifying-byte-values)的字符串。

```yaml
build:
  context: .
  shm_size: '2gb'
build:
  context: .
  shm_size: 10000000
```

#### 目标（TARGET）

> 在[v3.4](https://docs.docker.com/compose/compose-file/compose-versioning/#version-34)文件格式中添加

构建 Dockerfile 中的指定阶段 。有关 TARGET 详细信息，请参见 [多阶段构建文档](https://docs.docker.com/engine/userguide/eng-image/multistage-build/)。

```yaml
build:
  context: .
  target: prod
```

### cap_add，cap_drop

添加或删除容器功能。请参阅`man 7 capabilities`以获取完整列表。

```yaml
cap_add:
  - ALL

cap_drop:
  - NET_ADMIN
  - SYS_ADMIN
```

> **注意**：在（版本 3）编写[以群集模式部署堆栈](https://docs.docker.com/engine/reference/commandline/stack_deploy/)时，
> 将忽略这些选项 。

### cgroup_parent

为容器指定一个可选的父 cgroup。

```yaml
cgroup_parent: m-executor-abcd
```

> **注意**：在（版本 3）编写[以群集模式部署堆栈](https://docs.docker.com/engine/reference/commandline/stack_deploy/)时，将忽略这些选项 。

### 命令（command）

覆盖默认命令。

```yaml
command: bundle exec thin -p 3000
```

该命令也可以是列表，类似于 [dockerfile](https://docs.docker.com/engine/reference/builder/#cmd)：

```yaml
command: ["bundle", "exec", "thin", "-p", "3000"]
```

### 配置（config）

使用`configs` 配置授予服务对配置的访问权限。支持两种不同的语法。

> **注意**：该配置必须已经存在或 在`configs`的[顶级配置](https://docs.docker.com/compose/compose-file/#configs-configuration-reference)中[定义](https://docs.docker.com/compose/compose-file/#configs-configuration-reference)，否则集群部署失败。

有关配置的更多信息，请参见 [configs](https://docs.docker.com/engine/swarm/configs/)。

#### 短语法

短语法变量仅指定配置名称。这将授予容器访问配置的权限，并将其安装在`/<config_name>` 容器内。源名称和目标挂载点均设置为配置名称。

以下示例使用短语法来授予`redis`服务对`my_config`和`my_other_config`配置的访问权限。
`my_config`的值设置为`./my_config.txt`的内容，`my_other_config`定义为外部资源，这意味着它已经在 Docker 中定义，可以通过运行`docker config create` 命令或通过其他集群部署进行定义。
如果外部配置不存在，则集群部署失败并显示`config not found`错误。

> **注意**：`config`仅在 3.3 版及更高版本的 COMPOSE文件格式中支持。

```yaml
version: "3.7"
services:
  redis:
    image: redis:latest
    deploy:
      replicas: 1
    configs:
      - my_config
      - my_other_config
configs:
  my_config:
    file: ./my_config.txt
  my_other_config:
    external: true
```

#### 长语法

长语法提供了在服务的任务容器中更多粒度的创建配置。

- `source`：Docker 中存在的配置名称。
- `target`：要在服务的任务容器中挂载的文件的路径和名称。如果未指定，则默认为`/<source>`。
- `uid`和`gid`：服务的任务容器中拥有已挂载的配置文件的 UID 或 GID。如果未指定，在 Linux 上则两者默认为`0`，Windows 不支持。
- `mode`：服务的容器中文件的权限，以八进制表示法。
例如，`0444` 表示全部可读。默认值为`0444`。
由于配置文件挂载在临时文件系统中，因此它们不可写。
如果您修改可写位，则会被忽略。可执行位可以设置。
如果您不熟悉 UNIX 文件权限模式，则可能会发现此[权限计算器](http://permissions-calculator.org/)很有用。

下面的示例设置的名称`my_config`，以`redis_config`在容器内，将模式设定为`0440`（组可读），并且将所述用户和组`103`。该`redis`服务无权访问该`my_other_config` 配置。

```yaml
version: "3.7"
services:
  redis:
    image: redis:latest
    deploy:
      replicas: 1
    configs:
      - source: my_config
        target: /redis_config
        uid: '103'
        gid: '103'
        mode: 0440
configs:
  my_config:
    file: ./my_config.txt
  my_other_config:
    external: true
```

您可以授予服务访问多个配置的权限，并且可以混合长短语法。定义配置并不意味着授予对它的服务访问权限。

### container_name

指定自定义容器名称，而不是生成的默认名称。

```yaml
container_name: my-web-container
```

由于 Docker 容器名称必须唯一，因此如果您指定了自定义名称，则不能将服务扩展到 1 个以上的容器。尝试这样做会导致错误。

> **注意**：在以（版本 3）编写文件[以群集模式部署](https://docs.docker.com/engine/reference/commandline/stack_deploy/)时，将忽略此选项 。

### credential_spec

> **注意**：此选项已在 v3.3 中添加。在 Compose 版本 3.8 中支持将组托管服务帐户（gMSA）配置与 compose 文件一起使用。

配置托管服务帐户的凭据规范。此选项仅用于使用 Windows 容器的服务。在`credential_spec`必须在格式`file://`或`registry://`。

使用时`file:`，引用的文件必须存在于`CredentialSpecs` Docker数据目录的子目录中，默认情况下`C:\ProgramData\Docker\` 在Windows上。以下示例从名为的文件中加载凭据规范 `C:\ProgramData\Docker\CredentialSpecs\my-credential-spec.json`：

```yaml
credential_spec:
  file: my-credential-spec.json
```

使用`registry:`，将从守护程序主机上的 Windows 注册表中读取凭据规范。给定名称的注册表值必须位于：

```yaml
HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization\Containers\CredentialSpecs
```

以下示例从`my-credential-spec` 注册表中命名的值加载凭据规范：

```yaml
credential_spec:
  registry: my-credential-spec
```

#### GMSA 配置示例

为服务配置 gMSA 凭据规范时，您只需使用`config`即可指定凭据规范，如以下示例所示：

```yaml
version: "3.8"
services:
  myservice:
    image: myimage:latest
    credential_spec:
      config: my_credential_spec

configs:
  my_credentials_spec:
    file: ./my-credential-spec.json|
```

### 依赖（depend_on）

服务之间的依赖关系，服务依赖关系将导致以下行为：

- `docker-compose up`以依赖性顺序启动服务。在以下示例中，`db`和`redis`在之前启动`web`。
- `docker-compose up SERVICE`自动包含`SERVICE`的依赖项。在以下示例中，`docker-compose up web`还将创建并启动`db`和`redis`。
- `docker-compose stop`按依赖关系顺序停止服务。在以下示例中，`web`在`db`和之前停止`redis`。

简单的例子：

```yaml
version: "3.7"
services:
  web:
    build: .
    depends_on:
      - db
      - redis
  redis:
    image: redis
  db:
    image: postgres
```

> 使用时需要注意以下几点`depends_on`：
>
> - `depends_on` `web`不会等待`db`和`redis`“准备就绪”，只会等待到它们启动之时。
> 如果需要等待服务准备就绪，请参阅[控制启动顺序](https://docs.docker.com/compose/startup-order/) 以获取有关此问题的更多信息以及解决该问题的策略。
> - 版本 3 不再支持的`condition`形式`depends_on`。
> - 在以[集群模式](https://docs.docker.com/engine/reference/commandline/stack_deploy/) 版本的 Compose 文件部署 `depends_on`时，将忽略该选项 。

### 部署（deploy）

> **仅[版本 3](https://docs.docker.com/compose/compose-file/compose-versioning/#version-3)。**

指定与服务的部署和运行有关的配置。这只能部署到集群时生效，并且被忽略`docker-compose up`和`docker-compose run`。

```yaml
version: "3.7"
services:
  redis:
    image: redis:alpine
    deploy:
      replicas: 6
      update_config:
        parallelism: 2
        delay: 10s
      restart_policy:
        condition: on-failure
```

有几个子选项可用：

#### 端点模式

为连接到集群的外部客户端指定服务发现方式。

> **仅[版本 3.3](https://docs.docker.com/compose/compose-file/compose-versioning/#version-3)。**

- `endpoint_mode: vip`-Docker 为服务分配了一个虚拟 IP（VIP），该虚拟 IP 充当客户端访问网络服务的前端。
Docker 在客户端和服务的可用工作节点之间路由请求，而无需客户端知道有多少节点正在参与服务或其 IP 地址与端口。（这是默认设置。）
- `endpoint_mode: dnsrr`-DNS 轮询（DNSRR）服务发现不使用单个虚拟 IP。
Docker 设置服务 DNS 条目，以便对服务名称的 DNS 查询返回 IP 地址列表，并且客户端直接连接到其中之一。
在想要使用自己的负载平衡器或混合 Windows 和 Linux 应用程序的情况下，DNS 轮询很有用。

```yaml
version: "3.7"

services:
  wordpress:
    image: wordpress
    ports:
      - "8080:80"
    networks:
      - overlay
    deploy:
      mode: replicated
      replicas: 2
      endpoint_mode: vip

  mysql:
    image: mysql
    volumes:
       - db-data:/var/lib/mysql/data
    networks:
       - overlay
    deploy:
      mode: replicated
      replicas: 2
      endpoint_mode: dnsrr

volumes:
  db-data:

networks:
  overlay:
```

选项`endpoint_mode`还可以在群集模式 CLI 命令[docker service create](https://docs.docker.com/engine/reference/commandline/service_create/)上用作标志 。
有关所有 swarm 相关`docker`命令的快速列表，请参阅 [Swarm 模式 CLI 命令](https://docs.docker.com/engine/swarm/#swarm-mode-key-concepts-and-tutorial)。

要了解有关在群集模式下进行服务发现和联网的更多信息，请参阅在群集模式下 [配置服务发现](https://docs.docker.com/engine/swarm/networking/#configure-service-discovery)主题。

#### 标签（LABELS）

指定服务标签。这些标签仅在服务上设置，而不在服务的任何容器上设置。

```yaml
version: "3.7"
services:
  web:
    image: web
    deploy:
      labels:
        com.example.description: "This label will appear on the web service"
```

在容器上设置标签，在`deploy`外使用`labels`：

```yaml
version: "3.7"
services:
  web:
    image: web
    labels:
      com.example.description: "This label will appear on all containers for the web service"
```

#### 模式（MODE）

`global`（一个节点一个容器）或`replicated`（指定数量的容器）。默认值为`replicated`。（要了解更多信息，请参阅[集群](https://docs.docker.com/engine/swarm/)主题中的[复制服务和全局服务](https://docs.docker.com/engine/swarm/how-swarm-mode-works/services/#replicated-and-global-services)。）

```yaml
version: "3.7"
services:
  worker:
    image: dockersamples/examplevotingapp_worker
    deploy:
      mode: global
```

#### 位置（PLACEMENT）

指定约束和首选项的位置。有关[约束](https://docs.docker.com/engine/reference/commandline/service_create/#specify-service-constraints-constraint)语法
以及[首选项](https://docs.docker.com/engine/reference/commandline/service_create/#specify-service-placement-preferences-placement-pref)的可用类型完整说明，
请参阅 docker 服务 create 文档。

```yaml
version: "3.7"
services:
  db:
    image: postgres
    deploy:
      placement:
        constraints:
          - node.role == manager
          - engine.labels.operatingsystem == ubuntu 14.04
        preferences:
          - spread: node.labels.zone
```

#### 复制（REPLICAS）

如果服务设置`replicated`服务，指定了应运行的容器数。

```yaml
version: "3.7"
services:
  worker:
    image: dockersamples/examplevotingapp_worker
    networks:
      - frontend
      - backend
    deploy:
      mode: replicated
      replicas: 6
```

#### 资源（RESOURCES）

配置资源约束。

> **注意**：这取代了[旧的资源约束选项](https://docs.docker.com/compose/compose-file/compose-file-v2/#cpu-and-other-resources)，
例如包含在编写非集群模式文件之前版本（`cpu_shares`，`cpu_quota`，`cpuset`， `mem_limit`，`memswap_limit`，`mem_swappiness`）
看[升级版本 2.x 到 3.x](https://docs.docker.com/compose/compose-file/compose-versioning/#upgrading)的描述。

其中每个都是一个值，类似于 [docker service create](https://docs.docker.com/engine/reference/commandline/service_create/) 的对应项。

在示例中，`redis`服务被限制为使用不超过 50M 的内存和`0.50`（不超过单个内核的 50％）可用处理时间（CPU），并且具有保留`20M`的内存和`0.25`CPU 时间（始终可用）。

```yaml
version: "3.7"
services:
  redis:
    image: redis:alpine
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 50M
        reservations:
          cpus: '0.25'
          memory: 20M
```

以下主题描述了可用于集群服务或容器资源约束的可用选项。

> 寻找在非集群模式容器上设置资源的选项吗？
>
> 此处描述的选项特定于 `deploy`和集群模式。
如果要在非群集部署中设置资源限制，请使用[Compose 文件格式版本 2 CPU，内存和其他资源选项](https://docs.docker.com/compose/compose-file/compose-file-v2/#cpu-and-other-resources)。
如果您还有其他问题，请参阅有关GitHub问题 [docker / compose / 4513](https://github.com/docker/compose/issues/4513)的讨论。

##### 内存不足异常（OOME）

如果您的服务或容器尝试使用的内存超过系统可用的内存，则可能会遇到内存不足异常（OOME），并且内核 OOM 杀手可能会杀死容器或 Docker 守护程序。
为防止这种情况的发生，请确保您的应用程序在具有足够内存的主机上运行，请参阅了解[内存不足的风险](https://docs.docker.com/engine/admin/resource_constraints/#understand-the-risks-of-running-out-of-memory)。

#### RESTART_POLICY

配置在退出容器时如何重启容器方式。代替`restart`

- `condition`：`none`，`on-failure`或者`any`（默认值：`any`）。
- `delay`：重新启动尝试的等待的时间，指定 [持续时间](https://docs.docker.com/compose/compose-file/#specifying-durations)（默认值：0）。
- `max_attempts`：放弃之前尝试重新启动容器的次数（默认值：永不放弃）。如果重新启动在`windows`时间内未成功，则此尝试不会计入配置`max_attempts`值。例如，如果`max_attempts`设置为“ 2”，并且第 1 次尝试重启失败，则可能会再尝试 2 次。
- `window`：重新启动是否成功之前要等待的时间，指定为[持续时间](https://docs.docker.com/compose/compose-file/#specifying-durations)（默认值：立即）。

```yaml
version: "3.7"
services:
  redis:
    image: redis:alpine
    deploy:
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 120s
```

#### ROLLBACK_CONFIG

> [3.7 版文件格式](https://docs.docker.com/compose/compose-file/compose-versioning/#version-37)及更高版本

更新失败的情况下如何回滚服务。

- `parallelism`：一次要回滚的容器数。如果设置为 0，则所有容器将同时回滚。
- `delay`：每个容器组回滚之间等待的时间（默认为 0s）。
- `failure_action`：如果回滚失败将做什么。`continue`或者`pause`（默认`pause`）
- `monitor`：每次任务更新后监视的持续时间`(ns|us|ms|s|m|h)`（默认为 0s）。
- `max_failure_ratio`：在回滚期间可以容忍的故障率（默认为 0）。
- `order`：回滚期间的操作顺序。`stop-first`（旧任务在开始新的一个前停止），`start-first`（新的任务首先启动，并和正在运行的任务重叠）（默认值`stop-first`）。

#### UPDATE_CONFIG

配置如何更新服务。对于配置滚动更新很有用。

- `parallelism`：一次更新的容器数。
- `delay`：在更新一组容器之间等待的时间。
- `failure_action`：如果更新失败，该怎么办。`continue`，`rollback`或者`pause` （默认：`pause`）。
- `monitor`：每次任务更新后监视的持续时间`(ns|us|ms|s|m|h)`（默认为0s）。
- `max_failure_ratio`：更新期间可以容忍的故障率。
- `order`：更新期间的操作顺序。`stop-first`（旧任务在开始新的一个前停止），`start-first`（新的任务首先启动，并和正在运行的任务重叠）（默认`stop-first`）**注**：仅支持 V3.4 及更高版本。

> **注意**：`order`仅 v3.4 及更高版本的受支持。

```yaml
version: "3.7"
services:
  vote:
    image: dockersamples/examplevotingapp_vote:before
    depends_on:
      - redis
    deploy:
      replicas: 2
      update_config:
        parallelism: 2
        delay: 10s
        order: stop-first
```

#### 不支持 `DOCKER STACK DEPLOY`

下面的子选项（支持`docker-compose up`和`docker-compose run`）是*不支持*的`docker stack deploy`或`deploy`关键词的。

- [build](https://docs.docker.com/compose/compose-file/#build)
- [cgroup_parent](https://docs.docker.com/compose/compose-file/#cgroup_parent)
- [container_name](https://docs.docker.com/compose/compose-file/#container_name)
- [devices](https://docs.docker.com/compose/compose-file/#devices)
- [tmpfs](https://docs.docker.com/compose/compose-file/#tmpfs)
- [external_links](https://docs.docker.com/compose/compose-file/#external_links)
- [links](https://docs.docker.com/compose/compose-file/#links)
- [network_mode](https://docs.docker.com/compose/compose-file/#network_mode)
- [restart](https://docs.docker.com/compose/compose-file/#restart)
- [security_opt](https://docs.docker.com/compose/compose-file/#security_opt)
- [userns_mode](https://docs.docker.com/compose/compose-file/#userns_mode)

> **提示：**请参阅有关[如何为服务，集权和 docker-stack.yml 文件配置卷](https://docs.docker.com/compose/compose-file/#volumes-for-services-swarms-and-stack-files)的内容。卷是受支持的，但是要与群集和服务一起使用，必须将它们配置为命名卷或或有权访问卷的节点的服务关联。

### 设备（devices）

设备映射列表。使用与`--device`和 `docker client create`相同的格式。

```yaml
devices:
  - "/dev/ttyUSB0:/dev/ttyUSB0"
```

> **注意**：在（版本 3）[集群模式部署](https://docs.docker.com/engine/reference/commandline/stack_deploy/)时，将忽略此选项 。

### 域名系统（dns）

自定义 DNS 服务器。可以是单个值或列表。

```yaml
dns: 8.8.8.8
dns:
  - 8.8.8.8
  - 9.9.9.9
```

### dns_search

自定义 DNS 搜索域。可以是单个值或列表。

```yaml
dns_search: example.com
dns_search:
  - dc1.example.com
  - dc2.example.com
```

### 入口（entrypoint）

覆盖默认入口点。

```yaml
entrypoint: /code/entrypoint.sh
```

入口点也可以是列表，类似于 [dockerfile](https://docs.docker.com/engine/reference/builder/#entrypoint)：

```yaml
entrypoint:
    - php
    - -d
    - zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20100525/xdebug.so
    - -d
    - memory_limit=-1
    - vendor/bin/phpunit
```

> **注意**： 设置`entrypoint`会 覆盖 Dockerfile 指令中 `ENTRYPOINT` 的默认值，并清除镜像上的任何默认命令（command），这意味着如果 Dockerfile 中有`CMD`指令，则将其忽略。

### env_file

从文件添加环境变量。可以是单个值或列表。

如果您使用指定了 Compose 文件`docker-compose -f FILE`，`env_file`的路径是相对于该文件所在的目录。

在[环境](https://docs.docker.com/compose/compose-file/#environment)部分声明的环境变量将覆盖这些值 -- 即使这些值为空或未定义。

```yaml
env_file: .env
env_file:
  - ./common.env
  - ./apps/web.env
  - /opt/secrets.env
```

Compose 环境文件中的每一行都采用`VAR=VAL`格式。以开头的行`#`被视为注释，并被忽略。空行也将被忽略。

```yaml
# Set Rails/Rack environment
RACK_ENV=development
```

> **注意**：如果您的服务指定了[构建](https://docs.docker.com/compose/compose-file/#build)选项，则在构建过程中不会自动显示环境文件中定义的变量。使用的 [args](https://docs.docker.com/compose/compose-file/#args) 子选项`build`来定义构建时环境变量。

值按`VAL`原样使用，完全没有修改。例如，如果该值用引号引起来（通常是 shell 变量），则引号也包含在传递给 Compose 的值中。

请记住， 在确定分配给多次出现的变量的值时，列表中的文件顺序非常重要 。列表中的文件从上到下进行处理。对于`a.env`指定变量一个值，但又在 `b.env`指定相同变量另一个值，而如果`b.env`在`a.env`下面列出，则变量的值来自`b.env`。例如，在以下docker-compose.yml`：

```yaml
services:
  some-service:
    env_file:
      - a.env
      - b.env
```

和：

```yaml
# a.env
VAR=1
```

和：

```yaml
# b.env
VAR=hello
```

`$VAR`是`hello`。

### 环境（environment）

添加环境变量。您可以使用数组或字典，任何布尔值（true，false，yes，no）需要用引号引起来，以确保 YAML 解析器不会将其转换为 True 或 False。

只有一个键的环境变量被解析为运行在其上的机器上的值，这对于密钥或特定于主机的值很有帮助。

```yaml
environment:
  RACK_ENV: development
  SHOW: 'true'
  SESSION_SECRET:
environment:
  - RACK_ENV=development
  - SHOW=true
  - SESSION_SECRET
```

> **注意**：如果您的服务指定了[构建](https://docs.docker.com/compose/compose-file/#build)选项，`environment`则在构建期间不会自动显示中定义的变量。使用 [args](https://docs.docker.com/compose/compose-file/#args) 子选项`build`来定义构建时环境变量。

### 暴露（expose）

公开端口却不将其发布到主机上，只有链接的服务才能访问它们。只能指定内部端口。

```yaml
expose:
 - "3000"
 - "8000"
```

### 外部链接（external_links）

链接到这个`docker-compose.yml`外部启动的容器，甚至 Compose 之外，特别是对于提供共享或公共服务的容器。`external_links` 在同时指定容器名称和链接别名时（`CONTAINER:ALIAS`）遵循`links`。

```yaml
external_links:
 - redis_1
 - project_db_1:mysql
 - project_db_1:postgresql
```

> **注意：**
>
> 如果您使用的是版本 2 或更高版本，则外部创建的容器必须至少连接到与其链接的服务相同的网络。[Links](https://docs.docker.com/compose/compose-file/compose-file-v2#links)是旧选项。我们建议改为使用[netwarls](https://docs.docker.com/compose/compose-file/#networks)。
>
> 在（版本 3）[以集群模式部署](https://docs.docker.com/engine/reference/commandline/stack_deploy/)时，将忽略此选项。

### extra_hosts

添加主机名映射。使用与 docker client `--add-host`参数相同的值。

```yaml
extra_hosts:
 - "somehost:162.242.195.82"
 - "otherhost:50.31.209.229"
```

在`/etc/hosts`此服务的内部容器中创建一个具有 ip 地址和主机名的条目，例如：

```yaml
162.242.195.82  somehost
50.31.209.229   otherhost
```

### 健康检查

> [2.1 版文件格式](https://docs.docker.com/compose/compose-file/compose-versioning/#version-21)及更高版本。

配置运行的检查以确定该服务的容器是否“健康”。有关运行[状况检查](https://docs.docker.com/engine/reference/builder/#healthcheck) 如何工作的详细信息，请参阅文档中的 [HEALTHCHECK Dockerfile 指令](https://docs.docker.com/engine/reference/builder/#healthcheck)。

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost"]
  interval: 1m30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

`interval`，`timeout`和`start_period`指定间隔时间。

> **注意**：`start_period`仅 v3.4 及更高版本受支持。

`test`必须是字符串或列表。如果它是一个列表，第一项必须是`NONE`，`CMD`或`CMD-SHELL`。如果是字符串，则等效于指定`CMD-SHELL`后跟该字符串。

```yaml
# Hit the local web app
test: ["CMD", "curl", "-f", "http://localhost"]
```

如上所述，在`/bin/sh`中，以下两种形式是等效的。

```yaml
test: ["CMD-SHELL", "curl -f http://localhost || exit 1"]
test: curl -f https://localhost || exit 1
```

要禁用图像设置的任何默认运行状况检查，可以使用`disable: true`。这等效于指定`test: ["NONE"]`。

```yaml
healthcheck:
  disable: true
```

### 镜像（images）

指定要启动容器的镜像。可以是存储库/标签或部分镜像ID。

```yaml
image: redis
image: ubuntu:14.04
image: tutum/influxdb
image: example-registry.com:4000/postgresql
image: a4bc65fd
```

如果镜像不存在，除非您还指定了 [build](https://docs.docker.com/compose/compose-file/#build)，否则 Compose 会尝试将其 pull，在这种情况下，它将使用指定的选项来构建镜像并使用指定的标签对其进行标记。

### init

> [3.7 版文件格式添加](https://docs.docker.com/compose/compose-file/compose-versioning/#version-37)。

在容器内运行一个初始化程序，以转发信号并获取进程。设置此选项可以`true`为服务启用此功能。

```yaml
version: "3.7"
services:
  web:
    image: alpine:latest
    init: true
```

> 使用的默认初始化二进制文件是 [Tini](https://github.com/krallin/tini)，并安装在`/usr/libexec/docker-init`守护程序主机上。您可以通过[`init-path`配置选项](https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-configuration-file)将守护程序配置为使用自定义 init 二进制文件 。

### 隔离（isolation）

指定容器的隔离技术。在 Linux 上，唯一支持的值是`default`。在 Windows 中，可接受的值是`default`，`process`和 `hyperv`。 有关详细信息，请参阅 [Docker Engine文档](https://docs.docker.com/engine/reference/commandline/run/#specify-isolation-technology-for-container---isolation)。

### 标签（labels）

使用 [Docker 标签](https://docs.docker.com/engine/userguide/labels-custom-metadata/)将元数据添加到容器中。您可以使用数组或字典。

建议您使用反向 DNS 表示法，以防止标签与其他软件使用的标签冲突。

```yaml
labels:
  com.example.description: "Accounting webapp"
  com.example.department: "Finance"
  com.example.label-with-empty-value: ""
labels:
  - "com.example.description=Accounting webapp"
  - "com.example.department=Finance"
  - "com.example.label-with-empty-value"
```

### 链接（links）

> **警告**：该`--link`标志是 Docker 的旧功能。它最终可能会被删除。除非您绝对需要继续使用它，否则我们建议您使用[用户定义的网络](https://docs.docker.com/engine/userguide/networking//#user-defined-networks) 来促进两个容器之间的通信，而不要使用`--link`。 `--link`是在容器之间共享环境变量。但是，您可以使用其他机制（例如卷）以更可控的方式在容器之间共享环境变量。

链接到另一个服务中的容器。指定服务名称和链接别名（`SERVICE:ALIAS`），或者仅指定服务名称。

```yaml
web:
  links:
   - db
   - db:database
   - redis
```

链接服务的容器可以通过与别名相同的主机名访问，如果未指定别名，则可以使用服务名。

不需要链接即可使服务进行通信。默认情况下，任何服务都可以使用该服务的名称访问任何其他服务。（另请参见 [Compose 中的 Networking 中](https://docs.docker.com/compose/networking/#links)的 [Links 主题](https://docs.docker.com/compose/networking/#links)。）

链接也以与 [depends_on](https://docs.docker.com/compose/compose-file/#depends_on) 相同的方式表示服务之间的依赖性 ，因此它们确定了服务启动的顺序。

> **笔记**
>
> - 如果同时定义链接和[网络](https://docs.docker.com/compose/compose-file/#networks)，则它们之间具有链接的服务必须共享至少一个公共网络以进行通信。
> - 在（版本 3）[以集群模式部署](https://docs.docker.com/engine/reference/commandline/stack_deploy/)时，将忽略此选项 。

### logging

服务的日志记录配置。

```yaml
logging:
  driver: syslog
  options:
    syslog-address: "tcp://192.168.0.42:123"
```

该`driver` 名称指定了服务容器的日志记录驱动程序，`--log-driver`和 docker run 选项一样（[在此处记录](https://docs.docker.com/engine/admin/logging/overview/)）。

默认值为 json-file。

```yaml
driver: "json-file"
driver: "syslog"
driver: "none"
```

> **注意**：只有`json-file`和`journald`驱动程序才能从`docker-compose up`直接提供日志`docker-compose logs`。使用任何其他驱动程序不会打印任何日志。

用`options`关键词为日志记录驱动程序指定日志记录选项。

日志记录选项是键值对。`syslog`选项示例：

```yaml
driver: "syslog"
options:
  syslog-address: "tcp://192.168.0.42:123"
```

默认驱动程序 [json-file](https://docs.docker.com/engine/admin/logging/overview/#json-file)，有限制存储日志量的选项。因此，请使用键值对以设置最大存储大小和最大文件数：

```yaml
options:
  max-size: "200k"
  max-file: "10"
```

上面显示的示例将存储日志文件，直到它们达到`max-size`200kB，然后分割它们。单个日志文件的存储量由该`max-file`值指定。随着日志超过最大限制，将删除较旧的日志文件以允许存储新日志。

这是一个`docker-compose.yml`限制日志存储的示例文件：

```yaml
version: "3.7"
services:
  some-service:
    image: some-service
    logging:
      driver: "json-file"
      options:
        max-size: "200k"
        max-file: "10"
```

> 可用的日志记录选项取决于您使用的日志记录驱动程序
>
> 上面用于控制日志文件和大小的示例使用特定于 [json-file driver 的](https://docs.docker.com/engine/admin/logging/overview/#json-file)选项。这些特定选项在其他日志记录驱动程序上不可用。有关受支持的日志记录驱动程序及其选项的完整列表，请参阅 [日志记录驱动程序](https://docs.docker.com/engine/admin/logging/overview/)。

### 网络模式（network_mode）

网络模式。使用与docker client `--network`参数相同的值，以及特殊形式`service:[service name]`。

```yaml
network_mode: "bridge"
network_mode: "host"
network_mode: "none"
network_mode: "service:[service name]"
network_mode: "container:[container name/id]"
```

> **注意**
>
> - 在（版本 3）[以集群模式部署](https://docs.docker.com/engine/reference/commandline/stack_deploy/)时，将忽略此选项 。
> - `network_mode: "host"`不能与[链接](https://docs.docker.com/compose/compose-file/#links)混在一起。

### 网络

要加入的网络，参考 `networks` 关键词。

```yaml
services:
  some-service:
    networks:
     - some-network
     - other-network
```

#### 别名（ALIAES）

网络上此服务的别名（备用主机名）。同一网络上的其他容器可以使用服务名称或此别名来连接到服务的容器。

由于`aliases`是网络范围的，因此同一服务在不同的网络上可以具有不同的别名。

> **注意**：网络范围内的别名可以由多个容器甚至多个服务共享。如果是这样，则不能保证名称解析到哪个容器。

一般格式如下所示。

```yaml
services:
  some-service:
    networks:
      some-network:
        aliases:
         - alias1
         - alias3
      other-network:
        aliases:
         - alias2
```

在下面的例子中，提供了三种服务（`web`，`worker`，和`db`），其中两个网络（`new`和`legacy`）。该`db`服务是在`db`或`database`的`new`网络，`db`与`mysql`在`legacy`网络。

```yaml
version: "3.7"

services:
  web:
    image: "nginx:alpine"
    networks:
      - new

  worker:
    image: "my-worker-image:latest"
    networks:
      - legacy

  db:
    image: mysql
    networks:
      new:
        aliases:
          - database
      legacy:
        aliases:
          - mysql

networks:
  new:
  legacy:
```

#### IPV4_ADDRESS，IPV6_ADDRESS

加入网络后，为此服务的容器指定一个静态 IP 地址。

[顶级网络部分中](https://docs.docker.com/compose/compose-file/#network-configuration-reference)的相应网络配置必须具有一个 `ipam`块，其中子网配置覆盖每个静态地址。

> 如果需要 IPv6 寻址，则[`enable_ipv6`](https://docs.docker.com/compose/compose-file/compose-file-v2/##enable_ipv6) 设置该选项，并且必须使用 [2.x 版本的 Compose 文件](https://docs.docker.com/compose/compose-file/compose-file-v2/#ipv4_address-ipv6_address)。 *IPv6 选项当前在群集模式下不起作用*。

一个例子：

```yaml
version: "3.7"

services:
  app:
    image: nginx:alpine
    networks:
      app_net:
        ipv4_address: 172.16.238.10
        ipv6_address: 2001:3984:3989::10

networks:
  app_net:
    ipam:
      driver: default
      config:
        - subnet: "172.16.238.0/24"
        - subnet: "2001:3984:3989::/64"
```

#### pid

```yaml
pid: "host"
```

将 PID 模式设置为主机 PID 模式。这将打开容器和主机操作系统之间的 PID 地址空间共享。使用此标志启动的容器可以访问和操作主机名称空间中的其他容器，反之亦然。

#### 端口（ports）

暴露端口。

> **注意**：端口映射与`network_mode: host`不兼容

#### 短语法

要么指定两个端口（`HOST:CONTAINER`），要么仅指定容器端口（选择临时主机端口）。

> **注意**：以`HOST:CONTAINER`格式映射端口时，使用低于 60 的容器端口可能会遇到错误的结果，因为 YAML 会将格式的数字解析`xx:yy`为以 60 为底的值。因此，我们建议始终将端口映射显式指定为字符串。

```yaml
ports:
 - "3000"
 - "3000-3005"
 - "8000:8000"
 - "9090-9091:8080-8081"
 - "49100:22"
 - "127.0.0.1:8001:8001"
 - "127.0.0.1:5000-5010:5000-5010"
 - "6060:6060/udp"
```

#### 长语法

长格式语法允许配置其他不能以短格式表示的字段。

- `target`：容器内的端口
- `published`：公开端口
- `protocol`：端口协议（`tcp`或`udp`）
- `mode`：`host`用于在每个节点上发布主机端口，或`ingress`使群集模式端口达到负载平衡。

```yaml
ports:
  - target: 80
    published: 8080
    protocol: tcp
    mode: host
```

> **注意**：长语法是 v3.2 中的新增功能

### 重启（restart）

`no`是默认的重启策略，在任何情况下都不会重启容器。当`always`指定时，容器总是重新启动。 `on-failure`如果启动失败，则重启容器。

```yaml
restart: "no"
restart: always
restart: on-failure
restart: unless-stopped
```

> **注意**：在（版本3）[以集群模式部署](https://docs.docker.com/engine/reference/commandline/stack_deploy/)时，将忽略此选项 。请改用 [restart_policy](https://docs.docker.com/compose/compose-file/#restart_policy)。

### 密钥（secrets）

授予每个服务对机密的访问权。 。支持两种不同的语法变量。

> **注意**：密码必须已经存在或已 [在`secrets`](https://docs.docker.com/compose/compose-file/#secrets-configuration-reference) 文件[的顶级](https://docs.docker.com/compose/compose-file/#secrets-configuration-reference)[配置](https://docs.docker.com/compose/compose-file/#secrets-configuration-reference)中[定义](https://docs.docker.com/compose/compose-file/#secrets-configuration-reference)，否则部署失败。

有关密钥的更多信息，请参见[密钥](https://docs.docker.com/engine/swarm/secrets/)。

#### 短语法

短语法变量仅指定密钥名称。这将授予容器访问密钥的权限，并将其挂载在在容器的`/run/secrets/<secret_name>` 。源名称和目标挂载点都设置为密钥名称。

以下示例使用短语法授予`redis`服务对`my_secret`和`my_other_secret`密钥的访问权限。值 `my_secret`设置为file的内容`./my_secret.txt`， `my_other_secret`定义为外部资源，这意味着它已经在 Docker中 定义，可以通过运行`docker secret create` 命令或通过其他部署方式进行定义。如果外部密钥不存在，则部署将失败并显示`secret not found`错误。

```yaml
version: "3.7"
services:
  redis:
    image: redis:latest
    deploy:
      replicas: 1
    secrets:
      - my_secret
      - my_other_secret
secrets:
  my_secret:
    file: ./my_secret.txt
  my_other_secret:
    external: true
```

#### 长语法

长语法提供了在服务的容器中如何创建密钥的更多粒度。

- `source`：存在于 Docker 中密钥的名称。
- `target`：在服务的容器`/run/secrets/`挂载的文件的名称。如果未指定，默认为`source`。
- `uid`和`gid`：在服务的容器中拥有文件的数字 UID 或 GID 。如果未指定，则两者都默认为`0`。
- `mode`：文件的权限以八进制表示。例如，`0444` 表示全部可读。Docker 1.13.1 中的默认值为`0000`，较新的版本采用`0444`。密钥信息不可写，因为它们已挂载在临时文件系统中，因此，如果设置可写位，它也将被忽略。可执行位可以设置。如果您不熟悉 UNIX 文件权限模式，可能会发现此 [权限计算器](http://permissions-calculator.org/) 很有用。

下面的示例设置名称`my_secret`，在容器内命名`redis_secret`，模式为`0440`（组可读），并且将用户和组设置为`103`。该`redis`服务无权访问该`my_other_secret` 机密。

```yaml
version: "3.7"
services:
  redis:
    image: redis:latest
    deploy:
      replicas: 1
    secrets:
      - source: my_secret
        target: redis_secret
        uid: '103'
        gid: '103'
        mode: 0440
secrets:
  my_secret:
    file: ./my_secret.txt
  my_other_secret:
    external: true
```

您可以授予服务访问多个密钥的权限，并且可以混合长短语法。定义密钥并不意味着授予服务对其的访问权限。

### security_opt

覆盖每个容器的默认标签方案。

```yaml
security_opt:
  - label:user:USER
  - label:role:ROLE
```

> **注意**：在（版本 3）[以集群模式部署](https://docs.docker.com/engine/reference/commandline/stack_deploy/)时，将忽略此选项 。

### stop_grace_period

指定[`stop_signal`](https://docs.docker.com/compose/compose-file/#stopsignal)在发送 SIGKILL 之前，如果容器无法处理 SIGTERM（或已使用指定的任何停止信号）而试图停止容器的等待时间 。指定为[持续时间](https://docs.docker.com/compose/compose-file/#specifying-durations)。

```yaml
stop_grace_period: 1s
stop_grace_period: 1m30s
```

默认情况下，`stop`在发送 SIGKILL 之前等待容器退出 10 秒钟。

### 停止信号

设置替代信号以停止容器。默认情况下`stop`使用 SIGTERM。使用`stop_signal`原因设置替代信号会 `stop`改为发送该信号。

```yaml
stop_signal: SIGUSR1
```

### sysctls

在容器中设置内核参数。您可以使用数组或字典。

```yaml
sysctls:
  net.core.somaxconn: 1024
  net.ipv4.tcp_syncookies: 0
sysctls:
  - net.core.somaxconn=1024
  - net.ipv4.tcp_syncookies=0
```

您只能使用内核中命名空间的 sysctls。 Docker 不支持在容器中更改 sysctls 而修改主机系统。 请参阅[在运行时配置命名空间的内核参数（sysctls）](https://docs.docker.com/engine/reference/commandline/run/#configure-namespaced-kernel-parameters-sysctls-at-runtime)。

> 在（版本 3）Compose文件[以集群模式部署](https://docs.docker.com/engine/reference/commandline/stack_deploy/)时，此选项需要Docker Engine 19.03或更高 版本。

### tmpfs

> [版本 2 文件格式](https://docs.docker.com/compose/compose-file/compose-versioning/#version-2)及更高版本。

在容器内安装一个临时文件系统。可以是单个值或列表。

```yaml
tmpfs: /run
tmpfs:
  - /run
  - /tmp
```

> 在（版本 3-3.5）Compose文件[以集群模式部署](https://docs.docker.com/engine/reference/commandline/stack_deploy/)时，将忽略此选项 。
>
> [3.6 版文件格式](https://docs.docker.com/compose/compose-file/compose-versioning/#version-3)及更高版本。

在容器内安装一个临时文件系统。Size 参数指定 tmpfs 安装的大小（以字节为单位）。默认情况下不受限制。

```yaml
 - type: tmpfs
     target: /app
     tmpfs:
       size: 1000
```

### ulimits

覆盖容器的默认 ulimit。您可以将单个限制指定为整数，也可以将软/硬限制指定为映射。

```yaml
ulimits:
  nproc: 65535
  nofile:
    soft: 20000
    hard: 40000
```

### userns_mode

```yaml
userns_mode: "host"
```

如果 Docker 守护程序配置了用户名称空间，则禁用此服务的用户名称空间。有关更多信息，请参见 [dockerd](https://docs.docker.com/engine/reference/commandline/dockerd/#disable-user-namespace-for-a-container)。

> 在（版本 3）Compose文件[以集群模式部署](https://docs.docker.com/engine/reference/commandline/stack_deploy/)时，将忽略此选项 。

### 卷（volumes）

挂载主机路径或命名卷，指定为服务的子选项。

您可以将主机路径挂载为单个服务的定义的一部分，而无需在顶级`volumes`关键词中进行定义。

但是，如果要在多个服务之间重用卷，请在[顶级`volumes`关键词中](https://docs.docker.com/compose/compose-file/#volume-configuration-reference)定义一个命名卷。将命名卷与[服务，集群和文件一起使用](https://docs.docker.com/compose/compose-file/#volumes-for-services-swarms-and-stack-files)。

> **注意**：顶级卷定义了一个命名卷，并从每个服务的`volumes`列表中引用了该卷。这将替换`volumes_from`早期版本的 Compose 文件格式。有关[卷](https://docs.docker.com/engine/admin/volumes/volumes/)的信息，请参见[使用卷](https://docs.docker.com/engine/admin/volumes/volumes/)和[卷插件](https://docs.docker.com/engine/extend/plugins_volume/)。

这个例子显示了服务（`web`）正在使用的命名卷（`mydata`），以及为单个服务（`db`服务 下的第一个路径`volumes`）定义的绑定安装。该`db`服务还使用了一个名为`dbdata`（`db`service 下的第二个路径`volumes`）的命名卷，但是使用旧的字符串格式定义了该卷以挂载命名卷。`volumes`如图所示，必须在顶级键下列出命名的卷 。

```yaml
version: "3.7"
services:
  web:
    image: nginx:alpine
    volumes:
      - type: volume
        source: mydata
        target: /data
        volume:
          nocopy: true
      - type: bind
        source: ./static
        target: /opt/app/static

  db:
    image: postgres:latest
    volumes:
      - "/var/run/postgres/postgres.sock:/var/run/postgres/postgres.sock"
      - "dbdata:/var/lib/postgresql/data"

volumes:
  mydata:
  dbdata:
```

> **注意**：有关[卷](https://docs.docker.com/engine/admin/volumes/volumes/)的一般信息，请参阅[使用卷](https://docs.docker.com/engine/admin/volumes/volumes/)和[卷插件](https://docs.docker.com/engine/extend/plugins_volume/)。

#### 短语法

在主机上指定路径（`HOST:CONTAINER`）或访问模式（`HOST:CONTAINER:ro`）。

您可以在主机上挂载相对路径，该相对路径相对于正在使用的 Compose 配置文件的目录进行扩展。相对路径应始终以`.`或开头`..`。

```yaml
volumes:
  # Just specify a path and let the Engine create a volume
  - /var/lib/mysql

  # Specify an absolute path mapping
  - /opt/data:/var/lib/mysql

  # Path on the host, relative to the Compose file
  - ./cache:/tmp/cache

  # User-relative path
  - ~/configs:/etc/configs/:ro

  # Named volume
  - datavolume:/var/lib/mysql
```

#### 长语法

长格式语法允许配置其他不能以短格式表示的字段。

- `type`：类型`volume`，`bind`，`tmpfs`或`npipe`
- `source`：挂载的源，主机上用于绑定挂载的路径或[顶级`volumes`关键词中](https://docs.docker.com/compose/compose-file/#volume-configuration-reference)定义的卷的名称 。不适用于 tmpfs 挂载。
- `target`：卷的容器中的路径
- `read_only`：将卷设置为只读的标志
- `bind`：配置其他绑定选项
  - `propagation`：用于绑定的模式
- `volume`：配置其他卷选项
  - `nocopy`：创建卷时禁用从容器复制数据
- `tmpfs`：配置其他 tmpfs 选项
  - `size`：tmpfs 挂载的大小（以字节为单位）
- `consistency`：装载的一致性要求，`consistent`（主机和容器具有相同的视图），`cached`（读缓存，主机视图具有权威性）或`delegated`（读写缓存，容器的视图具有权威性）

```yaml
version: "3.7"
services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - type: volume
        source: mydata
        target: /data
        volume:
          nocopy: true
      - type: bind
        source: ./static
        target: /opt/app/static

networks:
  webnet:

volumes:
  mydata:
```

> **注意**：长语法是 v3.2 中的新增功能

#### 服务，集群和 STACK 文件的卷

当使用服务、集群和 `docke-stack.yml`文件时，请记住，支持服务的任务(容器)可以部署在集群中的任何节点上，而且每次更新服务时可能是不同的节点。

在没有使用指定源命名卷的情况下，Docker 为支持服务的每个任务创建一个匿名卷。删除关联的容器后，匿名卷不会继续存在。

如果要保留数据，请使用命名卷和支持多主机的卷驱动程序，以便可以从任何节点访问数据。或者，对服务设置约束，以便将其任务部署在具有该卷的节点上。

例如，[Docker Labs 中 votingapp 示例](https://github.com/docker/labs/blob/master/beginner/chapters/votingapp.md)的`docker-stack.yml`文件定义了一个运行数据库的服务。它被配置为命名卷，以将数据持久存储在群集中， 并且被约束为仅在节点上运行。这是该文件的相关片段：

```yaml
version: "3.7"
services:
  db:
    image: postgres:9.4
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - backend
    deploy:
      placement:
        constraints: [node.role == manager]
```

#### 卷挂载的缓存选项（适用于 MAC 的 DOCKER 桌面）

在 Docker 17.04 CE Edge 及更高版本（包括 17.06 CE Edge 和 Stable）上，您可以在 Compose 文件中为绑定挂载的目录配置容器和主机的一致性要求，以提高卷的读/写性能。这些选项解决了`osxfs`文件共享所特有的问题，因此仅适用于 Mac 的 Docker Desktop。

这些标志是：

- `consistent`：完全一致。容器运行时和主机始终保持相同的安装视图。这是默认值。
- `cached`：主机对挂载的视图是权威的。在容器中可以看到主机上所做的更新，这可能会有所延迟。
- `delegated`：容器运行时的挂载视图具有权威性。在主机上看到容器中所做的更新之前可能会有所延迟。

这是将卷配置为的示例`cached`：

```yaml
version: "3.7"
services:
  php:
    image: php:7.1-fpm
    ports:
      - "9000"
    volumes:
      - .:/var/www/project:cached
```

有关这些标志，它们所解决的问题以及`docker run`与之对应的问题的完整详细信息，请 参见 Docker Desktop for Mac 主题[“针对卷挂载（共享文件系统）的性能调整”](https://docs.docker.com/docker-for-mac/osxfs-caching/)。

### domainname, hostname，ipc，mac_address，privileged, read_only，shm_size，stdin_open，tty，user，working_dir

每个标志都是一个值，类似于其 [docker run](https://docs.docker.com/engine/reference/run/) 对应项。请注意，`mac_address`是一个旧选项。

```yaml
user: postgresql
working_dir: /code

domainname: foo.com
hostname: foo
ipc: host
mac_address: 02:42:ac:11:65:43

privileged: true


read_only: true
shm_size: 64M
stdin_open: true
tty: true
```

## 指定持续时间

一些配置选项，例如`interval`和`timeout`子选项 [`check`](https://docs.docker.com/compose/compose-file/#healthcheck)，将持续时间作为字符串以如下格式显示：

```yaml
2.5s
10s
1m30s
2h32m
5h34m56s
```

支持的单位是`us`，`ms`，`s`，`m`和`h`。

## 指定字节值

某些配置选项，例如的`shm_size`子选项 [`build`](https://docs.docker.com/compose/compose-file/#build)，接受字节值通过字符格式，格式如下：

```yaml
2b
1024kb
2048k
300m
1gb
```

支持的单位是`b`，`k`，`m`和`g`，和它们的替代符号`kb`， `mb`和`gb`。目前不支持十进制值。

## 卷配置参考

虽然可以在服务声明中在文件上声明[卷](https://docs.docker.com/compose/compose-file/#volumes)，但是本节允许您创建命名卷（不依赖`volumes_from`），这些卷可以在多个服务中重用，并且可以使用 docker 命令行或 API。有关更多信息，请参阅 [docker volume](https://docs.docker.com/engine/reference/commandline/volume_create/)子命令文档。

有关[卷](https://docs.docker.com/engine/admin/volumes/volumes/)的信息，请参见[使用卷](https://docs.docker.com/engine/admin/volumes/volumes/)和[卷插件](https://docs.docker.com/engine/extend/plugins_volume/)。

以下是两种服务设置的示例，其中数据库的数据目录作为卷与另一服务共享，以便可以定期备份它：

```yaml
version: "3.7"

services:
  db:
    image: db
    volumes:
      - data-volume:/var/lib/db
  backup:
    image: backup-service
    volumes:
      - data-volume:/var/lib/backup/data

volumes:
  data-volume:
```

顶级`volumes`键下的条目可以为空，在这种情况下，它使用引擎配置的默认驱动程序（在大多数情况下，这是 `local`驱动程序）。您可以使用以下键对其进行配置：

### driver

指定该卷应使用哪个卷驱动程序。默认为 Docker Engine 配置使用的驱动程序，大多数情况下是 `local`。如果驱动程序不可用，则引擎在`docker-compose up`尝试创建卷时将返回错误 。

```yaml
driver: foobar
```

### driver_opts

指定选项列表，以传递给该卷的驱动程序。这些选项取决于驱动程序-有关更多信息，请参考驱动程序的文档。

```yaml
volumes:
  example:
    driver_opts:
      type: "nfs"
      o: "addr=10.40.0.199,nolock,soft,rw"
      device: ":/docker/example"
```

### external

如果设置为`true`，则指定此卷是在 Compose 之外创建的。`docker-compose up`不会尝试创建它，如果不存在则引发错误。

3.3 和以下的版本，`external` 不能与其他卷配置键 （`driver`，`driver_opts`， `labels`）一起使用。对于 [3.4](https://docs.docker.com/compose/compose-file/compose-versioning/#version-34) 及更高[版本，](https://docs.docker.com/compose/compose-file/compose-versioning/#version-34)此限制不再存在 。

在下面的示例中，Compose 不会尝试创建一个名为`[projectname]_data`的卷，而是查找一个称为`data`的现有卷，并将其装入`db`服务的容器中。

```yaml
version: "3.7"

services:
  db:
    image: postgres
    volumes:
      - data:/var/lib/postgresql/data

volumes:
  data:
    external: true
```

> [不推荐 external.name](https://docs.docker.com/compose/compose-file/compose-versioning/#version-34)，使用`name`来代替。

您还可以在 compose 文件中分别指定卷名和引用卷名的名称：

```yaml
volumes:
  data:
    external:
      name: actual-name-of-volume
```

> 外部卷始终使用 docker stack deploy 创建
>
> 如果使用[docker stack deploy](https://docs.docker.com/compose/compose-file/#deploy)以[集群模式](https://docs.docker.com/engine/swarm/)启动应用程序 （而不是 [docker compose up](https://docs.docker.com/compose/reference/up/)），则会创建不存在的外部卷。在集群模式下，由服务定义卷后将自动创建该卷。由于服务任务是在新节点上安排的，因此  [swarmkit](https://github.com/docker/swarmkit/blob/master/README.md)在本地节点上创建卷。要了解更多信息，请参见 [moby / moby＃29976](https://github.com/moby/moby/issues/29976)。

### labels

使用 [Docker 标签](https://docs.docker.com/engine/userguide/labels-custom-metadata/)将元数据添加到容器中 。您可以使用数组或字典。

建议您使用反向 DNS 表示法，以防止标签与其他软件使用的标签冲突。

```yaml
labels:
  com.example.description: "Database volume"
  com.example.department: "IT/Ops"
  com.example.label-with-empty-value: ""
labels:
  - "com.example.description=Database volume"
  - "com.example.department=IT/Ops"
  - "com.example.label-with-empty-value"
```

### name

> [3.4 版文件格式添加](https://docs.docker.com/compose/compose-file/compose-versioning/#version-34)

为此卷设置自定义名称。name 字段可用于引用包含特殊字符的卷。该名称按原样使用，不会与 stack 名称一起限定作用域。

```yaml
version: "3.7"
volumes:
  data:
    name: my-app-data
```

它也可以与`external`属性一起使用：

```yaml
version: "3.7"
volumes:
  data:
    external: true
    name: my-app-data
```

## 网络配置参考

顶级`networks`关键词可让您指定要创建的网络。

- 有关 Compose 使用 Docker 网络功能和所有网络驱动程序选项的完整说明，请参阅《[网络指南》](https://docs.docker.com/compose/networking/)。
- 有关网络的 [Docker Labs](https://github.com/docker/labs/blob/master/README.md) 教程，请从[设计可扩展的便携式 Docker 容器网络开始](https://github.com/docker/labs/blob/master/networking/README.md)

### drive

指定该网络应使用哪个驱动程序。

默认驱动程序取决于您使用的 Docker 引擎的配置方式，但是在大多数情况下，`bridge`位于单个主机，`overlay`在集群上。

如果驱动程序不可用，Docker 引擎将返回错误。

```yaml
driver: overlay
```

#### BRIDGE

Docker 默认在单个主机上使用`bridge`网络。有关如何与`bridge`网络上运行的实例，请参阅实验室教程[桥网络](https://github.com/docker/labs/blob/master/networking/A2-bridge-networking.md)。

#### OVERLAY

该`overlay`驱动程序创建一个跨多个节点命名的网络[群](https://docs.docker.com/engine/swarm/)。

- 有关如何以`overlay`群体模式构建和使用带有服务的网络的有效示例 ，请参阅《[覆盖网络和服务发现》](https://github.com/docker/labs/blob/master/networking/A3-overlay-networking.md)的 Docker Labs 教程 。
- 有关深入了解其工作原理的信息，请参见“ [覆盖驱动程序网络体系结构”](https://github.com/docker/labs/blob/master/networking/concepts/06-overlay-networks.md)上的网络概念实验室。

#### HOST OR NONE

使用主机的网络，或者不使用网络。等同于 `docker run --net=host`或`docker run --net=none`。仅在使用`docker stack`命令时使用 。如果使用`docker-compose`命令，请改用 [network_mode](https://docs.docker.com/compose/compose-file/#network_mode)。

如果要在通用版本上使用特定网络，请使用第二个 yaml 文件示例中提到的 [network]。

使用内置网络（例如`host`和`none`）的语法略有不同。使用名称`host`或`none`（Docker 已自动创建的）定义一个外部网络，以及 Compose可 以使用的别名（`hostnet`或`nonet`），然后使用该别名向该网络授予服务访问权限。

```yaml
version: "3.7"
services:
  web:
    networks:
      hostnet: {}

networks:
  hostnet:
    external: true
    name: host
services:
  web:
    ...
    build:
      ...
      network: host
      context: .
      ...
services:
  web:
    ...
    networks:
      nonet: {}

networks:
  nonet:
    external: true
    name: none
```

### driver_opts

指定选项列表作为键值对，以传递给该网络的驱动程序。这些选项取决于驱动程序-有关更多信息，请参考驱动程序的文档。

```yaml
driver_opts:
  foo: "bar"
  baz: 1
```

### attachable

> **注意**：仅 v3.2 和更高版本支持。

仅在将`driver`设置为`overlay`时使用。如果设置为`true`，则除了服务之外，独立容器还可以连接到该网络。如果独立容器连接到覆盖网络，则它可以与也从其他 Docker 守护程序附加到覆盖网络的服务和独立容器进行通信。

```yaml
networks:
  mynet1:
    driver: overlay
    attachable: true
```

### enable_ipv6

在此网络上启用 IPv6 网络。

> 文件版本 3 不支持
>
> `enable_ipv6` 要求您使用版本 2 的 Compose 文件，因为 Swarm 模式尚不支持此指令。

### ipam

指定自定义 IPAM 配置。这是一个具有多个属性的对象，每个属性都是可选的：

- `driver`：自定义 IPAM 驱动程序，而不是默认驱动程序。
- `config`：具有零个或多个配置块的列表，每个配置块包含以下任何关键词：
  - `subnet`：代表网段的 CIDR 格式的子网

一个完整的例子：

```yaml
ipam:
  driver: default
  config:
    - subnet: 172.28.0.0/16
```

> **注意**：目前`gateway`，仅适用于版本 2 的其他 IPAM 配置。

### internal

默认情况下，Docker 还将桥接网络连接到它，以提供外部连接。如果要创建外部隔离的覆盖网络，可以将此选项设置为`true`。

### labels

使用 [Docker 标签](https://docs.docker.com/engine/userguide/labels-custom-metadata/)将元数据添加到容器中 。您可以使用数组或字典。

建议您使用反向 DNS 表示法，以防止标签与其他软件使用的标签冲突。

```yaml
labels:
  com.example.description: "Financial transaction network"
  com.example.department: "Finance"
  com.example.label-with-empty-value: ""
labels:
  - "com.example.description=Financial transaction network"
  - "com.example.department=Finance"
  - "com.example.label-with-empty-value"
```

### external

如果设置为`true`，则指定此网络是在 Compose 之外创建的。`docker-compose up`不会尝试创建它，如果不存在则引发错误。

3.3 和更低格式的版本，`external`不可以（`driver`，`driver_opts`， `ipam`，`internal`）使用。对于 [3.4](https://docs.docker.com/compose/compose-file/compose-versioning/#version-34) 及更高[版本，](https://docs.docker.com/compose/compose-file/compose-versioning/#version-34)此限制不再存在 。

在下面的示例中，`proxy`是通往外界的网关。Compose 不会尝试创建一个名为`[projectname]_outside`的网络，而是寻找一个称为`outside`的现有网络并将`proxy` 服务的容器连接到该网络。

```yaml
version: "3.7"

services:
  proxy:
    build: ./proxy
    networks:
      - outside
      - default
  app:
    build: ./app
    networks:
      - default

networks:
  outside:
    external: true
```

> [不推荐 external.name](https://docs.docker.com/compose/compose-file/compose-versioning/#version-35) ，使用`name`来代替。

您还可以在文件中单独指定网络名称和用于引用网络的名称：

```yaml
version: "3.7"
networks:
  outside:
    external:
      name: actual-name-of-network
```

### name

> [3.5 版文件格式添加](https://docs.docker.com/compose/compose-file/compose-versioning/#version-35)

为该网络设置自定义名称。名称字段可用于引用包含特殊字符的网络。该名称按原样使用，不会与堆栈名称一起限定作用域。

```yaml
version: "3.7"
networks:
  network1:
    name: my-app-net
```

它也可以与`external`属性一起使用：

```yaml
version: "3.7"
networks:
  network1:
    external: true
    name: my-app-net
```

## configs 配置参考

顶级`configs`声明定义或引用可以授予此 stack 中服务的[配置](https://docs.docker.com/engine/swarm/configs/)。配置的来源是`file`或`external`。

- `file`：使用指定路径中的文件内容创建配置。
- `external`：如果设置为 true，则指定此配置已创建。Docker 不会尝试创建它，如果它不存在， 则会发生`config not found`错误。
- `name`：Docker 中配置对象的名称。此字段可用于引用包含特殊字符的配置。该名称按原样使用，不会与 stack 名称一起限定作用域。3.5 版文件格式引入。

在此示例中，`my_first_config`被创建（就像 `_my_first_config)`部署堆栈时一样，并且`my_second_config`已经存在于 Docker 中。）

```yaml
configs:
  my_first_config:
    file: ./config_data
  my_second_config:
    external: true
```

外部配置的另一个变体是 Docker 中的配置名称与服务中存在的名称不同时。以下示例修改了前一个示例，以使用名为的外部配置 `redis_config`。

```yaml
configs:
  my_first_config:
    file: ./config_data
  my_second_config:
    external:
      name: redis_config
```

您仍然需要[将配置访问权限授予](https://docs.docker.com/compose/compose-file/#configs)堆栈中的每个服务。

## secret 配置参考

顶级`secrets`声明定义或引用可以授予此 stack 中服务的[配置](https://docs.docker.com/engine/swarm/configs/)。配置的来源是`file`或`external`。

- `file`：使用指定路径中的文件内容创建配置。
- `external`：如果设置为 true，则指定此配置已创建。Docker 不会尝试创建它，如果它不存在， 则会发生`config not found`错误。
- `name`：Docker 中配置对象的名称。此字段可用于引用包含特殊字符的配置。该名称按原样使用，不会与 stack 名称一起限定作用域。3.5 版文件格式引入。

在此示例中，`my_first_config`被创建（就像 `_my_first_config)`部署堆栈时一样，并且`my_second_config`已经存在于 Docker 中。）

```yaml
secrets:
  my_first_secret:
    file: ./secret_data
  my_second_secret:
    external: true
```

外部 secret 的另一个变体是 Docker 中的密钥名称与服务中存在的名称不同时。以下示例修改了前一个示例，以使用名为的外部密钥 `redis_secret`。

### v3.5 及更高版本

```yaml
secrets:
  my_first_secret:
    file: ./secret_data
  my_second_secret:
    external: true
    name: redis_secret
```

### v3.4 及以下版本

```yaml
  my_second_secret:
    external:
      name: redis_secret
```

您仍然需要向 stack 中的每个服务[授予对机密的访问权限](https://docs.docker.com/compose/compose-file/#secrets)。

## 变量替代（Variable substitution）

您的配置选项可以包含环境变量。Compose 使用`docker-compose`运行时所在的 shell 环境中的变量值。例如，假设 shell 包含`POSTGRES_VERSION=9.3`并提供以下配置：

```yaml
db:
  image: "postgres:${POSTGRES_VERSION}"
```

当您运行`docker-compose up`这个配置，寻找 `POSTGRES_VERSION`环境变量的 shell 和替换其值。在这个例子中，在运行配置之前，解析`image`到`postgres:9.3`。

如果未设置环境变量，则 Compose 替换为空字符串。在上面的示例中，如果`POSTGRES_VERSION`未设置，则`image`选项的值为`postgres:`。

您可以使用 Compose 自动查找的[`.env`文件](https://docs.docker.com/compose/env-file/)为环境变量设置默认值 。在 shell 环境中设置的值将覆盖为`.env`文件中设置的值。

> **重要说明**：该`.env file`功能仅在使用 `docker-compose up`命令时有效，而不能与一起使用`docker stack deploy`。

`$VARIABLE`和`${VARIABLE}`语法都支持。此外，当使用 [2.1 文件格式时](https://docs.docker.com/compose/compose-file/compose-versioning/#version-21)，可以使用典型的 shell 语法提供内联默认值：

- `${VARIABLE:-default}`环境中`VARIABLE`是否未设置，如果为空，则值为`default`。
- `${VARIABLE-default}`仅`VARIABLE`在环境中未设置时值为`default`。

同样，以下语法允许您指定变量：

- `${VARIABLE:?err}` 如果环境中的变量未设置或为空，则使用包含`err`的错误消息退出。
- `${VARIABLE?err}` 如果环境中的变量未设置，则使用包含`err`的错误消息退出。

不支持其他扩展的 shell 格式，例如`${VARIABLE/foo/bar}`。

`$$`当您的配置需要美元符号时，可以使用（双美元符号）。这也可以防止 Compose 插值，因此 `$$` 允许您引用您不想由 Compose 处理的环境变量。

```yaml
web:
  build: .
  command: "$$VAR_NOT_INTERPOLATED_BY_COMPOSE"
```

如果忘记并使用单个美元符号（`$`），则 Compose 会将值解释为环境变量，并警告您：

未设置 VAR_NOT_INTERPOLATED_BY_COMPOSE。替换为空字符串。

## 扩展字段

> [3.4 版文件格式添加](https://docs.docker.com/compose/compose-file/compose-versioning/#version-34)。

可以使用扩展字段重用配置片段。这些特殊字段可以是任何格式的，只要它们位于文件的根目录中，并且它们的名称以`x-`字符序列开头。

> **注意**
>
> 从 3.7 格式（对于 3.x 系列）和 2.4 格式（对于 2.x 系列）开始，扩展字段也允许在服务，卷，网络，配置和密码定义的根目录下使用。

```yaml
version: '3.4'
x-custom:
  items:
    - a
    - b
  options:
    max-size: '12m'
  name: "custom"
```

这些字段的内容被 Compose 忽略，但是可以使用 [YAML 锚点](http://www.yaml.org/spec/1.2/spec.html#id2765878)将其插入资源定义中。例如，如果您希望多个服务使用相同的日志记录配置：

```yaml
logging:
  options:
    max-size: '12m'
    max-file: '5'
  driver: json-file
```

您可以按如下方式编写 Compose 文件：

```yaml
version: '3.4'
x-logging:
  &default-logging
  options:
    max-size: '12m'
    max-file: '5'
  driver: json-file

services:
  web:
    image: myapp/web:latest
    logging: *default-logging
  db:
    image: mysql:latest
    logging: *default-logging
```

也可以使用 [YAML 合并类型](http://yaml.org/type/merge.html)部分覆盖扩展字段中的值。例如：

```yaml
version: '3.4'
x-volumes:
  &default-volume
  driver: foobar-storage

services:
  web:
    image: myapp/web:latest
    volumes: ["vol1", "vol2", "vol3"]
volumes:
  vol1: *default-volume
  vol2:
    << : *default-volume
    name: volume02
  vol3:
    << : *default-volume
    driver: default
    name: volume-local
```

## Compose 文件

- [用户指南](https://docs.docker.com/compose/)
- [安装compose](https://docs.docker.com/compose/install/)
- [compose 文件版本和升级](https://docs.docker.com/compose/compose-file/compose-versioning/)
- [开始使用Docker](https://docs.docker.com/get-started/)
- [样品](https://docs.docker.com/samples/)
- [命令行参考](https://docs.docker.com/compose/reference/)
