# 限制访问代理的HTTP资源

本文解释了如何设置一个连接的最大请求数量，或者从服务器下载的最大速率。

[TOC]

## 介绍

使用 NGINX 或 NGINX Plus，它可以限制：

- 每个键值的连接数（例如每个 IP 地址）

- 每个键值的请求速率（每秒或者每分钟允许处理的请求数）

- 每个连接的下载速率

  **注意：IP 地址可能被 NAT 设备共享，所以限制 IP 地址要慎重。**

## 限制连接数

1. 使用 `limit_conn_zone` 指令定义键并设置共享内存区域的参数(工作进程将使用此区域来共享键值的计数器) 。作为第一个参数，指定计算的表达式作为键。第二个参数 *zone* 中,指定区域的名称及其大小：

   ```nginx
   limit_conn_zone $binary_remote_addr zone=addr:10m;
   ```

2. 使用 `limit_conn` 指令在 *location { }， server { }， http { }* 中应用限制。第一个参数是指定共享内存区域的名字，第二个参数是设置允许每个键的连接数：

   ```nginx
   location /download/ {
        limit_conn addr 1;
   }
   ```

   因为 `$binary_remote_addr` 作为键，所以上方语句作用是限制了 IP 的连接数。

   另一种限制连接数的方式是使用 `$server_name` 变量：

   ```nginx
   http {
       limit_conn_zone $server_name zone=servers:10m;

       server {
           limit_conn servers 1000;
       }
   }
   ```

## 限制请求速率

速率限制可以防止 DDoS 攻击，或者防止上游服务器同时有太多请求。这种方式基于 **leaky bucket** 算法：请求以不同的速率到达桶，但以固定的速率离开桶。

在使用速率限制，需要配置 *“leaky bucket”* 的全局参数：

- 键（key）: 用于区分不同的客户端，通常是一个变量。
- 共享内存区域（shared memory zone）: 保存这些键状态的区域名字和尺寸。
- 速率（rate）: 请求限制每秒和每分钟（r/s，r/m）。*Requests per minute are used to specify a rate less than one request per second.*

 这些参数在 `$limit_req_zone` 中设置。这个指令定义在 *http { }* 级，这种方法允许应用不同的区域，或者不同的上下文设置不同的溢出参数：

   ```nginx
   http {
       #...
       limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;
   }
   ```

上方的配置中，创建了*10m* 大小的共享内存区域 *one*。这个区域保存了每个 IP 地址（$binary_remote_addr）的状态。`$remote_addr` 也是客户端的 IP 地址，但是使用 `$binary_remote_addr` 表示 IP 更短（字节更少，可以更省内存吧）。

可以使用以下方式计算共享内存区域的最佳大小：IPv4 地址的 `$binary_remote_addr` 值大小为 4 个字节，存储在 64 位平台上占用 128 个字节。因此，该区域的 1 兆字节可以存储大约 16,000 个 IP 地址的状态信息。

如果添加新记录时存储空间已用完，则会删除最旧的记录。如果释放的空间仍不足以容纳新记录，则 NGINX 将返回状态代码 *503 Service Unavailable*。这个状态码可以在 `limit_req_status` 中自定义。

一个区域设置后，可以在 NGINX 配置中通过 `limit_req` 在任何位置使用，*server { }， location { }, or http { }*。

   ```nginx
   http {
       #...
       limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;

       server {
           #...
           location /search/ {
               limit_req zone=one;
           }
       }
   }
   ```

使用这个配置，NGINX 将在 */search/* 中每秒处理不超过 1 个请求。延迟处理这些请求的方式是总速率不大于规定。如果请求数超过指定的速率，NGINX 将延迟处理此类请求，直到 “桶”（共享内存区域 *one*）满。对于存储空间用尽后的请求，NGINX 将返回 *503 Service Unavailable*（如果未使用 **limit_req_status** 自定义）。

## 处理过多的请求

使用 `limit_req_zone` 指令中定义的速率，如果请求数超过指定的速率且共享内存区域已满，NGINX 将返回一个错误。由于流量往往是突发性的，因此在流量突发期间，返回客户端请求错误并不是最好的选择。

NGINX 中可以将过多请求缓冲和处理。`limit_req` 指令的 *burst* 参数设置等待处理的最大数量。

   ```nginx
   http {
       #...
       limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;

       server {
           #...
           location /search/ {
               limit_req zone=one burst=5;
           }
       }
   }
   ```

使用此配置，如果请求速率超过每秒 *1* 个，超出速率的请求将被放入 *one* 区域。当区域满时，过多的请求将排队（burst），此队列的大小为 *5* 个请求。队列中的请求处理将被延迟，使得总速率不大于指定的速率。超过突发限制的请求将返回 *503* 错误。

如果在流量突发期间不需要延迟请求，请添加 *nodelay* 参数：

   ```nginx
   http {
       #...
       limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;

       server {
           #...
           location /search/ {
               limit_req zone=one burst=5 nodelay;
           }
       }
   }
   ```

使用此配置，突发（burst）限制内的请求，无论指定速率（rate），都立即处理。超过突发限制的请求将返回 *503* 错误。

## 延迟过多的请求

处理过多请求的另一种方法是马上处理其中的一些请求，然后应用速率限制，直到过多请求被拒绝为止。

这个能被实现通过 *delay* 和 *burst* 参数。*delay *参数定义了过多请求被延迟以符合定义的速率限制的点。

   ```nginx
   http {
       #...
       limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;

       server {
           #...
           location /search/ {
               limit_req zone=one burst=5 delay=3;
           }
       }
   }
   ```

使用此配置，前 3 个请求（delay）无延迟地执行，接下来的 2 个请求（burst - delay）以总速率不大于指定的方式延迟，因为总突发数目过多，因此过多的请求将被拒绝，后续的请求将被延迟。

## 限制带宽

限制每一个连接的带宽，使用 `limit_rate` 指令：

   ```nginx
   location /download/ {
       limit_rate 50k;
   }
   ```

通过此设置，客户端将能够通过单连接最高 50kb/s 的速度下载内容。但是，客户端可以打开多个连接。因此，如果目标是阻止下载速度大于指定值，则连接数也应该受到限制。例如，每个 IP 地址一个连接（如果使用上面指定的共享内存区域）：

```nginx
location /download/ {
    limit_conn addr 1;
    limit_rate 50k;
}
```

仅需要在客户端下载一定大小的数据后设置限制，使用 `limit_rate_after` 指令。允许客户端快速下载一定大小的数据（例如，文件头 - 电影索引）然后限制下载其余数据的速率（使用户观看电影而不是下载）。

```nginx
limit_rate_after 500k;
limit_rate 20k;
```

以下示例显示了用于限制连接数和带宽的组合配置。允许的最大连接数为每个客户端 5 个连接，这适用于大多数常见情况，因为现代浏览器通常一次最多打开 3 个连接。同时，只允许一个连接下载：

```nginx
http {
    limit_conn_zone $binary_remote_address zone=addr:10m

    server {
        root /www/data;
        limit_conn addr 5;

        location / {
        }

        location /download/ {
            limit_conn addr 1;
            limit_rate 1m;
            limit_rate 50k;
        }
    }
}
```

> [Limiting Access to Proxied HTTP Resources](https://docs.nginx.com/nginx/admin-guide/security-controls/controlling-access-proxied-http/#)
>
> [Nginx下limit_req模块burst参数超详细解析](<https://blog.csdn.net/hellow__world/article/details/78658041>)
