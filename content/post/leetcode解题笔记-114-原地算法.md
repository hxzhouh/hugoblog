---
title: leetcode解题笔记-114-原地算法
date: 2020-03-24T11:55:43+08:00
tags: ["算法","leetCode"]
categories: ["leetCode"]
lastmod: 2023-09-22T14:46:20+08:00
createAt: 2022-09-30 15:14:57
---

>In [computer science](https://en.wikipedia.org/wiki/Computer_science), an **in-place algorithm** is an [algorithm](https://en.wikipedia.org/wiki/Algorithm) which transforms input using no auxiliary [data structure](https://en.wikipedia.org/wiki/Data_structure). However a small amount of extra storage space is allowed for auxiliary variables. The input is usually overwritten by the output as the algorithm executes. In-place algorithm updates input sequence only through replacement or swapping of elements. An algorithm which is not in-place is sometimes called **not-in-place** or **out-of-place**.——摘自[原地算法](https://en.wikipedia.org/wiki/In-place_algorithm)的维基百科

一句话总结就是: 原地算法不依赖额外的资源或者依赖少数的额外资源，仅依靠输出来覆盖输入的一种算法操作。

# 原理

假设要将具有 *n* 项内容的数组 a 翻转过来。一种看似简单的方法是创建一个大小相等的新数组，用适当的顺序填充副本，然后再删除：

```python
function reverse(a[0..n-1])
     allocate b[0..n-1]  # 额外设定一个数组
     for i from 0 to n-1 # 从 0 到 n-1 遍历数组 a
         b[n -1 - i] := a[i] 
     return b
```

这种方法虽然简单，但是需要 O(n) 的额外空间以使数组 a 和 b 同时可用。此外，分配存储空间和释放存储空间通常是缓慢的操作。如果我们不再需要数组 a 的话，可使用原地算法，用它自己翻转的内容来覆盖掉原先的内容。这样，无论数组有多大，它都只需要辅助变量 i 和 tmp：

```python
 function reverse_in_place(a[0..n-1])
     for i from 0 to floor((n-2)/2)
         tmp := a[i]
         a[i] := a[n − 1 − i]
         a[n − 1 − i] := tmp
```

这样既节省了存储器空间又加快了运算速度。



example:

[leetCode 114](https://leetcode-cn.com/problems/flatten-binary-tree-to-linked-list/)

go 实现

``` go
func flatten(root *TreeNode)  {
	if root == nil {
		return
	}
	flatten(root.Left)
	flatten(root.Right)
	temp := root.Right
	root.Right = root.Left
	root.Left = nil
	for root.Right != nil {
		root = root.Right
	}
	root.Right = temp
}
```

其实就是使用前序遍历把右边的树节点移动到左边

第一趟，处理的节点为3，保持不变

第二趟，处理节点 4 保持不变

第三趟，处理节点2 需要把 节点3移动到2的右节点，然后把4 移动到2的最右的右节点



![](https://blog-image-1253555052.cos.ap-guangzhou.myqcloud.com/20200324161451.png)

![](https://blog-image-1253555052.cos.ap-guangzhou.myqcloud.com/20200324161514.png)

第四趟：处理节点6，不变。

第五趟处理节点 5 不变，

第六趟处理节点1 需要把 2 移动到 1 的右节点，然后把 5 移动到 1的最右右节点。

![](https://blog-image-1253555052.cos.ap-guangzhou.myqcloud.com/20200324161751.png)

![](https://blog-image-1253555052.cos.ap-guangzhou.myqcloud.com/20200324161823.png)

到此，移动完毕，全程只用了一个变量temp。满足原地算法。