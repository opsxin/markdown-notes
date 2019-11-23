# Git 快速参考手册

[TOC]

## 预准备仓库

### 初始化仓库

```bash
git init
```

在当前目录创建新的空仓库

### 克隆仓库

```bash
git clone <URL> [dir]
```

## 配置

### 显示配置

```bash
git config --list
```

显示当前的配置

### 设置用户名

```bash
git config user.name <name>
```

### 设置用户 Email

```bash
git config user.email <email>
```

### Unix/Win EOL 转换

```bash
git config core.autocrlf true
```

自动转换 unix 和 Win 在提交（commit）和 检出（checkout）的行未 EOF（CRLF 和 LF）问题

### 只在保存时转换 EOL

```bash
git config core.autoclrlf input
```

只在提交时转换 CRLF 到 LF，检出不变

### 改变默认编辑器

```bash
git config core.editor <editor_name>
```

### 获取配置

```bash
git config --get <config-name>
```

### 取消设置的配置

```bash
git config --unset <config-name>
```

### 配置影响范围

```bash
git config [--system | --global] <name> <value>
```

- system：系统级别
- global：用户级别
- local：repo 级别

## 操作仓库

### 显示当前状态

```bash
git status
```

显示工作目录状态，哪些文件修改过

### 添加文件索引

```bash
git add <file>
```

在提交前，添加文件或路径的索引

### 添加修改的文件

```bash
git add -u
```

修改过的文件添加索引，不会在新增的文件上添加索引

### 移除文件索引

```bash
git reset -- <file>
```

移除文件索引，当前目录的文件修改内容不受影响

### 丢弃修改

```bash
git checkout -- <file>
```

丢弃修改，还原索引

### 删除文件

```bash
git rm <file>
```

### 提交修改

```bash
git commit -m <message>
```

### 修改提交

```bash
git commit --amend
```

修改最后一次提交的信息

### 重置作者

```bash
git commit --amend --reset-author
```

### 修改作者

```bash
git commit --amend --author=<name <email>>
```

### 修改提交时间

```bash
git commit --amend --data=<data>
```

### 显示提交日志

```bash
git log [-n <num>]
```

### 显示短日志

```bash
git shortlog
```

### 显示短日志总数

```bash
git shortlog -s
```

### 当前工作目录和分支的区别

```bash
git diff <branch-name>
```

### 分支之间的不同

```bash
git diff <branch-1> <branch-2>
```

### 删除没有追踪过的文件

```bash
git clean -n
```

提示哪些文件会删除，但不会真正的删除文件

### 交互移除

```bash
git clean -i
```

## 分支管理

### 列出分支

```bash
git beanch [--list]
```

### 列出远程追踪的分支

```bash
git branch -r
```

### 列出分支和提交信息

```bash
git branch -v
```

### 通过提交时间排序分支

```bash
git branch -v --short=committerdate
```

### 列出所有分支

```bash
git branch -a
```

### 删除分支

```bash
git branch -d <branch-name>
```

### 强制删除分支

```bash
git branch -D <branch-name>
```

### 合并分支

```bash
git merge <branch>
```

### 合并使用合并的提交信息

```bash
git merge --no-ff <branch>
```

不使用 `fast-forward` 方式合并，保留分支的 commit 历史

### 交互式变基

```bash
git rebase -i <branch>
```

## Tag 管理

### 列出 Tags

```bash
git tag
```

### 添加 Tag

```bash
git tag <tag-name>
```

### 删除 Tag

```bash
git tag -d <tag-name>
```

## 存储工作目录

### 暂存当前工作目录

```bash
git stash save
```

保存当前工作目录的状态和清理工作目录

### 列出已暂存信息

```bash
git stash list
```

### 还原最后一次暂存

```bash
git stash pop
```

### 移除最后一次暂存

```bash
git stash drop
```

### 清理暂存区

```bash
git stash clear
```

## 远程仓库

### 显示远程仓库

```bash
git remote -v
```

### 添加远程仓库

```bash
git remote add <remote-name> <url>
```

### Push 分支到远程

```bash
git push <remote-name> <branch-name>
```

### 删除远程分支

```bash
git push --delete <remote-name> <>branch-name
```

### Push Tag

```bash
git push <remote-name> <tag-name>
```

### Push 所有 Tag

```bash
git push --tags <remote-name>
```

### 删除远程 Tag

```bash
git push --delete <remote-name> <tag-name>
```

### 从远程取出（fetch）

```bash
git fetch <remote-name>
```

更新远程追踪的分支，不自动和本地分支合并

### 从远处拉取（pull）

```bash
git pull <remote-name> <branch-name>
```

自动和本地分支合并

## 仓库保养

### 优化仓库

```bash
git gc
```

移除不必要的文件和引用

### 校验仓库

```bash
git fsck
```
