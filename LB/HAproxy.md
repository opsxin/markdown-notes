# HAproxy 使用

HAproxy^1^ 可以实现基于 TCP（四层，SSH、SMTP、MYSQL）和 HTTP（七层，WEB）应用代理软件，同时也可以作为负载均衡使用。
​HAproxy 可以支持数以万计的并发连接，同时可以保护 WEB 服务不暴露到网络上。

[TOC]

## 主流负载均衡软件对比^2^

### LVS

1. 抗负载能力强，性能高，能达到 F5 硬件的 60%，对内存和 cpu 资源消耗比较低 ;
2. 工作在网络 4 层，具体的流量由 linux 内核处理，因此没有流量的产生;
3. 稳定性、可靠性好，自身有完美的热备方案（如：LVS+Keepalived）；
4. 应用范围比较广，可以对所有应用做负载均衡； 
5. 不支持正则处理，不能做动静分离;
6. 支持负载均衡算法：rr（轮循）、wrr（带权轮循）、lc（最小连接）、wlc（权重最小连接）; 
7. 配置复杂，对网络依赖比较大，稳定性很高。

###  Ngnix

 1. 工作在网络的 7 层之上，可以针对 http 应用做一些分流的策略，比如针对域名、目录结构； (补充：现在同样支持 4 层负载，类似 LVS 的 NAT 模式)
 2. Nginx 对网络的依赖比较小，理论上能 ping 通就就能进行负载功能； 
 3. Nginx 安装和配置比较简单，测试起来比较方便； 
 4. 可以承担高的负载压力且稳定，一般能支撑超过 1 万次的并发；
 5. 对后端服务器的健康检查，只支持通过端口来检测，不支持通过 url 来检测；
 6. Nginx 对请求的异步处理可以帮助节点服务器减轻负载； 
 7. Nginx 仅能支持 http、https 和 Email 协议，这样就在适用范围较小；（补充：同第一点）
 8. 不支持 Session 的直接保持，但能通过 ip_hash 来解决，对 Big request header 的支持不是很好；
 9. 支持负载均衡算法：Round-robin（轮循）、Weight-round-robin（带权轮循）、Ip-hash（Ip哈希） ；
 10. Nginx 还能做 Web 服务器与 Cache 服务器。

##  HAProxy的特点 

 1. 支持两种代理模式：TCP（四层）和 HTTP（七层），支持虚拟主机；

 2. 能够补充 Nginx 的一些缺点，比如 Session 的保持，Cookie 的引导等；

 3. 支持后端的服务器 URL 检测； 

 4. 负载均衡策略：动态加权轮循（Dynamic Round Robin），加权源地址哈希（Weighted Source Hash）， 加权 URL 哈希和加权参数哈希（Weighted Parameter Hash）已经实现 ；

 5. 单纯从效率上来讲 HAProxy 比 Nginx 有更出色的负载均衡速度； 

 6. HAProxy 可以对 Mysql 进行负载均衡，对后端的 DB 节点进行检测和负载均衡； 

 7. 支持负载均衡算法：Round-robin（轮循）、Weight-round-robin（带权轮循）、source（原地址保持）、 RI（请求URL）、rdp-cookie（根据cookie）； 

 8. 不能做 Web 与 Cache 服务器。

