1. ##### template

   ```bash
   #ansible-doc -s template
   #src: 模板源文件，位于控制主机
   #dest：复制到被控主机的目的地
   #owner：复制到被控主机的属主
   #group：复制到被控主机的属组
   #mode：权限，如mode=0644
   #force：强制复制到被控主机，覆盖同名文件
   #backup：备份被控主机的同名文件
   ```

2. ##### jinja

   ```bash
   {{   }}：用来装载表达式，比如变量、运算表达式、比较表达式等。
   #{{ ansible.host }} 172.16.0.1
   
   #{{ 1 == 1 }}  True
   #{{ 2 != 2 }}  False
   #{{ 2 > 1 }}   True
   #{{ (2 > 1) or (1 > 2) }} True
   
   #{{ 3 + 2 }}    5
   #{{ 3 - 4 }}    -1
   #{{ 3 * 5 }}    15
   #{{ 2 ** 3 }}   8
   #{{ 7 / 5 }}    1.4
   #{{ 7 // 5 }}   1
   #{{ 17 % 5 }}   2
   #{{ 1 in [1,2,3,4] }}  True
   
   ### str
   {{ 'testString' }}   testString
   {{ "testString" }}   testString
   ### num
   {{ 15 }}     15
   {{ 18.8 }}   18.8
   ### list
   {{ ['Aa','Bb','Cc','Dd'] }}      ['Aa','Bb','Cc','Dd']
   {{ ['Aa','Bb','Cc','Dd'].1 }}     Bb
   {{ ['Aa','Bb','Cc','Dd'][1] }}    Bb
   ### tuple
   {{ ('Aa','Bb','Cc','Dd') }}      ('Aa','Bb','Cc','Dd')
   {{ ('Aa','Bb','Cc','Dd').0 }}     Aa
   {{ ('Aa','Bb','Cc','Dd')[0] }}    Aa
   ### dic
   {{ {'name':'bob','age':18} }}           {'name':'bob','age':18}
   {{ {'name':'bob','age':18}.name }}       bob
   {{ {'name':'bob','age':18}['name'] }}    bob
   
   #{{ 'abc' | upper }}            ABC
   #{{ testvar1 is defined }}      True
   #{{ testvar1 is undefined }}    False
   #{{ '/opt' is exists }}         True
   #{{ '/opt' is file }}           False
   #{{ '/opt' is directory }}      True
   
   #{{ lookup('env','PATH') }}    /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
   
   {#   #}：用来装载注释，模板文件被渲染后，注释不会包含在最终生成的文件中。
   ```

   ```bash
   {%   %}：用来装载控制语句，比如 if 控制结构，for循环控制结构。
   
   #{% if 条件 %}
   #...
   #{% elif %}
   #...
   #{% else %}
   #...
   #{% endif %}
   
   # <do something> if <something is true> else <do something else>
   {{ 'a' if 2>1 else 'b' }}   a
   
   #设置变量
   #{% set teststr='abc' %}
   #{{ teststr }}
   
   #{% for 迭代变量 in 可迭代对象 %}
   #{{ 迭代变量 }}
   #{% endfor %}
   #每次循环后都会自动换行，如果不想要换行，在for的结束控制符"%}"之前添加了减号"-",在endfor的开始控制符"{%"之后添加到了减号"-"
   {% for i in [3,1,7,8,2] -%}
   {{ i }}{{' '}}{{ loop.index }}  #或{{i~' '~loop.index}}表示join
   {%- endfor %}
   3 1 7 8 2 
   
   loop.index     当前循环操作为整个循环的第几次循环，序号从1开始
   loop.index0    当前循环操作为整个循环的第几次循环，序号从0开始
   loop.revindex  当前循环操作距离整个循环结束还有几次，序号到1结束
   loop.revindex0 当前循环操作距离整个循环结束还有几次，序号到0结束
   loop.first     当操作可迭代对象中的第一个元素时，此变量的值为true
   loop.last      当操作可迭代对象中的最后一个元素时，此变量的值为true
   loop.length    可迭代对象的长度
   loop.depth     当使用递归的循环时，当前迭代所在的递归中的层级，层级序号从1开始
   loop.depth0    当使用递归的循环时，当前迭代所在的递归中的层级，层级序号从0开始
   loop.cycle()   这是一个辅助函数，通过这个函数我们可以在指定的一些值中进行轮询取值
   
   #1,3,5,7，但不包括9
   {% for i in range(1,9,2) if i > 3 %}
     {{ i }}
   {%else%}
     {{ i }}
   {% endfor %}
   
   ###loop.cycle()
   {% set userlist=['Naruto','Kakashi','Sasuke','Sakura','Lee','Gaara','Itachi']  %}
   {% for u in userlist %}
     {{ u ~'----'~ loop.cycle('team1','team2','team3')}}
   {%endfor%}
   Naruto----team1
   Kakashi----team2
   Sasuke----team3
   Sakura----team1
   Lee----team2
   Gaara----team3
   Itachi----team1
   
   #include，默认引入上下文环境
   #引入另一个模板，**without context：不引入对应的上下文**
   {% include 'test1.j2' without context %}
   #在指定包含的文件不存在时，自动忽略包含对应的文件
   {% include 'test2.j2' ignore missing with context %}
   
   #import，默认不引入上下文环境
   #引入另一个模板的所有宏，**with context同时引入上下文**
   {% import 'function_lib.j2' as funclib with context %}
   #使用宏函数
   {{ funclib.testfunc(1,2,3) }}
   #引入另一个模板的特定宏
   {% from 'function_lib.j2' import testfunc as tf, testfunc1 as tf1  %}
   {{ tf(1,2) }}
   {{ tf1('a') }}
   ```

