##### 组成

**Input**(tail, tcp, udp, http, syslog…) –>  **Buffer**(Memory, File) –> **Output**(Kafka, MongoDB, ES…)

##### 插件

- Input 
  输入插件。内置的有 tail、http、tcp、udp 等。

- Parser 
  解析器。可自定义解析规则，如解析 nginx， json 日志。

- Filter 
  Filter 插件，可过滤掉事件，或增加字段，删除字段。

  ```bash
  Input -> filter 1 -> ... -> filter N -> Output
  
  # Filter 是按照顺序全部都执行
  # match 第一个如果匹配上，后面匹配的将不会再执行
  ```

- Output 
  输出插件。内置的有 file、hdfs、s3、kafka、elasticsearch、mongoDB、stdout 等。

- Formatter 
  Formatter 插件。可自定义输出格式如 json、csv 等。

- Storage 
  Storage 插件可将各状态保存在文件或其他存储中，如 Redis、MongoDB 等。

- Buffer 
  Buffer 缓冲插件。缓冲插件由输出插件使用。在输出之前先缓冲，然后以如 Kafka Producer Client 的方式批量提交。有 file、memory 两种类型。flush_interval 参数决定了提交的间隔，默认 60 秒刷新一次。

##### 匹配模式

- \* 用来匹配 tag 的一部分（比如：a.\* 可以匹配 a.b，但是不能匹配 a 或者 a.b.c）
- \*\* 可以用来匹配 tag 的 0 个或多个部分（比如：a.\*\* 可以匹配 a、a.b 和 a.b.c）
- {X,Y,Z} 匹配 X,Y 或者 Z（比如：{a,b} 可以匹配 a 和 b，但是不能匹配 c。他可以和 \* 或者 \*\* 结合起来一起使用）
- 如果有多个匹配模式写在里面，则可以用空格分开(比如：能够匹配 a 和 b。<match a.\*\* b.\* >能够匹配 a，a.b，a.b.c 和 b.d)

##### 数据类型

- `string`：字符串，最常见的格式，详细支持语法见文档
- `integer`：整数
- `float`：浮点数
- `size`：大小，仅支持整数
  - `<INTEGER>k` 或 `<INTERGER>K`
  - `<INTEGER>m` 或 `<INTERGER>M`
  - `<INTEGER>g` 或 `<INTERGER>G`
  - `<INTEGER>t` 或 `<INTERGER>T`
- `time`：时间
  - `<INTEGER>s` 或 `<INTERGER>S`
  - `<INTEGER>m` 或 `<INTERGER>M`
  - `<INTEGER>h` 或 `<INTERGER>H`
  - `<INTEGER>d` 或 `<INTERGER>D`
- `array`：按照 JSON array 解析，如 [“key1”, “key2”]
- `hash`：按照 JSON object 解析，如 {“key1”: “value1”, “key2”: “value2”}

##### 示例

```html
# 输入（Input）
<source>
  # 类似于 tail -f 命令
  @type tail
  # 日志文件路径
  path /var/log/browse-*.log
  # 偏移量记录文件路径，记录上一次读取的位置
  pos_file /var/log/fluentd/browse.pos
  # 打标签，路由到不同 Output
  tag browse

  <parse>
    # 以 json 格式解析
    @type json
  </parse>
</source>

# 输出（Output）
# 匹配上方的 tag：browse
<match browse>
    # 将 event 拷贝到多个 output
    @type copy
    <store>
       # 输出到文件
       @type file
       path /tmp/log/testBackup.log
    </store>
    <store>
       # 输出到控制台
       @type stdout
    </store>
    <store>
       # 输出到 kafka
       @type kafka
       brokers node1:6667,node2:6667,node3:6667
       default_topic testTopic3
       # 缓冲类型
       buffer_type file
       # 缓存的文件路径
       buffer_path /tmp/buffer/click_buffer
    </store>
</match>
```



> 1. [数据收集之Fluentd](https://blog.csdn.net/wangpei1949/article/details/81841431)
> 2. [Fluentd语法速记](https://blog.csdn.net/luanpeng825485697/article/details/83339985)
> 3. [Fluentd Doc]([https://docs.fluentd.org](https://docs.fluentd.org/))