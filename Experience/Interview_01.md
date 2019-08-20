##### Apache和Nginx区别

1. 工作模式

   1. Apache工作模式：

      - **prefork模式：**多个子进程，每个子进程只有一个线程。每个`进程`在确定的时间只能维持一个连接，所以一个进程只能处理一个请求。

        工作原理：控制进程在最初创建若干个子进程。为了不在请求来临时再生成子进程，所以需要根据需求不断的创建新进程，最大可以达到每秒32个，直到满足需求。

        **优点：**　效率高、稳定，进程之间完全独立，无须担心线程安全的问题。
        **缺点：**　相比worker模式消耗资源更多。

      - **worker模式：**多个子进程，每个子进程同时有多个线程。每个`线程`在确定的时间只能维持一个连接，所以一个进程可以处理多个请求。
      
        工作原理：控制进程生成若干个子进程，每个子进程包含固定的线程数。为了不在请求到来时再生成线程，在配置文件中设置了最小和最大的空闲子进程的线程总数。如果现有子进程的线程总数不能满足并发和负载，控制进程会派生新的子进程。
      
        **优点：**内存占用比prefork模式低，适合高并发高流量HTTP服务。
        **缺点：**假如一个线程崩溃，整个进程就会连同其任何线程一起“挂掉”，由于线程共享内存空间，所以一个程式在运行时必须被系统识别为"每个线程都是安全的"。服务稳定性不如prefork模式。在keep-alive长连接的方式下，某个线程会被一直占用，即使中间没有请求，也需要等待到超时才会被释放。
        
      - **event模式：**同worker模式，但解决了在keep-alive模式下，线程被长期占用直到超时，从而导致资源浪费的问题。
      
          在event模块中，有一个专门的线程来管理这些keep-alive类型的线程，当接收到真实的请求时，会将请求传递给服务线程，执行完毕后，会将对应的服务线程释放，这样就能实现线程的**异步非阻塞**。
      
   2. Nginx工作模式：
   
      - master进程：
        - 管理worker进程，包含：接收来自外界的信号，向各worker进程发送信号，监控worker进程的运行状态，当worker进程退出后(异常情况下)，会自动重新启动新的worker进程。
        - 充当整个进程组与用户的交互接口，同时对进程进行监护。它不需要处理网络事件，不负责业务的执行，只会通过管理worker进程来实现重启服务、平滑升级、更换日志文件、配置文件实时生效等功能。
      - worker进程：
        - 多个worker进程之间是对等的，他们同等竞争来自客户端的请求，各进程互相之间是独立的。
        - 一个请求，只可能在一个worker进程中处理，一个worker进程，不可能处理其它进程的请求。
        - worker进程的个数是可以设置的，一般我们会设置与机器cpu核数一致。
        - **采用了异步非阻塞的方式**。
   
2. 模块加载

   - Apache： [动态模块加载](http://howtolamp.com/lamp/httpd/2.4/dso/) 能够在无需重新编译主服务器文件的基础上，将模块编译并添加到 Apache 扩展中。在使用系统包管理器安装后，可以通过诸如 [a2enmod](http://manpages.ubuntu.com/cgi-bin/search.py?cx=003883529982892832976%3A5zl6o8w6f0s&cof=FORID%3A9&ie=UTF-8&titles=404&lr=lang_en&q=a2enmod.8) 这样的命令，将其添加到扩展中。

   - Nginx：无法灵活的实现动态添加模块的功能，通常需要在构建 Nginx 时，通过设置参数选项，才能将其添加进 Nginx 服务器。

     目前支持以下官方模块动态加载，第三方模块需要升级支持才可编译成模块。

     ![1561704109439](1561704109439.png)

3. 重写

   - Apache：支持在目录级别上控制服务器配置，每个目录都能够配置自己的 **.htaccess** 文件。
   - Nginx：不支持目录级别的重写。

---

##### LVS和Nginx的负载区别

[参考HAproxy](https://github.com/opsxin/script/blob/master/markdown/LB/HAproxy.md)

----

K8S的基础模块

Etcd，kubeadmin，kubeproxy，kubectl。

后续准备学习（:sob:，学过忘），记录成markdown。

---

##### Python的列表和字典的遍历

```python
# 定义列表
list=[1, 2, 3, 4, 5]
# 定义字典
dict={“a”:1, “b”:2}

# 遍历列表
for i in list:
    print(i)
    
# 遍历字典
# dict.keys()遍历key
# dict.values()遍历value
for key, value in dict.items():
	print(key, value) 
```

---

##### Python WEB框架

1. [Django](https://docs.djangoproject.com/zh-hans/2.2/)
2. [Flask](http://docs.jinkan.org/docs/flask/)
   - [Flask Web开发实战：入门、进阶与原理解析](https://read.douban.com/ebook/110053633/)
3. [Tornado](https://tornado-zh.readthedocs.io/zh/latest/)



> [Apache worker/prefork模式说明和优化配置](https://www.kancloud.cn/curder/apache/91277)
>
> [httpd的运行模式prefork、worker、event](https://www.jianshu.com/p/dce263d6d429)
>
> [Nginx工作模式，Apache工作模式](https://www.cnblogs.com/mayinet/articles/5633833.html)
>
> [Nginx工作原理和优化总结](https://blog.csdn.net/hguisu/article/details/8930668)
>
> [GINX 加载动态模块（NGINX 1.9.11开始增加加载动态模块支持）](https://www.cnblogs.com/tinywan/p/6965467.html)
>
> [Apache 与 Nginx 性能对比：Web 服务器优化技术](https://learnku.com/articles/16074)

