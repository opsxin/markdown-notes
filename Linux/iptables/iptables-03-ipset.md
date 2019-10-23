# IPset 操作

ipset 是 iptables 的协助工具，可以管理一组 IP 地址。

[TOC]

## 创建集合

```bash
# TYPENAME := method:datatype[,datatype[,datatype]]
# method := bitmap, hash, list
# dateatype := ip, net, mac, port, iface
ipset create SETNAME(自定义名称) TYPENAME [ CREATE-OPTIONS ]

# 添加一个叫做 "myset" 的 "net" 网络地址的 "hash" 集合
ipset create myset hash:net

# 添加一个叫做 "myset-ip" 的 "ip" 的 "hash" 集合
# 可添加 IP 段，但是实际通过 IP 的方式保存
ipset create myset-ip hash:ip
```

## 添加地址

```bash
# 加入的 ADD-ENTRY 必须与创建 ipset 时指定的格式匹配
ipset add SETNAME ADD-ENTRY [ ADD-OPTIONS ]

# 添加一组 IP 地址
ipset add myset 1.1.1.0/24
# 添加一个 IP 地址
ipset add myset-ip 1.1.1.1
```

## 使用集合

```bash
# 使用 iptables 的 set 模块
# 源地址（src）属于 myset，就进行 REJECT，还可添加目的地址（dst）等
iptables -I INPUT -m set --match-set myset src -j REJECT
```

## 其他命令

### 删除记录

```bash
# 删除记录
ipset del SETNAME DEL-ENTRY [ DEL-OPTIONS ]
# 清空集合
ipset flush [ SETNAME ]
# 删除集合
ipset destroy [ SETNAME ]
```

### 查询记录

```bash
# 测试记录是否在集合当中
ipset test SETNAME TEST-ENTRY [ TEST-OPTIONS ]
# 显示集合中记录
ipset list [ SETNAME ] [ OPTIONS ]
```

### 导入导出

```bash
ipset save [ SETNAME ] > FILENAME
ipset restore < FILENAME
```

## 其他用法

### 取消匹配

```bash
# 使用 nomatch
ipset add myset 1.1.1.0/24
ipset add myset 1.1.1.0/30 nomatch
```

### 匹配 ip:port

```bash
ipset create myset-port hash:ip,port 
ipset add myset-port 1.1.1.1,80
ipset add myset-port 1.1.1.1,udp:53
ipset add myset-port 1.1.1.1,60-70
```

### 超时

```bash
# 设置超时
ipset create myset-time hash:ip timeout 300
ipset add myset-time 1.1.1.1 
ipset add myset-time 1.1.1.2 timeout 60

# 如果需要重新设置超时时间，使用 -exist
ipset -exist add myset-time 1.1.1.2 time 100
```

<br/>

> 1. [Ipset (简体中文)](<https://wiki.archlinux.org/index.php/Ipset_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)
> 2. [利用 ipset 封禁大量 IP](<https://fixatom.com/block-ip-with-ipset/>)
> 3. [ipset：linux的ipset命令的使用](<https://www.lijiaocn.com/%E6%8A%80%E5%B7%A7/2017/08/06/linux-net-ipset.html>)