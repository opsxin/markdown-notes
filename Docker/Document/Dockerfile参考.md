# Dockerfile 参考

Docker 可以从 `Dockerfile` 文件中读取指令并自动构建镜像（image）。Dockerfile 文件包含用户在命令行上可以使用的所有命令去组成镜像。使用 `docker build` ，用户可以创建一个自动化的执行多条命令行指令的构建（build）。

这一页描述了在 Dockerfile 中可以使用的命令。当你阅读完这一页，可以看看[最佳实践](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/)。

[TOC]

## 用法

`docker build` 命令从 Dockerfile 和上下文（context）构建一个镜像，这个构建的上下文是指定路径中的一些文件或者 URL。这个路径（PATH）是你本地主机的一个目录，URL 则是一个 Git 仓库路径。

上下文是递归处理的（processed recursively），因此，一个路径包含它的子目录，URL 包含仓库中的子模块。下面这个例子显示了构建命令使用了当前目录作为上下文：

```bash 
docker build .
```

构建是由 Docker 守护进程（daemon）运行，而不是 CLI。首先是构建进程发送整个上下文到守护进程，在大多数情况下，最好将空目录作为上下文，然后添加需要用到的 Dockerfile。

> **警告：**不要使用根目录（/），因为它会造成整个硬盘都传输到 Docker Daemon。

 要在构建中使用文件，Dockerfile 使用指令指定文件 ，例如  `copy` 指令。为了提高构建的性能，通过添加 `.dockerignore`忽略额外的文件和目录 。

传统的，Dockerfile 位于上下文的根目录中，你可以使用 `-f` 标识指出 `docker build` 要使用的 Dockerfile。

```bash
docker build -f /path/Dockerfile .
```

你可以给构建成功后的镜像指定仓库（repository）和标签：

```bash
docker build -t shykes/myapp .
```

要在构建之后将镜像打上多个标签，请运行构建命令时添加多个 `-t` 参数 :

```bash
docker build -t shykes/myapp:1.0.2 -t shykes/myapp:latest .
```

在 Docker 守护进程运行 Dockerfile 之前，它会对 Dockerfile 进行初步验证，如果语法不正确，则返回一个错误 ：

```bash
docker build -t test/myapp .
# Sending build context to Docker daemon 2.048 kB
# Error response from daemon: Unknown instruction: RUNCMD
```

Docker 守护进程将逐个运行 Dockerfile 中的指令，如果有必要，每个指令的结果都会提交到一个新镜像中，最后输出新镜像的 ID。Docker 守护进程将自动清理上下文。 

注意每个指令是独立运行的，因为新的镜像被创建，所以 `RUN cd /tmp` 对下个指令没有任何影响。

只要有可能，Docker 将重用中间映像（缓存），以加快 Docker 的构建。这是由控制台输出中的使用缓存的消息：

```bash
docker build -t svendowideit/ambassador .
# Sending build context to Docker daemon 15.36 kB
# Step 1/4 : FROM alpine:3.2
#  ---> 31f630c65071
# Step 2/4 : MAINTAINER SvenDowideit@home.org.au
#  ---> Using cache
#  ---> 2a1c91448f5f
# Step 3/4 : RUN apk update &&      apk add socat &&        rm -r /var/cache/
#  ---> Using cache
#  ---> 21ed6e7fbb73
# Successfully built 7ea8aef582cc
```

 构建缓存仅被用于具有本地父链（local chain）的映像。  这意味着这些镜像是由以前的构建创建的，或者整个镜像链是用`docker load`的。 如果你希望使用特定镜像的构建缓存，你可以通过 `--cache-from` 指定它。 使用 `--cache-from`指定的镜像不需要父链，并且可以从其他仓库（registries）获取。 

