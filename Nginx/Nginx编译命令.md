```bash
./configure --user=nginx --group=nginx \ 
	--with-http_v2_module --with-http_ssl_module \
    --with-stream --with-stream_ssl_module --with-http_sub_module \
    --with-http_realip_module --with-stream_realip_module \
    --with-pcre=<PATH> --with-zlib=<PATH> --with-openssl=<PATH>
```

1. [with-http_v2_module](http://nginx.org/cn/docs/http/ngx_http_v2_module.html)：支持 HTTP2
2. [with-http_ssl_module](http://nginx.org/cn/docs/http/ngx_http_ssl_module.html)：支持 HTTP SSL，即 HTTPS
3. [with-stream](http://nginx.org/en/docs/stream/ngx_stream_core_module.html)：支持四层负载
4. [with-stream_ssl_module](http://nginx.org/cn/docs/stream/ngx_stream_ssl_module.html)：支持四层配置证书
5. [with-http_sub_module](http://nginx.org/en/docs/http/ngx_http_sub_module.html)：网页文本、XML 内容替换
6. [with-http_realip_module](http://nginx.org/en/docs/http/ngx_http_realip_module.html)：HTTP 级别记录真实 IP，例如不记录 CDN，反代 IP
7. [with-stream_realip_module](http://nginx.org/en/docs/stream/ngx_stream_realip_module.html)：Stream 级别记录真实 IP
8. [with-pcre](https://www.pcre.org/)：Rewrite 需要
9. [with-zlib](https://zlib.net/)：Gzip 需要
10. [with-openssl](https://www.openssl.org/)：SSL 需要

