# iptables 操作

[TOC]

## 基本操作

### 查询表中规则

- `v`：显示该表中的所有链
- `n`：禁止使用名称转换
- `L`：显示规则
- `--line`：显示规则在该链的行号

```bash
iptables -t 表名 -vnL --line
```

## 规则管理

### 命令行参数

`I`：插入，`A`：追加，`D`：删除（可匹配），`F`：清空所有规则，`t`：操作的表，`p`：协议（tcp，udp，icmp等），`i`：网络接口，`s`：源地址，`d`：目的地址，`sport`：源端口，`dport`：目的端口，`j`：动作。

### 使用示例

```bash
# 接受源地址为 192.168.0.0/16，协议为 tcp，目的端口为 22 的数据包
iptables -I INPUT -t filter -p tcp --dport 22 -i eth0 -s 192.168.0.0/16 -j ACCEPT
# 拒绝目的地址为 192.168.0.0/16 的数据包
iptables -A OUTPUT -t filter -d 192.168.0.0/16 -j REJECT
# 删除 INPUT 链的第一条规则，删除匹配源地址为 192.168.0.0/16 的规则
iptables -D INPUT 1 -t filter ； iptables -D INPUT -s 192.168.0.0/16
# 清空 filter 表的所有规则
iptables -t filter -F 
# 修改 OUTPUT 链的第一条规则为 DROP。注意：-d 192.168.0.0/16 不能省略
iptables -R OUTPUT 1 -t filter -d 192.168.0.0/16 -j DROP
# 设置 INPUT 的默认匹配规则为 DROP
iptables -P INPUT -t filter DROP

# 多地址
iptables -I INPUT -s 192.168.1.1,192.168.1.2 -j ACCEPT

# 多端口，可组合使用
# 连续端口
iptables -I INPUT -p tcp --dport 22:25 -j ACCEPT
# 非连续端口
iptables -I INPUT -p tcp -m multiport --dports 22,34,45 -j ACCEPT
```

## NAT 表

### `REJECT` 动作

`icmp-net-unreachable`，`icmp-host-unreachable`，`icmp-port-unreachable`，`icmp-proto-unreachable`，`icmp-net-prohibited`，`icmp-host-prohibited`，`icmp-admin-prohibited`。

默认动作为：**icmp-port-unreachable**。

### NAT 使用

#### 开启 Linux 核心转发

```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
# 从文件中加载值
sysctl -p
```

#### 源地址 NAT

主要用于共享同一个外网 IP，修改源 IP 为外网 IP，达到访问互联网的目的。

```bash
# 如果外网 IP 固定
iptables -t nat -I POSTROUTING -s 10.0.0.0/16（内网 IP 段） -j SNAT --to-source 1.1.1.1（外网 IP）
# 如果外网 IP 不固定
iptables -t nat -I POSTROUTING -S 10.0.0.0/16（内网 IP 段） -o eth0（外网网口） -j MASQUERADE
```

#### 目的地址 NAT

主要用于内网提供互联网服务，如 WEB，MySQL 等，同时起到隐藏 IP 的作用。

```bash
# DNAT
iptables -t nat -I PREROUTING  -d 1.1.1.1(公网 IP) -p tcp --dport 80(公网端口) -j DNAT --to-destination 10.0.0.2:80(私网 IP：PORT)
# SNAT 
iptables -t nat -I POSTROUTING -s 10.0.0.0/16(私网网段) --to-source 1.1.1.1(公网 IP)

# 或指定端口
iptables -t nat -I POSTROUTING -d 10.0.0.2(内网 IP) -p tcp --dport 80 -j SNAT --to-source 1.1.1.1(外网 IP)
```

#### 主机端口重定向

REDIRECT，主要用于本地主机端口转发。

```bash
iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
```

## 自定义链

### 新建自定义链

```bash
iptables -t filter -N WEB-IN
```

### 自定义链添加规则

```bash
iptables -I WEB-IN ... -j ACCEPT
```

### 使用自定义链

```bash
iptables - I INPUT -p tcp --dport 80 -j WEB-IN
```

### 重命名自定义链

```bash
iptables -E WEB-IN WEB
```

### 删除自定义链

#### 删除 INPUT 中引用的链

```bash
iptables -D INPUT 1
```

#### 清空 WEB 链

```bash
iptables -F WEB
```

#### 删除自定义链

```bash
iptables -X WEB
```

## 保存规则

```bash
# CentOS
service iptables save

# Debian
# 手动保存
iptables-save > /etc/iptables-rules
# 设置开机加载
cat << EOF > /etc/network/if-pre-up.d/iptables
#!/bin/bash 
iptables-restore < /etc/iptables.rules
EOF
chmod +x /etc/network/if-pre-up.d/iptables

# 设置关机保存
cat << EOF > /etc/network/if-post-down.d/iptables
#!/bin/bash
iptables-save > /etc/iptables.rules
EOF 
chmod +x /etc/network/if-post-down.d/iptables
```

## 常用模块

> [常用模块](<http://www.zsythink.net/archives/1564>)
>
> [tcp模块](<http://www.zsythink.net/archives/1578>)

<br/>

> 1. [iptables用例](<https://wangchujiang.com/linux-command/c/iptables.html>)
> 2. [iptables详解](<http://www.zsythink.net/archives/1517>)
> 3. [iptables详解-nat](<http://www.zsythink.net/archives/1764>)

