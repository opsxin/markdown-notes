##### 监控 Ingress-Nginx

```yaml
...
annotations:
   prometheus.io/port: "10254"
   prometheus.io/scrape: "true"
...
```

使用 [ingress-nginx/deploy](https://github.com/kubernetes/ingress-nginx/tree/master/deploy) 安装的 Ingress-Nginx 已经内置了 `/metrics` 接口，并已启用，因此只需要在 Prometheus 的配置文件内添加 job 即可。

```yaml
# 先将 Ingress-Nginx:10254 作为 Service
apiVersion: v1
kind: Service
metadata:
  # name 自己设定
  name: ingress-prome-svc
  namespace: ingress-nginx
spec:
  selector:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
  ports:
  - name: export-port
    port: 10254
    targetPort: 10254
    
---
# 在 Prometheus 的 ConfigMap 中添加 Job
...
- job_name: 'ingress-nginx'
  static_configs:
  # 使用 FQDN
  # <svc-name>.<namespace>.svc.cluster.local
  - targets: ['ingress-prome-svc.ingress-nginx.svc.cluster.local:10254']
```

重载配置，使配置生效

```bash
curl -X POST http://NodeIP:Port/-/reload
```

浏览器访问 `http://NodeIP:Port`，查看。

---

##### 使用 Exporter 监控应用

官方文档已分类总结 Exporter（包括第三方）：[EXPORTERS AND INTEGRATIONS](https://prometheus.io/docs/instrumenting/exporters/)

```yaml
# 试用 redis-exposter
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-prome
  namespace: kube-prome
spec:
  selector:
    matchLabels:
      app: redis-prome
  template:
    metadata:
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9121"
      labels:
        app: redis-prome
    spec:
      containers:
      - name: redis-prome
        image: redis 
        resources:
          limits:
            memory: "100Mi"
            cpu: "50m"
          requests:
            memory: "100Mi"
            cpu: "10m"
        ports:
        - containerPort: 6379
          name: redis-port
      - name: redis-export
        image: oliver006/redis_exporter
        resources:
          limits: 
            memory: "100Mi"
            cpu: "50m"
          requests:
            memory: "50Mi"
            cpu: "10m"
        ports:
          - name: export-port
            containerPort: 9121

---
apiVersion: v1
kind: Service
metadata:
  name: redis-prome-svc
  namespace: kube-prome
spec:
  selector:
    app: redis-prome
  ports:
  - port: 6379
    targetPort: redis-port
    name: redis-svc
  - port: 9121
    targetPort: export-port
    name: export-svc
```

```yaml 
# 修改 ConfigMap，注意修改文件名和 Namespace
# kubectl edit cm prometheus-config -n kube-prometheus
# 添加 Job
- job_name: 'redis-export'
  static_configs:
  - targets: ['redis-prome-svc:9121']
```

重载配置，使配置生效

```bash
curl -X POST http://NodeIP:Port/-/reload
```

浏览器访问 `http://NodeIP:Port`，查看。

---

##### 监控集群节点

> - kube-state-metrics 主要关注的是业务相关的一些元数据，比如 Deployment、Pod、副本状态等
> - metrics-server 主要关注的是[资源度量 API](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/instrumentation/resource-metrics-api.md) 的实现，比如 CPU、文件描述符、内存、请求延时等指标。
>
> 以上两种只是显示数据，并不提供数据存储服务。

```yaml
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: kube-prometheus
  labels:
    name: node-exporter
spec:
  template:
    metadata:
      labels:
        name: node-exporter
    spec:
      hostPID: true
      hostIPC: true
      hostNetwork: true
      containers:
      - name: node-exporter
        image: prom/node-exporter
        ports:
        - containerPort: 9100
        resources:
          requests:
            memory: "100Mi"
            cpu: "0.15"
        securityContext:
          privileged: true
        args:
        - --path.procfs
        - /host/proc
        - --path.sysfs
        - /host/sys
        - --collector.filesystem.ignored-mount-points
        - '"^/(sys|proc|dev|host|etc)($|/)"'
        volumeMounts:
        - name: dev
          mountPath: /host/dev
        - name: proc
          mountPath: /host/proc
        - name: sys
          mountPath: /host/sys
        - name: rootfs
          mountPath: /rootfs
      tolerations:
      - key: "node-role.kubernetes.io/master"
        operator: "Exists"
        effect: "NoSchedule"
      volumes:
        - name: proc
          hostPath:
            path: /proc
        - name: dev
          hostPath:
            path: /dev
        - name: sys
          hostPath:
            path: /sys
        - name: rootfs
          hostPath:
            path: /
```

###### 服务发现

> 在 Kubernetes 下，Promethues 通过与 Kubernetes API 集成，目前主要支持5中服务发现模式，分别是：Node、Service、Pod、Endpoints、Ingress。

配置 ConfigMap

```yaml
- job_name: 'kubernetes-nodes'
  kubernetes_sd_configs:
  - role: node
  relabel_configs:
  - source_labels: [__address__]
    regex: '(.*):10250'
    replacement: '${1}:9100'
    target_label: __address__
    action: replace
  - action: labelmap
    regex: __meta_kubernetes_node_label_(.+)
```

重载配置，使配置生效

```bash
curl -X POST http://NodeIP:Port/-/reload
```

浏览器访问 `http://NodeIP:Port`，查看。



> [kubernetes_sd_config]([https://prometheus.io/docs/prometheus/latest/configuration/configuration/#%3Ckubernetes_sd_config%3E](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#))