```bash
# 文件路径
# /var/www/default.conf
# 请求路径
# http://${IP}/t/default.conf
# 注意末尾的 /，特别是 alias 的

location /t {
    root /var/www        ;
}
2019/05/28 09:07:59 [error] 61#61: *9 open() "/var/www/t/default.conf" failed (2: No such file or directory), client: 1.1.1.1, server: localhost, request: "GET /t/default.conf HTTP/1.1", host: "118.25.175.58:8080"
1.1.1.1 - - [28/May/2019:09:07:59 +0000] "GET /t/default.conf HTTP/1.1" 404 556 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36" "-"
# http://${IP}  /t/default.conf
# /var/www      /t/default.conf  /var/www/t/default.conf

location /t {
    root /var/www/;
}
2019/05/28 09:08:14 [error] 67#67: *10 open() "/var/www/t/default.conf" failed (2: No such file or directory), client: 1.1.1.1, server: localhost, request: "GET /t/default.conf HTTP/1.1", host: "118.25.175.58:8080"
1.1.1.1 - - [28/May/2019:09:08:14 +0000] "GET /t/default.conf HTTP/1.1" 404 556 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36" "-"
# http://${IP}  /t/default.conf
# /var/www/     /t/default.conf  /var/www//t/default.conf

location /t/ {
    root /var/www/;
}
2019/05/28 09:08:31 [error] 73#73: *11 open() "/var/www/t/default.conf" failed (2: No such file or directory), client: 1.1.1.1, server: localhost, request: "GET /t/default.conf HTTP/1.1", host: "118.25.175.58:8080"
1.1.1.1 - - [28/May/2019:09:08:31 +0000] "GET /t/default.conf HTTP/1.1" 404 556 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36" "-"
# http://${IP}/  t/default.conf
# /var/www/      t/default.conf  /var/www/t/default.conf

location /t/ {
    root /var/www;
}
2019/05/28 09:08:44 [error] 79#79: *12 open() "/var/www/t/default.conf" failed (2: No such file or directory), client: 1.1.1.1, server: localhost, request: "GET /t/default.conf HTTP/1.1", host: "118.25.175.58:8080"
1.1.1.1 - - [28/May/2019:09:08:44 +0000] "GET /t/default.conf HTTP/1.1" 404 556 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36" "-"
# http://${IP}/  t/default.conf
# /var/www       t/default.conf  /var/wwwt/default.conf



location /t {
    alias /var/www;
}
1.1.1.1 - - [28/May/2019:09:09:24 +0000] "GET /t/default.conf HTTP/1.1" 200 441 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36" "-"
# http://${IP}/t  /default.conf
# /var/www        /default.conf  /var/www/default.conf

location /t {
    alias /var/www/;
}
1.1.1.1 - - [28/May/2019:09:09:38 +0000] "GET /t/default.conf HTTP/1.1" 200 442 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36" "-"
# http://${IP}/t  /default.conf
# /var/www/       /default.conf  /var/www//default.conf

location /t/ {
    alias /var/www/;
}
1.1.1.1 - - [28/May/2019:09:09:55 +0000] "GET /t/default.conf HTTP/1.1" 200 443 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36" "-"
# http://${IP}/t/  default.conf
# /var/www/        default.conf  /var/www/default.conf

location /t/ {
    alias /var/www;
}
2019/05/28 09:10:13 [error] 103#103: *16 open() "/var/wwwdefault.conf" failed (2: No such file or directory), client: 1.1.1.1, server: localhost, request: "GET /t/default.conf HTTP/1.1", host: "118.25.175.58:8080"
1.1.1.1 - - [28/May/2019:09:10:13 +0000] "GET /t/default.conf HTTP/1.1" 404 556 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36" "-"
# http://${IP}/t/  default.conf
# /var/www         default.conf  /var/wwwdefault.conf
```

```bash
# root
location /dir/ 
root root_path ->  http://host/dir/file.txt  -> root_path/dir/file.txt

# alias
location /dir
alias alias_path ->  http://host /dir /file.txt  -> alias_path/file.txt

location /dir/ 
alias alias_path/ ->  http://host /dir/ file.txt  -> alias_path/file.txt
```



> [Nginx静态服务配置---详解root和alias指令](<https://www.jianshu.com/p/4be0d5882ec5>)