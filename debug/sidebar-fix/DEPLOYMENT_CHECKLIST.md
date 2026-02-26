# 侧边栏消失问题排查清单

## 🔍 问题诊断

### 本地检查
- [x] 本地 `hexo server` 运行时侧边栏显示正常
- [x] 本地构建的 HTML 中包含侧边栏代码
- [x] 配置文件 `_config.anzhiyu.yml` 中 `aside.enable: true`

### 线上检查
- [ ] 访问线上网站，打开浏览器开发者工具（F12）
- [ ] 检查 HTML 源码中是否包含 `<div class="aside-content">`
- [ ] 检查 Console 中是否有 JavaScript 错误
- [ ] 检查 Network 标签中是否有加载失败的资源

## 🛠️ 解决步骤

### 步骤 1: 清理 GitHub Pages 缓存
1. 进入 GitHub 仓库设置
2. 找到 "Pages" 部分
3. 重新部署（可以通过 push 一个空 commit 触发）

### 步骤 2: 检查部署日志
1. 进入 GitHub Actions
2. 查看最新的 "Pages" 工作流运行日志
3. 确认 "Build" 步骤中没有错误
4. 确认 "Deploy" 步骤成功完成

### 步骤 3: 强制刷新浏览器
1. 打开线上网站
2. 按 `Ctrl+Shift+Delete`（Windows）或 `Cmd+Shift+Delete`（Mac）清理缓存
3. 或者使用无痕模式访问

### 步骤 4: 检查浏览器控制台
1. 打开开发者工具（F12）
2. 切换到 "Console" 标签
3. 查看是否有红色错误信息
4. 特别注意与 "aside"、"sidebar" 相关的错误

### 步骤 5: 检查网络请求
1. 打开开发者工具（F12）
2. 切换到 "Network" 标签
3. 刷新页面
4. 查看是否有失败的请求（红色标记）
5. 特别检查 CSS 和 JavaScript 文件

## 📋 常见原因和解决方案

### 原因 1: 外部 CDN 资源加载失败
**症状**: 侧边栏 HTML 存在但不显示
**解决**: 
- 检查网络请求中是否有失败的 CDN 资源
- 尝试更换 CDN 或使用本地资源

### 原因 2: JavaScript 执行错误
**症状**: 控制台有错误信息
**解决**:
- 查看错误信息
- 检查是否有脚本加载失败
- 尝试禁用某些功能（如 pjax）

### 原因 3: CSS 加载失败
**症状**: 侧边栏显示但样式混乱
**解决**:
- 检查 CSS 文件是否加载成功
- 检查 CSS 文件路径是否正确

### 原因 4: 浏览器缓存
**症状**: 本地正常，线上不正常
**解决**:
- 清理浏览器缓存
- 使用无痕模式访问
- 等待 GitHub Pages 缓存过期（通常 24 小时）

## 🚀 快速修复

### 方案 A: 强制重新部署
```bash
# 本地执行
git add .
git commit --allow-empty -m "Force rebuild"
git push origin main
```

### 方案 B: 清理并重新构建
```bash
# 本地执行
pnpm run clean
pnpm run build
# 然后 push 到 GitHub
```

### 方案 C: 检查配置
确保 `_config.anzhiyu.yml` 中有以下配置：
```yaml
aside:
  enable: true
  hide: false
  button: true
  mobile: true
  position: right
```

## 📞 需要帮助？

如果以上步骤都不能解决问题，请提供以下信息：
1. 线上网站 URL
2. 浏览器控制台的错误信息截图
3. Network 标签中失败请求的截图
4. 最近一次 GitHub Actions 的构建日志
