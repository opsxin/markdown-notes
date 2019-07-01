1. ###### let命令（整数）

   ```bsah
   let a=1+1
   echo ${a}
   ```

   

2. ###### expr（整数）

   ```bash
   expr 1 + 1
   expr 2 \* 3
   ```

   

3. ###### bc（整数，小数）

   ```bash
   echo "1.1+1.1" | bc
   echo "8/3" | bc
   #返回2
   echo "scale=3; 8/3" | bc
   #返回2.666
   ```

   

4. ###### $[],$(())（整数）

   ```bash
   echo $[1+1]
   echo $((1+1))
   
   a=1
   b=2
   echo $[${a}+${b}]
   echo $((${a}+${b}))
   ```

   **在$[]，$(())中的变量可省略‘$’**。

   ```bash
   a=1
   b=2
   echo $[a+b]
   echo $((a+b))
   ```



> [Shell算数运算](http://www.zsythink.net/archives/1145)