### Python操作Redis

1. #### 字符串 String

   PYTHON对于字符串的主要操作函数包括：SET, GET, GETSET, SETNX, MSET, MSEINX, INCR（INCRBY, DECR, DECRBY）, APPEND, SETRANGE, STRLEN。

   1. SET：为指定的键（key）设定值（value）,set(self, name, value, **kwargs)。
   2. GET：获取指定键（key）的值（value），get(self, name)。
   3. GETSET：为指定的键设置新的值，并返回旧的值，getset(self, name, value)。
   4. SETEX：为指定的键设置过期时间（以秒计），setex(self, name, value, time)。
   5. MSET：一次性设置多个键值对，函数设置的键值对（即mapping所指向的内容）数据以python字典数据类型传入，mset(self, mapping).
   6. MSETNX：键值对不存在时，设置键值对， msetnx(self, mapping)。
   7. INCR：自增函数，默认步长为1，通过对步长(amount)大小及字符的控制实现INCRBY（amount>=1）。
   8. APPEND：未指定的字符串追加值，若==不存在则直接创建==，append(self, key, value)
   9. SETRANGE：用value参数覆写给定的key所存储的字符串值，从偏移量offset开始，setrange(self, name, offset, value)。
   10. STRLEN：返回字符串的长度，当name不存在时返回0，strlen(self, name)。

   实例代码如下：

   ```python
   #!/usr/bin/python3
   # -*- coding: utf-8 -*- 
   # __author__ = 'Xin'
   import redis
   
   pool = redis.ConnectionPool(host='119.28.9.229', port=6379)
   r = redis.Redis(connection_pool=pool)
   r.flushall()
   
   # 设置新值，过期时间5s
   r.setex('name', value='xin', time=5)
   # 批量设置新值
   r.mset(k1='v1', k2='v2', k3='v3')
   # 批量获取值
   print(r.mget('k1', 'k2', 'k3'))
   # 设置新值并返回原来的值
   print(r.getset('name', 'hao'))
   # 获取子序列（0<=x<=1）
   print(r.getrange('name', 0, 1))
   # 修改字符串内容，从指定字符串索引开始向后替换（新值太长时，则向后添加），返回值的长度
   r.setrange('name', 0, 'ye')
   
   source = 'foo'
   r.set('n1', source)
   r.setbit('n1', 7, 1)
   '''
   注：如果在Redis中有一个对应： n1 = "foo"，
       那么字符串foo的二进制表示为：01100110 01101111 01101111
       所以，如果执行 setbit('n1', 7, 1)，则就会将第7位设置为1，
       那么最终二进制则变成 01100111 01101111 01101111，即："goo"
   '''
   print(r.get('n1'))
   # 获取n1对应的值的二进制表示中的某位的值 （0或1）
   print(r.getbit('n1', 7))
   r.set('n2', '汉字char')
   # 返回对应的字节长度（一个汉字3个字节）
   print(r.strlen('n2'))
   
   r.set('num', 1)
   # 自增，步长为10
   r.incr('num', amount=10)
   # 自减，步长为1
   r.decr('num', amount=1)
   # 自增num对应的值，当name不存在时，则创建name＝amount，否则，则自增。
   print(r.get('num'))
   # 在redis num对应的值后面追加内容
   r.append('num', 111)
   print(r.get('num'))
   
   结果：
   [b'v1', b'v2', b'v3']
   b'xin'
   b'ha'
   b'goo'
   1
   10
   b'10'
   b'10111'
   ```

