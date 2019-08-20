##### 简介

Prometheus 是一套开源的系统监控报警框架。它启发于 Google 的 borgmon 监控系统，由工作在 SoundCloud 的 google 前员工在 2012 年创建，作为社区开源项目进行开发，并于 2015 年正式发布。2016 年，Prometheus 正式加入 CNCF（Cloud Native Computing Foundation），成为受欢迎度仅次于 Kubernetes 的项目。

##### 特点

- 强大的多维度数据模型：
  1. 时间序列数据通过 metric 名和键值对来区分。
  2. 所有的 metrics 都可以设置任意的多维标签。
  3. 数据模型更随意，不需要刻意设置为以点分隔的字符串。
  4. 可以对数据模型进行聚合，切割和切片操作。
  5. 支持双精度浮点类型，标签可以设为全 unicode。

- 灵活而强大的查询语句（PromQL）：在同一个查询语句，可以对多个 metrics 进行乘法、加法、连接、取分数位等操作。
- 易于管理： Prometheus server 是一个单独的二进制文件，可直接在本地工作，不依赖于分布式存储。
- 高效：平均每个采样点仅占 3.5 bytes，且一个 Prometheus server 可以处理数百万的 metrics。
- 使用 HTTP pull 模式采集时间序列数据，这样不仅有利于本机测试而且可以避免有问题的服务器推送坏的 metrics。
- 可以采用 push gateway 的方式把时间序列数据推送至 Prometheus server 端。
- 可以通过服务发现或者静态配置去获取监控的 targets。
- 多种可视化图形和仪表盘。

> 由于数据采集可能会有丢失，所以 Prometheus 不适用对采集数据要 100% 准确的情形。
>
> 对于记录时间序列数据，Prometheus 具有很大的查询优势，此外，Prometheus 适用于微服务的体系架构。

##### 组成及架构

- **Prometheus Server**: 用于收集和存储时间序列数据。
- **Client Library**: 客户端库，为需要监控的服务生成相应的 metrics 并暴露给 Prometheus server。当 Prometheus server 来 pull 时，直接返回实时状态的 metrics。
- **Push Gateway**: 主要用于短期的 jobs。由于这类 jobs 存在时间较短，可能在 Prometheus 来 pull 之前就消失了。为此，这次 jobs 可以直接向 Prometheus server 端推送它们的 metrics。这种方式主要用于服务层面的 metrics，对于机器层面的 metrices，需要使用 node exporter。
- **Exporters**: 用于暴露已有的第三方服务的 metrics 给 Prometheus。
- **Alertmanager**: 从 Prometheus server 端接收到 alerts 后，会进行去除重复数据，分组，并路由到对收的接受方式，发出报警。常见的接收方式有：电子邮件，pagerduty，OpsGenie, webhook 等。

![架构图](image001.png)

大概的工作流程是：

1. Prometheus server 定期从配置好的 jobs 或者 exporters 中拉 metrics，或者接收来自 Pushgateway 发过来的 metrics，或者从其他的 Prometheus server 中拉 metrics。
2. Prometheus server 在本地存储收集到的 metrics，并运行已定义好的 alert.rules，记录新的时间序列或者向 Alertmanager 推送警报。
3. Alertmanager 根据配置文件，对接收到的警报进行处理，发出告警。
4. 在图形界面中，可视化采集数据。

##### 相关概念

###### 数据模型

Prometheus 中存储的数据为时间序列，是由 metric 的名字和一系列的标签（键值对）唯一标识的，不同的标签则代表不同的时间序列。

- metric 名字：该名字应该具有语义，一般用于表示 metric 的功能，例如：http_requests_total, 表示 http 请求的总数。其中，metric 名字由 ASCII 字符，数字，下划线，以及冒号组成，且必须满足正则表达式 [a-zA-Z_:][a-zA-Z0-9_:]*。
- 标签：使同一个时间序列有了不同维度的识别。例如 http_requests_total{method="Get"} 表示所有 http 请求中的 Get 请求。当 method="post" 时，则为新的一个 metric。标签中的键由 ASCII 字符，数字，以及下划线组成，且必须满足正则表达式 [a-zA-Z_:][a-zA-Z0-9_:]*。
- 样本：实际的时间序列，每个序列包括一个 float64 的值和一个毫秒级的时间戳。
- 格式：<metric name>{<label name>=<label value>, …}，例如：http_requests_total{method="POST",endpoint="/api/tracks"}。

###### **Metric 类型**

1. **Counter**

   - 一种累加的 metric，典型的应用如：请求的个数，结束的任务数，出现的错误数等等。

   例如，查询 http_requests_total{method="get", job="Prometheus", handler="query"} 返回 8，10 秒后，再次查询，则返回 14。

2. **Gauge**

   - 一种常规的 metric，典型的应用如：温度，运行的 goroutines 的个数。
   - 可以任意加减。

   例如：go_goroutines{instance="172.17.0.2", job="Prometheus"} 返回值 147，10 秒后返回 124。

3. **Histogram**

   - 可以理解为柱状图，典型的应用如：请求持续时间，响应大小。
   - 可以对观察结果采样，分组及统计。

   例如，查询 http_request_duration_microseconds_sum{job="Prometheus", handler="query"} 时，返回结果如下：

   ![Histogram 结果图](image002.png)

4. **Summary**

   - 类似于 Histogram, 典型的应用如：请求持续时间，响应大小。
   - 提供观测值的 count 和 sum 功能。
   - 提供百分位的功能，即可以按百分比划分跟踪结果。

###### Instance 和 Jobs

**Instance**：一个单独的 scrape 的目标，一般对应一个进程

**jobs**：一组相同类型的 instance（保证可扩展性和可靠性），例如

```yaml
job: api-server
    instance 1: 1.2.3.4:5670
    instance 2: 1.2.3.4:5671
    instance 3: 5.6.7.8:5670
    instance 4: 5.6.7.8:5671
```

当 scrape 目标时，Prometheus 会自动给这个 scrape 的时间序列附加一些标签以便更好的分别，例如： instance，job。

![Metrics 示例](image003.png)

如上图所示，这三个 metric 的名字都一样，他们仅凭 handler 不同而被标识为不同的 metrics。这类 metrics 只会向上累加，是属于 Counter 类型的 metric，且 metrics 中都含有 instance 和 job 这两个标签。



> 1. [Prometheus 入门与实践](https://www.ibm.com/developerworks/cn/cloud/library/cl-lo-prometheus-getting-started-and-practice/index.html)
> 2. [Prometheus 入门](https://www.hi-linux.com/posts/25047.html)
> 3. [在 Kubernets 中手动安装 Prometheus]([https://www.qikqiak.com/k8s-book/docs/52.Prometheus%E5%9F%BA%E6%9C%AC%E4%BD%BF%E7%94%A8.html](https://www.qikqiak.com/k8s-book/docs/52.Prometheus基本使用.html))