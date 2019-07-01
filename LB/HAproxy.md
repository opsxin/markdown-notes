1. ### 简介^1^

   ​	HAproxy可以实现基于TCP（四层，SSH、SMTP、MYSQL）和HTTP（七层，WEB）应用代理软件，同时也可以作为负载均衡使用。
   ​	HAproxy可以支持数以万计的并发连接，同时可以保护WEB服务不暴露到网络上。

2. ### 主流负载均衡软件对比^2^

   >LVS： 
   >
   >1. 抗负载能力强。抗负载能力强、性能高，能达到F5硬件的60%；对内存和cpu资源消耗比较低 ;
   >2. 工作在网络4层，具体的流量由linux内核处理，因此没有流量的产生;
   >3. 稳定性、可靠性好，自身有完美的热备方案（如：LVS+Keepalived）；
   >4. 应用范围比较广，可以对所有应用做负载均衡； 
   >5. 不支持正则处理，不能做动静分离;
   >6. 支持负载均衡算法：rr（轮循）、wrr（带权轮循）、lc（最小连接）、wlc（权重最小连接）; 
   >7. 配置复杂，对网络依赖比较大，稳定性很高。

   > Ngnix： 
   >
   > 1. 工作在网络的7层之上，可以针对http应用做一些分流的策略，比如针对域名、目录结构； (补充：现在同样支持四层负载，通过类似NAT)
   > 2. Nginx对网络的依赖比较小，理论上能ping通就就能进行负载功能； 
   > 3. Nginx安装和配置比较简单，测试起来比较方便； 
   > 4. 可以承担高的负载压力且稳定，一般能支撑超过1万次的并发；
   > 5. 对后端服务器的健康检查，只支持通过端口来检测，不支持通过url来检测；
   > 6. Nginx对请求的异步处理可以帮助节点服务器减轻负载； 
   > 7. Nginx仅能支持http、https和Email协议，这样就在适用范围较小；（补充：同第一点）
   > 8. 不支持Session的直接保持，但能通过ip_hash来解决，对Big request header的支持不是很好；
   > 9. 支持负载均衡算法：Round-robin（轮循）、Weight-round-robin（带权轮循）、Ip-hash（Ip哈希） ；
   > 10. Nginx还能做Web服务器即Cache功能。

   > HAProxy的特点是： 
   >
   > 1. 支持两种代理模式：TCP（四层）和HTTP（七层），支持虚拟主机；
   > 2. 能够补充Nginx的一些缺点比如Session的保持，Cookie的引导等工作 ；
   > 3. 支持url检测后端的服务器出问题的检测会有很好的帮助； 
   > 4. 更多的负载均衡策略比如：动态加权轮循(Dynamic Round Robin)，加权源地址哈希(Weighted Source Hash)， 加权URL哈希和加权参数哈希(Weighted Parameter Hash)已经实现 ；
   > 5. 单纯从效率上来讲HAProxy更会比Nginx有更出色的负载均衡速度； 
   > 6. HAProxy可以对Mysql进行负载均衡，对后端的DB节点进行检测和负载均衡； 
   > 7. 支持负载均衡算法：Round-robin（轮循）、Weight-round-robin（带权轮循）、source（原地址保持）、 RI（请求URL）、rdp-cookie（根据cookie）； 
   > 8. 不能做Web服务器即Cache。

