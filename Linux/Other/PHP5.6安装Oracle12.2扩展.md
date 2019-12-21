# PHP 5.6 安装 Oracle 12.2 扩展

PHP 安装 Oracle 12.2 oci 和 pdo_oci 扩展。

[TOC]

## 安装 Oracle 客户端

### 下载

从[Instant Client Downloads for Linux x86-64 (64-bit)](https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html)处下载`instantclient-sdk-linux.x64-12.2.0.1.0.zip`和`instantclient-basic-linux.x64-12.2.0.1.0.zip`。

- 即时客户端软件包-sdk：用于使用 Instant Client 开发 Oracle 应用程序的附加头文件和示例 makefile。
- 即时客户端软件包-basic：运行 OCI，OCCI 和 JDBC-OCI 应用程序所需的所有文件。

### 解压

```bash
unzip instantclient-sdk-linux.x64-12.2.0.1.0.zip
unzip instantclient-basic-linux.x64-12.2.0.1.0.zip
mkdir /usr/lib/oracle
mv instantclient_12_2 /usr/lib/oracle/12.2
```

### 创建软连接

```bash
cd /usr/lib/oracle/12.2
ln -s libclntsh.so.12.2 libclntsh.so
ln -s libocci.so.12.2 libocci.so
```

### 配置 lib

```bash
echo "/usr/lib/oracle/12.2" > /etc/ld.so.conf.d/oracle-12.2.conf
ldconfig
```

## 安装 OCI8

### 下载 oci8

从[Extension for Oracle Database](https://pecl.php.net/package/oci8)下载[oci8-2.0.12.tgz](https://pecl.php.net/get/oci8-2.0.12.tgz)。

### 解压

```bash
tar zxvf oci8-2.0.12.tgz
```

### 安装

```bash
cd oci8-2.0.12
phpize
./configure --with-php-config=/php/bin/php-config  --with-oci8=instantclient,/usr/lib/oracle/12.2
# --with-oci8=instantclient,Oracle 安装位置
make install
```

## 安装 pdo_oci

### 当前安装 PHP 版本的源码

```bash
cd /php-version-source/ext/pdo_oci/
```

### 修改 config 文件

PHP 5.6 的 config.m4 文件不包含 Oracle 12.2 版本的支持，手动添加 12.2 版本。

```bash
sed -i "s/10.1/12.2/g" config.m4
```

### 安装

```bash
phpize
./configure --with-pdo-oci=instantclient,/usr/lib/oracle/12.2,12.2 --with-php-config=/php/bin/php-config
# --with-pdo-oci=instantclient,Oracle 安装位置,Oracle 版本
```

## 配置 php.ini

```bash
cat >> php.ini << EOF
extension=oci8.so
extension=pdo_oci.so
EOF
```

## 配置 php-fpm.conf

因为 PHP-FPM 可能读取不到 Oracle 安装位置，因此需要将 Oracle 安装位置通过环境变量注入。

**在当前使用的 Pool 下添加（如 www）。**

```bash
cat >> php-fpm.conf << EOF
env[LD_LIBRARY_PATH] = /usr/lib/oracle/12.2
env[ORACLE_HOME] = /usr/lib/oracle/12.2
EOF
```

## 重启 PHP-FPM

```bash
kill -USR2 $(cat php-fpm.pid)
```

> [technote-php-instant-12c](https://developer.oracle.com/dsl/technote-php-instant-12c.html)
>
> [Oracle database connection in php 5.6 in Ubuntu](https://stackoverflow.com/questions/51875180/oracle-database-connection-in-php-5-6-in-ubuntu)
