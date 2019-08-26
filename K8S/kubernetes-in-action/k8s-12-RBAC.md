##### 使用 RBAC 认证

基于角色的访问控制（RBAC）是一种基于企业中单个用户角色来调节对计算机或网络资源访问的方法。

`RBAC` 使用 `rbac.authorization.k8s.io` API 组实现认证，允许管理员通过 Kubernetes API 动态配置策略。

截至 1.8，RBAC 模式是稳定的，由 rbac.authorization.k8s.io/v1 API 提供支持。

要使用 RBAC，需要在启动 apiserver 时添加 `--authorization-mode=RBAC` 。

---

##### API 概述

本节将介绍 RBAC API 所定义的四种顶级类型。用户可以像其他 Kubernetes API 资源一样 （例如通过`kubectl`、API调用等）与这些资源进行交互。

###### Role 和 ClusterRole

在 RBAC API 中，一个角色规则代表了一组权限。 权限以纯粹是累加的（没有”否定”的规则）。角色可以在命名空间（namespace）内的`Role`对象定义，而整个 Kubernetes 集群范围内有效的角色则通过`ClusterRole`对象实现。

角色（Role）只能用于授予单个命名空间中的资源访问。下面是缺省命名空间（Default）中的一个示例角色（Role），可对 pods 的读访问权授权：

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
# "" 代表 core API group
- apiGroups: [""] 
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

`ClusterRole` 可以被用于授权和`Role`相同的权限，但是因为它是集群范围内的，因此也被用于授权接入：

- 集群资源（像 Node）
- 非资源端点（non-resource endpoints）（像 “/healthz”）
- 命名空间资源（像 Pods）访问所有命名空间（需要去运行 `kubectl get pods –all-namespaces`）

下列`clusterRole`可以被使用授权读特定命名空间内的 `secrets` ，或者所有命名空间（取决于它的绑定方式([bound](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding))）内的：

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  # "namespace" omitted since ClusterRoles are not namespaced
  # ClusterRole 是集群范围对象，所以不需要定义 "namespace" 字段
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]
```

###### RoleBinding 和 ClusterRoleBinding

角色绑定（RoleBinding）将一个角色（Role）中定义的权限授予一个用户或一组用户。它包含一个主题列表(用户（users）、组（groups）或服务帐户（service accounts）)，以及对被授予角色的引用。命名空间内通过角色绑定（RoleBinding）授予权限，在集群范围内使用集群绑定（ClusterRoleBinding）授予权限。

角色绑定引用一个角色在相同的命名空间，下列的角色绑定（RoleBinding）在默认命名空间（default）授权 “pod-reader” 角色给 “jane” 。

`roleRef`是实际创建绑定的方式， 类型（kind）将是 Role 或 ClusterRole ，名称（name）将引用 Role 或ClusterRole 的名称。在下面的示例中，这个角色绑定（RoleBinding）使用 roleRef 将用户 jane 绑定到上面创建的名为 pod-reader 的角色。

```yaml
apiVersion: rbac.authorization.k8s.io/v1
# This role binding allows "jane" to read pods in the "default" namespace.
# 以下角色绑定定义将允许用户 "jane" 从 "default" 命名空间中读取 pod。
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  # Name is case sensitive
  # 大小写敏感
  name: jane 
  apiGroup: rbac.authorization.k8s.io
roleRef:
  # this must be Role or ClusterRole
  # 必须是 Role 或者 ClusterRole
  kind: Role 
  # this must match the name of the Role or ClusterRole you wish to bind to
  # 这里是你希望绑定的角色名字
  name: pod-reader 
  apiGroup: rbac.authorization.k8s.io
```

角色绑定（RoleBinding）还可以引用 `ClusterRole` 用于在`RoleBinding`所在的命名空间内授予用户对所引用的`ClusterRole`中定义的命名空间资源的访问权限。这允许管理员为整个集群定义一组公共角色，然后在多个名称空间中重用。

例如，即使下面的角色绑定（RoleBinding）引用了 ClusterRole, “dave”（主题（Subject）,区分大小写）也只能读取 “development” 命名空间(角色绑定的命名空间)中的 secrets

```yaml
apiVersion: rbac.authorization.k8s.io/v1
# This role binding allows "dave" to read secrets in the "development" namespace.
kind: RoleBinding
metadata:
  name: read-secrets
  # This only grants permissions within the "development" namespace.
  # 只被授权 “development” 命名空间
  namespace: development 
subjects:
- kind: User
  # Name is case sensitive 
  # 大小写敏感
  name: dave 
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

最后，可以使用 ClusterRoleBinding 在集群级别和所有命名空间中授予权限。下面的 ClusterRoleBinding 允许组中的任何用户读取任何命名空间中的 secret。

