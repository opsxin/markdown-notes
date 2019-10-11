# Ingress-Nginx 安装

> Configuring a webserver or loadbalancer is harder than it should be. Most webserver configuration files are very similar. There are some applications that have weird little quirks that tend to throw a wrench in things, but for the most part you can apply the same logic to them and achieve a desired result.
>
> The Ingress resource embodies this idea, and an Ingress controller is meant to handle all the quirks associated with a specific "class" of Ingress.
>
> An Ingress Controller is a daemon, deployed as a Kubernetes Pod, that watches the apiserver's `/ingresses` endpoint for updates to the [Ingress resource](https://kubernetes.io/docs/concepts/services-networking/ingress/). 
>
> 配置一个 Web 服务器或者负载均衡器比想象的难。大多数 Web 服务的配置文件非常相似。有些应用需要一些奇怪的需求，但是在大多数的情况下，可以使用相同的逻辑以达到预期的效果。
>
> Ingress 资源体现了这一思想，ingress 控制器处理了上述奇怪的需求。
>
> Ingress 控制器是一个守护进程，作为一个 Pod 部署，它监视 Apiserver 的 ingresses 端点以获取 ingress 资源的更新。

[TOC]

## 下载部署文件

```bash
# Ingress-nginx Deployment YAML 文件
for file in configmap.yaml mandatory.yaml namespace.yaml rbac.yaml with-rbac.yaml; do wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/$file; done

# Service Nodeport YAML 文件
wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/service-nodeport.yaml
```

## 修改 Service Nodeport 文件

```yaml
...
ports:
    - name: http
      port: 80
      targetPort: 80
      # 自定义 NodPort
      # 确保重启 SVC 后，Port 不变
      nodePort: 30080
      protocol: TCP
    - name: https
      port: 443
      targetPort: 443
      nodePort： 30443
      protocol: TCP
...
```

## 部署 Ingress

```bash
kubectl apply ./

# 查看 Ingress-Deploy、Service
# 注意：namespace 为 ingress-nginx
kubectl get deploy -n ingress-nginx
kubectl get svc -n ingress-nginx
```

## 测试 Ingress

### 创建 Nginx

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ingress-nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ingress-nginx
      release: test
  template:
    metadata:
      labels:
        app: ingress-nginx
        release: test
    spec:
      containers:
      - name: ingress-nginx
        image: nginx
        resources:
          limits:
            memory: "128Mi"
            cpu: "50m"
        ports:
        - containerPort: 80
          name: nginx-port

---
apiVersion: v1
kind: Service
metadata:
  name: ingress-nginx-svc
spec:
  selector:
    app: ingress-nginx
    release: test
  ports:
  - port: 80
    targetPort: nginx-port
```

### 创建 Ingress

```yaml
apiVersion: extensions/v1beta1
kind: Ingress 
metadata:
  name: nginx-ingress
  annotations: 
    kubernetes.io/ingress.class: "nginx"
spec:
  rules: 
  	# host: 确保域名与 Node 的 IP 对应
  	# 1.1.1.1 test.test.com
    - host: test.test.com
      http: 
        paths:
          - path: 
            backend:
              serviceName: ingress-nginx-svc
              servicePort: 80
```

### 部署测试应用

```bash
kubectl apply -f ./
```

### 查看 Ingress

```bash 
kubectl get ingress
# 查看详细信息
kubectl describe ingress nginx-ingress
```

### 验证 Ingress

通过外网访问域名加端口，此处为 test.test.com:30080。

<br/>

> 1. [一个nginx-ingress部署示例](https://haojianxun.github.io/2018/10/14/nginx-ingress/)
> 2. [Ingress-nginx Installation Guide](https://github.com/kubernetes/ingress-nginx/blob/master/docs/deploy/index.md)