---
title: Obsidian 最佳实践
date: 2023-09-24T08:26:01+08:00
lastmod: 2023-09-24T08:26:03+08:00
draft: true
categories:
  - 随笔
create_at: 2023-09-24 08:26:01
update_at: 2023-11-08 10:05:25
---
# Obsidian 最佳实践
#obsidian

# 我用Obsidian 来做什么？

## 写博客 
我的[blog](https://blog.hxzhouh.com/) 是用Hugo 编译， 托管在Cloudflare 上面的，具体托管教程请参考：[Deploy a Hugo site](https://developers.cloudflare.com/pages/framework-guides/deploy-a-hugo-site/) obsidian再中间的作用就是 管理文章了。我用软链接将 hugo 目录里面的content 连接到 obsidian 的目录，然后配合 插件 QuickAdd & Template 插件，很方便的就添加一个新的博客。  
写完博客后，用Raycast 触发一下push（脚本），这样就搞定了。。

## 使用简悦记录网络内容
## 本地日记本。
https://github.com/Kenshin/simpread/discussions/3807

# 一些小技巧
## 特定文件夹自动使用某个模板。


# 正在使用的插件 

- [Natural Language Dates](https://github.com/argenos/nldates-obsidian) 方便的输入时间，具体请参考 GitHub主页，后面一些自动化功能都是基于 [Natural Language Dates](https://github.com/argenos/nldates-obsidian) 实现
- [Linter](https://github.com/platers/obsidian-linter)：一个自动格式化工具，可以实现诸如自动添加创建时间 、更新时间到metadata，自动纠错等功能。很强大，也比较复杂，可以尝试了解一下