```yaml
apiVersion: rbac.authorization.k8s.io/v1
# This cluster role binding allows anyone in the "manager" group to read secrets in any namespace.
kind: ClusterRoleBinding
metadata:
  name: read-secrets-global
subjects:
- kind: Group
  name: manager # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

不能修改绑定对象引用的角色或集群角色，试图更改绑定对象的 roleRef 字段将导致验证错误，要更改现有绑定对象上的 roleRef 字段，必须删除并重新创建对象绑定，这种限制有两个主要原因：

1. 绑定到不同角色是一种根本不同的绑定。删除/重新绑定去更改 roleRef 确保绑定中的所有主题（subjects）列表都被授予新角色（应该授予新角色权限，而不是在现有主题（subjects）的情况下修改 roleRef）。
2. 使 roleRef 不可变允许将现有绑定对象的更新（update）权限授予用户，这允许用户管理主题列表，而不能更改授予这些主题的角色。

`kubectl auth`命令行能够创建或更新包含 RBAC 对象的清单文件（manifest），并处理删除和重新创建绑定对象(如果需要更改它们所引用的角色)。

###### 引用资源（Referring to Resources）

大多数资源都用字符串表示名字，比如 pods，就像它出现在相关 API 端点（API Endpoint）的URL中一样。然而，一些 Kubernetes api 涉及子资源（subresource），比如 pod 的日志，pods 日志端点的 URL 是：

```bash
GET /api/v1/namespaces/{namespace}/pods/{name}/log
```

在本例中，pods 是命名空间资源，log 是 pods 的子资源。要在 RBAC 角色中表示这一点，请使用斜杠分隔资源和子资源。要允许主题同时读取 pod 和 pod 日志，可以这样写：

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-and-pod-logs-reader
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list"]
```

资源也能被引用通过某些名字请求通过 resourceNames 列表，当指定时，可以将请求限制为资源的单个实例。要将 subject 限制为只获取（get）和更新（update）一个 configmap，可以这样写:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: configmap-updater
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["my-configmap"]
  verbs: ["update", "get"]
```

注意，create 不能设置 resourceName，因为在授权时不知道对象名称（object name）。一个例外是删除收集（delete collection）。

###### 分配集群角色（Aggregated ClusterRoles）

从1.9开始，可以使用 aggregationRule 组合其他集群角色来创建集群角色。聚合集群角色的权限由控制器管理，并通过统一与提供的标签选择器匹配的任何集群角色的规则来填充。聚合的 ClusterRole 示例：

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring
aggregationRule:
  clusterRoleSelectors:
  - matchLabels:
      rbac.example.com/aggregate-to-monitoring: "true"
# Rules are automatically filled in by the controller manager.
# Rules 被控制器自动填充
rules: [] 
```

创建标签选择器匹配的 ClusterRole 将向聚合的 ClusterRole 添加规则。在这种情况下，可以通过创建 “monitoring” 集群角色通过创建另一个有标签为 `rbac.example.com/aggregate-to-monitoring：true` 的集群角色:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-endpoints
  labels:
    rbac.example.com/aggregate-to-monitoring: "true"
# These rules will be added to the "monitoring" role.
# 这些 Rules 将被添加到 “Monitoring” 角色
rules:
- apiGroups: [""]
  resources: ["services", "endpoints", "pods"]
  verbs: ["get", "list", "watch"]
```

默认的面向用户的角色使用 ClusterRole 聚合。这使得管理员可以在缺省角色上包含定制资源的规则，例如由customresourcedefinition 或聚合 API 服务器提供的规则。例如，以下 ClusterRoles 允许管理员和编辑默认角色管理自定义资源 CronTabs，而视图（view）角色对资源执行只读操作。

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: aggregate-cron-tabs-edit
  labels:
    # Add these permissions to the "admin" and "edit" default roles.
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
rules:
- apiGroups: ["stable.example.com"]
  resources: ["crontabs"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: aggregate-cron-tabs-view
  labels:
    # Add these permissions to the "view" default role.
    rbac.authorization.k8s.io/aggregate-to-view: "true"
rules:
- apiGroups: ["stable.example.com"]
  resources: ["crontabs"]
  verbs: ["get", "list", "watch"]
```

###### 角色示例（Role Examples）

允许读 pods 资源

