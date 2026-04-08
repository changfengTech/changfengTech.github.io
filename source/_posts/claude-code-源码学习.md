---
title: claude code 源码学习
categories: AI
ai: true
date: 2026-04-07 13:12:02
cover: https://pic.changfeng.online/blog/202604/a61f60c2cda4cac34ae935e9fd04f5e4.vscode_picgo_1775538788376.png
description: 基于 cc-haha 项目对 claude code 源码进行学习
keywords: AI, claude code, 源码学习
tags: agent
top_img: https://pic.changfeng.online/blog/202604/32836780ec6653d1017aeed9f3c925eb.vscode_picgo_1775538883348.png
---

# 引言

2026-03-31，Anthropic 在发布 Claude Code 新版本 npm 包时，**误把 source map 文件一起打包上传**。全网出现大量镜像并传播，本着学习和研究的目的，通过 `cc-haha` 项目学习 agent 相关的知识。

在 `deepwiki` 中可以直接学习 `cc-haha` 项目的源码：https://deepwiki.com/NanmiCoder/cc-haha

# 系统架构

![image](https://pic.changfeng.online/blog/202604/af69e83db1a77dbf248353e62aea57eb.vscode_picgo_1775542990433.png)

整个流程可以总结如下：

1. 用户输入命令
2. CLI 入口解析命令
3. Commander.js 将解析后的命令转发的 `REPL（Read Eval Print Loop）`
4. QueryEngine 分析输入
5. 决定
   - 调用本地工具
   - 调用 LLM 的 API
6. 返回结果，循环等待下一条输入

通过这样的架构方式，实现了`读取-执行-输出-读取`的循环。

