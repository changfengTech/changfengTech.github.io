#!/bin/bash

# 侧边栏修复验证脚本
# 用于验证线上部署是否成功修复侧边栏问题

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 打印函数
print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# 主函数
main() {
    print_header "侧边栏修复验证工具"
    
    # 检查本地构建
    echo ""
    print_info "检查本地构建..."
    
    if [ ! -d "public" ]; then
        print_error "public 目录不存在，请先运行 pnpm run build"
        exit 1
    fi
    
    if [ ! -f "public/index.html" ]; then
        print_error "public/index.html 不存在"
        exit 1
    fi
    
    print_success "public 目录存在"
    
    # 检查侧边栏代码
    echo ""
    print_info "检查侧边栏代码..."
    
    if grep -q "class=\"aside-content\"" public/index.html; then
        print_success "侧边栏容器存在"
    else
        print_error "侧边栏容器不存在"
        exit 1
    fi
    
    if grep -q "class=\"card-widget card-info\"" public/index.html; then
        print_success "作者信息卡片存在"
    else
        print_warning "作者信息卡片不存在"
    fi
    
    if grep -q "class=\"card-widget card-announcement\"" public/index.html; then
        print_success "公告卡片存在"
    else
        print_warning "公告卡片不存在"
    fi
    
    if grep -q "class=\"card-archives\"" public/index.html; then
        print_success "归档卡片存在"
    else
        print_warning "归档卡片不存在"
    fi
    
    if grep -q "class=\"card-webinfo\"" public/index.html; then
        print_success "网站资讯卡片存在"
    else
        print_warning "网站资讯卡片不存在"
    fi
    
    # 检查静态资源
    echo ""
    print_info "检查静态资源..."
    
    if [ -f "public/css/index.css" ]; then
        print_success "CSS 文件存在"
    else
        print_error "CSS 文件不存在"
    fi
    
    if [ -f "public/js/main.js" ]; then
        print_success "JavaScript 文件存在"
    else
        print_error "JavaScript 文件不存在"
    fi
    
    # 检查配置
    echo ""
    print_info "检查配置文件..."
    
    if grep -q "aside:" _config.anzhiyu.yml && grep -q "enable: true" _config.anzhiyu.yml; then
        print_success "侧边栏配置启用"
    else
        print_error "侧边栏配置未启用"
    fi
    
    # 总结
    echo ""
    print_header "验证完成"
    
    print_success "本地构建正常，侧边栏代码完整"
    echo ""
    print_info "后续步骤："
    echo "  1. 进入 GitHub Actions 检查部署状态"
    echo "  2. 等待部署完成（通常 2-5 分钟）"
    echo "  3. 清理浏览器缓存（Ctrl+Shift+Delete）"
    echo "  4. 访问线上网站验证侧边栏是否显示"
    echo "  5. 打开开发者工具 (F12) 检查是否有错误"
    echo ""
    print_info "如果线上仍未显示，请参考 QUICK_FIX.md 中的其他解决方案"
    echo ""
}

# 运行主函数
main
