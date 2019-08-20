##### 从 [ingress-nginx](https://github.com/kubernetes/ingress-nginx) 下载 Deploy  Yaml 文件

```bash
for file in configmap.yaml mandatory.yaml namespace.yaml rbac.yaml with-rbac.yaml; do wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/$file; done
```

##### 下载 Service-Nodeport 文件

```bash
wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/service-nodeport.yaml
```

##### 修改 Service-Nodeport 文件

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

##### 应用已下载 Yaml

```bash
kubectl apply ./
```

##### 查看 Ingress-Deploy、Service

```bash
# 注意：namespace 为 ingress-nginx
kubectl get deploy -n ingress-nginx
kubectl get svc -n ingress-nginx
```

##### 测试 Ingress

###### 创建 Nginx

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

###### 创建 Ingress

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

###### 应用 Yaml

```bash
kubectl apply -f ./
```

###### 查看 Ingress

```bash 
kubectl get ingress
# 查看详细信息
kubectl describe ingress nginx-ingress
```

###### 验证 Ingress

通过外网访问域名加端口，此处为 test.test.com:30080。



> 1. [一个nginx-ingress部署示例](https://haojianxun.github.io/2018/10/14/nginx-ingress/)
> 2. [Ingress-nginx Installation Guide](https://github.com/kubernetes/ingress-nginx/blob/master/docs/deploy/index.md)