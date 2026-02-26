# 设置 Cloudflare API 自动清理缓存

## 🎯 目标

在 GitHub Actions 中自动清理 Cloudflare 缓存，每次部署后无需手动操作。

## 📋 前置条件

- 有 Cloudflare 账户
- 你的域名 `blog.changfeng.online` 已在 Cloudflare 中配置
- 有 GitHub 仓库的管理员权限

## 🔑 第 1 步：获取 Cloudflare API Token

### 方法 A: 使用 API Token（推荐）

#### 1. 登录 Cloudflare 控制台

访问 [Cloudflare 控制台](https://dash.cloudflare.com/)

#### 2. 进入 API Token 设置

1. 点击右上角的头像
2. 选择 "My Profile"
3. 点击 "API Tokens" 标签

#### 3. 创建新的 API Token

1. 点击 "Create Token"
2. 选择 "Custom token"
3. 点击 "Get started"

#### 4. 配置 Token 权限

**权限设置：**
- **Permissions:**
  - Zone → Cache Purge → Purge
  - Zone → Zone → Read

**Zone Resources:**
- Include → Specific zone → blog.changfeng.online

**TTL:**
- 设置过期时间（建议 90 天或更长）

#### 5. 创建 Token

1. 点击 "Create Token"
2. 复制生成的 Token（只会显示一次！）

### 方法 B: 使用 Global API Key（不推荐）

如果你想使用 Global API Key：

1. 进入 "My Profile" → "API Tokens"
2. 找到 "Global API Key"
3. 点击 "View" 查看你的 API Key

## 🔍 第 2 步：获取 Zone ID

### 方法 1: 从 Cloudflare 控制台获取

1. 进入 [Cloudflare 控制台](https://dash.cloudflare.com/)
2. 选择你的域名 `blog.changfeng.online`
3. 在右侧边栏找到 "Zone ID"
4. 复制 Zone ID

### 方法 2: 使用 API 获取

```bash
# 替换 YOUR_API_TOKEN 为你的 API Token
curl -X GET "https://api.cloudflare.com/client/v4/zones" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json"

# 在返回的 JSON 中找到 "id" 字段，那就是你的 Zone ID
```

## 🔐 第 3 步：添加 GitHub Secrets

### 1. 进入 GitHub 仓库设置

1. 进入你的 GitHub 仓库
2. 点击 "Settings" 标签
3. 在左侧菜单中选择 "Secrets and variables" → "Actions"

### 2. 添加 CLOUDFLARE_API_TOKEN

1. 点击 "New repository secret"
2. **Name:** `CLOUDFLARE_API_TOKEN`
3. **Value:** 粘贴你从 Cloudflare 复制的 API Token
4. 点击 "Add secret"

### 3. 添加 CLOUDFLARE_ZONE_ID

1. 点击 "New repository secret"
2. **Name:** `CLOUDFLARE_ZONE_ID`
3. **Value:** 粘贴你的 Zone ID
4. 点击 "Add secret"

## ✅ 第 4 步：验证配置

### 1. 检查 GitHub Secrets

1. 进入 "Settings" → "Secrets and variables" → "Actions"
2. 确认看到：
   - `CLOUDFLARE_API_TOKEN` ✅
   - `CLOUDFLARE_ZONE_ID` ✅

### 2. 测试工作流

1. 进行一个小的代码更改
2. 提交并推送到 main 分支
3. 进入 "Actions" 标签
4. 查看最新的 "Pages" 工作流
5. 等待工作流完成
6. 检查 "Purge Cloudflare Cache" 步骤是否成功

## 🧪 测试清理是否成功

### 方法 1: 检查工作流日志

1. 进入 GitHub Actions
2. 点击最新的 "Pages" 工作流
3. 展开 "Purge Cloudflare Cache" 步骤
4. 查看输出日志

**成功的输出应该包含：**
```json
{
  "success": true,
  "result": {
    "id": "..."
  }
}
```

### 方法 2: 检查 Cloudflare 缓存状态

```bash
# 清理前
curl -I https://blog.changfeng.online/

# 清理后（立即）
curl -I https://blog.changfeng.online/
# 查看 cf-cache-status 应该是 MISS（缓存未命中）
```

### 方法 3: 浏览器检查

1. 打开浏览器开发者工具 (F12)
2. 切换到 "Network" 标签
3. 刷新页面
4. 查看响应头中的 `cf-cache-status`
5. 应该显示 "MISS"（表示从源服务器获取）

## 📋 检查清单

- [ ] 已登录 Cloudflare 控制台
- [ ] 已创建 API Token
- [ ] 已复制 API Token
- [ ] 已获取 Zone ID
- [ ] 已在 GitHub 添加 `CLOUDFLARE_API_TOKEN` secret
- [ ] 已在 GitHub 添加 `CLOUDFLARE_ZONE_ID` secret
- [ ] 已验证 GitHub Secrets 配置
- [ ] 已测试工作流
- [ ] 已验证缓存清理成功

## 🔧 工作流配置说明

已在 [`.github/workflows/pages.yml`](.github/workflows/pages.yml) 中添加了以下步骤：

```yaml
- name: Purge Cloudflare Cache
  run: |
    curl -X POST "https://api.cloudflare.com/client/v4/zones/${{ secrets.CLOUDFLARE_ZONE_ID }}/purge_cache" \
      -H "Authorization: Bearer ${{ secrets.CLOUDFLARE_API_TOKEN }}" \
      -H "Content-Type: application/json" \
      --data '{"purge_everything":true}'
  continue-on-error: true
```

**说明：**
- 在部署完成后自动执行
- 使用 GitHub Secrets 中的凭证
- 清理所有 Cloudflare 缓存
- `continue-on-error: true` 表示即使清理失败也不会中断工作流

## 🚀 使用流程

从现在开始，每次你推送代码到 main 分支：

1. ✅ GitHub Actions 自动构建项目
2. ✅ 自动部署到 GitHub Pages
3. ✅ **自动清理 Cloudflare 缓存**（新增！）
4. ✅ 用户立即看到最新版本

**无需手动清理缓存！**

## 💡 高级配置

### 只清理特定文件

如果你想只清理特定文件而不是所有缓存：

```yaml
- name: Purge Cloudflare Cache
  run: |
    curl -X POST "https://api.cloudflare.com/client/v4/zones/${{ secrets.CLOUDFLARE_ZONE_ID }}/purge_cache" \
      -H "Authorization: Bearer ${{ secrets.CLOUDFLARE_API_TOKEN }}" \
      -H "Content-Type: application/json" \
      --data '{
        "files": [
          "https://blog.changfeng.online/",
          "https://blog.changfeng.online/css/index.css",
          "https://blog.changfeng.online/js/main.js"
        ]
      }'
  continue-on-error: true
```

### 添加通知

如果清理失败，发送通知：

```yaml
- name: Purge Cloudflare Cache
  id: purge
  run: |
    curl -X POST "https://api.cloudflare.com/client/v4/zones/${{ secrets.CLOUDFLARE_ZONE_ID }}/purge_cache" \
      -H "Authorization: Bearer ${{ secrets.CLOUDFLARE_API_TOKEN }}" \
      -H "Content-Type: application/json" \
      --data '{"purge_everything":true}'
  continue-on-error: true

- name: Notify if purge failed
  if: failure()
  run: echo "⚠️ Cloudflare cache purge failed"
```

## 📞 故障排除

### 问题 1: API Token 无效

**症状：** 工作流日志显示 "Unauthorized"

**解决：**
1. 检查 API Token 是否正确复制
2. 检查 API Token 是否过期
3. 重新创建 API Token

### 问题 2: Zone ID 错误

**症状：** 工作流日志显示 "Zone not found"

**解决：**
1. 确认 Zone ID 是否正确
2. 确认域名是否在 Cloudflare 中配置
3. 重新获取 Zone ID

### 问题 3: 权限不足

**症状：** 工作流日志显示 "Insufficient permissions"

**解决：**
1. 检查 API Token 权限是否包含 "Cache Purge"
2. 重新创建 API Token 并设置正确的权限

### 问题 4: 工作流没有执行清理步骤

**症状：** 工作流日志中没有 "Purge Cloudflare Cache" 步骤

**解决：**
1. 检查工作流文件是否正确更新
2. 确认 GitHub Secrets 已添加
3. 重新推送代码触发工作流

## 🔗 相关资源

- [Cloudflare API 文档](https://developers.cloudflare.com/api/)
- [Cloudflare Cache Purge API](https://developers.cloudflare.com/api/operations/zone-cache-purge-cache)
- [GitHub Secrets 文档](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub Actions 文档](https://docs.github.com/en/actions)

## 🎉 完成！

现在你的部署流程已经完全自动化了：

```
代码推送 → 自动构建 → 自动部署 → 自动清理缓存 → 用户看到最新版本
```

无需任何手动操作！
