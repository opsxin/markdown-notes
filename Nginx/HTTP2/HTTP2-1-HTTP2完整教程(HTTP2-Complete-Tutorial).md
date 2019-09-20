		HTTP/1.1在1999年提出，从那时起web已经发生了变化。越来越多的人访问移动和平板中的网站，这些网站的连接速度相对较慢，每页引入外部资源的数量也在增加，导致页面加载量增加。通过多个HTTP客户端和服务端调校使web表现更好，但是最终每个不是常规的配置都有它自己的后果。因此，需要一个新的协议使web更快面对不同的连接类型和设备。

### SPDY和HTTP/2的不同

​		SPDY是GOOGLE在2009年提出的网络协议。它的目标是减少web的延时（在请求和回应的时间间隔）和增加安全性。

​		HTTP/2是对SPDY的复制。Google已经停止SPDY的开发，用SPDY相同的思路开发HTTP/2。

### HTTP/2的目标

​		这些是HTTP/2协议的目的：

- 减少延时
- 减少总TCP连接数。例如减少连接sockets的数目
- 更安全
- 适配现在的HTTP/1.1客户端和服务端
- 和HTTP/1.1相同的可用性。例如可以在使用HTTP/1.1的地方使用

### HTTP/2特性

1. 多路复用（Multiplexing）：多个异步HTTP请求在同一个TCP连接
2. 服务推送（server push）：单个请求，多个回应
3. 头部压缩（Header Compression）：压缩HTTP头部内容
4. 请求优先级（Request prioritization）：多个HTTP请求相同域名，可以对它们进行优先级排序
5. 二进制协议（Binary Protocol）：HTTP/2是二进制协议，HTTP/1.1是文本协议

### HTTP/2解决了哪些HTTP/1.1哪些问题

- HTTP流水线（HTTP Pipelining）：一些HTTP/1.1客户端使用这个技术去减少TCP连接数。HTTP流水线是一种在单个TCP连接上发送多个HTTP请求而无需等待相应响应的技术。服务端按照请求的顺序发送回应--整个连接保持先进先出和HOL堵塞（一个回应延迟导致后续回应延迟）。HTTP流水线请求异步但是回应是同步的。HTTP/2解决这个问题通过多路复用，在单个TCP连接上异步多个请求和响应，解决HOL堵塞的问题。
- 同一个域的多个TCP连接（Multiple TCP Connection for Same Domain）：在HTTP/1.1上，同一个域需要多个TCP连接来发送多个HTTP请求。但是在HTTP/2允许每个域只有一个TCP连接，HTTP请求通过多路复用在这条TCP连接上异步传输。
- TCP连接关闭时间（TCP Connection Close Time）：HTTP/1.1在请求结束后就关闭，HTTP/2在请求结束后能够保持一段时间。
- 头部压缩（Header Compression）：HTTP/1.1没有头部压缩，HTTP/2有。进一步减少了延时。

### HTTP/2对老的浏览器和服务器的适配^2^

​		一个巨大的问题随之而来，就是老旧的浏览器怎么处理HTTP/2 web服务。

​		HTTP/2使用升级（upgrade）和探索（discovery）的方式检查服务是否支持HTTP/2。

​		HTTP/2客户端默认不发送HTTP/2请求，它总是发送一个HTTP/1.1请求，同时头部带有*upgrade： HTTP/2.0*。假如web服务端支持HTTP/2，然后服务端回应*HTTP/1.1 101 Switching Protocols*，假如不支持，则服务端返回HTTP/1.1响应。

​		客户端通常记着服务端是否支持HTTP/2。下一次请求就会直接尝试使用HTTP/2请求。



> 1. [HTTP/2 Complete Tutorial](<http://qnimate.com/post-series/http2-complete-tutorial/#comments>)
> 2. [HTTP/2 Compatibility with old Browsers and Servers](<http://qnimate.com/http2-compatibility-with-old-browsers-and-servers/>)
> 3. [**HTTP/2 简介**](<https://developers.google.com/web/fundamentals/performance/http2/>)
> 4. [HTTP2简介和基于HTTP2的Web优化](<https://github.com/creeperyang/blog/issues/23>)

