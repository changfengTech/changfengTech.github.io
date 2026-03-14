---
title: '基于MF的微前端实践（一）: 搭建项目'
categories: 前端
date: 2026-03-11 21:31:20
cover: https://pic.changfeng.online/blog/202603/26d81ddb9ea417cb6605705fef0f026b.vscode_picgo_1773236152581.png
description: 本文章属于微前端专栏，介绍基于MF的微前端实践。
keywords:
  - 微前端
  - Module Federation
  - 架构
tags: 微前端
top_img: https://pic.changfeng.online/blog/202603/5a2863b85b51a0d367e7a8560687b0f3.vscode_picgo_1773236234123.png
ai: true
---

# 引言

大家好啊，我是`长风`。

你是小阿巴，在一家**互联网大厂做前端开发实习**。

![下载](https://pic.changfeng.online/blog/202603/24ac7c22b39c0ec135edeef41df853cb.%E4%B8%8B%E8%BD%BD.jpeg)

这一天，你的`mentor`给了你一个紧急的任务，让你**重构一个老页面**。原来的老页面在**老仓库**中，并且是用`React`写的，现在要在新的`Monorepo`仓库中用`Vue`来重构该页面。要求`3天`内必须上线。

你评估了一下，发现时间根本不够，`mentor`和你说，`xx组件不用重构，直接引入线上的就行`，只重构其他部分，工作量不大的。

但是要怎么才能保持某个页面中的某个组件不动，只重构其他部分呢？

- 直接在代码仓库中`CV`？不行，一方面，**新老仓库技术栈**不同，`React`的代码没法直接`CV`到`Vue`项目中；另一方面，老仓库中的依赖关系复杂，组件嵌套组件，直接`CV`代码会把老仓库的**屎山拉到新仓库里**。
- 用`iframe`直接嵌套？也不行，`iframe`虽然能够较好地实现**应用隔离**，但是会有以下问题：
  - 不同`iframe`之间通信只能用`window.postMessage`这种原始`API`，没有类型，需要自己维护协议，调试也非常困难。
  - 路由无法统一，刷新会丢失状态，深链接困难。
  - 性能差，每个`ifram`都要加载自己依赖的第三方库，哪怕不同的`iframe`间，有的库是共用的。

难道就要就此认输吗？难道就毫无办法了吗？

![images](https://pic.changfeng.online/blog/202603/eba372133baca6e8c31f19094fdaed92.images.png)

突然，你灵光乍现，火光冲天，醍醐灌顶，一飞冲天（好了，编不下去了。。。😋）

![main](https://pic.changfeng.online/blog/202603/678e3cbc611d681e37e0623bddaf8230.main.png)

对，就是**微前端**，这个你之前看到过的技术方案，好像就是专门用来解决这种复杂大型应用的问题的。那我们就一起来看一下，如何通过`Module Federation(MF)`来实现微前端。

> 本文属于专栏[基于 MF 的微前端实践](https://juejin.cn/column/7615915954712231976)系列文章，`长风`会在该专栏详细记录基于 `MF`来实践微前端架构的过程，欢迎各位读者**订阅，点赞，加关注**，👍🏻👍🏻👍🏻

# 什么是`Module Federation`

`Module Federation`是一种`JavaScript`应用分治的架构模式（类似于服务端的微服务），它允许你在多个`JavaScript`应用程序（或微前端）之间**共享代码和资源**。这可以帮助你：

- 减少代码重复
- 提高代码可维护性
- 降低应用程序整体大小
- 提高应用程序的性能

这使得可以创建微前端风格的应用程序，多个系统可以共享代码，并在不需要重新构建整个应用程序的情况下进行动态更新。

## 什么是`Module Federation 2.0`

与`Webpack 5`内置的`Module Federation`相比，`Module Federation 2.0`除了支持原有的模块导出，模块加载和依赖共享等核心功能，还新增了：

- 动态类型提示
- `Manifest`
- `Federation Runtime`
- `Runtime Plugin System`
- `Chrome Devtool`

等特性。这些增强功能使得`Module Federation 2.0`更加适合作为构建和管理大型`Web`应用的微前端架构标准。

# Demo快速上手

## 设置环境

首先使用`fnm`或`nvm`安装`20`及以上的`LTS`的`Node`。

```bash
# fnm 安装node20
fnm install 20
# 或者nvm install 20
```

在使用过程总，我们要遵循以下步骤：

> - 识别共享模块：确定要在应用程序之间共享的模块。
> - 创建共享包/仓库：将这些模块添加到共享包或代码仓库中。
> - 确保访问权限：确保每个应用程序都可以访问共享包或代码仓库。
> - 配置构建插件：配置每个应用程序的`Webpack`，`Rspack`配置文件以使用`Module Federation`
> - 使用共享模块：根据需要在应用程序中使用共享模块。

## 新项目创建

你可以使用`create-module-federation`脚手架来创建一个`Module Federation`项目，调用以下命令：

```bash
pnpm create module-federation@latest
```

然后再`CLI`中进行交互式地选择，这里你可以先创建一个消费者`Consumer`。

![image-20260312113332627](https://pic.changfeng.online/blog/202603/57172fde7b2f72c0065f3e90006caf79.image-20260312113332627.png)

根据`Next steps`的提示进行安装后，进入项目。根目录下会有一个`module-federation.config.ts`的配置文件，如下图：

![image-20260312115418376](https://pic.changfeng.online/blog/202603/1c79328f01736a50ea20c37e30e8fbb4.image-20260312115418376.png)

这里已经提前给你配置了一个生产者`provider`，是一个`https://unpkg.com`提供的远程组件。

注意这里在`remote`对象中，配置的远程组件的字段名叫`provider`，所以在下面的`App.tsx`中使用的时候，要从`provider`中导入：

![image-20260312115909164](https://pic.changfeng.online/blog/202603/fa5d466fc10c5ea07b69b06b937517bc.image-20260312115909164.png)

> 这个名称是给远程模块命名的**本地别名**，可以任意自定义，不一定非得是`provider`，但是在`module-federation.config.ts`中的`remote`对象中配置的字段名要和在`App.tsx`中导入的包名一致。

这里提到了两个概念`生产者`和`消费者`。

> 顾名思义，
>
> 所谓生产者，指的是通过`Module Federation`构建插件设置了`exposes`暴露某些模块给**其他`JavaScript`应用**消费的应用，即`Provider`，注意，生产者同时也可以作为一个消费者去消费其他生产者提供的模块。
>
> 所谓消费者，指的是通过`Module Federation`构建插件设置了`remotes`消费其他生产者的模块的应用，即`Comsumer`，同理，消费者同时也可以作为一个生产者。

在`module-federation.config.ts`中的相关配置，要通过`plugin`导入到项目对应的`bundler`（如`webpack, rsbuild, vite`等）中，才能生效。

示例项目，采用的是`rsbuild`进行构建，所以，`rsbuild.config.ts`文件如下：

```ts
// rsbuild.config.ts
import { defineConfig } from '@rsbuild/core';
import { pluginReact } from '@rsbuild/plugin-react';
import { pluginModuleFederation } from '@module-federation/rsbuild-plugin';
import moduleFederationConfig from './module-federation.config';

export default defineConfig({
  plugins: [pluginReact(), pluginModuleFederation(moduleFederationConfig)],
});
```

# 调试

## 开启调试模式

为了便于排查问题，`Module Federation`提供了调试模型，你可以在执行构建时添加`FEDERATION_DEBUG=true`环境变量或者在浏览器执行`localStorege.setItem('FEDERATION_DEBUG', 'true')`来开启`Module Federation`的调试模式。

在构建时添加环境变量可以使用最简单的命令行参数方式：

```bash
# 调试开发模式
FEDERATION_DEBUG=true pnpm dev

# 调试生成模式
FEDERATION_DEBUG=true pnpm build
```

也可以在`package.json`中，添加一个自定义的脚本：

![image-20260312141545919](https://pic.changfeng.online/blog/202603/7d022e3bd7c9fad4fc81c1a277ce1c41.image-20260312141545919.png)

这样后续只需要运行`pnpm debug`即可开启调试模式。

运行时添加环境变量，则直接在控制台执行以下代码即可：

```js
localStorage.setItem('FEDERATION_DEBUG', 'true');
```

可以进行相关测试，未开启调试模式时，启动应用，`terminal`输出如下：

![image-20260312142328403](https://pic.changfeng.online/blog/202603/96440211d2ddaa026250b955c7abd495.image-20260312142328403.png)

开启调试模式后，控制台输出如下：

![image-20260312142501345](https://pic.changfeng.online/blog/202603/f3c00066efe7854a33bb4714ee54a263.image-20260312142501345.png)

这里给出了很多以`[Module Federation]`开头的调试信息，包括开始拉取远程类型，构建等步骤的耗时以及详细的调用栈信息，方便你排查问题。

## Chrome Devtool

`微前端`架构不同于传统的单体应用的开发模式，其分开开发，部署，调试的特征使其需需要一套新的调试工具来满足新的使用场景，比如：

- 在开发`Module Federation`时怎么验证模块在实际项目中的效果
- `Module Federation`的依赖是否和宿主环境进行了复用
- 当前页面加载了哪些`Module Federation`
- `Module Federation`的依赖关系
- `Module Federation`间的数据流转是怎么样的

`Chrome Devtool`提供了以下能力：

- 支持`Module Federation`代理功能，将线上页面中的`Module Federation`代理到用户本地的`Module Federation`
- 切换线上页面`Module Federation`版本，来进行快速的功能验证
- 支持查看模块依赖信息
- 支持筛选特定依赖模块的信息

> **关于 Chrome Devtool 的限制：**
>
> 必须使用`mf-manifest.json`才可以使用`Chrome devtool`提供的可视化和代理能力

### 使用场景

`DevTools` 提供了多个功能面板，适用于开发环境以及生产环境的不同调试需求：

- **Proxy(代理)**：用于将线上或测试环境的模块代理的本地开发环境
  - 支持本地服务端口号，例如 `key: appA -> value`: `http://localhost:3000/mf-manifest.json`，页面将直接加载`3000`端口的`Module Federation`内容。
  - 支持使用 `mf-manifest.json`文件地址形式，例如 `key: appA -> value`: `https://xxx/static/mf-manifest.json`，页面将加载指定地址的 `Module Federation`内容。
- **Module Info(模块信息)**：用于查看当前页面加载的所有 `Federation` 模块的详细信息系，包括版本，入口地址等。
- **Dependency Graph(依赖关系图)**：以可视化的方式展示模块之间的依赖引用关系，帮助理清复杂的微前端架构。
- **Shared(共享依赖)**：深入分析 `Shared Dependencies` 的使用情况。
  - 查看已加载和未加载的共享依赖
  - 分析共享依赖的版本复用情况（Loaded / Reused）
  - 检查单例（Singleton）、严格版本（Strict Version）等配置的生效状态。

### 如何安装

打开 [Module Federation 插件详情页](https://chromewebstore.google.com/detail/module-federation/aeoilchhomapofiopejjlecddfldpeom?hl=zh-CN&utm_source=ext_sidebar), 点击 `添加到 Chrome` 按钮

![img](https://pic.changfeng.online/blog/202603/f4288d654091c2f956a94c727ff78cfb.chrome-store-add-devtool.c275e2c67d.png)

### 如何使用

插件提供了 Devtools 面板

- F12 打开开发者工具，选择点击 `Module Federation` tab，进入代理页面，便可对依赖的模块进行代理调试

![img](https://pic.changfeng.online/blog/202603/00a5850f06d6989e1d8cc5b7acd9db33.launch-devtool.jpg)

### 整体交互

如下图所示，代理页面（ `Proxy` 选项卡上提供了 `add new proxy module`，`producer selector`，`version or local port or custom entry`等选项操作。

- 通过选择 `producer selector` 选择出目标页面需要代理的一个模块；
- 通过 `version or local prot` 选择或者输入指定的地址（包括端口号和 `mf-manifest.json` 结尾的地址），进行代理操作；
- 如果需要同时代理多个模块，点击 `add nnew proxy module` 区域，增加对应的代理模块。
- **支持多 Tab 隔离**：在多个标签页中同时打开使用了 `Module Federation` 的页面时，每个 Tab 的代理规则和模块信息都是相互独立的。你在 Tab A 中设置的代理规则不会影响 Tab B，反之亦然。这允许你同时调试多个环境或应用状态。

![img](https://pic.changfeng.online/blog/202603/f6f007f88be227f7b5d5344a69a2b790.proxy.png)

### 如何将本地开发的模块代理到线上

- 首先需要在本地启动生产者

![img](https://pic.changfeng.online/blog/202603/e78eb378a29ce1b68d5f10a2496ab4aa.dev-to-proxy.af466b0ae8.png)

- 然后将启动成功的 `manifest` 地址，输入到代理页面的版本选择输入框内
- 之后调整本地的生产者代码，消费者页面将会自动 `Reload`

![img](https://pic.changfeng.online/blog/202603/fd6ea0864a1aec427bee2522b1832887.proxy-to-local.b699c14d00.png)

# 总结

本文从一个日常开发中的问题引入，**如何在重构过程中复用线上应用的部分组件**，介绍了`Module Federation`的相关概念，同时给出了一个快速上手的 `Demo` 搭建步骤，并总结了调试的相关方法，特别是 `Chrome Devtool` 的使用方法。希望通过本文能够使读者对`微前端`和`MF`有一个宏观的认识和了解，并能够通过 `Demo` 验证相关概念。

在本专栏下一篇文章中，我们会在本地再创建一个消费者的 `Demo`，并进行代理调试，感兴趣的读者，欢迎订阅👏🏻👏🏻👏🏻。

好了，这篇文章就到这里啦，如果对您有所帮助，欢迎`点赞,收藏,分享👍👍👍`。您的认可是我更新的最大动力。由于笔者水平有限，难免有疏漏不足之处，欢迎各位大佬评论区指正。

> 本文属于专栏[基于 MF 的微前端实践](https://juejin.cn/column/7615915954712231976)系列文章，`长风`会在该专栏详细记录基于 `MF`来实践微前端架构的过程，欢迎各位读者**订阅，点赞，加关注**，👍🏻👍🏻👍🏻

> 往期推荐✨✨✨
>
> - [从0到1搭一个monorepo项目（一）](https://juejin.cn/post/7562097702891061274)
> - [从零到一开发一个Chrome插件（一）](https://juejin.cn/post/7544202006890758183)
> - [CJS和ESM两种模块化标准的异同分析](https://juejin.cn/post/7473814041867780130)
> - [🤔5202年了，你不会还不知道WebAssembly吧？](https://juejin.cn/post/7498988293209784374)
> - [🚀🚀🚀实在受不了混乱的提交——我使用了commitlint和commitizen](https://juejin.cn/post/7508919522905522226)
> - [当我用deepwiki来学习React源码](https://juejin.cn/post/7514876424806334504)
> - [【🚀🚀🚀代码随想录刷题总结】leetcode707-设计链表](https://juejin.cn/post/7519769941501165631)

我是`长风`，我们下期见！
