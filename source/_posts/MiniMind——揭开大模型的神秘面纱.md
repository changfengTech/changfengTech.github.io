---
title: MiniMind——揭开大模型的神秘面纱
categories: AI
ai: true
date: 2026-03-14 15:46:42
cover: https://pic.changfeng.online/blog/202603/a62bbdfb4eaf4fbf657a8c9fe53046b9.vscode_picgo_1773474808610.png
description: 记录通过 MiniMind 学习 LLM 生命周期的过程
keywords: AI, LLM, MiniMind
tags: LLM
top_img: https://pic.changfeng.online/blog/202603/a62bbdfb4eaf4fbf657a8c9fe53046b9.vscode_picgo_1773474808610.png
---

# 引言

AI 时代的浪潮浩浩汤汤，对于我们传统的软件工程师也有了新时代的能力要求。因此，学习 AI，拥抱 AI，对于我们任何一个人都非常重要。作为一名前端工程师，学习 AI，LLM，Agent 等相关的知识已经不是可选项，而是必选项。本文会通过 `MiniMind` 搞清楚 `LLM` 内部到底在干什么，让`LLM`对于我们应用工程师来说，不在是一个黑盒。

# 什么是 `MiniMind`

[MiniMind Github 地址](https://github.com/jingyaogong/minimind)

`MiniMind` 是一个**开源的小型 GPT 类语言模型项目，最小版本只有约 `26M` 参数（0.026B），可以在普通电脑上进行训练和运行。

特点是：
- 2 小时即可训练一个 GPT 模型
- 成本约 3 元人民币
- 提供 **完成 LLM 训练流程代码**
  - 预训练（Pretrain）
  - 监督微调（SFT）
  - LoRA 微调
  - 强化学习（RLHF / DPO）
  - 模型蒸馏
  - 推理部署

# 为什么需要 `MiniMind`

只有一句话，让**个人电脑也能体验训练 LLM 的全流程**。

用该项目作者在 `README.md` 中提到的话来说：

> “用乐高拼出一架飞机，远比坐在头等舱里飞行更让人兴奋！”

# 怎么使用 `MiniMind`

具体教程可以参考 [MiniMind 官方文档](https://github.com/jingyaogong/minimind)

## 快速开始

> 由于本文面向有一定开发基础的读者，所以基础的环境配置，如 `git`，`python` 等不再赘述，可自行搜索。

```bash
# 拉取项目

git clone https://github.com/jingyaogong/minimind.git

# 创建虚拟环境
python -m venv .venv

# 激活虚拟环境
source .venv/bin/activate

# 安装依赖
pip install -r requirements.txt

# 用 MiniMind2 做测试
python eval_llm.py --load_from jingyaogong/MiniMind2
```
选择 `0` 进行自动测试，就会测试代码里面的 `prompts` 示例。

![image](https://pic.changfeng.online/blog/202603/6079d4fa94c3e2fb63531cdc776bd055.vscode_picgo_1773482640242.png)

# 训练过程

## Tokenizer

## Pretrain

## SFT

## RLHF

## Reason

