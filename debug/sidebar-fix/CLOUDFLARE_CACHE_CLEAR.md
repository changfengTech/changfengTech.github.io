# Cloudflare 缓存清理指南

## 🎯 发现

你的网站使用的是 **Cloudflare CDN**，而不是 AWS CloudFront！

### 诊断结果

```
Server: cloudflare
Via: 1.1 varnish
```

## ✅ 解决方案

### 方案 A: 通过 Cloudflare 控制台清理（推荐）

#### 步骤 1: 登录 Cloudflare 控制台

1. 访问 [Cloudflare 控制台](https://dash.cloudflare.com/)
2. 使用你的 Cloudflare 账户登录

#### 步骤 2: 选择你的域名

1. 在左侧菜单中选择你的域名 `blog.changfeng.online`

#### 步骤 3: 清理缓存

**方法 1: 清理所有缓存**
1. 点击 "Caching" 标签
2. 点击 "Purge Cache"
3. 选择 "Purge Everything"
4. 点击 "Purge Everything" 确认
5. 等待完成（通常立即完成）

**方法 2: 清理特定文件**
1. 点击 "Caching" 标签
2. 点击 "Purge Cache"
3. 选择 "Custom Purge"
4. 输入要清理的 URL：
   ```
   https://blog.changfeng.online/
   https://blog.changfeng.online/css/index.css
   https://blog.changfeng.online/js/main.js
   ```
5. 点击 "Purge"

### 方案 B: 使用 Cloudflare API 清理

如果你有 Cloudflare API Token：

```bash
# 清理所有缓存
curl -X POST "https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/purge_cache" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{"purge_everything":true}'

# 清理特定文件
curl -X POST "https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/purge_cache" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "files": [
      "https://blog.changfeng.online/",
      "https://blog.changfeng.online/css/index.css",
      "https://blog.changfeng.online/js/main.js"
    ]
  }'
```

### 方案 C: 使用 GitHub Actions 自动清理

在 GitHub Actions 工作流中添加自动清理步骤：

```yaml
# .github/workflows/pages.yml

# ... 其他步骤 ...

- name: Purge Cloudflare Cache
  if: github.event_name == 'push'
  run: |
    curl -X POST "https://api.cloudflare.com/client/v4/zones/${{ secrets.CLOUDFLARE_ZONE_ID }}/purge_cache" \
      -H "Authorization: Bearer ${{ secrets.CLOUDFLARE_API_TOKEN }}" \
      -H "Content-Type: application/json" \
      --data '{"purge_everything":true}'
```

## 🔍 验证清理是否成功

### 方法 1: 检查响应头

```bash
# 清理前
curl -I https://blog.changfeng.online/

# 清理后（立即生效）
curl -I https://blog.changfeng.online/
# 查看 cf-cache-status 字段
```

### 方法 2: 浏览器检查

1. 打开浏览器开发者工具 (F12)
2. 切换到 "Network" 标签
3. 刷新页面
4. 查看响应头中的 `cf-cache-status` 字段
5. 应该显示 "MISS"（缓存未命中，从源服务器获取）

### 方法 3: 清理浏览器缓存后访问

1. 清理浏览器缓存：Ctrl+Shift+Delete
2. 访问网站
3. 检查侧边栏是否显示

## 📊 Cloudflare 缓存状态说明

| 状态 | 含义 | 说明 |
|------|------|------|
| HIT | 缓存命中 | 从 Cloudflare 缓存返回 |
| MISS | 缓存未命中 | 从源服务器获取 |
| EXPIRED | 缓存过期 | 从源服务器刷新 |
| STALE | 缓存陈旧 | 返回陈旧缓存 |
| BYPASS | 绕过缓存 | 直接从源服务器获取 |
| ERROR | 错误 | Cloudflare 返回错误 |

## 🛠️ 诊断命令

```bash
# 检查主页
curl -I https://blog.changfeng.online/

# 检查 CSS 文件
curl -I https://blog.changfeng.online/css/index.css

# 检查 JavaScript 文件
curl -I https://blog.changfeng.online/js/main.js

# 查看完整响应头
curl -v https://blog.changfeng.online/ 2>&1 | grep -E "^<|^>|^cf-"
```

## 📋 检查清单

- [ ] 确认你有 Cloudflare 账户
- [ ] 登录 Cloudflare 控制台
- [ ] 选择你的域名 `blog.changfeng.online`
- [ ] 进入 "Caching" 标签
- [ ] 点击 "Purge Cache"
- [ ] 选择 "Purge Everything"
- [ ] 确认清理
- [ ] 清理浏览器缓存
- [ ] 访问网站验证侧边栏是否显示

## 💡 预防措施

### 1. 配置缓存规则

在 Cloudflare 中为不同类型的文件设置不同的缓存规则：

1. 进入 "Rules" → "Page Rules"
2. 创建规则：
   ```
   URL: blog.changfeng.online/index.html
   Cache Level: Bypass Cache
   ```
   （HTML 文件不缓存，每次都从源服务器获取）

3. 创建规则：
   ```
   URL: blog.changfeng.online/css/*
   Cache Level: Cache Everything
   Browser Cache TTL: 1 month
   ```
   （CSS 文件缓存 1 个月）

### 2. 自动清理缓存

在 GitHub Actions 中添加自动清理步骤（见上面的示例）

### 3. 使用版本化资源

为资源添加版本号：
```
css/index.css?v=1.0.0
js/main.js?v=1.0.0
```

### 4. 监控缓存

启用 Cloudflare 分析，定期检查缓存命中率

## 🚀 快速修复步骤

### 立即清理缓存

1. 进入 [Cloudflare 控制台](https://dash.cloudflare.com/)
2. 选择你的域名
3. 点击 "Caching" → "Purge Cache"
4. 选择 "Purge Everything"
5. 确认

### 等待生效

- Cloudflare 缓存清理通常立即生效
- 但浏览器缓存可能需要清理

### 清理浏览器缓存

```
Windows/Linux: Ctrl + Shift + Delete
Mac: Cmd + Shift + Delete
```

### 访问网站验证

1. 访问 https://blog.changfeng.online/
2. 检查右侧是否显示侧边栏
3. 打开开发者工具 (F12) 检查 cf-cache-status

## 📞 需要帮助？

如果问题仍未解决：

1. 检查 Cloudflare 是否正确配置
2. 查看 Cloudflare 分析中的缓存命中率
3. 检查源服务器（GitHub Pages）是否正常
4. 参考 Cloudflare 官方文档

## 🔗 相关资源

- [Cloudflare 控制台](https://dash.cloudflare.com/)
- [Cloudflare 缓存文档](https://developers.cloudflare.com/cache/)
- [Cloudflare API 文档](https://developers.cloudflare.com/api/)
- [Cloudflare 页面规则](https://support.cloudflare.com/hc/en-us/articles/218411427)