2. #### 列表 List

   Python操作redis主要的操作命令时LPUSH, LRANGE, LINDEX, BLPOP, BRPOP。函数说明如下：

   1. lpush函数实现从向指定redis列表头部压入数据的功能， lpush key value。
   2. lrange获取列表指定范围内的数据， lrange key start end。
   3. linde根据列表的下标获取列表元素的值，lindex key index。
   4. blpop从列表头部取出第一个元素，返回该元素并从列表中删除（l表示left）。
   5. brpop从列表尾部取出第一个元素，返回该元素并从列表中删除（r表示right）。
   6. LPUSHX、RPUSHX以及其他一些Redis列表（List）函数目前版本无法实现。

   实例代码如下：

   ```python
   r.lpush('list', 11)
   r.lpush('list', 22)
   r.lpush('list', 33)
   # 在name对应的list中添加元素，只有name存在的情况下，值添加到列表的最左边
   r.lpushx('list', 44)
   print(r.lrange('list', 0, -1))
   # name对应的list的元素个数
   print(r.llen('list'))
   
   # 在11之前插入18
   r.linsert('list', 'before', 11, 18)
   # 在name对应的索引位置修改值
   r.lset('list', 2, 222)
   print(r.lrange('list', 0, -1))
   
   # 在name对应的list中删除指定的值.num=0，删除列表中所有的指定值；num=2,从前到后，删除2个；num=-2,从后向前，删除2个
   r.lrem('list', 222, num=1)
   print(r.lrange('list', 0, -1))
   
   # 在name对应的列表的左侧获取第一个元素并在列表中移除，返回值则是第一个元素
   print(r.lpop('list'))
   # 在name对应的列表中根据索引获取列表元素
   print(r.lindex('list', 0))
   
   # 在name对应的列表中移除没有在[start-end]索引之间的值
   print(r.lrange('list', 0, -1))
   r.ltrim('list', 1, 2)
   print(r.lrange('list', 0, -1))
   
   # 从一个列表取出最右边的元素，同时将其添加至另一个列表的最左边;src要取数据的列表的name, dst要添加数据的列表的name
   r.rpoplpush('list', 'list_2')
   
   # timeout，当src对应的列表中没有数据时，阻塞等待其有数据的超时时间（秒），0 表示永远阻塞
   r.brpoplpush('list', 'list_2', timeout=3)
   
   '''
       # 由于redis类库中没有提供对列表元素的增量迭代，如果想要循环name对应的列表的所有元素，那么就需要：
       # 1、获取name对应的所有列表
       # 2、循环列表
       # 但是，如果列表非常大，那么就有可能在第一步时就将程序的内容撑爆，所有有必要自定义一个增量迭代的功能：
   '''
   print('自定义增量迭代：')
   r.flushall()
   r.lpush('l1', 11)  # index为0
   r.rpush('l1', 22)
   r.rpush('l1', 33)
   r.rpush('l1', 44)
   r.rpush('l1', 55)  # index为4
   
   
   def list_iter(name):
       list_count = r.llen(name)
       for index in range(list_count):
           yield r.lindex(name, index)
   
   
   for item in list_iter('l1'):
       print(item)
   
       
   结果：[b'44', b'33', b'22', b'11']
   4
   [b'44', b'33', b'222', b'18', b'11']
   [b'44', b'33', b'18', b'11']
   b'44'
   b'33'
   [b'33', b'18', b'11']
   [b'18', b'11']
   自定义增量迭代：
   b'11'
   b'22'
   b'33'
   b'44'
   b'55'
   ```

