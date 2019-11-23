# Nginx 的 URL 匹配及重写规则

[TOC]

## location规则

- **\=**：精确匹配
- **\~**：使用正则匹配，区分大小写
- **\^\~**：匹配字符串开头
- **\~\***：使用正则匹配，不区分大小写
- **/**：通用匹配
- **优先级**：\= \> 完整路径 \> \^\~ \> \~/\~\* \> /，实际使用中最常用 \~，\~\*，/

## Rewrite规则

rewrite 规则**只能放在 server{ } 或 location{ } 或 if{ } 块中**，并且只能对域名后边的除去传递的参数外的字符串起作用。例如`http://abc.def/a/b/index.php?id=1&u=str`只对`/a/b/index.php`重写。

语法 `rewrite regex replacement [flag];`

rewrite 是在同一域名内更改获取资源的路径，location 是一类路径做控制，可以反代到其他地址。执行的顺序：

1. 执行 server 块的 rewrite 规则
2. 执行 location 规则
3. 执行 location 内的 rewrite 规则

### `flag` 标志位

1. last：标识完成 rewrite 规则，**浏览器的 URL 地址不变**

2. break：本条规则匹配后，将不再匹配后面得规则，**URL 地址不变**

3. redirect：表示 302 临时跳转，**显示跳转后的URL**

4. permanent：301 永久跳转，**显示跳转后的URL**

   ```bash
   # 把 /html/*.html => /[post/*.html](http://post/*.html) ，301定向
   rewrite ^/html/(.+?).html$ /[post/$1.html](http://post/$1.html) permanent;
   # 把 /search/key => /search.html?keyword=key
   rewrite ^/search\/([^\/]+?)(\/|$) /search.html?keyword=$1 permanent;
   ```

### `if` 指令和全局变量

1. 语法：`if(condition){ }`
   - 表达式是一个变量时，如果值为空或者**以 0 开头的字符串都是 False**
   - 直接比较变量和内容时，使用 `=` 或 `!=`
   - \~ 正则匹配，\~\* 不区分大小写匹配，\!\~ 区分大小写匹配
   - -f ：是否存在文件
   - -d：是否存在目录
   - -e：是否存在文件或目录
   - -x：文件是否可以执行

2. 内置的全局变量：
   - `$args` ：请求行中的参数，同 `$query_string`
   - `$content_length` ： 请求头中的 Content-length 字段
   - `$content_type` ： 请求头中的 Content-Type 字段
   - `$document_root` ： 当前请求在 root 指令中指定的值
   - `$host` ： 请求主机头字段，否则为服务器名称
   - `$http_user_agent` ： 客户端 agent 信息
   - `$http_cookie` ： 客户端 cookie 信息
   - `$limit_rate` ： 可以限制连接速率
   - `$request_method`： 客户端请求动作，通常为 GET 或 POST
   - `$remote_addr` ： 客户端的 IP 地址
   - `$remote_port`： 客户端的端口
   - `$remote_user` ： 已经经过 Auth Basic Module 验证的用户名
   - `$request_filename`： 当前请求的文件路径，由 root 或 alias 指令与 URI 请求生成
   - `$scheme` ： HTTP 方法（如 http，https）
   - `$server_protocol`： 请求使用的协议，通常是 HTTP/1.0 或 HTTP/1.1
   - `$server_addr` ： 服务器地址，在完成一次系统调用后可以确定这个值
   - `$server_name`： 服务器名称
   - `$server_port`： 请求到达服务器的端口号
   - `$request_uri`： 包含请求参数的原始 URI，不包含主机名，如 ”/[foo/bar.php?arg=baz](http://foo/bar.php?arg=baz)”
   - `$uri` ： 不带请求参数的当前URI，`$uri` 不包含主机名，如 ”/[foo/bar.html](http://foo/bar.html)”
   - `$document_uri` ： 与 `$uri` 相同

> [nginx配置url重写](<https://xuexb.com/post/nginx-url-rewrite.html>)
>
> [Nginx中if语句中的判断条件](https://www.cnblogs.com/songxingzhu/p/6382007.html)
