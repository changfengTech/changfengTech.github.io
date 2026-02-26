# CloudFront 缓存清理指南

## 🎯 问题

你的网站使用了 CloudFront CDN，但 CloudFront 缓存了旧版本的文件，导致侧边栏消失。

## ✅ 解决方案

### 方案 A: 通过 AWS 控制台清理（推荐）

#### 步骤 1: 登录 AWS 控制台

1. 访问 [AWS CloudFront 控制台](https://console.aws.amazon.com/cloudfront/)
2. 使用你的 AWS 账户登录

#### 步骤 2: 找到你的分布

1. 在 CloudFront 控制台中找到你的分布
2. 记下分布 ID（通常以 E 开头，比如 E1234ABCD）

#### 步骤 3: 创建 Invalidation

1. 点击你的分布 ID
2. 切换到 "Invalidations" 标签
3. 点击 "Create invalidation"
4. 在 "Object paths" 中输入：
   ```
   /*
   ```
5. 点击 "Create invalidation"
6. 等待状态变为 "Completed"（通常 1-5 分钟）

### 方案 B: 使用 AWS CLI 清理

如果你已安装 AWS CLI：

```bash
# 替换 DISTRIBUTION_ID 为你的分布 ID
aws cloudfront create-invalidation \
  --distribution-id DISTRIBUTION_ID \
  --paths "/*"

# 查看失效状态
aws cloudfront list-invalidations \
  --distribution-id DISTRIBUTION_ID
```

### 方案 C: 使用 GitHub Actions 自动清理

在 GitHub Actions 工作流中添加自动清理步骤：

```yaml
# .github/workflows/pages.yml

# ... 其他步骤 ...

- name: Invalidate CloudFront Cache
  if: github.event_name == 'push'
  run: |
    aws cloudfront create-invalidation \
      --distribution-id ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }} \
      --paths "/*"
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    AWS_DEFAULT_REGION: us-east-1
```

## 🔍 验证清理是否成功

### 方法 1: 检查响应头

```bash
# 清理前
curl -I https://blog.changfeng.online/
# 查看 x-cache 字段

# 清理后（等待 1-5 分钟）
curl -I https://blog.changfeng.online/
# x-cache 应该显示 "Hit from cloudfront" 或 "Miss from cloudfront"
```

### 方法 2: 浏览器检查

1. 打开浏览器开发者工具 (F12)
2. 切换到 "Network" 标签
3. 刷新页面
4. 查看响应头中的 `x-cache` 字段
5. 应该显示 "Hit from cloudfront"（缓存命中）

### 方法 3: 清理浏览器缓存后访问

1. 清理浏览器缓存：Ctrl+Shift+Delete
2. 访问网站
3. 检查侧边栏是否显示

## 📊 CloudFront 缓存状态说明

| 状态 | 含义 | 说明 |
|------|------|------|
| Hit from cloudfront | 缓存命中 | 从 CloudFront 缓存返回 |
| Miss from cloudfront | 缓存未命中 | 从源服务器获取 |
| Error from cloudfront | 错误 | CloudFront 返回错误 |
| Refresh from origin | 刷新 | 从源服务器刷新 |

## 🛠️ 诊断命令

```bash
# 检查主页
curl -I https://blog.changfeng.online/

# 检查 CSS 文件
curl -I https://blog.changfeng.online/css/index.css

# 检查 JavaScript 文件
curl -I https://blog.changfeng.online/js/main.js

# 检查特定资源
curl -I https://blog.changfeng.online/2026/02/26/test/

# 查看完整响应头
curl -v https://blog.changfeng.online/ 2>&1 | grep -E "^<|^>|^x-"
```

## 📋 检查清单

- [ ] 确认你有 AWS 账户和 CloudFront 分布
- [ ] 记下你的 CloudFront 分布 ID
- [ ] 创建 Invalidation 清理缓存
- [ ] 等待 Invalidation 完成（1-5 分钟）
- [ ] 清理浏览器缓存
- [ ] 访问网站验证侧边栏是否显示
- [ ] 检查响应头中的 x-cache 字段

## 💡 预防措施

### 1. 配置缓存策略

在 CloudFront 中为不同类型的文件设置不同的 TTL：

- **HTML 文件**: 5 分钟（短期缓存）
- **CSS/JS 文件**: 1 天（长期缓存）
- **图片文件**: 7 天（长期缓存）

### 2. 自动清理缓存

在 GitHub Actions 中添加自动清理步骤（见上面的示例）

### 3. 使用版本化资源

为资源添加版本号：
```
css/index.css?v=1.0.0
js/main.js?v=1.0.0
```

### 4. 监控缓存错误

启用 CloudFront 日志，定期检查错误率

## 🚀 快速修复步骤

1. **立即清理缓存**
   ```bash
   aws cloudfront create-invalidation \
     --distribution-id YOUR_DISTRIBUTION_ID \
     --paths "/*"
   ```

2. **等待完成** (1-5 分钟)

3. **清理浏览器缓存** (Ctrl+Shift+Delete)

4. **访问网站验证**

## 📞 需要帮助？

如果问题仍未解决：

1. 检查 CloudFront 分布是否正确配置
2. 查看 CloudFront 日志中的错误信息
3. 检查源服务器（GitHub Pages）是否正常
4. 参考 AWS CloudFront 官方文档

## 🔗 相关资源

- [AWS CloudFront 文档](https://docs.aws.amazon.com/cloudfront/)
- [CloudFront Invalidation 指南](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Invalidation.html)
- [AWS CLI CloudFront 命令](https://docs.aws.amazon.com/cli/latest/reference/cloudfront/)
