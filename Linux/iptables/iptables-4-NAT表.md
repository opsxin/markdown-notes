1. ###### REJECT动作

   - icmp-net-unreachable
   - icmp-host-unreachable
   - icmp-port-unreachable
   - icmp-proto-unreachable
   - icmp-net-prohibited
   - icmp-host-prohibited
   - icmp-admin-prohibited

   默认为**icmp-port-unreachable**

2. ###### NAT表

   1. 需要开启Linux的核心转发

      ```bash
      echo 1 > /proc/sys/net/ipv4/ip_forward
      #从文件中加载值
      sysctl -p
      ```

   2. SNAT操作

      源地址NAT，主要用于共享同一个外网IP，修改源IP为外网IP，达到访问互联网的目的。

      ```bash
      #如果外网IP固定
      iptables -t nat -I POSTROUTING -s 10.0.0.0/16(内网IP段) -j SNAT --to-source 1.1.1.1(外网IP)
      #如果外网IP不固定
      iptables -t nat -I POSTROUTING -S 10.0.0.0/16(内网IP段) -o eth0(外网网口) -j MASQUERADE
      ```

   3. DNAT操作

      目的地址NAT，主要用于内网提供互联网服务，如WEB，MySQL等，同时起到隐藏IP的作用。

      ```bash
      #DNAT
      iptables -t nat -I PREROUTING  -d 1.1.1.1(公网IP) -p tcp --dport 80(公网端口) -j DNAT --to-destination 10.0.0.2:80(私网IP：PORT)
      #SNAT 
      iptables -t nat -I POSTROUTING -s 10.0.0.0/16(私网网段) --to-source 1.1.1.1(公网IP)
      #或指定端口
      iptables -t nat -I POSTROUTING -d 10.0.0.2(内网IP) -p tcp --dport 80 -j SNAT --to-source 1.1.1.1(外网IP)
      ```

   4. REDIRECT操作

      主要用于本地主机端口转发。

      ```bash
      iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
      ```

      


> [iptables详解](<http://www.zsythink.net/archives/1764>)

