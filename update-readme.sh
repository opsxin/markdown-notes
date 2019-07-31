#!/bin/bash

# 不显示 PNG、png、gif、GIF 格式的文件，最大深度为3层
tree -I "*.png|*.gif" -v -L 3 --ignore-case | awk 'BEGIN{print "```bash"} {print} END{print "```"}' > README.md
