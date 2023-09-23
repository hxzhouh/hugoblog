---
tags:
  - 反向代理
  - 密码托管
  - docker
categories:
  - blog
description: 
draft: false
Author: hxzhouh
title: 在VPS上搭建vaultwarden
date: 2023-09-23T21:43:28+08:00
lastmod: 2023-09-23T22:20:16+08:00
---
# 在VPS上搭建vaultwarden
之前一直在寻找一个支持跨平台的密码管理工具，先后尝试了 1Password 和 LastPass，迫于贫穷，切换到了开源的 [Bitwarden](https://bitwarden.com/) 支持自托管服务端,但是 [Bitwarden](https://bitwarden.com/) 对性能要求比较高， 退而求其次，用它的另一个实现 [Vaultwarden](https://github.com/dani-garcia/vaultwarden)（原名 Bitwarden_rs） [Vaultwarden](https://github.com/dani-garcia/vaultwarden) 完美兼容[Bitwarden](https://bitwarden.com/) ，这样我们就在AWS 的免费主机上得到了一个  [Vaultwarden](https://github.com/dani-garcia/vaultwarden) 做后端，[Bitwarden](https://bitwarden.com/)做前端的 免费密码托管服务。  
本文详细整理了使用vps 搭建 私有 vaultwarden服务，实现 bitwarden自托管的步骤，设置的内容有：#VPS，#反向代理，rclone 自动挂载Google Drive等。

<!-- more -->
## Vaultwarden 部署
使用docker-compose  部署。
```yaml
version: '3'
services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: always
    ports:
      - 8080:80
      - 3012:3012
    environment:
      ADMIN_TOKEN: V9ZE7sCSfR9hx8Pi3M+GhiBTSG1gag0G
      WEBSOCKET_ENABLED: "true" # Enable WebSocket notifications.
    volumes:
      - /data/vaultwarden/:/data/

  backup:
    #备份服务
    image: ttionya/vaultwarden-backup:latest
    restart: always
    environment:
      CRON: '0 0 * * * ?'
      ZIP_ENABLE: 'TRUE'
      ZIP_PASSWORD: '123456'
      ZIP_TYPE: 'zip'
      BACKUP_FILE_SUFFIX: '%Y%m%d'
      ACKUP_KEEP_DAYS: 7
      #   PING_URL: ''
      MAIL_SMTP_ENABLE: 'TRUE'
      MAIL_SMTP_VARIABLES: '  -S smtp-use-starttls \ -S smtp=smtp://smtp.164.com:587 \ -S smtp-auth=login \ -S smtp-auth-user=email-user \ -S smtp-auth-password=your-auth \ -S from=email-from(Vaultwarden_Backup)'
      MAIL_TO: 'example@gmail.com'
      MAIL_WHEN_SUCCESS: 'FALSE'
      MAIL_WHEN_FAILURE: 'TRUE'
      TIMEZONE: 'Asia/Shanghai'
      DATA_DIR: '/data'
    volumes:
      - /data/vaultwarden/:/data/
      - vaultwarden-rclone-data:/config/
    #   - /path/to/env:/.env

volumes:
  vaultwarden-data:
    name: vaultwarden-data
  vaultwarden-rclone-data:
    external: true
    name: vaultwarden-rclone-data
```
这个docker-compose.yaml 文件包含 了 vaultwarden ，以及vaultwarden-backup 两部分。  
运行这个前，需要设置一下 rclone，这里以 rclone 连接 google drive为例。

> rclone是一款开源的命令行工具，用于在不同云存储服务之间同步、复制和管理文件。它支持多种云存储提供商，包括Google Drive、Dropbox、Amazon S3等，允许用户通过简单的命令实现文件的上传、下载和同步，还提供了加密和缓存等功能，是一个强大的云存储管理工具。

运行 下面的指令，进入配置页面， 参考文章 [vps使用rclone挂载Google Drive详细记录](https://pickstar.today/2022/05/vps%e4%bd%bf%e7%94%a8rclone%e6%8c%82%e8%bd%bdgoogle-drive%e8%af%a6%e7%bb%86%e8%ae%b0%e5%bd%95/)进行设置。
```shell
docker run --rm -it \
  --mount type=volume,source=vaultwarden-rclone-data,target=/config/ \
  ttionya/vaultwarden-backup:latest \
  rclone config
```

然后查看一下配置的内容
```shell
docker run --rm -it \
  --mount type=volume,source=vaultwarden-rclone-data,target=/config/ \
  ttionya/vaultwarden-backup:latest \
  rclone config show
```

![image.png](https://images.hxzhouh.com/blog-images/2023/09/3781bb366cac1dcc520970ff606ff536.png)

这样就好了。

再用docker-compose 启动vaultwarden 以及vaultwarden-backup。

![image.png](https://images.hxzhouh.com/blog-images/2023/09/c79a80b302ac3bbaff32a97b0798ff81.png)

## cloudflare 反向代理
vaultwarden 很多功能依赖 https 实现，所以我们需要给vps:8080端口套一个域名 + 证书，
### 证书
为了方便起见，这里直接使用了 cloudflare 代理域名，同时可以前往 SSL/TLS -> 源服务器下载其生成的主机证书，用来加密 cloudflare 与主机间的通讯。

将私钥与公钥分别保存在 `/etc/nginx/cert/private.key` `/etc/nginx/cert/public.pem`。  
然后再VPS nginx 里面配置
```shell
ubuntu@ip-172-31-20-69:~$ cat /etc/nginx/nginx.conf
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
	worker_connections 768;
	# multi_accept on;
}

http {
	sendfile on;
	tcp_nopush on;
	types_hash_max_size 2048;
	include /etc/nginx/mime.types;
	default_type application/octet-stream;
	ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;
	access_log /var/log/nginx/access.log;
	gzip on;


	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
	server {
    		listen 80;
    		server_name vaultwarden.example.com;
		return 301 https://$host$request_uri;
	}

	# ssl配置

	server {
		listen 443 ssl default_server;
		server_name vaultwarden.example.com;
		ssl_certificate /etc/nginx/cert/public.pem;
		ssl_certificate_key /etc/nginx/cert/private.key;
		location / {
        		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        		proxy_set_header Host $http_host;
        		proxy_set_header X-Real-IP $remote_addr;
        		proxy_set_header Range $http_range;
        		proxy_set_header If-Range $http_if_range;
        		proxy_redirect off;
        		proxy_pass http://127.0.0.1:8080;
    		}
	}
}
```

## 客户端设置
[Bitwarden](https://bitwarden.com/) 客户端支持全平台，包括浏览器。所以 可以把所有的密码都保存到vaultwarden 中来

具体使用 ，请参考 [# Vaultwarden：安全私密的个人密码管理器](https://blog.tsinbei.com/archives/731/#4-4%E3%80%81%E4%BD%BF%E7%94%A8)


---
Enjoy 😄