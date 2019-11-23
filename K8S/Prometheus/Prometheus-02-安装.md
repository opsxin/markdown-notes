# 安装 prometheus

## Prometheus 配置文件

```yaml
# 全局设置，可以被覆盖
global:
  # 每次数据收集的间隔，默认值为 15s
  scrape_interval: 15s
  # 控制评估规则的频率
  # prometheus 使用规则产生新的时间序列数据或者产生警报
  evaluation_interval：15s
  # 所有时间序列和警告与外部通信时用的外部标签
  external_labels:  
    monitor: 'codelab-monitor'
# 警告规则设置文件
rule_files:
  - '/etc/prometheus/alert.rules'

# 用于配置 scrape 的 endpoint
scrape_configs:
  # 全局唯一, 采集 Prometheus 自身的 metrics
  - job_name: 'prometheus'
    # 覆盖全局的 scrape_interval
    scrape_interval: 5s
    # 静态目标的配置
    static_configs:
      - targets: ['127.0.0.1:9090']

  # 全局唯一, 采集本机的 metrics，需要在本机安装 node_exporter
  - job_name: 'node'
    scrape_interval: 10s
    static_configs:
      # 本机 node_exporter 的 endpoint
      - targets: ['10.0.2.15:9100']
```

## Alert 配置文件

```yaml
# alert 名字（InstanceDown）
ALERT InstanceDown  
  # 判断条件
  IF up == 0
  # 条件保持 5m 才会发出 alert
  FOR 5m
  # alert 的标签
  LABELS { severity = "critical" }
  # 其他标签，但不用于标识 alert
  ANNOTATIONS {
    summary = "Instance {{ $labels.instance }} down",
    description = "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes.",
 }
```

----

## 创建 Namespace（便于管理）

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: kube-prometheus
  labels:
    name: kube-prometheus
```

## 创建 ConfigMap（管理 Prometheus 配置文件）

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  # 使用新创建的 Namespace
  namespace: kube-prometheus
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      scrape_timeout: 15s
    scrape_configs:
    - job_name: 'prometheus'
      static_configs:
      - targets: ['localhost:9090']
```

## 创建 RBAC

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus
  # 使用新创建的 Namespace
  namespace: kube-prometheus

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus
rules:
- apiGroups:
  - ""
  resources:
  - nodes
  - services
  - endpoints
  - pods
  - nodes/proxy
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - configmaps
  - nodes/metrics
  verbs:
  - get
- nonResourceURLs:
  - /metrics
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: prometheus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus
subjects:
- kind: ServiceAccount
  name: prometheus
  # 使用新创建的 Namespace
  namespace: kube-prometheus
```

## 创建 PVC

 ```yaml
# 此处使用 NFS-Client
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prometheus
  namespace: kube-prometheus
  annotations:
    volume.beta.kubernetes.io/storage-class: "managed-nfs-storage"
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 200M
 ```

## 创建 Prometheus Server

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus-server
  namespace: kube-prometheus
spec:
  selector:
    matchLabels:
      app: prometheus-server
  template:
    metadata:
      labels:
        app: prometheus-server
    spec:
      serviceAccountName: prometheus
      containers:
      - name: prometheus-server
        image: prom/prometheus
        command:
          - "/bin/prometheus"
        args:
          - "--config.file=/etc/prometheus/prometheus.yml"
          # 指定 TSDB 的存储路径
          - "--storage.tsdb.path=/prometheus"
          # 指定 TSDB 的存储时间
          - "--storage.tsdb.retention=24h"
          - "--web.enable-admin-api"
          # 开启热更新
          # 访问 localhost:9090/-/reload，就能使配置文件生效
          - "--web.enable-lifecycle"
        resources:
          limits:
            memory: "128Mi"
            cpu: "50m"
        ports:
        - containerPort: 9090
          name: prome-port
        volumeMounts:
          - mountPath: "/prometheus"
            subPath: prometheus01
            name: data
          - mountPath: "/etc/prometheus"
            name: config
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: prometheus
        - name: config
          configMap:
            name: prometheus-config
```

## 创建 Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: prome-svc
  namespace: kube-prometheus
spec:
  selector:
    app: prometheus-server
  # 使用 NodePort 方式
  type: NodePort
  ports:
  - port: 9090
    targetPort: prome-port
```

## 应用上方创建的所有 Yaml

```bash
kubectl create -f ./
```

通过访问 `http://nodeport:port` 访问 Prometheus WebUI。
