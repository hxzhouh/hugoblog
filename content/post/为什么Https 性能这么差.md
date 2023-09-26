---
tags:
  - 为什么这么设计
  - https
  - tls
categories:
  - blog
description: 
draft: true
Author: hxzhouh
createAt: 2023-03-21 14:03:34
---
HTTP 协议（Hypertext Transfer Protocol）已经成为互联网上最常用的应用层协议，然而其本身只是用于传输超文本的网络协议，不会提供任何安全上的保证，使用明文在互联网上传输数据包使得窃听和中间人攻击成为可能，通过 HTTP 传输密码其实与在互联网上裸奔也差不多。  
HTTPS 是对 HTTP 协议的扩展，我们可以使用它在互联网上安全地传输数据，然而 HTTPS 请求的发起方第一次从接收方获取响应需要经过 4.5 倍的往返延迟（Round-Trip Time，RTT）以及7次握手，这就是Https 协议性能差的原因。
<!-- more -->

