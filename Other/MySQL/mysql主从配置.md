# MySQL 不停机主从同步配置

[Percona XtraBackup](https://www.percona.com/software/mysql-database/percona-xtrabackup) 工具提供了 MySQL 数据热备份的方法。 XtraBackup 是一个适用于 MySQL 的免费的、开源的、完整的数据库备份解决方案。XtraBackup 在事务系统上执行非阻塞、紧密压缩、高度安全的完全备份，因此在备份维护期间，应用程序仍然完全可用。

[TOC]

## 安装 XtraBackup

### 获取仓库源包

```bash
apt update && apt install -y lsb-core wget && 
wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
```

### 安装仓库包

```bash
dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
```

### 国内加速

```bash
sed -i "s|repo.percona.com|mirrors.tuna.tsinghua.edu.cn|g" /etc/apt/sources.list.d/percona-original-release.list
```

### 安装

percona-xtrabackup-24 版本支持 MySQL 5.7 版本，percona-xtrabackup-80 版本支持 MySQL 8.0 之后版本。

```bash
apt update && apt install percona-xtrabackup-24
```

## MySQL 配置

### Master 配置

#### 修改配置文件

配置`my.cnf`内的`mysqld`部分，设置`server-id`和`log-bin`参数：

```ini
log-bin     = /var/log/mysql/mysql-bin.log
server-id   = 1
```

#### 重启 mysql

```bash
systemctl restart mysql.service
```

#### 检查

进入 mysql 命令行，执行：

```mysql
show variables like "log_bin";
```

如果看到下图，则配置成功：

```txt
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| log_bin       | ON    |
+---------------+-------+
1 row in set (0.00 sec)
```

#### 创建同步用户

```mysql
GRANT REPLICATION SLAVE ON *.* to REPL_USER@'SLAVE_IP' IDENTIFIED BY 'REPL_PASSWORD';
flush privileges;
```

### Slave 配置

#### 停止 MySQL

```bash
systemctl stop mysql.service
```

#### 修改配置文件

配置`my.cnf`内的`mysqld`部分，设置`server-id`和`read-only`参数：

```ini
server-id = 2
read-only=1
```

#### 移除旧数据

```bash
mv /var/lib/mysql  ~/backup/mysql-old-bak
```

## XtraBackup 导入导出数据

### Master 端

#### 全量备份

```bash
mkdir ~/backup
sudo xtrabackup --backup --user=root --password='YOUR_PASSWORD' --target-dir=~/backup
sudo xtrabackup --prepare --user=root --password='YOUR_PASSWORD' --target-dir=~/backup
```

#### 复制数据到 slave

```bash
rsync -avzP ~/backup "SLAVE_IP":/backup
```

### Slave 端

#### 还原数据

```bash
## 选择一种方式
# 复制
xtrabackup --copy-back --target-dir=/backup
# 移动
xtrabackup --move-back --target-dir=/backup
```

#### 设置权限

```bash 
chown -R mysql:mysql /var/lib/mysql
```

#### 启动 mysql

```bash
systemctl start mysql.service
```

#### 查看当前 Master 的 bin-log 信息

```bash
cat /var/lib/mysql/xtrabackup_binlog_info
```

显示如下信息：

```txt
# MASTER_LOG_FILE MASTER_LOG_POS
mysql-bin.000001   50
```

#### 配置同步信息

```mysql
CHANGE MASTER TO MASTER_HOST='MASTER_IP',
    MASTER_USER='REPL_USER',
    MASTER_PASSWORD='REPL_PASSWORD',
    MASTER_LOG_FILE='MASTER_LOG_FILE',
    MASTER_LOG_POS=MASTER_LOG_POS;
```

#### 开始同步

```mysql
start slave;
```

#### 检查是否同步

```mysql
show slave status\G;
```

如下显示则为正在同步：

```ini
Slave_IO_Running: Yes
Slave_SQL_Running: Yes
```

## Ubuntu 数据`datadir`自定义的问题

如自定义配置`datadir=/data/mysql`，启动时可能会遇到报错：

```txt
audit[3329]: AVC apparmor="DENIED" operation="open" profile="/usr/sbin/mysqld" name="/data/mysql/ibdata1" pid=3329 comm="mysqld" requested_mask="rw" denied_mask="rw" fsuid=107 ouid=107
```

则需要修改`/etc/apparmor.d/usr.sbin.mysqld`的`\# Allow data dir access`部分：

```ini
 /var/lib/mysql/ r,
 # 增加
 /data/mysql/ r,
 /var/lib/mysql/** rwk,
 # 增加
 /data/mysql/** rwk,
```



> [Installing Percona XtraBackup on Debian and Ubuntu](https://www.percona.com/doc/percona-xtrabackup/8.0/installation/apt_repo.html)
>
> [The Backup Cycle - Full Backups Creating a backup](https://www.percona.com/doc/percona-xtrabackup/LATEST/backup_scenarios/full_backup.html)
