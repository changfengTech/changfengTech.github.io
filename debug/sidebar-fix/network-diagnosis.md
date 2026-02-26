# 网络诊断 - CloudFront CDN 问题

## 📊 收集到的响应头信息

```
access-control-allow-origin: *
content-length: 74
content-type: text/plain
date: Thu, 26 Feb 2026 11:24:31 GMT
server: nginx/1.21.6
via: 1.1 83fa2b0fcfdd33500c450580584dd080.cloudfront.net (CloudFront)
x-amz-cf-id: 6w_UWZmNTEpKJKaKfj9rk4fskLN3lP7UWEE2cMOCwH-emEhBO_XejQ==
x-amz-cf-pop: HKG54-P2
x-cache: Error from cloudfront
```

## 🔍 问题分析

### 1. CloudFront 缓存错误
```
x-cache: Error from cloudfront
```
- CloudFront 返回了错误
- 可能是源服务器返回了错误响应
- 可能是 CloudFront 配置问题

### 2. 地理位置信息
```
x-amz-cf-pop: HKG54-P2
```
- 请求来自香港 CloudFront 节点
- 这是正常的（你在中国）

### 3. CORS 配置
```
access-control-allow-origin: *
```
- 允许所有来源的跨域请求
- 这是正确的配置

## 🎯 可能的原因

### 原因 1: 源服务器错误
- GitHub Pages 返回了错误响应
- CloudFront 缓存了这个错误

### 原因 2: 特定资源加载失败
- 某个 CSS、JS 或图片文件返回 404
- CloudFront 缓存了 404 错误

### 原因 3: 超时问题
- 源服务器响应超时
- CloudFront 返回错误

## 🛠️ 诊断步骤

### 步骤 1: 检查具体是哪个资源出错

打开浏览器开发者工具 (F12)，切换到 "Network" 标签：

1. 刷新页面
2. 查看所有请求的状态码
3. 找出状态码为 4xx 或 5xx 的请求
4. 特别注意：
   - CSS 文件 (css/index.css)
   - JavaScript 文件 (js/main.js)
   - 图片文件 (头像、二维码等)

### 步骤 2: 检查 CloudFront 缓存

```bash
# 查看响应头中的缓存信息
curl -I https://blog.changfeng.online/

# 查看特定资源的缓存状态
curl -I https://blog.changfeng.online/css/index.css
curl -I https://blog.changfeng.online/js/main.js
```

### 步骤 3: 清理 CloudFront 缓存

如果你有 AWS 账户和 CloudFront 分布：

1. 进入 AWS CloudFront 控制台
2. 找到你的分布
3. 创建 Invalidation（失效）
4. 输入路径：`/*`
5. 等待失效完成（通常 1-5 分钟）

### 步骤 4: 检查 GitHub Pages 状态

```bash
# 直接访问 GitHub Pages（绕过 CloudFront）
curl -I https://changfengtech.github.io/

# 检查特定资源
curl -I https://changfengtech.github.io/css/index.css
```

## 📋 检查清单

- [ ] 打开浏览器开发者工具 (F12)
- [ ] 切换到 "Network" 标签
- [ ] 刷新页面
- [ ] 查看是否有 4xx 或 5xx 错误
- [ ] 记录失败的资源 URL
- [ ] 检查 CloudFront 缓存状态
- [ ] 如果需要，清理 CloudFront 缓存

## 🔧 解决方案

### 方案 A: 清理 CloudFront 缓存（推荐）

如果你有 AWS 账户：

1. 进入 [AWS CloudFront 控制台](https://console.aws.amazon.com/cloudfront/)
2. 选择你的分布
3. 点击 "Invalidations" 标签
4. 点击 "Create invalidation"
5. 输入 `/*` 清理所有缓存
6. 点击 "Create invalidation"
7. 等待完成

### 方案 B: 等待缓存过期

CloudFront 默认缓存时间：
- 通常 24 小时
- 可能更短（取决于你的配置）

### 方案 C: 强制刷新浏览器

```
Windows/Linux: Ctrl + F5
Mac: Cmd + Shift + R
```

## 📞 需要帮助？

如果问题仍未解决：

1. 运行诊断命令：
   ```bash
   curl -I https://blog.changfeng.online/
   curl -I https://blog.changfeng.online/css/index.css
   curl -I https://blog.changfeng.online/js/main.js
   ```

2. 检查浏览器开发者工具中的网络请求

3. 查看 GitHub Pages 的部署状态

4. 检查 CloudFront 的缓存设置

## 💡 预防措施

为了避免将来出现类似问题：

1. **配置 CloudFront 缓存策略**
   - 为 HTML 文件设置较短的 TTL（比如 5 分钟）
   - 为静态资源设置较长的 TTL（比如 1 天）

2. **监控 CloudFront 错误**
   - 启用 CloudFront 日志
   - 定期检查错误率

3. **自动清理缓存**
   - 在 GitHub Actions 中添加清理 CloudFront 缓存的步骤
   - 每次部署后自动失效缓存

4. **使用版本化的资源**
   - 为 CSS 和 JS 文件添加版本号
   - 这样可以避免缓存问题
