# 安装 FTP

## 安装vsftpd

   ```bash
   yum install -y vsftpd
   ```

## 修改vsftpd的配置文件

   ```bash
   #创建/etc/vsftpd/chroot_list
   echo "" >> /etc/vsftpd/chroot_list

   vim /etc/vsftpd/vsftpd.conf

   #禁止匿名登录
   anonymous_enable=NO
   #允许本地用户登录
   local_enable=YES
   #ascii支持
   ascii_upload_enable=YES
   ascii_download_enable=YES
   #使user家目录作为root根目录，禁止访问系统其它文件
   chroot_local_user=YES
   chroot_list_enable=YES
   #在文件中列出的用户，可以切换到其他目录
   #未在文件中列出的用户，不能切换到其他目录
   chroot_list_file=/etc/vsftpd/chroot_list
   #添加可写根目录
   allow_writeable_chroot=YES
   ```

## 添加用户

   ```bash
   #添加用户ftpuser，归属ftp组，家目录（ftp上传目录）为/home/ftp/pub
   useradd -d /home/ftp/pub -g ftp -s /sbin/nologin ftpuser
   #修改ftpuser密码
   passwd ftpuser
   ```

## 修改SELinux

   ```bash
   #允许自定义ftp路径
   setsebool -P ftpd_full_access 1
   #或者
   ausearch -c 'vsftpd' --raw | audit2allow -M my-vsftpd
   semodule -i my-vsftpd.pp
   ```

## 修改防火墙

   ```bash
   #允许外网访问20，21端口
   iptables -I INPUT -p tcp --dport 20:21 -j ACCEPT
   ```

## 启动FTP

   ```bash
   #开始
   systemctl start vsftpd
   #开机启动
   systemctl enable vsftpd
   ```

> [Centos7安装vsftpd (FTP服务器)](<https://www.jianshu.com/p/9abad055fff6>)
>
> [CentOS7安装配置vsftp搭建FTP](https://segmentfault.com/a/1190000008161400)
