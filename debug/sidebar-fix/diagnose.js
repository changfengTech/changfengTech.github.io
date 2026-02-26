#!/usr/bin/env node

/**
 * 侧边栏诊断脚本
 * 用于检查本地构建的 HTML 文件中是否包含侧边栏相关代码
 */

const fs = require('fs');
const path = require('path');

const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function checkFile(filePath, checks) {
  if (!fs.existsSync(filePath)) {
    log(`❌ 文件不存在: ${filePath}`, 'red');
    return false;
  }

  const content = fs.readFileSync(filePath, 'utf-8');
  let allPassed = true;

  log(`\n📄 检查文件: ${filePath}`, 'cyan');
  log('─'.repeat(60), 'cyan');

  checks.forEach(({ name, pattern, required = true }) => {
    const found = pattern.test(content);
    const status = found ? '✅' : '❌';
    const color = found ? 'green' : required ? 'red' : 'yellow';

    log(`${status} ${name}`, color);

    if (!found && required) {
      allPassed = false;
    }
  });

  return allPassed;
}

function main() {
  log('\n🔍 Hexo 侧边栏诊断工具', 'blue');
  log('═'.repeat(60), 'blue');

  const publicDir = path.join(__dirname, 'public');
  const indexFile = path.join(publicDir, 'index.html');

  // 检查 public 目录是否存在
  if (!fs.existsSync(publicDir)) {
    log('\n❌ public 目录不存在，请先运行 pnpm run build', 'red');
    process.exit(1);
  }

  // 检查 index.html
  const indexChecks = [
    {
      name: '侧边栏容器存在',
      pattern: /class="aside-content"/,
      required: true,
    },
    {
      name: '作者信息卡片存在',
      pattern: /class="card-widget card-info"/,
      required: true,
    },
    {
      name: '公告卡片存在',
      pattern: /class="card-widget card-announcement"/,
      required: true,
    },
    {
      name: '微信卡片存在',
      pattern: /class="card-widget anzhiyu-right-widget"/,
      required: true,
    },
    {
      name: '归档卡片存在',
      pattern: /class="card-archives"/,
      required: true,
    },
    {
      name: '网站资讯卡片存在',
      pattern: /class="card-webinfo"/,
      required: true,
    },
    {
      name: 'CSS 文件引用存在',
      pattern: /href=".*\.css"/,
      required: true,
    },
    {
      name: 'JavaScript 文件引用存在',
      pattern: /src=".*\.js"/,
      required: true,
    },
  ];

  const indexPassed = checkFile(indexFile, indexChecks);

  // 检查 CSS 文件
  log('\n\n📦 检查静态资源', 'cyan');
  log('─'.repeat(60), 'cyan');

  const cssFile = path.join(publicDir, 'css', 'index.css');
  const jsFile = path.join(publicDir, 'js', 'main.js');

  const cssExists = fs.existsSync(cssFile);
  const jsExists = fs.existsSync(jsFile);

  log(`${cssExists ? '✅' : '❌'} CSS 文件存在: ${cssFile}`, cssExists ? 'green' : 'red');
  log(`${jsExists ? '✅' : '❌'} JavaScript 文件存在: ${jsFile}`, jsExists ? 'green' : 'red');

  // 检查配置文件
  log('\n\n⚙️  检查配置文件', 'cyan');
  log('─'.repeat(60), 'cyan');

  const configFile = path.join(__dirname, '_config.anzhiyu.yml');
  if (fs.existsSync(configFile)) {
    const configContent = fs.readFileSync(configFile, 'utf-8');
    const asideEnabled = /aside:\s*\n\s*enable:\s*true/.test(configContent);
    const asideNotHidden = /aside:\s*[\s\S]*?hide:\s*false/.test(configContent);

    log(`${asideEnabled ? '✅' : '❌'} aside.enable 设置为 true`, asideEnabled ? 'green' : 'red');
    log(`${asideNotHidden ? '✅' : '❌'} aside.hide 设置为 false`, asideNotHidden ? 'green' : 'red');
  }

  // 总结
  log('\n\n📊 诊断结果', 'blue');
  log('═'.repeat(60), 'blue');

  if (indexPassed && cssExists && jsExists) {
    log('✅ 本地构建正常，侧边栏代码完整', 'green');
    log('\n💡 如果线上仍然不显示，可能是以下原因：', 'yellow');
    log('  1. GitHub Pages 缓存问题 - 尝试清理浏览器缓存或等待 24 小时', 'yellow');
    log('  2. 外部资源加载失败 - 检查浏览器控制台的网络请求', 'yellow');
    log('  3. JavaScript 执行错误 - 检查浏览器控制台的错误信息', 'yellow');
  } else {
    log('❌ 本地构建存在问题，请检查上述错误', 'red');
    log('\n💡 建议步骤：', 'yellow');
    log('  1. 运行 pnpm run clean 清理构建文件', 'yellow');
    log('  2. 运行 pnpm run build 重新构建', 'yellow');
    log('  3. 再次运行此诊断脚本', 'yellow');
  }

  log('\n');
}

main();
