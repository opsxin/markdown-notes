1. #### location规则：

   - **=：**精确匹配 
   - **~：**使用正则匹配，区分大小写
   - **^~：**匹配字符串开头
   - **~*：**使用正则匹配，不区分大小写
   - **/：**通用匹配
   - 优先级：**= > 完整路径 > ^~ > \~/\~* > /**，实际使用中最常用^\~，\~*，/

2. #### Rewrite规则：

   ​		rewrite规则**只能放在server{ }或location{ }或if{ }块中**，并且只能对域名后边的除去传递的参数外的字符串起作用。例如”http://seanlook.com/a/we/index.php?id=1&u=str“ 只对/a/we/index.php重写。

   ​		语法 *rewrite regex replacement [flag];*

   ​		rewrite是在同一域名内更改获取资源的路径，location是一类路径做控制，可以反代到其他地址。执行的顺序：

   1. 执行server块的rewrite规则
   2. 执行location规则
   3. 执行location内的rewrite规则

3. #### [flag]标志位：

   1. last：标识完成rewrite规则，浏览器的URL地址不变

   2. break：本条规则匹配后，将不再匹配后面得规则，URL地址不变

   3. redirect：表示302临时跳转，显示跳转后的URL

   4. permanent：301永久跳转，显示跳转后的URL

      ```bash
      # 把 /html/*.html => /[post/*.html](http://post/*.html) ，301定向
      rewrite ^/html/(.+?).html$ /[post/$1.html](http://post/$1.html) permanent;
      # 把 /search/key => /search.html?keyword=key
      rewrite ^/search\/([^\/]+?)(\/|$) /search.html?keyword=$1 permanent; 
      ```

4. ####   if指令和全局变量：

   1. 语法：*if(condition){……}*
      - 如果表达式是一个变量时，如果值为空或者以0开头的字符串都是False
      - 直接比较变量和内容时，使用=或!=
      - \~正则匹配，\~*不区分大小写匹配，!~区分大小写匹配
      - -f ：是否存在文件
      - -d：是否存在目录
      - -e：是否存在文件或目录
      - -x：文件是否可以执行

   2. 内置的全局变量：
      - $args ：这个变量等于请求行中的参数，同$query_string
      - $content_length ： 请求头中的Content-length字段
      - $content_type ： 请求头中的Content-Type字段
      - $document_root ： 当前请求在root指令中指定的值
      - $host ： 请求主机头字段，否则为服务器名称
      - $http_user_agent ： 客户端agent信息
      - $http_cookie ： 客户端cookie信息
      - $limit_rate ： 这个变量可以限制连接速率
      - $request_method ： 客户端请求的动作，通常为GET或POST
      - $remote_addr ： 客户端的IP地址
      - $remote_port ： 客户端的端口
      - $remote_user ： 已经经过Auth Basic Module验证的用户名
      - $request_filename ： 当前请求的文件路径，由root或alias指令与URI请求生成
      - $scheme ： HTTP方法（如http，https）
      - $server_protocol ： 请求使用的协议，通常是HTTP/1.0或HTTP/1.1
      - $server_addr ： 服务器地址，在完成一次系统调用后可以确定这个值
      - $server_name ： 服务器名称
      - $server_port ： 请求到达服务器的端口号
      - $request_uri ： 包含请求参数的原始URI，不包含主机名，如：”/[foo/bar.php?arg=baz](http://foo/bar.php?arg=baz)”
      - $uri ： 不带请求参数的当前URI，$uri不包含主机名，如”/[foo/bar.html](http://foo/bar.html)”
      - $document_uri ： 与$uri相同

> [nginx配置url重写](<https://xuexb.com/post/nginx-url-rewrite.html>)
>
> [[Nginx中if语句中的判断条件](https://www.cnblogs.com/songxingzhu/p/6382007.html)]