3. #### 集合sets

   集合对象是由string类型的无重复元素的集合，底层编码是intset或者hashtable。inset编码的集合对象用整数集合最为底层实现，所有对象元素保存在整数集合中。Python的redis模块实现了 SADD、SCARD 、SDIFF 、SDIFFSTORE、SINTER 、SINTERSTORE、SISMEMBER 、SMEMBERS 、SMOVE、SPOP、SRANDMEMBER、SREM、SUNION、SUNIONSTORE操作命令的基本用法。函数说明如下：

   1. *SADD：向集合对象添加成员，sadd(self, name, value)

   2. SCARD：获取集合元素个数，scard(self, name)

   3. SDIFF：返回给定多个集合对象的差集(set key1-set key2..-set keyn)，从左到右计算集合差集，sdiff(self, keys, *args)

   4. SDIFFSTORE：返回给定给定多个集合对象的差集并存储在目标（dest）集合中，sdiffstore(self, dest, keys, *args)

   5. SINTER：返回给定所有集合（keys, args）的交集, sinter(self, keys, args)

   6. SINTERSTORE：返回给定所有集合（keys, args）的交集并存储在 集合(dest) 中, sinterstore(self, dest, keys, args)

   7. SISMEMBER：判断 value元素是否是集合 name 的成员,返回布尔逻辑值True或者False，sismember(self, name, value)

   8. SMEMBERS：返回集合中所元素值的Python集合类型数据，smembers(self, name)

   9. SMOVE：将元素value从集合src移动到 集合 dest。若元素value在集合src中不存在，则集合dest中不会添加元素value， smove(self, src, dest, value)

   10. SPOP：移除并返回集合中的一个随机元素, spop(self, name)

   11. SRANDMEMBER：返回集合中一个随机数，但是不做移除操作, srandmember(self, name)。从Redis 2.6 版本开始， 在命令行下Srandmember 命令接受可选返回元素数量的参数 redis>SRANDMEMBER name count

   12. SREM：移除集合中一个元素，srem(self, name, value)，redis模块任然沿用Redis 2.4 版本以前的只接受单个元素的用法。

   13. SUNION：返回所有给定集合的并集中所有元素，sunion(self, keys, *args)

   14. SUNIONSTORE：所有给定集合的并集存储在集合dest 中, sunionstore(self, dest, keys, *args)

   15. SSCAN：迭代集合中的元素，sscan(self, name, cursor=0, match=None, count=None)

       实例代码如下：

       ```python
       # name对应的集合中添加元素
       r.sadd('s1', 'v1', 'v1', 'v2', 'v3')  
       # name对应的集合中添加元素
       r.sadd('s2', 'v2', 'v4')  
       # 获取name对应的集合中元素个数
       print(r.scard('s1'))  
       #在第一个name对应的集合中且不在其他name对应的集合的元素集合
       print(r.sdiff('s1', 's2'))  
       
       # 获取第一个name对应的集合中且不在其他name对应的集合，再将其新加入到dest对应的集合中
       r.sdiffstore('s3', 's1', 's2')  
       # 获取s3对应的集合的所有成员
       print(r.smembers('s3'))  
       
       # 获取s1, s2对应集合的交集
       print(r.sinter('s1', 's2'))  
       # 获取s1, s2对应集合的交集，并将其存放到集合是s4中
       r.sinterstore('s4', 's1', 's2')  
       print(r.smembers('s4'))
       
       # 获取s1, s2对应集合的并集
       print(r.sunion('s1', 's2'))  
       
       # 获取s1, s2对应集合的交集，并将其存放到集合是s5中
       r.sunionstore('s5', 's1', 's2')  
       print(r.smembers('s5'))
       
       # 检查value是否是name对应的集合的成员
       print(r.sismember('s4', 'v4'))  
       
       # 将集合s2中成员v4移至集合s1中
       r.smove('s2', 's1', 'v4')  
       print(r.smembers('s1'))
       # 在name对应的集合中删除某些值
       r.srem('s1', 'v1')  
       
       # 从集合的右侧（尾部）移除一个成员，并将其返回 注意：集合是无序的，故结果随机！
       print(r.spop('s1'))  
       
       # 从name对应的集合中随机获取 numbers 个元素(Redis 2.6+)
       print(r.srandmember('s1'))  
       
       
       结果：
       3
       {b'v3', b'v1'}
       {b'v3', b'v1'}
       {b'v2'}
       {b'v2'}
       {b'v3', b'v2', b'v4', b'v1'}
       {b'v3', b'v2', b'v4', b'v1'}
       False
       {b'v3', b'v2', b'v4', b'v1'}
       b'v2'
       b'v3'
       ```