## 配置文件^3^

  1. `globe`：参数时进程级别的，通常是和操作系统相关。

  2. `defaults`：默认参数，这些参数可以用到 frontend，backend，listen 组件。

  3. `frontend`：接受请求的前端虚拟节点，可以增加规则指定后端的 backend；

  4. `backend`：后端服务集群的配置，是真实存在的服务器，一个 backend 对应一个或者多个服务器。

  5. `listen`：frontend 和 backend 的组合体（即 frontend 和 backend 合写）。

     ```yaml
     ## haproxy.conf
     
     # 全局参数的设置
     global   
     # log 语法：log <address> [max_level] 
     # 全局的日志配置，使用 log 关键字，指定使用 127.0.0.1 上的 syslog 服务中的 local0 日志设备，记录日志等级为 info
     log 127.0.0.1 local0 info
     # 设置运行 haproxy 的用户和组，也可使用 uid，gid 关键字替代之
     user haproxy
     group haproxy
     # 以守护进程的方式运行           
     daemon
     # 设置 haproxy 启动时的进程数
     # 将其理解为：该值的设置应该和服务器的 CPU 核心数一致，即常见的 2 颗 8 核心 CPU 的服务器，即共有 16 核心，则可以将其值设置为：<=16 
     # 创建多个进程数，可以减少每个进程的任务队列，但是过多的进程数也可能会导致进程的崩溃           
     nbproc 16
     # 定义每个 haproxy 进程的最大连接数 ，由于每个连接包括一个客户端和一个服务器端，所以单个进程的 TCP 会话最大数目将是该值的两倍。           
     maxconn 4096
     # 设置最大打开的文件描述符数，在 1.4 的官方文档中提示，该值会自动计算，所以不建议进行设置         
     #ulimit -n 65536
     # 定义 haproxy 的 pid 存放位置            
     pidfile /var/run/haproxy.pid
     
     # 默认部分的定义           
     defaults 
     # mode 语法：mode {http|tcp|health} 。
     # http 是七层模式，tcp 是四层模式，health 是健康检测，返回 OK 
     mode http
     # 使用 127.0.0.1 上的 syslog 服务的 local3 设备记录           
     log 127.0.0.1 local3 err
     # 定义连接后端服务器的失败重连次数，连接失败次数超过此值后将会将对应后端服务器标记为不可用         
     retries 3
     # 启用日志记录 HTTP 请求，默认 haproxy 日志记录是不记录 HTTP 请求的，只记录“时间[Jan 5 13:23:46] 日志服务器[127.0.0.1] 实例名已经 pid[haproxy[25218]] 信息[Proxy http_80_in stopped.]”，日志格式很简单。           
     option httplog
     # 当使用了 cookie 时，haproxy 将会将其请求的后端服务器的 serverID 插入到 cookie 中，以保证会话的 SESSION 持久性；而此时，如果后端的服务器宕掉了，但是客户端的 cookie 是不会刷新的，如果设置此参数，将会将客户的请求强制定向到另外一个后端 server 上，以保证服务的正常。           
     option redispatch
     # 当服务器负载很高的时候，自动结束掉当前队列处理比较久的链接           
     option abortonclose
     # 启用该项，日志中将不会记录空连接。所谓空连接就是在上游的负载均衡器或者监控系统为了探测该服务是否存活可用时，需要定期的连接或者获取某一固定的组件或页面，或者探测扫描端口是否在监听或开放等动作被称为空连接；官方文档中标注，如果该服务上游没有其他的负载均衡器的话，建议不要使用该参数，因为互联网上的恶意扫描或其他动作就不会被记录下来           
     option dontlognull
     # 使用该参数，每处理完一个 request 时，haproxy 都会去检查 http 头中的 Connection 的值，如果该值不是 close，haproxy 将会将其删除，如果该值为空将会添加为：Connection: close。使每个客户端和服务器端在完成一次传输后都会主动关闭 TCP 连接。与该参数类似的另外一个参数是 “option forceclose”，该参数的作用是强制关闭对外的服务通道，因为有的服务器端收到 Connection: close 时，也不会自动关闭 TCP 连接，如果客户端也不关闭，连接就会一直处于打开，直到超时。           
     option httpclose
     # 设置成功连接到一台服务器的最长等待时间，默认单位是毫秒，新版本的 haproxy 使用 timeout connect 替代，该参数向后兼容           
     contimeout 5000
      # 设置连接客户端发送数据时的成功连接最长等待时间，默认单位是毫秒，新版 本haproxy 使用 timeout client 替代。该参数向后兼容           
     clitimeout 3000
     # 设置服务器端回应客户度数据发送的最长等待时间，默认单位是毫秒，新版本 haproxy 使用 timeout server 替代。该参数向后兼容          
     srvtimeout 3000
                
     # 定义一个名为 status 的部分    
     listen status 
       bind 0.0.0.0:1080
       # 定义监听的套接字
       mode http
       # 定义为 HTTP 模式
       log global
       # 继承 global 中 log 的定义
       stats refresh 30s
       # stats 是 haproxy 的一个统计页面的套接字，该参数设置统计页面的刷新间隔为 30s
       stats uri /admin?stats
       # 设置统计页面的 uri 为 /admin?stats
       stats realm Private lands
       # 设置统计页面认证时的提示内容
       stats auth admin:password
       # 设置统计页面认证的用户和密码，如果要设置多个，另起一行写入即可
       stats hide-version
       # 隐藏统计页面上的 haproxy 版本信息
     
     # 定义一个名为 http_80_in 的前端部分
     frontend http_80_in 
       bind 0.0.0.0:80
       # http_80_in 定义前端部分监听的套接字
       mode http
       # 定义为 HTTP 模式
       log global
       # 继承 global 中 log 的定义
       option forwardfor
       # 启用 X-Forwarded-For，在 requests 头部插入客户端 IP 发送给后端的 server，使后端 server 获取到客户端的真实 IP
       acl static_down nbsrv(static_server) lt 1
       # 定义一个名叫 static_down 的 acl，当 backend static_sever 中存活机器数小于1时会被匹配到
       acl php_web url_reg /*.php$
       #acl php_web path_end .php
       # 定义一个名叫php_web的 acl，当请求的 url 末尾是以 .php 结尾的，将会被匹配到，上面两种写法任选其一
       acl static_web url_reg /*.(css|jpg|png|jpeg|js|gif)$
       #acl static_web path_end .gif .png .jpg .css .js .jpeg
       # 定义一个名叫 static_web 的 acl，当请求的url 末尾是以 .css、.jpg、.png、.jpeg、.js、.gif 结尾的，将会被匹配到，上面两种写法任选其一
       use_backend php_server if static_down
       # 如果满足策略 static_down 时，就将请求交予 backend php_server
       use_backend php_server if php_web
       # 如果满足策略 php_web 时，就将请求交予 backend php_server
       use_backend static_server if static_web
       # 如果满足策略 static_web 时，就将请求交予 backend static_server
     
     # 定义一个名为 php_server 的后端部分
     backend php_server 
       mode http
       # 设置为http 模式
       balance source
       # 设置 haproxy 的调度算法为源地址 hash
       cookie SERVERID
       # 允许向 cookie 插入 SERVERID，每台服务器的 SERVERID 可在下面使用 cookie 关键字定义
       option httpchk GET /test/index.php
       # 开启对后端服务器的健康检测，通过 GET /test/index.php 来判断后端服务器的健康情况
       server php_server_1 10.12.25.68:80 cookie 1 check inter 2000 rise 3 fall 3 weight 2
       server php_server_2 10.12.25.72:80 cookie 2 check inter 2000 rise 3 fall 3 weight 1
       server php_server_bak 10.12.25.79:80 cookie 3 check inter 1500 rise 3 fall 3 backup
       # server 语法：server [:port] [param*] 
       # 使用server关键字来设置后端服务器；为后端服务器所设置的内部名称[php_server_1]，该名称将会呈现在日志或警报中、后端服务器的IP地址，支持端口映射[10.12.25.68:80]、指定该服务器的SERVERID为1[cookie 1]、接受健康监测[check]、监测的间隔时长，单位毫秒[inter 2000]、监测正常多少次后被认为后端服务器是可用的[rise 3]、监测失败多少次后被认为后端服务器是不可用的[fall 3]、分发的权重[weight 2]、最后为备份用的后端服务器，当正常的服务器全部都宕机后，才会启用备份服务器[backup]
         
     backend static_server
        mode http
        option httpchk GET /test/index.html
        server static_server_1 10.12.25.83:80 cookie 3 check inter 2000 rise 3 fall 3
     ```

  6. 检查配置是否正确

     ```bash
     haproxy -f /etc/haproxy/phaproxy.cfg -c
     ```

<br/>

> 1. [Haproxy配置文件详解](https://www.jianshu.com/p/b671610b5cea)
> 2. [HAProxy安装配置](https://www.jianshu.com/p/92677d58b6f1)
> 3. [HAProxy系列—配置文件详解](https://blog.csdn.net/u012758088/article/details/78643704)
> 4. [haproxy配置文件详解和ACL功能](https://www.cnblogs.com/f-ck-need-u/p/8502593.html)
