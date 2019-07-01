1. ###### 基本操作

   ```bash
   #查询表中的所有规则
   #v:显示该表中的所有链
   #n:禁止使用名称转换
   #L:显示规则
   #--line：显示规则在该链的行号
   iptables -t 表名 -vnL --line
   ```

2. ###### 规则管理

   ```bash
   #添加一条规则
   #I:插入；A:追加；D:删除(可匹配)；F:清空所有规则
   #t:操作的表
   #p:协议（tcp，udp，icmp等）
   #i:网络接口
   #s:源地址
   #d:目的地址
   #sport:源端口
   #dport:目的端口
   #j:动作
   
   #接受源地址为192.168.0.0/16,协议为tcp，目的端口为22的数据包
   iptables -I INPUT -t filter -p tcp --dport 22 -i eth0 -s 192.168.0.0/16 -j ACCEPT
   #拒绝目的地址为192.168.0.0/16的数据包
   iptables -A OUTPUT -t filter -d 192.168.0.0/16 -j REJECT
   #删除INPUT链的第一条规则；删除匹配源地址为192.168.0.0/16的规则
   iptables -D INPUT 1 -t filter ； iptables -D INPUT -s 192.168.0.0/16
   #清空filter表的所有规则
   iptables -t filter -F 
   #修改OUTPUT链的第一条规则为DROP。**注意：-d 192.168.0.0/16不能省略**
   iptables -R OUTPUT 1 -t filter -d 192.168.0.0/16 -j DROP
   #设置INPUT的默认匹配规则为DROP
   iptables -P INPUT -t filter DROP
   
   #多地址
   iptables -I INPUT -s 192.168.1.1,192.168.1.2 -j ACCEPT
   #多端口，可组合使用
   #连续端口
   iptables -I INPUT -p tcp --dport 22:25 -j ACCEPT
   #非连续端口
   iptables -I INPUT -p tcp -m multiport --dports 22,34,45 -j ACCEPT
   ```

3. ###### 保存规则

   ```bash
   #CentOS
   service iptables save
   #Debian
   #手动保存
   iptables-save > /etc/iptables-rules
   #设置开机加载
   cat << EOF > /etc/network/if-pre-up.d/iptables
   #!/bin/bash 
   iptables-restore < /etc/iptables.rules
   EOF
   #设置关机保存
   cat << EOF > /etc/network/if-post-down.d/iptables
   #!/bin/bash
   iptables-save > /etc/iptables.rules
   EOF 
   ```

4. 常用模块

   > [常用模块](<http://www.zsythink.net/archives/1564>)
   >
   > [tcp模块](<http://www.zsythink.net/archives/1578>)



> 1. [iptables用例](<https://wangchujiang.com/linux-command/c/iptables.html>)
> 2. [iptables详解](<http://www.zsythink.net/archives/1517>)