4. #### 有序集合 sorted sets

   | 命令                                                         | 描述                                                         |
   | ------------------------------------------------------------ | ------------------------------------------------------------ |
   | [Redis Zadd 命令](http://www.redis.net.cn/order/3609.html)   | 向有序集合添加一个或多个成员，或者更新已存在成员的分数       |
   | [Redis Zcard 命令](http://www.redis.net.cn/order/3610.html)  | 获取有序集合的成员数                                         |
   | [Redis Zcount 命令](http://www.redis.net.cn/order/3611.html) | 计算在有序集合中指定区间分数的成员数                         |
   | [Redis Zincrby 命令](http://www.redis.net.cn/order/3612.html) | 有序集合中对指定成员的分数加上增量 increment                 |
   | [Redis Zinterstore 命令](http://www.redis.net.cn/order/3613.html) | 计算给定的一个或多个有序集的交集并将结果集存储在新的有序集合 key 中 |
   | [Redis Zlexcount 命令](http://www.redis.net.cn/order/3614.html) | 在有序集合中计算指定字典区间内成员数量                       |
   | [Redis Zrange 命令](http://www.redis.net.cn/order/3615.html) | 通过索引区间返回有序集合成指定区间内的成员                   |
   | [Redis Zrangebylex 命令](http://www.redis.net.cn/order/3616.html) | 通过字典区间返回有序集合的成员                               |
   | [Redis Zrangebyscore 命令](http://www.redis.net.cn/order/3617.html) | 通过分数返回有序集合指定区间内的成员                         |
   | [Redis Zrank 命令](http://www.redis.net.cn/order/3618.html)  | 返回有序集合中指定成员的索引                                 |
   | [Redis Zrem 命令](http://www.redis.net.cn/order/3619.html)   | 移除有序集合中的一个或多个成员                               |
   | [Redis Zremrangebylex 命令](http://www.redis.net.cn/order/3620.html) | 移除有序集合中给定的字典区间的所有成员                       |
   | [Redis Zremrangebyrank 命令](http://www.redis.net.cn/order/3621.html) | 移除有序集合中给定的排名区间的所有成员                       |
   | [Redis Zremrangebyscore 命令](http://www.redis.net.cn/order/3622.html) | 移除有序集合中给定的分数区间的所有成员                       |
   | [Redis Zrevrange 命令](http://www.redis.net.cn/order/3623.html) | 返回有序集中指定区间内的成员，通过索引，分数从高到底         |
   | [Redis Zrevrangebyscore 命令](http://www.redis.net.cn/order/3624.html) | 返回有序集中指定分数区间内的成员，分数从高到低排序           |
   | [Redis Zrevrank 命令](http://www.redis.net.cn/order/3625.html) | 返回有序集合中指定成员的排名，有序集成员按分数值递减(从大到小)排序 |
   | [Redis Zscore 命令](http://www.redis.net.cn/order/3626.html) | 返回有序集中，成员的分数值                                   |
   | [Redis Zunionstore 命令](http://www.redis.net.cn/order/3627.html) | 计算给定的一个或多个有序集的并集，并存储在新的 key 中        |
   | [Redis Zscan 命令](http://www.redis.net.cn/order/3628.html)  | 迭代有序集合中的元素（包括元素成员和元素分值）               |

实例代码如下：

```python
# 在name对应的有序集合中添加元素
r.zadd('z1', '11', 1, '22', 2, '33', 3, '44', 4, '55', 5, '66', 6, '66', 7)  
# 获取name对应的有序集合元素的数量
print(r.zcard('z1'))  
# 获取name对应的有序集合中分数 在 [min,max] 之间的个数
print(r.zcount('z1', 1, 2))  
# 自增name对应的有序集合的 name 对应的分数
r.zincrby('z1', '11', amount=5)  
# 值11被排序到最后;此处表示按元素的值升序排列
print(r.zrange('z1', 0, -1, desc=False, withscores=True))  

# 获取某个值在 name对应的有序集合中的排行（从 0 开始）
print(r.zrank('z1', 33))  

# 删除name对应的有序集合中值是values的成员
r.zrem('z1', '66')  
print(r.zrange('z1', 0, -1, desc=False, withscores=True))

# 根据排行范围删除
r.zremrangebyrank('z1', 0, 1)  
print(r.zrange('z1', 0, -1, desc=False, withscores=True))

# 根据分数范围删除
r.zremrangebyscore('z1', 4.5, 5.5)  
print(r.zrange('z1', 0, -1, desc=False, withscores=True))

# 获取name对应有序集合中 value 对应的分数
print(r.zscore('z1', 11))  

r.zadd("zset_name", "a1", 6, "a2", 2, "a3", 5)
r.zadd('zset_name1', a1=7, b1=10, b2=5)
'''
    获取两个有序集合的交集并放入dest集合，如果遇到相同值不同分数，则按照aggregate进行操作
    aggregate的值为: SUM  MIN  MAX
'''
r.zinterstore('zset_name2', ('zset_name', 'zset_name1'), aggregate='Sum')

print(r.zrange('zset_name2', 0, -1, desc=False, withscores=True))


结果：
6
2
[(b'22', 2.0), (b'33', 3.0), (b'44', 4.0), (b'55', 5.0), (b'11', 6.0), (b'66', 6.0)]
1
[(b'22', 2.0), (b'33', 3.0), (b'44', 4.0), (b'55', 5.0), (b'11', 6.0)]
[(b'44', 4.0), (b'55', 5.0), (b'11', 6.0)]
[(b'44', 4.0), (b'11', 6.0)]
6.0
[(b'a1', 13.0)]
```

5. #### 哈希 hashes

   Redis 数据库hash数据类型是一个string类型的key和value的映射表，适用于存储对象。redis 中每个hash可以存储键值对多达40亿。Python的redis模块实现了Redis哈希（Hash）命令行操作的几乎全部命令，包括HDEL、HEXISTS、HGET、HGETALL、HINCRBY、HKEYS、HLEN 、HMGET 、HMSET 、HSET 、HSETNX 、HVALS 、HINCRBYFLOAT等命令。函数说明如下：

   1. **HDEL**：删除对应哈希（Hash）表的指定键（key）的字段，hdel(self, name, key)
   2. **HEXISTS**：检测哈希（Hash）表对应键（key）字段是否存在，返回布尔逻辑，hexists(self, name, key)
   3. **HGET**：获取哈希（Hash）指定键（key）对应的值，hget(self, name, key)
   4. **HGETALL**：获取哈希(Hash)表的键-值对（key-value pairs）,返回python字典类型数据，hgetall(self, name)
   5. **HINCRBY**：为哈希表（Hash）指定键（key）对应的值（key）加上指定的整数数值（int，可为负值）hincrby(self>, name, key, amount=1)，Redis 中本操作的值被限制在 64 位(bit)有符号数字。
   6. **HKEYS**：返回哈希表（Hash）对应键（key）的数组（Python称之为列表List），hkeys(self, name)
   7. **HLEN**： 获取哈希表（Hash）中键-值对（key-value pairs）个数，hlen(self, name)
   8. **HMGET**：获取哈希表（Hash）中一个或多个给点字段的值，不存在返回nil(Redis命令行)/None(Python)，hmget(self, name, keys)，其中keys可以为列表（list）
   9. **HMSET**：设置对个键-值对（key-value pairs）到哈希表（Hash）中，python输入值（mapping）为字典（dictionary）类型，hmset(self, name, mapping)
   10. **HSET**：为哈希表（Hash）赋值，若键（key）存在值（value）则覆盖，不存在则创建，hset(self, name, key, value)
   11. **HSETNX**：为哈希表（Hash）不存值（value）的键（key）赋值，存在操作无效，对应值（value）无变化，hsetnx(self, name, key, value)
   12. **HVALS**：返回哈希表（Hash）对应值（value）的列表，hvals(self, name)
   13. **HINCRBYFLOAT**：为哈希表 key 中的指定字段的浮点数值加上增量 increment ，hincrbyfloat(self, name, key, amount=1.0)

示例代码如下：

```python
# hset(name, key, value),name对应的hash中设置一个键值对（不存在，则创建；否则，修改）
r.hset('n1', 'k1', 'v1')  
print(r.hget('n1', 'k1'))
# hmset(name, mapping),在name对应的hash中批量设置键值对
r.hmset('n2', {'k1': 'v1', 'k2': 'v2', 'k3': 'v3'})  
print(r.hmget('n2', 'k2'))
# 获取name对应hash的所有键值
print(r.hgetall('n2'))  
# 获取name对应的hash中键值对的个数
print(r.hlen('n2')) 
# 获取name对应的hash中所有的key的值
print(r.hkeys('n2')) 
# 获取name对应的hash中所有的value的值
print(r.hvals('n2')) 
# 检查name对应的hash是否存在当前传入的key
print(r.hexists('n2', 'k4')) 
# 将name对应的hash中指定key的键值对删除
r.hdel('n2', 'k3')  
r.hset('n3', 'k1', 1)
# hincrby(name, key, amount=1),自增name对应的hash中的指定key的value的值，不存在则创建key=amount
r.hincrby('n3', 'k1', amount=1)  
print(r.hgetall('n3'))


结果：
b'v1'
[b'v2']
{b'k1': b'v1', b'k2': b'v2', b'k3': b'v3'}
3
[b'k1', b'k2', b'k3']
[b'v1', b'v2', b'v3']
False
{b'k1': b'2'}
```




> [Python操作Redis大全](https://segmentfault.com/a/1190000016696863)