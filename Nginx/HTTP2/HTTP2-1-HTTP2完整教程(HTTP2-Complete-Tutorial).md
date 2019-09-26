# HTTP2 完整教程

HTTP/1.1 在 1999 年提出，从那时起 web 已经发生了变化。越来越多的人访问移动和平板中的网站，这些网站的连接速度相对较慢，每页引入外部资源的数量也在增加，导致页面加载量增加。通过多个 HTTP 客户端和服务端调校使 web 表现更好，但是最终每个不是常规的配置都有它自己的后果。因此，需要一个新的协议使 web 更快面对不同的连接类型和设备。

[TOC]

## SPDY 和 HTTP/2 的不同

SPDY 是 GOOGLE 在 2009 年提出的网络协议。它的目标是减少 web 的延时（在请求和回应的时间间隔）和增加安全性。

HTTP/2 是对 SPDY 的复制。Google 已经停止 SPDY 的开发，用 SPDY 相同的思路开发 HTTP/2。

## HTTP/2 的目标

这些是 HTTP/2 协议的目的：

- 减少延时
- 减少总 TCP 连接数。例如减少连接 sockets 的数目
- 更安全
- 适配现在的 HTTP/1.1 客户端和服务端
- 和 HTTP/1.1 相同的可用性。例如可以在使用 HTTP/1.1 的地方使用

## HTTP/2 特性

1. 多路复用（Multiplexing）：多个异步 HTTP 请求在同一个 TCP 连接
2. 服务推送（server push）：单个请求，多个回应
3. 头部压缩（Header Compression）：压缩 HTTP 头部内容
4. 请求优先级（Request prioritization）：多个 HTTP 请求相同域名，可以对它们进行优先级排序
5. 二进制协议（Binary Protocol）：HTTP/2 是二进制协议，HTTP/1.1 文本协议

## HTTP/2 解决了哪些 HTTP/1.1 哪些问题

- HTTP 流水线（HTTP Pipelining）：一些 HTTP/1.1 客户端使用这个技术去减少 TCP 连接数。HTTP 流水线是一种在单个 TCP 连接上发送多个 HTTP 请求而无需等待相应响应的技术。服务端按照请求的顺序发送回应--整个连接保持先进先出和 HOL 堵塞（一个回应延迟导致后续回应延迟）。HTTP 流水线请求异步但是回应是同步的。HTTP/2 解决这个问题通过多路复用，在单个 TCP 连接上异步多个请求和响应，解决 HOL 堵塞的问题。
- 同一个域的多个 TCP 连接（Multiple TCP Connection for Same Domain）：在 HTTP/1.1 上，同一个域需要多个 TC P连接来发送多个 HTTP 请求。但是在 HTTP/2 允许每个域只有一个 TCP 连接，HTTP 请求通过多路复用在这条 TCP 连接上异步传输。
- TCP 连接关闭时间（TCP Connection Close Time）：HTTP/1.1 在请求结束后就关闭，HTTP/2 在请求结束后能够保持一段时间。
- 头部压缩（Header Compression）：HTTP/1.1 没有头部压缩，HTTP/2 有。进一步减少了延时。

## HTTP/2 对老的浏览器和服务器的适配^2^

一个巨大的问题随之而来，就是老旧的浏览器怎么处理 HTTP/2 web 服务。

HTTP/2 使用升级（upgrade）和探索（discovery）的方式检查服务是否支持 HTTP/2。

HTTP/2 客户端默认不发送 HTTP/2 请求，它总是发送一个 HTTP/1.1 请求，同时头部带有 `upgrade： HTTP/2.0`。假如 web 服务端支持 HTTP/2，然后服务端回应 `HTTP/1.1 101 Switching Protocols`，假如不支持，则服务端返回 HTTP/1.1 响应。

客户端通常记着服务端是否支持 HTTP/2。下一次请求就会直接尝试使用 HTTP/2 请求。



> 1. [HTTP/2 Complete Tutorial](<http://qnimate.com/post-series/http2-complete-tutorial/#comments>)
> 2. [HTTP/2 Compatibility with old Browsers and Servers](<http://qnimate.com/http2-compatibility-with-old-browsers-and-servers/>)
> 3. [**HTTP/2 简介**](<https://developers.google.com/web/fundamentals/performance/http2/>)
> 4. [HTTP2简介和基于HTTP2的Web优化](<https://github.com/creeperyang/blog/issues/23>)