3. ##### 转义

   ```bash
   #置于''中
   {{  '{{' }}
   {{  '}}' }}
   {{ '{{ test string }}' }}
   {{ '{% test string %}' }}
   {{ '{# test string #}' }}
   
   #置于{{raw}}中
   {% raw %}
     {{ test }}
     {% test %}
     {# test #}
     {% if %}
     {% for %}
   {% endraw %}
   ```

4. ##### 宏

   ```bash
   #定义
   {% macro testfunc() %}
     test string
   {% endmacro %}
   #使用
   {{ testfunc() }}
   
   #varargs
   {% macro testfunc(testarg1=1,testarg2=2) %}
     test string
     {{testarg1}}
     {{testarg2}}
     #varargs接受多传入的参数
     {{varargs}}
   {% endmacro %}
    
   {{ testfunc('a','b','c','d','e') }} 
   #test string
   #a
   #b
   #('c', 'd', 'e')
   
   #kwargs
   {% macro testfunc(tv1='tv1') %}
     test string
     {{varargs}}
     #构成字典
     {{kwargs}}
   {% endmacro %}
    
   {{ testfunc('a',2,'test',testkeyvar='abc') }}
   #test string
   #(2, 'test')
   #{'testkeyvar': 'abc'}
   
   #caller()
   {% macro testfunc() %}
     test string
     {{caller()}}
   {% endmacro %}
    
   {%call testfunc()%}
   something~~~~~
   something else~~~~~
   {%endcall%}
   
   #test string
   #something~~~~~
   #something else~~~~~
   
   name属性：宏的名称。
   arguments属性：宏中定义的所有参数的参数名，这些参数名组成了一个元组存放在arguments中。
   defaults属性：宏中定义的参数如果有默认值，这些默认值组成了一个元组存放在defaults中。
   catch_varargs属性：如果宏中使用了varargs变量，此属性的值为true。
   catch_kwargs属性： 如果宏中使用了kwargs变量，此属性的值为true。
   caller属性：如果宏中使用了caller变量，此属性值为true。
   
   #**私有宏，不能被引入到其他的模板中**
   {% macro _test() %}
   something in test macro
   {% endmacro %}
    
   {{_test()}}
   ```

5. ##### 继承

   ```bash
   https://www.zsythink.net/archives/3051
   ```

   

> [jinja2模板](<https://www.zsythink.net/archives/2999>)