当你完成构建，你可以看看[推送镜像到仓库](https://docs.docker.com/engine/tutorials/dockerrepos/#/contributing-to-docker-hub)。

## BuildKit

从 18.09 版本开始，Docker 支持由 [moby/buildkit](https://github.com/moby/buildkit) 提供的用于执行构建的新后端。这个构建器对比旧的构建器提供了更多优点，例如：

-  检测并跳过未使用的构建阶段
-  并行构建独立的构建阶段 
-  在构建之间只增量传输上下文中更改的文件 
-  在构建之间检测并跳过上下文中未使用的文件 
-  使用额外的 Dockerfile 实现许多新特性
-  避免 API 其余部分的副作用（中间镜像和容器）
-  为自动清理设置构建缓存的优先级 

为了使用 Buildkit 后端，在调用 `docker build` 之前，你需要设置一个环境变量`DOCKER_BUILDKIT=1` 。

 要了解基于 BuildKit 的构建 Dockerfile 语法，请[参考 BuildKit 存储库中的文档](https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/experimental.md)。 

## 格式

下方是 Dockerfile 的格式：

```dockerfile
# Comment
INSTRUCTION arguments
```

指令是大小写敏感的。然而， 按照惯例，它们应该是大写的，以便更容易地将它们与参数区分。

Docker 按照顺序运行 Dockerfile 中的指令。**Dockerfile 必须从 `FROM` 指令开始**。`FROM` 指令定义了一个构建[基础镜像](https://docs.docker.com/engine/reference/glossary/#base-image)。 `FROM` 之前可能有一个或多个`ARG`指令，它们声明了 Dockerfile 的 `FROM`行中使用的参数。 

Docker 将`#`开头的行视为注释， 除非该行是一个有效的[解析器指令](https://docs.docker.com/engine/reference/builder/#parser-directives) 。 行中任何位置的`#`标记都被视为参数。这允许像这样的语句：

```dockerfile
# Comment
RUN echo 'we are running some # of cool things'
```

 注释中不支持行延续字符。 

## 解析器指令

解析器指令是可选的，并且影响 Dockerfile 中后续行的处理方式。解析器指令不向构建中添加层，也不会显示为构建步骤。解析器指令被编写为`# directive=value`中的一种特殊类型的注释。单个指令只能使用一次。 

一旦处理了注释、空行或生成器指令，Docker 就不再寻找解析器指令。相反，它将任何格式化为解析器指令的内容视为注释，并且不尝试验证它是否可能是解析器指令。因此，所有解析器指令必须位于 Dockerfile 的最顶层。 

解析器指令不区分大小写。但是，习惯上它们都是小写的。约定还包括任何解析器指令后面的空行。解析器指令不支持行延续字符。 

由于这些规则，下面的例子都是无效的：

由于行延续而无效 ：

```dockerfile
# direc \
tive=value
```

因为出现两次无效：

```dockerfile
# directive=value1
# directive=value2

FROM ImageName
```

由于在生成器指令之后出现的而被视为注释：

```dockerfile
FROM ImageName
# directive=value
```

由于出现在非解析器指令的注释之后，所以被视为注释：

```dockerfile
# About my dockerfile
# directive=value
FROM ImageName
```

未知指令将被视为注释，因为它不能识别。此外，由于出现在注释之后，已知的指令被视为注释，而注释不是解析器指令。 

```dockerfile
# unknowndirective=value
# knowndirective=value
```

解析器指令中允许非断行空白。因此，下面的行都是相同的：

```dockerfile
#directive=value
# directive =value
#	directive= value
# directive = value
#	  dIrEcTiVe=value
```

支持下列解析器指令：

- `syntax`
- `escape`

### 语法（syntax）

```dockerfile
# syntax=[remote image reference]
```

例如

```dockerfile
# syntax=docker/dockerfile
# syntax=docker/dockerfile:1.0
# syntax=docker.io/docker/dockerfile:1
# syntax=docker/dockerfile:1.0.0-experimental
# syntax=example.com/user/repo:tag@sha256:abcdef...
```

这个特性只能在 BuildKit 中使用。

语法指令定义用于构建当前 Dockerfile 的生成器的位置。BuildKit 后端允许无缝地使用构建器的外部实现，这些构建器以 Docker 镜像的形式分发，并在容器沙箱环境中执行。 

自定义 Dockerfile 实现允许你这样做：

-  不更新的守护程序，而自动获得错误修复
-  确保所有用户使用相同的实现来构建 Dockerfile 
-  在不更新守护进程的情况下使用最新的特性 
-  尝试新的实验性或第三方特性 

### 正式发布

Docker 分发可用于在 Docker Hub 上的 docker/dockerfile 存储库下构建 Dockerfile 镜像的正式版本。 有两个发布新镜像的通道：稳定版和实验版。

稳定的通道遵循语义版本控制。例如：

- docker/dockerfile:1.0.0 - 只允许 1.0.0 版本
- docker/dockerfile:1.0 - 允许 1.0.*
- docker/dockerfile:1 - 允许 1.*.* 
- docker/dockerfile:latest -最新的稳定版本

实验通道在发布时使用来自稳定通道的主组件和次组件的增量版本控制。例如：

- docker/dockerfile:1.0.1-experimental - only allow immutable version 1.0.1-experimental
- docker/dockerfile:1.0-experimental - latest experimental releases after 1.0
- docker/dockerfile:experimental - latest release on experimental channel

您应该选择最适合自己需求的通道。 如果仅需要错误修复，则应使用 docker/dockerfile:1.0。 如果您想使用实验功能的特性，则应使用实验通道。 如果您正在使用实验性特性，则较新的版本可能无法向后兼容，因此建议使用不可变的完整版本。

对于主构建和每晚的特性发布，请参考[源存储库](https://github.com/moby/buildkit/blob/master/README.md)中的描述。

### escape

```dockerfile
# escape=\ (backslash)
```

或者

```dockerfile
# escape=` (backtick)
```

`escape` 指令设置 Dockerfile 中转义字符的字符。如果没有指定，默认的转义字符是 `\`。 

转义字符既用于转义行中的字符，也用于转义换行。这允许 Dockerfile 指令跨越多行。注意，无论 Dockerfile 中是否包含`escape`解析器指令，除了在行尾之外，都不会在`RUN`命令中执行转义。 

将转义字符设置为`'`在 Windows 上特别有用，因为`\`是目录路径分隔符。与 Windows PowerShell 一致。 

考虑下面的示例，它在 Windows 上以一种不太明显的方式失败。位于第二行的末尾的第二个`\`将被解释为换行符的转义，而不是从第一个`\`开始的转义目标。类似地，第三行末尾的`\`将（假设它实际上是作为一条指令处理的），因为它被视为行延续。这个 dockerfile 的结果是，第二行和第三行被认为是一条单独的指令:

```dockerfile
FROM microsoft/nanoserver
COPY testfile.txt c:\\
RUN dir c:\
```

结果是：

```dockerfile
PS C:\John> docker build -t cmd .
Sending build context to Docker daemon 3.072 kB
Step 1/2 : FROM microsoft/nanoserver
 ---> 22738ff49c6d
Step 2/2 : COPY testfile.txt c:\RUN dir c:
GetFileAttributesEx c:RUN: The system cannot find the file specified.
```

上面的一种解决方案是将`/`用作`COPY`指令和`dir`的目标。 但是，此语法是令人困惑的，因为 Windows 上的路径并不自然，而最糟糕的是，由于 Windows 上的所有命令都不支持`/`作为路径分隔符，因此容易出错。

通过添加转义解析器指令，下面的 Dockerfile 按照预期，成功地使用了 Windows 上文件路径的自然平台语义：

```dockerfile
# escape=`

FROM microsoft/nanoserver
COPY testfile.txt c:\
RUN dir c:\
```

结果是：

```dockerfile
PS C:\John> docker build -t succeeds --no-cache=true .
Sending build context to Docker daemon 3.072 kB
Step 1/3 : FROM microsoft/nanoserver
 ---> 22738ff49c6d
Step 2/3 : COPY testfile.txt c:\
 ---> 96655de338de
Removing intermediate container 4db9acbb1682
Step 3/3 : RUN dir c:\
 ---> Running in a2c157f842f5
 Volume in drive C has no label.
 Volume Serial Number is 7E6D-E0F7

 Directory of c:\

10/05/2016  05:04 PM             1,894 License.txt
10/05/2016  02:22 PM    <DIR>          Program Files
10/05/2016  02:14 PM    <DIR>          Program Files (x86)
10/28/2016  11:18 AM                62 testfile.txt
10/28/2016  11:20 AM    <DIR>          Users
10/28/2016  11:20 AM    <DIR>          Windows
           2 File(s)          1,956 bytes
           4 Dir(s)  21,259,096,064 bytes free
 ---> 01c7f3bef04f
Removing intermediate container a2c157f842f5
Successfully built 01c7f3bef04f
```

## 环境变换（Environment replacement）

环境变量（通过`ENV`声明） 也可以在某些指令中用作 Dockerfile 要解释的变量。 还可以处理转义，将类似变量的语法按字面意思包含到语句中。 

环境变量在 Dockerfile 中以`$变量名`或`${变量名}`标记。它们是一样的，大括号语法通常用于处理变量名没有空格的问题，比如`${foo}_bar`。 

`${变量名}`语法还支持下面指定的一些标准 bash 修饰符：

- `${variable:-word}`表示如果设置了变量，那么结果将是该值。如果变量没有设置，那么 word 将是结果。 
- `${variable:+word}`表示如果设置了变量，则结果为 word，否则结果为空字符串。 

在所有情况下，word 可以是任何字符串，包括额外的环境变量。 

可以通过在变量前面添加一个`\`来进行转义，例如，`\$foo`或`\${foo}`将分别转换为`$foo`和`${foo}`文本。 

示例（解析后的表示形式在`#`后面显示）:

```dockerfile
FROM busybox
ENV foo /bar
WORKDIR ${foo}   # WORKDIR /bar
ADD . $foo       # ADD . /bar
COPY \$foo /quux # COPY $foo /quux
```

Dockerfile 中的下列指令列表支持环境变量：

- `ADD`
- `COPY`
- `ENV`
- `EXPOSE`
- `FROM`
- `LABEL`
- `STOPSIGNAL`
- `USER`
- `VOLUME`
- `WORKDIR`

同样：

- `ONBUILD`（当与上面支持的指令之一结合使用时）

> 注意： 在 1.4 之前，`ONBUILD` 指令**不支持环境变量**，即使与所列的任何指令相结合 

环境变量替换将在整个指令中对每个变量使用相同的值。换句话说，在这个例子中：

```dockerfile
ENV abc=hello
ENV abc=bye def=$abc
ENV ghi=$abc
```

将导致`def`的值为`hello`，而不是`bye`。然而，`ghi`将有一个值`bye`，因为它不是设置`abc`为`bye`的同一指令的一部分。 

## .dockerignore 文件

在 docker CLI 将上下文发送到 docker 守护进程之前，它在上下文的根目录中查找一个名为 .dockerignore 的文件。如果该文件存在，CLI 将修改上下文以排除与其中模式匹配的文件和目录。这有助于避免不必要地向守护进程发送大型或敏感的文件和目录，并可能使用`ADD`或`COPY`将它们添加到镜像中。 

CLI 将 .dockerignore 文件解释为一个新行分隔的模式列表，类似于 Unix shell 的文件 globs。为了进行匹配，上下文的根被认为是工作目录和根目录。例如，模式`/foo/bar`和`foo/bar`都排除了`PATH`的`foo`子目录或位于 URL 的 git 存储库根目录中名为 bar 的文件或目录。两者都不排除其他任何东西。

如果 .dockerignore 文件中的一行以`#`开始，那么这一行将被视为注释，并在 CLI 解释之前被忽略。

下面是 .dockerignore 的一个例子： 

```dockerfile
# comment
*/temp*
*/*/temp*
temp?
```

此文件导致以下构建行为：

| 规则        | 行为                                                         |
| :---------- | :----------------------------------------------------------- |
| `# comment` | 忽略                                                         |
| `*/temp*`   | 排除根目录后一级中任何带有`temp`的文件和目录。例如，纯文本`/somedir/temporary.txt`和`/somedir/temp`都将被排除。 |
| `*/*/temp*` | 排除根目录后二级中任何带有`temp`的文件和目录。例如，纯文本`/somedir/subdir/temporary.txt` 将被排除。 |
| `temp?`     | 排除以`temp`开头的文件或文件夹，例如, `/tempa` 和 `/tempb` 将被排除。 |

使用 Go 的 [filepath.Match](http://golang.org/pkg/path/filepath#Match) 进行匹配。预处理步骤使用 [filepath.clean](http://golang.org/pkg/path/filepath/#Clean) 删除开头和结尾的空格与消除`.`和`..`。预处理后空行将被忽略。 

除去 GO 的匹配规则，Docker 同样支持特殊的通配符字符串`**`匹配任何的目录数（包括 0 个），例如，`**/*.go`匹配以`.go`结尾的所有目录（根目录和所有子目录）的所有文件。

以`!`开始，可以用来排除例外情况。下面是一个使用这种方式的 .dockerignore 例子：

```dockerfile
*.md
!README.md
```

所有 Markdown 文件，除了 `README.md` 文件。

放置`!`位置会影响行为。 .dockerignore 中与特定文件匹配的最后一行决定它是被包含还是被排除。考虑以下例子：

```dockerfile
*.md
!README*.md
README-secret.md
```

除了 README-secret.md 以外，上下文中包含其他 README 文件。

>  `*.md` 和 `README-secret.md`起效果。

现在考虑这个例子：

```dockerfile
*.md
README-secret.md
!README*.md
```

所有的 README 文件都包括在内。中间的行没有效果，因为 `!README*.md` 匹配 README-secret.md。 

>  `*.md` 和 `!README*.md`起效果。

你甚至可以使用 .dockerignore 文件来排除 Dockerfile 和 .dockerignore 文件。这些文件仍然被发送到守护进程，因为守护进程需要它们来完成自己的工作，但是`ADD`和`COPY`指令不会将它们复制到镜像。 

最后，你可能指定上下文中要包含的文件，而不是要排除哪些文件。要实现这一点，将`*`指定为第一个模式，然后指定一个或多个`!`取反模式。 

>  注意：由于历史原因，模式`.`将被忽略。 

## FROM

```dockerfile
FROM <image> [AS <name>]
```

或者

```dockerfile
FROM <image>[:<tag>] [AS <name>]
```

或者

```dockerfile
FROM <image>[@<digest>] [AS <name>]
```

`FROM`指令初始化一个新的构建阶段，并为后续指令设置基本镜像。一个正确的 Dockerfile 必须从 `FROM` 指令开始。镜像可以是多种多样，它是极其容易的从[公共仓库](https://docs.docker.com/engine/tutorials/dockerrepos/)拉取。

- `ARG` 指令是唯一可能在 `FROM` 之前的指令。
- `FROM` 可以在一个 Dockerfile 中多次出现，以创建多个镜像，或者使用一个构建阶段作为另一个构建阶段的依赖项。只需在每条新的 `FROM` 指令之前，通过提交记录最后一个镜像 ID 输出。每个`FROM`指令清除以前的指令创建的任何状态。 
- 可以通过`AS name`给一个新的构建阶段命名。后续的 `FROM` 和 `COPY --from=<name|index>` 指令可以引用已命名的镜像。
- `tag` 和 `digest` 值是可选的。如果省略其中任何一个，构建器默认使用`lastest` 的标记。如果生成器找不到`tag`，则返回一个错误。 

### 理解 `ARG` 和 `FROM`

`FROM` 支持 `ARG` 中定义的任何变量。

```dockerfile
ARG  CODE_VERSION=latest
FROM base:${CODE_VERSION}
CMD  /code/run-app

FROM extras:${CODE_VERSION}
CMD  /code/run-extras
```

在`FROM`之前声明的 `ARG` 在构建阶段之外，因此在`FROM`之后的任何指令中都不能使用它。若要使用在第一个`FROM`之前声明的`ARG`的默认值，请使用在构建阶段中没有值的`ARG`指令。

```dockerfile
ARG VERSION=latest
FROM busybox:$VERSION
ARG VERSION
RUN echo $VERSION > image_version
```

## RUN

`RUN` 有两种格式：

- `RUN <command>`：shell 格式，命令运行在一个 Shell 中，Linux 默认为`/bin/sh -c`， Win 为 `cmd /S /C`
- `RUN [“executable”, “param1”,  “param2”]`：exec 格式。

`RUN` 指令将执行任何命令在现在镜像之上的一个新的层，并生成一个新的镜像，后续步骤将使用这个镜像。

exec 格式可以避免使用 shell 字符串，`RUN` 命令使用不包含特定的 shell 可执行文件的基本镜像。 

在 shell 格式中，你可以使用`\`（反斜杠）将单个`RUN`指令延续到下一行。例如：

```dockerfile
RUN /bin/bash -c 'source $HOME/.bashrc; \
echo $HOME'
```

它们加起来等于这一行：

```dockerfile
RUN /bin/bash -c 'source $HOME/.bashrc; echo $HOME'
```

> 注意：使用不同的 Shell，不仅仅 `/bin/sh`，使用 exec 格式描述要使用的 Shell，例如：
>
> `RUN ["/bin/bash", "-c", "echo hello"]`

>  注意：exec 格式被解析为 JSON 数组，这意味着必须在单词周围使用双引号(“”)，而不是单引号(‘’)。 

> 注意：与 shell 格式不同，exec 格式不调用 shell 命令。这意味着不会发生正常的 shell 处理。例如，`RUN ["echo"， "$HOME"]` 不会对`$HOME`执行变量替换。如果您想要 shell 处理，那么要么使用 shell 格式，要么直接执行 shell，例如：`RUN ["sh"， "-c"， "echo $HOME"]`。当使用 exec 格式并直接执行 shell 时，执行环境变量扩展的是 shell，而不是 docker。
>
> 
>
> 注意：在 JSON 格式中，必须转义反斜杠。这在以反斜杠为路径分隔符的 Windows 中特别重要。下面这行代码由于不是有效的 JSON，将被视为 shell 格式，并以一种不可预计的方式运行：`RUN ["c:\windows\system32\tasklist.exe"]`，本例的正确语法是：`RUN ["c:\\windows\\system32\\tasklist.exe"]`

`RUN`指令的缓存不会在下一次构建期间自动失效。像`RUN apt-get distt -upgrade -y`这样的指令的缓存将在下一个构建过程中重用。`RUN`指令的缓存可以通过使用`–no-cache` 标志来失效，例如 `docker build –no-cache`。 

`RUN`指令的缓存可以通过`ADD`指令失效。 

### 已知的问题（RUN）

- [问题 783](https://github.com/docker/docker/issues/783) 是发生在 AUFS 文件系统上的文件权限问题，你可以通过 `rm` 一个文件注意到它，例如：

  对于拥有最新 AUFS 版本的系统（即， `dirperm1`挂载选项可以设置)，docker 将尝试修复该问题，自动挂载层通过 `dirperm1`选项。更多关于`dirperm1`选项的细节可以在 [aufs 手册页](https://github.com/sfjro/aufs3-linux/tree/aufs3.18/Documentation/filesystems/aufs)找到 。

  如果您的系统不支持`dirperm1`，则该问题描述了一种变通方法。 

## CMD

`CMD`指令有三种格式：

- `CMD [“executable”, “param1”,“param2”]`：exec 格式，推荐这种格式
- `CMD ["param1", "param2"]`：作为 ENTRYPOINT 的默认参数
- `CMD command param1 param2`：shell 格式

一个 Dockerfile 中只能有一条 `CMD` 指令。如果你列出一个以上的 `CMD`，那么只有最后一个 `CMD` 会生效。 

`CMD` 的主要用途是为执行容器提供默认值。这些缺省值可以包括可执行文件，也可以省略可执行文件，在这种情况下，您还必须指定一个`ENTRYPOINT`。 

> 注意：如果`CMD`用于为 `ENTRYPOINT` 指令提供默认参数，那么`CMD`和`ENTRYPOINT`指令都应该使用 JSON 数组格式指定。

>  注意：exec 格式被解析为 JSON 数组，这意味着必须在单词周围使用双引号(“”)，而不是单引号(‘’)。 

在 shell 或 exec 格式中使用时，`CMD`指令设置镜像要执行的命令。 

如果你使用 Shell 格式的 `CMD`，然后 `<command>`将被执行通过`/bin/sh -c`：

```dockerfile
FROM ubuntu
CMD echo "This is a test." | wc -
```

如果您想运行没有 shell 的 `<command>`，那么您必须将该命令表示为 JSON 数组，并给出可执行文件的完整路径。这种数组形式是`CMD`的首选格式。任何附加参数都必须单独表示为数组中的字符串：

```dockerfile
FROM ubuntu
CMD ["/usr/bin/wc","--help"]
```

如果希望容器每次都运行相同的可执行文件，那么应该考虑将 `ENTRYPOINT`与`CMD`结合使用。

如果用户指定 docker 运行的参数，那么他们将覆盖 `CMD`中指定的默认值。 

> 注意：不要将`RUN`与`CMD`混淆，`RUN`实际运行命令并提交结果；`CMD`在构建时不执行任何操作，但是为镜像指定预期的命令 

## LABEL

```dockerfile
LABEL <key>=<value> <key>=<value> <key>=<value> ...
```

`LABEL` 指令将元数据添加到镜像中，标签是键值对。要在标签值中包含空格，可以使用引号和反斜杠，就像在命令行解析中一样。一些用法示例：

```dockerfile
LABEL "com.example.vendor"="ACME Incorporated"
LABEL com.example.label-with-value="foo"
LABEL version="1.0"
LABEL description="This text illustrates \
that label-values can span multiple lines."
```

一个镜像可以有多个标签，可以在一行中指定多个标签。在 Docker 1.10 之前，这降低了最终镜像的大小，但现在不再是这样了。您仍然可以选择在一条指令中指定多个标签，方法有以下两种：

```dockerfile
LABEL multi.label1="value1" multi.label2="value2" other="value3"

LABEL multi.label1="value1" \
      multi.label2="value2" \
      other="value3"
```

包含在基本镜像或基础镜像（`FROM`行中的镜像）中的标签由镜像继承。如果标签已经存在，但值不同，则最新的值将覆盖以前的值。 

要查看镜像的标签，使用`docker inspect`命令。 

```dockerfile
"Labels": {
    "com.example.vendor": "ACME Incorporated"
    "com.example.label-with-value": "foo",
    "version": "1.0",
    "description": "This text illustrates that label-values can span multiple lines.",
    "multi.label1": "value1",
    "multi.label2": "value2",
    "other": "value3"
},
```

## EXPOSE

```dockerfile
EXPOSE <port> [<port>/<protocol>...]
```

`EXPOSE` 指令通知 Docker 容器在运行时监听指定的网络端口。您可以指定端口监听 TCP 还是 UDP，如果没有指定协议，则默认为 TCP。 

`EXPOSE`指令实际上并不发布端口。它的功能类似于构建镜像的人员和运行容器的人员之间的一种文档说明关于要发布哪些端口。要在运行容器时实际使用端口，可以使用`docker run`上的`-p`标志来发布和映射一个或多个端口，或者使用`-p`标志来发布所有公开的端口并将它们映射到端口。 

默认的，`EXPOSE`使用 TCP，你可以指定 UDP：

```dockerfile
EXPOSE 80/udp
```

同时暴露 TCP 和 UDP，包括这两行：

```dockerfile
EXPOSE 80/tcp
EXPOSE 80/udp
```

在这种情况下，如果您在`docker run`中使用`-P`，那么 TCP 和 UDP 端口将分别公开一次。请记住，`-P`在主机上使用临时的主机端口，因此 TCP 和 UDP 的端口将不相同。

不管`EXPOSE`设置如何，您都可以在运行时使用`-p`标志覆盖它们。例如：

```bash
docker run -p 80:80/tcp -p 80:80/udp ...
```

要在主机系统上设置端口重定向，请参阅使用`-P`标志。`docker network`命令支持在容器之间创建通信网络，而不需要公开或发布特定的端口，因为连接到网络的容器可以通过任何端口相互通信。

## ENV

```dockerfile
ENV <key> <value>
ENV <key>=<value> ...
```

`ENV`指令将环境变量`<key>`设置为值`<value>`。此值将位于构建阶段中所有后续指令的环境中，也可以内联地替换许多指令。 

`ENV`指令有两种形式。第一种形式是`ENV <key> <value>`，它将把单个变量设置为一个值。第一个空格之后的整个字符串将被视为`<value>`--包括空白字符。该值将被解释为其他环境变量，因此如果没有转义，引号字符将被删除。 

第二种形式，`ENV <key>=<value>…`，允许同时设置多个变量。注意，第二种形式在语法中使用了等号(=)，而第一种形式没有。与命令行解析一样，引号和反斜杠可用于在值中包含空格。 

```dockerfile
ENV myName="John Doe" myDog=Rex\ The\ Dog \
    myCat=fluffy
```

和

```dockerfile
ENV myName John Doe
ENV myDog Rex The Dog
ENV myCat fluffy
```

将在最后产生一样的结果。

当从结果镜像运行容器时，使用`ENV`设置的环境变量将保持不变。您可以使用`docker inspect`查看这些值，并使用`docker run --env <key>=<value>`更改它们。

> 注意：保持环境变量可能会导致意外的副作用。例如，设置`ENV DEBIAN_FRONEND noninteractive`，可能会使用户使用基于 DEBIAN 的镜像上的`apt-get`时产生困惑。要设置单个命令的值，使用`RUN <key>=<value> <command>`。  

## ADD

`ADD` 有两种格式：

- `ADD [--chown=<user>:<group>] <src>... <dest> `
-  `ADD [--chown=<user>:<group>] ["<src>",... "<dest>"] `：这种格式要求路径包含空格

> 注意：`--chown`特性只支持用于构建 Linux 容器的 Dockerfiles，而不能用于 Windows 容器。由于用户和组所有权概念不能在 Linux 和 Windows 之间转换，因此使用`/etc/passwd`和`/etc/group`将用户名和组名转换为 IDs，这限制了该特性只能用于基于 Linux OS 的容器。

`ADD`指令从`<src>`复制新的文件、目录或远程文件 url，并将它们添加到路径`<dest>`的镜像文件系统中。 

可以指定多个`<src>`资源，但是如果它们是文件或目录，它们的路径将被解释为相对于构建上下文的源。

每个`<src>`可能包含通配符，匹配将使用 Go 的 filepath.Match 规则。例如：

```dockerfile
ADD hom* /mydir/        # adds all files starting with "hom"
ADD hom?.txt /mydir/    # ? is replaced with any single character, e.g., "home.txt"
```

`<dest>`是一个绝对路径，或相对于 WORKDIR 的路径，源文件将被复制到目标容器中。 

```dockerfile
ADD test relativeDir/          # adds "test" to `WORKDIR`/relativeDir/
ADD test /absoluteDir/         # adds "test" to /absoluteDir/
```

在添加包含特殊字符（如`[`和`]`)的文件或目录时，需要转义那些遵循 Golang 规则的路径，以防止它们被视为匹配模式。例如，添加一个名为`arr[0].txt`，使用以下命令 ：

```dockerfile
ADD arr[[]0].txt /mydir/    # copy a file named "arr[0].txt" to /mydir/
```

所有新创建的文件和目录的 UID 和 GID 都是 0，除非可选的`–chown`标志指定了一个 user、groupname 或UID/GID 组合来请求添加内容的特定所有权。`–chown`标志的格式允许在任何组合中使用 user 和 groupname 字符串或直接整数 UID 和 GID。提供没有 groupname 的 user 或没有 GID 的 UID 将使用与 GID 相同的数字 UID。如果提供了 user 或 groupname，则将使用容器的根文件系统`/etc/passwd`和`/etc/group`文件分别执行从名称到整数 UID 或 GID 的转换。下面的例子展示了`–chown`标志的有效定义：

```dockerfile
ADD --chown=55:mygroup files* /somedir/
ADD --chown=bin files* /somedir/
ADD --chown=1 files* /somedir/
ADD --chown=10:11 files* /somedir/
```

如果容器根文件系统不包含`/etc/passwd`或`/etc/group`文件，并且在`–chown`标志中使用了用户名或组名，那么在添加操作时构建将失败。使用数字 id 不需要查找，也不依赖于容器根文件系统的内容。

在远程文件 URL 的情况下，目的地的权限为 600。如果正在检索的远程文件具有 HTTP Last-Modified 标头，则来自该标头的时间戳将用于设置目标文件的时间。但是，与添加过程中处理的任何其他文件一样，在确定文件是否更改以及是否应该更新缓存时，并不包括 mtime。

> 注意：如果您通过 STDIN (`docker build - < somefile`)传递一个 Dockerfile 来构建，则没有构建上下文，因此 Dockerfile 只能包含一个基于 URL 的添加指令。您还可以通过 STDIN (`docker build - < archive.tar.gz`)传递压缩的归档文件，归档文件根目录下的 Dockerfile 和归档文件的其余部分将用作构建的上下文。 

> 注意：如果您的 URL 文件使用身份验证进行保护，那么您将需要在容器中使用`RUN wget`、`RUN curl`或其他工具，因为`ADD`指令不支持身份验证。 

> 注意:如果`<src>`的内容发生了变化，第一次遇到的`ADD`指令将使 Dockerfile 中的所有后续指令的缓存失效。这包括使`RUN`指令的缓存无效。

`ADD`遵循以下规则：

- `<src>`必须在构建的上下文中，你不能` ADD ../something /something `，因为 docker 构建的第一步是将上下文目录(和子目录)发送到 docker 守护进程。
- 如果`<src>`是一个 URL，并且没有以斜杠结尾，则从该 URL 下载一个文件并复制到`<dest>`。
- 如果`<src>`是一个 URL，并且以一个斜杠结尾，那么从 URL 推断文件名，文件被下载到`/`。例如，`ADD http://example.com/foobar/` 将创建文件`/foobar`。URL 必须有一个重要的路径，这样才能在这种情况下找到一个合适的文件名(http://example.com将不起作用)。
- 如果`<src>`是一个目录，则复制目录的全部内容，包括文件系统元数据。

> 注意：目录本身不是复制的，只是它的内容。 

- 如果`<src>`是一个以可识别的压缩格式(identity、gzip、bzip2或xz)进行压缩的本地 tar 存档，则将其作为目录解压缩。来自远程 url 的资源没有解压缩。当目录被复制或解压缩时，它的行为与 tar -x 相同，结果是：

  1.  无论目标路径和源树的内容存在什么，都要在逐个文件的基础上解决冲突。

  > 注意：一个文件是否被识别为可识别的压缩格式仅仅是基于文件的内容，而不是文件的名称。例如，如果一个空文件以`.tar.gz`结尾，那么它将不会被识别为压缩文件，也不会生成任何类型的解压缩错误消息，而只是简单地将该文件复制到目的地。 

- 如果`<src>`是任何其他类型的文件，它将与元数据一起单独复制。在这种情况下，如果以一个斜杠`/`结尾，它将被认为是一个目录，的内容将写在` <dest>/base(<src>)` 。

- 如果`<src>`直接指定了多个资源，或者由于使用了通配符，那么必须是一个目录，并且必须以斜杠`/`结尾。

- 如果`<src>`没有以斜杠结尾，它将被视为一个常规文件，`<src>`的内容将被写在`<dest>`。

- 如果`<dest>`不存在，它将与路径中所有缺失的目录一起创建。

## COPY

`COPY`有两种格式：

- `COPY [--chown=:] ... `
- `COPY [--chown=:] ["",... ""]` (这种方式要求路径包含空格)

> 注意：`--chown`特性只支持用于构建 Linux 容器的 Dockerfiles，而不能用于 Windows 容器。由于用户和组所有权概念不能在 Linux 和 Windows 之间转换，因此使用`/etc/passwd`和`/etc/group`将用户名和组名转换为 IDs，这限制了该特性只能用于基于 Linux OS 的容器。

`COPY`指令从`<src>`复制新文件或目录，并将它们添加到容器路径`<dest>`的文件系统中。

指定多个`<src>`资源，但是文件和目录的路径将被解释为相对于构建上下文的源。

每个`<src>`可能包含通配符，匹配将使用 Go 的filepath.Match 规则。例如：

```dockerfile
COPY hom* /mydir/        # adds all files starting with "hom"
COPY hom?.txt /mydir/    # ? is replaced with any single character, e.g., "home.txt"
```

在添加包含特殊字符（如`[`和`]`)的文件或目录时，需要转义那些遵循 Golang 规则的路径，以防止它们被视为匹配模式。例如，添加一个名为`arr[0].txt`，使用以下命令 ：

```dockerfile
COPY arr[[]0].txt /mydir/    # copy a file named "arr[0].txt" to /mydir/
```

所有新创建的文件和目录的 UID 和 GID 都是 0，除非可选的`–chown`标志指定了一个 user、groupname 或UID/GID 组合来请求添加内容的特定所有权。`–chown`标志的格式允许在任何组合中使用 user 和 groupname 字符串或直接整数 UID 和 GID。提供没有 groupname 的 user 或没有 GID 的 UID 将使用与 GID 相同的数字 UID。如果提供了 user 或 groupname，则将使用容器的根文件系统`/etc/passwd`和`/etc/group`文件分别执行从名称到整数 UID 或 GID 的转换。下面的例子展示了`–chown`标志的有效定义：

```dockerfile
COPY --chown=55:mygroup files* /somedir/
COPY --chown=bin files* /somedir/
COPY --chown=1 files* /somedir/
COPY --chown=10:11 files* /somedir/
```

如果容器根文件系统不包含`/etc/passwd`或`/etc/group`文件，并且在`–chown`标志中使用了用户名或组名，那么在添加操作时构建将失败。使用数字 id 不需要查找，也不依赖于容器根文件系统的内容。

>  注意：如果使用 STDIN (`docker build - < somefile`)进行构建，没有构建上下文，因此不能使用`COPY`。 

可选地`COPY`接受一个标志`–from=<name|index>`，该标志可用于将源位置设置到前一个构建阶段(使用`from ..  AS <name>`)，而不是用户发送的构建上下文。该标志还接受为从`FROM`指令开始的所有先前构建阶段分配的数字索引。如果无法找到具有指定名称的构建阶段，则尝试使用具有相同名称的镜像。

`COPY` 遵守下列规则：

- `<src>`必须在构建的上下文中，你不能` ADD ../something /something `，因为 docker 构建的第一步是将上下文目录(和子目录)发送到 docker 守护进程。
- 如果`<src>`是一个目录，则复制目录的全部内容，包括文件系统元数据。

> 注意：目录本身不是复制的，只是它的内容。 

- 如果`<src>`是任何其他类型的文件，它将与元数据一起单独复制。在这种情况下，如果以一个斜杠`/`结尾，它将被认为是一个目录，的内容将写在` <dest>/base(<src>)` 。
- 如果`<src>`直接指定了多个资源，或者由于使用了通配符，那么必须是一个目录，并且必须以斜杠`/`结尾。
- 如果`<src>`没有以斜杠结尾，它将被视为一个常规文件，`<src>`的内容将被写在`<dest>`。
- 如果`<dest>`不存在，它将与路径中所有缺失的目录一起创建。

## ENTRYPOINT

`ENTRYPOINT`有两种格式：

- `ENTRYPOINT ["executable", "param1", "param2"]`：exec 格式，推荐
- `ENTRYPOINT command param1 param2`：shell  格式

`ENTRYPOINT` 允许您配置将作为可执行文件运行的容器。

例如，下面将使用 nginx 的默认内容启动 nginx，监听端口 80 :

```bash
docker run -i -t --rm -p 80:80 nginx
```

`docker run <image>`的命令行参数将追加到 exec 格式的 ENTRYPOINT 的所有元素之后，并将覆盖使用 CMD 指定的所有元素。这允许参数被传递到`ENTRYPOINT`，即，` docker run <image> -d`将把`-d`参数传递给`ENTRYPOINT`。您可以使用`docker run --entrypoint`标志覆盖`ENTRYPOINT`指令。

Shell 格式可防止使用任何`CMD`或`RUN`命令行参数，但有以下缺点：`ENTRYPOINT`将作为`/bin/sh -c`的子命令启动，该子命令不传递信号。 这意味着可执行文件将不是容器的`PID 1`，并且不会接收 Unix 信号，因此您的可执行文件将不会从 `docker stop <container>`接收到`SIGTERM`。

只有 Dockerfile 中的最后一条 `ENTRYPOINT` 指令才会起作用。 

### Exec form ENTRYPOINT 例子

您可以使用`ENTRYPOINT`的 exec 格式来设置默认命令和参数，然后使用`CMD`的任何一种形式来设置更改其他默认值。 

```dockerfile
FROM ubuntu
ENTRYPOINT ["top", "-b"]
CMD ["-c"]
```

当您运行容器时，您可以看到 `top` 是惟一的进程：

```bash
$ docker run -it --rm --name test  top -H
top - 08:25:00 up  7:27,  0 users,  load average: 0.00, 0.01, 0.05
Threads:   1 total,   1 running,   0 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.1 us,  0.1 sy,  0.0 ni, 99.7 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem:   2056668 total,  1616832 used,   439836 free,    99352 buffers
KiB Swap:  1441840 total,        0 used,  1441840 free.  1324440 cached Mem

  PID USER      PR  NI    VIRT    RES    SHR S %CPU %MEM     TIME+ COMMAND
    1 root      20   0   19744   2336   2080 R  0.0  0.1   0:00.04 top
```

要进一步检查结果，可以使用`docker exec `

```bash
$ docker exec -it test ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  2.6  0.1  19752  2352 ?        Ss+  08:24   0:00 top -b -H
root         7  0.0  0.1  15572  2164 ?        R+   08:25   0:00 ps aux
```

您可以使用`docker stop test`优雅地请求`top`关闭。 

下面的 Dockerfile 展示了如何使用`ENTRYPOINT`在前台运行 Apache (即，作为 PID 1) ：

```dockerfile
FROM debian:stable
RUN apt-get update && apt-get install -y --force-yes apache2
EXPOSE 80 443
VOLUME ["/var/www", "/var/log/apache2", "/etc/apache2"]
ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
```

如果需要为单个可执行文件编写启动脚本，可以使用 exec 和 gosu 命令确保最终可执行文件接收到 Unix 信号：

```bash
#!/usr/bin/env bash
set -e

if [ "$1" = 'postgres' ]; then
    chown -R postgres "$PGDATA"

    if [ -z "$(ls -A "$PGDATA")" ]; then
        gosu postgres initdb
    fi

    exec gosu postgres "$@"
fi

exec "$@"
```

最后，如果您需要在关闭时进行一些额外的清理(或与其他容器进行通信)，或者需要协调多个可执行文件，那么您可能需要确保`ENTRYPOINT`脚本接收到 Unix 信号，将它们传递下去，然后执行更多的工作：

```bash
#!/bin/sh
# Note: I've written this using sh so it works in the busybox container too

# USE the trap if you need to also do manual cleanup after the service is stopped,
#     or need to start multiple services in the one container
trap "echo TRAPed signal" HUP INT QUIT TERM

# start service in background here
/usr/sbin/apachectl start

echo "[hit enter key to exit] or run 'docker stop <container>'"
read

# stop service and clean up here
echo "stopping apache"
/usr/sbin/apachectl stop

echo "exited $0"
```

如果您使用 `docker run –rm -p 80:80 –name apache`，那么您可以使用`docker exec`或`docker top`检查容器进程，然后要求脚本停止 apache：

```bash
$ docker exec -it test ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.1  0.0   4448   692 ?        Ss+  00:42   0:00 /bin/sh /run.sh 123 cmd cmd2
root        19  0.0  0.2  71304  4440 ?        Ss   00:42   0:00 /usr/sbin/apache2 -k start
www-data    20  0.2  0.2 360468  6004 ?        Sl   00:42   0:00 /usr/sbin/apache2 -k start
www-data    21  0.2  0.2 360468  6000 ?        Sl   00:42   0:00 /usr/sbin/apache2 -k start
root        81  0.0  0.1  15572  2140 ?        R+   00:44   0:00 ps aux
$ docker top test
PID                 USER                COMMAND
10035               root                {run.sh} /bin/sh /run.sh 123 cmd cmd2
10054               root                /usr/sbin/apache2 -k start
10055               33                  /usr/sbin/apache2 -k start
10056               33                  /usr/sbin/apache2 -k start
$ /usr/bin/time docker stop test
test
real	0m 0.27s
user	0m 0.03s
sys	0m 0.03s
```

> 注意：您可以使用 `--entrypoint`覆盖`ENTRYPOINT`设置,但这只能将二进制设置为 exec(不使用 sh -c) 

> 注意：exec 格式被解析为 JSON 数组，这意味着必须在单词周围使用双引号(“”)，而不是单引号(‘’)。

> 注意：与 shell 格式不同，exec 格式不调用 shell 命令。这意味着不会发生正常的 shell 处理。例如，`RUN ["echo"， "$HOME"]` 不会对`$HOME`执行变量替换。如果您想要 shell 处理，那么要么使用 shell 格式，要么直接执行 shell，例如：`RUN ["sh"， "-c"， "echo $HOME"]`。当使用 exec 格式并直接执行 shell 时，执行环境变量扩展的是 shell，而不是 docker。

### Shell form ENTRYPOINT 例子

您可以为` ENTRYPOINT `指定一个纯字符串，它将在`/bin/sh -c`中执行。此表单将使用 shell 处理来替代 shell 环境变量，并将忽略任何`CMD`或`docker run`命令行参数。要确保 `docker stop`将信号传入长时间运行的 `ENTRYPOINT`  ，你需要通过 exec 启动：

```dockerfile
FROM ubuntu
ENTRYPOINT exec top -b
```

运行该镜像时，您将看到单个`PID 1`进程：

```bash
$ docker run -it --rm --name test top
Mem: 1704520K used, 352148K free, 0K shrd, 0K buff, 140368121167873K cached
CPU:   5% usr   0% sys   0% nic  94% idle   0% io   0% irq   0% sirq
Load average: 0.08 0.03 0.05 2/98 6
  PID  PPID USER     STAT   VSZ %VSZ %CPU COMMAND
    1     0 root     R     3164   0%   0% top -b
```

使用 `docker stop` 停止：

```bash
$ /usr/bin/time docker stop test
test
real	0m 0.20s
user	0m 0.02s
sys	0m 0.04s
```

如果忘记在`ENTRYPOINT`的开头添加 exec：

```dockerfile
FROM ubuntu
ENTRYPOINT top -b
CMD --ignored-param1
```

接着运行它：

```bash
$ docker run -it --name test top --ignored-param2
Mem: 1704184K used, 352484K free, 0K shrd, 0K buff, 140621524238337K cached
CPU:   9% usr   2% sys   0% nic  88% idle   0% io   0% irq   0% sirq
Load average: 0.01 0.02 0.05 2/101 7
  PID  PPID USER     STAT   VSZ %VSZ %CPU COMMAND
    1     0 root     S     3168   0%   0% /bin/sh -c top -b cmd cmd2
    7     1 root     R     3164   0%   0% top -b
```

从 top 的输出可以看出，指定的入口点不是`PID 1`。 

如果您随后运行`docker stop test`，容器将不会干净地退出，`stop`命令将在超时后强制发送一个`SIGKILL`。 

```bash
$ docker exec -it test ps aux
PID   USER     COMMAND
    1 root     /bin/sh -c top -b cmd cmd2
    7 root     top -b
    8 root     ps aux
$ /usr/bin/time docker stop test
test
real	0m 10.19s
user	0m 0.04s
sys	0m 0.03s
```

### 理解 CMD 和 ENTRYPOINT 如何交互 

`CMD`和`ENTRYPOINT`指令都定义了在运行容器时执行什么命令。有一些规则描述他们之间的合作。 

1.  Dockerfile 应该指定至少一个`CMD`或`ENTRYPOINT`命令。 
2.  `ENTRYPOINT`应该定义一个可执行文件。 
3.  `CMD` 应该用作定义`ENTRYPOINT`命令的默认参数或在容器中执行特定命令。
4.  `CMD`将被覆盖在运行带有可选参数的容器时。

这个表格显示了`ENTRYPOINT`和 `CMD`组合使用：

|                                | No ENTRYPOINT              | ENTRYPOINT exec_entry p1_entry | ENTRYPOINT [“exec_entry”, “p1_entry”]          |
| :----------------------------- | :------------------------- | :----------------------------- | :--------------------------------------------- |
| **No CMD**                     | *error, not allowed*       | /bin/sh -c exec_entry p1_entry | exec_entry p1_entry                            |
| **CMD [“exec_cmd”, “p1_cmd”]** | exec_cmd p1_cmd            | /bin/sh -c exec_entry p1_entry | exec_entry p1_entry exec_cmd p1_cmd            |
| **CMD [“p1_cmd”, “p2_cmd”]**   | p1_cmd p2_cmd              | /bin/sh -c exec_entry p1_entry | exec_entry p1_entry p1_cmd p2_cmd              |
| **CMD exec_cmd p1_cmd**        | /bin/sh -c exec_cmd p1_cmd | /bin/sh -c exec_entry p1_entry | exec_entry p1_entry /bin/sh -c exec_cmd p1_cmd |

> 注意：如果`CMD`是从基础镜像定义的，设置`ENTRYPOINT`将把`CMD`重置为空值。在这种情况下，必须在当前映像中重新定义`CMD`才能获得一个值。 

## VOLUME