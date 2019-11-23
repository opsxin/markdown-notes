# 安装 NFS

1. 关闭 SeLinux 和防火墙（CentOS）

   ```bash
   # 临时关闭 SeLinux，重启机器会恢复
   setenforce 0
   # 永久关闭 SeLinux
   sed -i "s/SELINUX=enforcing/SELINUX=permissive/" /etc/selinux/config

   # 关闭 iptables
   systemctl stop iptables
   # 关闭 firewalld
   systemctl stop firewalld
   ```

2. 安装 NFS 软件

   ```bash
   # CentOS
   yum install -y nfs-utils rpcbind

   # Debian
   apt-get install -y nfs-common nfs-kernel-server
   ```

3. 创建 Data 目录

   ```bash
   mkdir /data
   chmod 755 /data
   ```

4. 编辑配置文件

   ```bash
   # /etc/exports
   # <path> <allow-host>(<option>)
   /data 10.140.0.0/14(rw,sync,no_root_squash)
   ```

5. 启动

   ```bash
   # CentOS
   systemctl start nfs.service
   systemctl start rpcbind.service

   # Debian
   systemctl start nfs-server
   systemctl restart nfs-kernel-server
   ```

6. 客户端配置

   ```bash
   # 检查是否有共享目录
   showmount -e <nfs-server-ip>
   ```

7. 挂载

   ```bash
   # 创建本地目录
   mkdir /test
   # 挂载 nfs
   mount -t nfs <nfs-server-ip>:<path> /test
   ```

8. 附加

   1. allow-host：

      IP，IP/Mask，Domain，*

   2. option：

      - ro：只读
      - rw：读写
      - all_squash：将远程访问的所有普通用户及所属组都映射为匿名用户或用户组（nfsnobody）；
      - no_all_squash：与all_squash取反（默认设置）；
      - root_squash：将 root 用户及所属组都映射为匿名用户或用户组（默认设置）；
      - no_root_squash：与 rootsquash 取反；
      - anonuid=xxx：将远程访问的所有用户都映射为匿名用户，并指定该用户为本地用户（UID=xxx）；
      - anongid=xxx：将远程访问的所有用户组都映射为匿名用户组账户，并指定该匿名用户组账户为本地用户组账户（GID=xxx）；
      - secure：限制客户端只能从小于 1024 的 tcp/ip 端口连接 nfs 服务器（默认设置）；
      - insecure：允许客户端从大于 1024 的 tcp/ip 端口连接服务器；
      - sync：将数据同步写入内存缓冲区与磁盘中，效率低，但可以保证数据的一致性；
      - async：将数据先保存在内存缓冲区中，必要时才写入磁盘；
      - wdelay：检查是否有相关的写操作，如果有则将这些写操作一起执行，这样可以提高效率（默认设置）；
      - no_wdelay：若有写操作则立即执行，应与 sync 配合使用；
      - subtree：若输出目录是一个子目录，则 nfs 服务器将检查其父目录的权限(默认设置)；
      - no_subtree：即使输出目录是一个子目录，nfs 服务器也不检查其父目录的权限，这样可以提高效率；

> [Debian Linux安装NFS](https://www.centos.bz/2018/06/debian-linux安装nfs/)
>
> [Linux NFS服务器的安装与配置](https://www.cnblogs.com/mchina/archive/2013/01/03/2840040.html)