```yaml
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

允许读/写 extensions，apps API 组内的 deployment

```yaml
rules:
- apiGroups: ["extensions", "apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```

允许读 pod，读写 jobs

```yaml
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["batch", "extensions"]
  resources: ["jobs"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```

允许读 “my-config” 的 ConfigMap（必须与 RoleBinding 绑定以限制单个命名空间中的单个 ConfigMap）

```yaml
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["my-config"]
  verbs: ["get"]
```

允许读取核心组中的资源节点(因为节点（Node）是集群范围的，所以必须将其绑定在集群角色（ClusterRole）中，并使用集群角色（CluterRoleBinding）绑定才能有效)

```yaml
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list", "watch"]
```

允许 “Get” 和 “Post” 请求在非资源端点和所有子路径（subpath）（必须在 ClusterRole 和ClusterRoleBinding 绑定生效）

```yaml
rules:
- nonResourceURLs: ["/healthz", "/healthz/*"] # '*' in a nonResourceURL is a suffix glob match
  verbs: ["get", "post"]
```

###### 引用对象（Referring to Subjects）

`RoleBinding`或者`ClusterRoleBinding`将角色绑定到*角色绑定主体*（Subject）。 角色绑定主体可以是用户组（Group）、用户（User）或者服务账户（Service Accounts）。

用户由字符串表示。可以是纯粹的用户名，例如 ”alice”、电子邮件风格的名字，如 “bob@example.com” 或者是用字符串表示的数字 id。由 Kubernetes 管理员配置[认证模块](https://k8smeetup.github.io/docs/admin/authentication/) 以产生所需格式的用户名。对于用户名，RBAC 授权系统不要求任何特定的格式。然而，前缀 `system:` 是 为 Kubernetes 系统使用而保留的，所以管理员应该确保用户名不会意外地包含这个前缀。

Kubernetes 中的用户组信息由授权模块提供。用户组与用户一样由字符串表示。Kubernetes 对用户组字符串没有格式要求，但前缀`system:`同样是被系统保留的。

[服务账户](https://k8smeetup.github.io/docs/tasks/configure-pod-container/configure-service-account/)拥有包含 `system:serviceaccount:`前缀的用户名，并属于拥有`system:serviceaccounts:`前缀的用户组。

###### 角色绑定示例

对于用户 “alice@example.com”

```yaml
subjects:
- kind: User
  name: "alice@example.com"
  apiGroup: rbac.authorization.k8s.io
```

对于 “fornted-admins” 组

```yaml
subjects:
- kind: Group
  name: "frontend-admins"
  apiGroup: rbac.authorization.k8s.io
```

对于默认服务账号（default service account）在 kube-system 命名空间

```yaml
subjects:
- kind: ServiceAccount
  name: default
  namespace: kube-system
```

对于服务账户在 “qa” 命名空间

```yaml
subjects:
- kind: Group
  name: system:serviceaccounts:qa
  apiGroup: rbac.authorization.k8s.io
```

对于所有服务账户

```yaml
subjects:
- kind: Group
  name: system:serviceaccounts
  apiGroup: rbac.authorization.k8s.io
```

对于所有认证用户（版本 1.5+）

```yaml
subjects:
- kind: Group
  name: system:authenticated
  apiGroup: rbac.authorization.k8s.io
```

对于所有未认证用户（版本 1.5+）

```yaml
subjects:
- kind: Group
  name: system:unauthenticated
  apiGroup: rbac.authorization.k8s.io
```

对于所有用户（版本 1.5+）

```yaml
subjects:
- kind: Group
  name: system:authenticated
  apiGroup: rbac.authorization.k8s.io
- kind: Group
  name: system:unauthenticated
  apiGroup: rbac.authorization.k8s.io
```

---

###### 默认角色和角色绑定

API Server 会创建一组默认的 `ClusterRole` 和 `ClusterRoleBinding` 对象。 这些默认对象中有许多包含 `system: `前缀，表明这些资源由 Kubernetes 基础组件 ”拥有”。 对这些资源的修改可能导致非功能性集群（non-functional cluster）。一个例子是 `system:node` ClusterRole 对象。 这个角色定义了 kubelets 的权限。如果这个角色被修改，可能会导致 kubelets 无法正常工作。

所有默认的 ClusterRole 和 ClusterRoleBinding 对象都会被标记为`kubernetes.io/bootstrapping=rbac-defaults`。

###### 自动协调（Auto-reconciliation）

在每次启动时，API 服务器都会使用任何丢失的（missing）权限更新默认集群角色，并使用任何丢失的主题更新默认集群角色绑定。这允许集群修复意外的修改，并在新版本中随着权限和主题的更改而更新角色和角色绑定。

要选择退出此协调，请设置默认群集角色或 rolebinding上的rbac.authorization.kubernetes.io/autoupdate 设置为 false。请注意，缺少默认权限和主题可能会导致非功能性群集。

自动协调可用在 Kubernetes 1.6+，并当 RBAC 授权器处于活动状态时。

###### 发现角色（Discovery Roles）

未理解翻译加拷贝太痛苦，先理解再来试着翻译。

To-Do…



> [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
>
> [RBAC——基于角色的访问控制](https://jimmysong.io/kubernetes-handbook/guide/rbac.html)