3. ### 配置文件^3^

   1. globe：参数时进程级别的，通常是和操作系统相关。
   2. defaults：默认参数，这些参数可以用到frontend，backend，listen组件。
   3. **frontend**：接受请求的前端虚拟节点，可以增加规则指定后端的backend；
   4. **backend**：后端服务集群的配置，是真实存在的服务器，一个backend对应一个或者多个服务器。
   5. listen：frontend和backend的组合体(即frontend和backwend合写)。

      ```:haproxy.conf:
      global   # 全局参数的设置
          log 127.0.0.1 local0 info
          # log语法：log <address_1>[max_level_1] # 全局的日志配置，使用log关键字，指定使用127.0.0.1上的syslog服务中的local0日志设备，记录日志等级为info的日志
          user haproxy
          group haproxy
          # 设置运行haproxy的用户和组，也可使用uid，gid关键字替代之
          daemon
          # 以守护进程的方式运行
          nbproc 16
          # 设置haproxy启动时的进程数，根据官方文档的解释，我将其理解为：该值的设置应该和服务器的CPU核心数一致，即常见的2颗8核心CPU的服务器，即共有16核心，则可以将其值设置为：<=16 ，创建多个进程数，可以减少每个进程的任务队列，但是过多的进程数也可能会导致进程的崩溃。这里我设置为16
          maxconn 4096
          # 定义每个haproxy进程的最大连接数 ，由于每个连接包括一个客户端和一个服务器端，所以单个进程的TCP会话最大数目将是该值的两倍。
          #ulimit -n 65536
          # 设置最大打开的文件描述符数，在1.4的官方文档中提示，该值会自动计算，所以不建议进行设置
          pidfile /var/run/haproxy.pid
          # 定义haproxy的pid存放位置 
       
      defaults # 默认部分的定义
          mode http
          # mode语法：mode {http|tcp|health} 。http是七层模式，tcp是四层模式，health是健康检测，返回OK
          log 127.0.0.1 local3 err
          # 使用127.0.0.1上的syslog服务的local3设备记录错误信息
          retries 3
          # 定义连接后端服务器的失败重连次数，连接失败次数超过此值后将会将对应后端服务器标记为不可用
          option httplog
          # 启用日志记录HTTP请求，默认haproxy日志记录是不记录HTTP请求的，只记录“时间[Jan 5 13:23:46] 日志服务器[127.0.0.1] 实例名已经pid[haproxy[25218]] 信息[Proxy http_80_in stopped.]”，日志格式很简单。
          option redispatch
          # 当使用了cookie时，haproxy将会将其请求的后端服务器的serverID插入到cookie中，以保证会话的SESSION持久性；而此时，如果后端的服务器宕掉了，但是客户端的cookie是不会刷新的，如果设置此参数，将会将客户的请求强制定向到另外一个后端server上，以保证服务的正常。
          option abortonclose
          # 当服务器负载很高的时候，自动结束掉当前队列处理比较久的链接
          option dontlognull
          # 启用该项，日志中将不会记录空连接。所谓空连接就是在上游的负载均衡器或者监控系统为了探测该服务是否存活可用时，需要定期的连接或者获取某一固定的组件或页面，或者探测扫描端口是否在监听或开放等动作被称为空连接；官方文档中标注，如果该服务上游没有其他的负载均衡器的话，建议不要使用该参数，因为互联网上的恶意扫描或其他动作就不会被记录下来
          option httpclose
          # 这个参数我是这样理解的：使用该参数，每处理完一个request时，haproxy都会去检查http头中的Connection的值，如果该值不是close，haproxy将会将其删除，如果该值为空将会添加为：Connection: close。使每个客户端和服务器端在完成一次传输后都会主动关闭TCP连接。与该参数类似的另外一个参数是“option forceclose”，该参数的作用是强制关闭对外的服务通道，因为有的服务器端收到Connection: close时，也不会自动关闭TCP连接，如果客户端也不关闭，连接就会一直处于打开，直到超时。
          contimeout 5000
          # 设置成功连接到一台服务器的最长等待时间，默认单位是毫秒，新版本的haproxy使用timeout connect替代，该参数向后兼容
          clitimeout 3000
          # 设置连接客户端发送数据时的成功连接最长等待时间，默认单位是毫秒，新版本haproxy使用timeout client替代。该参数向后兼容
          srvtimeout 3000
          # 设置服务器端回应客户度数据发送的最长等待时间，默认单位是毫秒，新版本haproxy使用timeout server替代。该参数向后兼容
   
      listen status # 定义一个名为status的部分
          bind 0.0.0.0:1080
          # 定义监听的套接字
          mode http
          # 定义为HTTP模式
          log global
          # 继承global中log的定义
          stats refresh 30s
          # stats是haproxy的一个统计页面的套接字，该参数设置统计页面的刷新间隔为30s
          stats uri /admin?stats
          # 设置统计页面的uri为/admin?stats
          stats realm Private lands
          # 设置统计页面认证时的提示内容
          stats auth admin:password
          # 设置统计页面认证的用户和密码，如果要设置多个，另起一行写入即可
          stats hide-version
          # 隐藏统计页面上的haproxy版本信息
   
      frontend http_80_in # 定义一个名为http_80_in的前端部分
          bind 0.0.0.0:80
          # http_80_in定义前端部分监听的套接字
          mode http
          # 定义为HTTP模式
          log global
          # 继承global中log的定义
          option forwardfor
          # 启用X-Forwarded-For，在requests头部插入客户端IP发送给后端的server，使后端server获取到客户端的真实IP
          acl static_down nbsrv(static_server) lt 1
          # 定义一个名叫static_down的acl，当backend static_sever中存活机器数小于1时会被匹配到
          acl php_web url_reg /*.php$
          #acl php_web path_end .php
          # 定义一个名叫php_web的acl，当请求的url末尾是以.php结尾的，将会被匹配到，上面两种写法任选其一
          acl static_web url_reg /*.(css|jpg|png|jpeg|js|gif)$
          #acl static_web path_end .gif .png .jpg .css .js .jpeg
          # 定义一个名叫static_web的acl，当请求的url末尾是以.css、.jpg、.png、.jpeg、.js、.gif结尾的，将会被匹配到，上面两种写法任选其一
          use_backend php_server if static_down
          # 如果满足策略static_down时，就将请求交予backend php_server
          use_backend php_server if php_web
          # 如果满足策略php_web时，就将请求交予backend php_server
          use_backend static_server if static_web
          # 如果满足策略static_web时，就将请求交予backend static_server
   
      backend php_server #定义一个名为php_server的后端部分
          mode http
          # 设置为http模式
          balance source
          # 设置haproxy的调度算法为源地址hash
          cookie SERVERID
          # 允许向cookie插入SERVERID，每台服务器的SERVERID可在下面使用cookie关键字定义
          option httpchk GET /test/index.php
          # 开启对后端服务器的健康检测，通过GET /test/index.php来判断后端服务器的健康情况
          server php_server_1 10.12.25.68:80 cookie 1 check inter 2000 rise 3 fall 3 weight 2
          server php_server_2 10.12.25.72:80 cookie 2 check inter 2000 rise 3 fall 3 weight 1
          server php_server_bak 10.12.25.79:80 cookie 3 check inter 1500 rise 3 fall 3 backup
          # server语法：server [:port] [param*] # 使用server关键字来设置后端服务器；为后端服务器所设置的内部名称[php_server_1]，该名称将会呈现在日志或警报中、后端服务器的IP地址，支持端口映射[10.12.25.68:80]、指定该服务器的SERVERID为1[cookie 1]、接受健康监测[check]、监测的间隔时长，单位毫秒[inter 2000]、监测正常多少次后被认为后端服务器是可用的[rise 3]、监测失败多少次后被认为后端服务器是不可用的[fall 3]、分发的权重[weight 2]、最后为备份用的后端服务器，当正常的服务器全部都宕机后，才会启用备份服务器[backup]
   
      backend static_server
          mode http
          option httpchk GET /test/index.html
          server static_server_1 10.12.25.83:80 cookie 3 check inter 2000 rise 3 fall 3
      ```

   6. 检查配置是否正确

      ```shell
      haproxy -f /etc/haproxy/phaproxy.cfg -c
      ```



> 1. [Haproxy配置文件详解](https://www.jianshu.com/p/b671610b5cea)
> 2. [HAProxy安装配置](https://www.jianshu.com/p/92677d58b6f1)
> 3. [HAProxy系列—配置文件详解](https://blog.csdn.net/u012758088/article/details/78643704)
> 4. [haproxy配置文件详解和ACL功能](https://www.cnblogs.com/f-ck-need-u/p/8502593.html)
