---
title: Linux 远程服务器免密登录
tags:
  - linux
categories: 
  - 技术
description: 
draft: false
date: 2023-09-22T10:42:13+08:00
lastmod: 2023-09-22T14:54:40+08:00
createAt: 2023-09-22 10:42:13
create_at: 2023-09-22 10:42:13
update_at: 2023-10-30 16:03:42
---
# Linux 远程服务器免密登录

免密登录的原理：通过密钥认证登录，首先在自己的服务器上生成公钥和私钥，其次将公钥上传到远程服务中，在于远程服务器建立连接通信时，远程服务器首先会验证该服务器上是否包含请求服务器的公钥，若不包含则需要远程登录的用户输入密码。
<!-- more -->

免密登录的原理：通过密钥认证登录，首先在自己的服务器上生成公钥和私钥，其次将公钥上传到远程服务中，在于远程服务器建立连接通信时，远程服务器首先会验证该服务器上是否包含请求服务器的公钥，若不包含则需要远程登录的用户输入密码。
## 创建本地密钥对

（如果没有~/.ssh文件夹，则新建一个.ssh文件夹，mkdir ～/.ssh）在本地生成密钥对（公钥与私钥）  
`ssh-keygen -t rsa`

敲下回车后会有三个交互，第一个是文件名，默认是id_rsa，如需修改，自己输入一个文件名即可。第二个与第三个是密码与密码确认，是以后使用该公钥时要输入的密码，一般不设置，如有强烈的安全需求，自己设置即可。最后会生成两个文件id_rsa，id_rsa.pub。以.pub结尾的公钥，另一个是私钥。
## 上传公钥到目标服务器

进入～/.ssh文件夹中有id_rsa（私钥文件）id_rsa.pub(公钥文件)，将公钥文件id_rsa.pub上传到服务器的.ssh/authorized_keys文件中。  
上传  
`scp  ～/.ssh/id_rsa.pub glt@10.112.1.1:~/`  
然后 进入远程服务器，找到上传的id_rsa.pub文件，然后将公钥添加到远程服务器的~/.ssh/authorized_keys 文件中:  
`cat ~/id_rsa.pub >> ~./.ssh/authorized_keys`  
或者直接用ssh-copy-id命令，将文件上传到服务器：  
`ssh-copy-id -i ~/.ssh/id_rsa.pub glt@10.112.1.1

> ssh-copy-id是用来将本地公钥拷贝到远程的authorized_keys文件的脚本命令，它还会将身份标识追加到远程服务器的 `～/.ssh/authorized_keys` 文件中，并给远程主机的用户目录适当的权限。

1. 把专用密钥添加到ssh-agent的高速缓存中：  
`ssh-add`
1. 重启ssh服务  
`service sshd restart`  
或者  
`systemctl  restart  sshd`

6.使用ssh登录远程服务器系统  
`ssh 服务器用户名@服务器地址`  
补充：  
如果上述配置失败。
1. 先在本地配置，配置自身服务器的免密登录，自己连接自己。
2. 检查文件权限

将authorized_keys 文件的权限修改为600： `chmod 600 authorized_keys`  
将 .ssh  文件夹的权限修改为700： `chmod 700  .ssh`

3.查看配置文件sshd_config  :   

vim /etc/ssh/sshd_config
```shell
RSAAuthentication yes        #RSA认证
PubkeyAuthentication yes     #公钥认证
AuthorizedKeysFile .ssh/authorized_keys #公钥认证文件路径
```

如果用root用户有失败的情况，检查PermitRootLogin yes  这个配置选项（注意，这是root用户的远程登录，比较危险）。

4.修改配置文件后，让配置文件生效  
立即生效：source /etc/ssh/sshd_coonfig  
重启ssh服务：sudo /etc/init.d/ssh restart  
## 本地配置免密登录

5.给远程登录配置别名

进入本地机器的目录～/.ssh下找到config文件（若不存在，则创建一个touch config）, 按如下进行配置

```shell
Host  glt                                  # 给远程服务器取一个别名
HostName  10.1.1.1       #目的机器的ip
User username              #ssh登录时的用户名
Port   22                         #ssh所使用的端口，默认是22
IdentityFile  /home/用户名/.ssh/id_rsa.pub     #对应服务器公钥的本地私钥文件路径
```

接下来就可以使用ssh glt   进行远程登录。