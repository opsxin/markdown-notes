# AdGuard

> AdGuard Home is a network-wide software for blocking ads & tracking. After you set it up, it'll cover ALL your home devices, and you don't need any client-side software for that.
>
> It operates as a DNS server that re-routes tracking domains to a "black hole," thus preventing your devices from connecting to those servers.
>
> AdGuard Home 是一个阻止广告和追踪的网络软件。设置完成后，它将覆盖所有的家用设备，并且不需要安装任何的客户端，
>
> 它作为 DNS 服务器，将追踪的域名路由到 “黑洞” 中，从而防止你的设备连接这些服务。

[TOC]

## 下载 AdGuard

浏览 [AdGuard 官方 Github](https://github.com/AdguardTeam/AdGuardHome)，README 和 Wiki 中有详细的项目介绍和快速开始，有兴趣的可以阅读。

[官方下载地址](https://github.com/AdguardTeam/AdGuardHome/releases)：请根据自己的服务器架构选择下载。

## 配置 AdGuard

### 解压

```bash
# 当前最新的版本为 0.98.1
$tar zxvf AdGuardHome_linux_amd64.tar.gz
AdGuardHome/
AdGuardHome/LICENSE.txt
AdGuardHome/AdGuardHome
AdGuardHome/README.md
```

### 移动执行文件

```bash
# 将可执行文件移动到 /usr/local/bin 下
$mv AdGuardHome /usr/local/bin
```

### 启动服务

```bash
#AdGuardHome -s install
2019/09/24 21:01:24 [info] Service control action: install
2019/09/24 21:01:24 [info] Action install has been done successfully on linux-systemd
2019/09/24 21:01:24 [info] Service has been started
2019/09/24 21:01:24 [info] Almost ready!
AdGuard Home is successfully installed and will automatically start on boot.
There are a few more things that must be configured before you can use it.
Click on the link below and follow the Installation Wizard steps to finish setup.
2019/09/24 21:01:24 [info] AdGuard Home is available on the following addresses:
2019/09/24 21:01:24 [info] Go to http://127.0.0.1:3000
2019/09/24 21:01:24 [info] Go to http://172.17.0.10:3000
```

### 配置防火墙

```bash
# 允许 AdGuardHome 的 WEB 界面
#iptables -I INPUT -p tcp --dport 3000 -j ACCEPT
# 允许 DNS UDP 53 端口
#iptables -I INPUT -p udp --dport 53 -j ACCEPT
```

### 访问 WEB 界面

![1569331350257](1569331350257.png)

### WEB 页面中配置

1. 建议 “使用 AdGuard【浏览安全】网页服务” 和 “强制安全搜索” 也选择。

   ![1569331391278](1569331391278.png)



2. 设置上游服务器

   国内阿里和腾讯的 DNS 相对还可靠，所以设置上游 DNS 服务器为这两家的。

   建议选上 ”通过同时查询所有上流服务器以使用并行查询加速解析“ 加速解析。

   ![1569331605853](1569331605853.png)

3. 配置过滤器

   因为官方的广告规则不太适合国内的情况，所以添加适合国情的的源。

   下列是一些建议的源：

   1. [EasyList China](https://www.runningcheese.com/go?url=https://easylist-downloads.adblockplus.org/easylistchina.txt)：EasyList China 的官方源。
   2. [EasyPrivacy](https://www.runningcheese.com/go?url=https://easylist-downloads.adblockplus.org/easyprivacy.txt)：隐私防护。
   3. [CJX's Annoyance List](https://www.runningcheese.com/go?url=https://raw.githubusercontent.com/cjx82630/cjxlist/master/cjx-annoyance.txt)：同样是隐私防护。
   4. [ChinaList](https://www.runningcheese.com/go?url=http://tools.yiclear.com/ChinaList2.0.txt)：视频广告拦截。

   ![1569331837033](1569331837033.png)


## 使用 AdGuard

