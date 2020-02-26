# Jenkins 加速下载插件(Plugins)

## 调整升级站点

依次点击*Jenkins -> 插件管理 -> 高级(Jenkins -> Manage Plugins -> Advanced)* ，修改 URL 为`https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json`，并提交。

## 调整 Json 文件

### 切换当前目录到 Jenkins 家目录的 updates 文件夹下

```bash
cd ${JENKINS_HOME}/updates/
```

### 修改 default.json

```bash
sed -i 's|http://updates.jenkins-ci.org/download|https://mirrors.tuna.tsinghua.edu.cn/jenkins|g' default.json
sed -i 's|http://www.google.com|https://www.baidu.com|g' default.json
```

## 重启 Jenkins
