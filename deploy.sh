#!/bin/bash
# 部署到 github pages 脚本
# 错误时终止脚本
set -e
# 删除旧数据,
#rm /d/me/hugo-bolg/content/post/*
#cp /d/和彩云同步文件夹/13689512015/blog/go/* /d/me/hugo-bolg/content/post/
#cp /d/和彩云同步文件夹/13689512015/blog/redis/* /d/me/hugo-bolg/content/post/
#cp /d/和彩云同步文件夹/13689512015/blog/算法/* /d/me/hugo-bolg/content/post/
#cp /d/和彩云同步文件夹/13689512015/blog/arts/* /d/me/hugo-bolg/content/post/

# 删除打包文件夹
#rm -rf public

# 打包。even 是主题
#hugo -t even # if using a theme, replace with `hugo -t <YOURTHEME>`
# 进入打包文件夹
git pull 
git add -A
# Commit changes.
msg="building site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# 推送到gitee  
git push --set-upstream origin master

# 删除打包文件夹
#rm -rf public
# 清理
#hugo --gc
# 打包。even 是主题
#hugo -t even # if using a theme, replace with `hugo -t <YOURTHEME>`

# 进入打包文件夹
#cd public

# Add changes to git.

#git init
#git add -A

# Commit changes.
#msg="building site `date`"
#if [ $# -eq 1 ]
#  then msg="$1"
#fi
#git commit -m "$msg"

# 推送到githu  
# nusr.github.io 只能使用 master分支
#git push -f git@github.com:hxzhouh/hxzhouh.github.io.git master

# 回到原文件夹
#cd ..

# 清理
#hugo --gc

# 打包。even 是主题
#hugo -t even # if using a theme, replace with `hugo -t <YOURTHEME>`
