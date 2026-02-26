#!/bin/bash

# 网络诊断脚本
# 用于检查 CloudFront 缓存和网络连接问题

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

# 检查 URL 的响应头
check_url() {
    local url=$1
    local name=$2
    
    echo ""
    print_info "检查: $name"
    print_info "URL: $url"
    
    if command -v curl &> /dev/null; then
        local response=$(curl -s -I "$url" 2>&1)
        
        # 检查 HTTP 状态码
        local status=$(echo "$response" | head -n 1)
        echo "状态: $status"
        
        # 检查 CloudFront 缓存状态
        local cache_status=$(echo "$response" | grep -i "x-cache:" | cut -d' ' -f2-)
        if [ -n "$cache_status" ]; then
            if [[ "$cache_status" == *"Error"* ]]; then
                print_error "CloudFront 缓存错误: $cache_status"
            elif [[ "$cache_status" == *"Hit"* ]]; then
                print_success "CloudFront 缓存命中: $cache_status"
            else
                print_warning "CloudFront 缓存状态: $cache_status"
            fi
        fi
        
        # 检查 Content-Type
        local content_type=$(echo "$response" | grep -i "content-type:" | cut -d' ' -f2-)
        if [ -n "$content_type" ]; then
            print_info "Content-Type: $content_type"
        fi
        
        # 检查 Content-Length
        local content_length=$(echo "$response" | grep -i "content-length:" | cut -d' ' -f2-)
        if [ -n "$content_length" ]; then
            print_info "Content-Length: $content_length"
        fi
        
        # 检查 Server
        local server=$(echo "$response" | grep -i "server:" | cut -d' ' -f2-)
        if [ -n "$server" ]; then
            print_info "Server: $server"
        fi
        
        # 检查 Via（CloudFront）
        local via=$(echo "$response" | grep -i "via:" | cut -d' ' -f2-)
        if [ -n "$via" ]; then
            print_info "Via: $via"
        fi
        
        # 检查 CORS
        local cors=$(echo "$response" | grep -i "access-control-allow-origin:" | cut -d' ' -f2-)
        if [ -n "$cors" ]; then
            print_info "CORS: $cors"
        fi
    else
        print_error "curl 命令不存在，请安装 curl"
    fi
}

# 主函数
main() {
    print_header "网络诊断工具"
    
    # 检查网络连接
    echo ""
    print_info "检查网络连接..."
    
    if ping -c 1 8.8.8.8 &> /dev/null; then
        print_success "网络连接正常"
    else
        print_warning "网络连接可能有问题"
    fi
    
    # 检查 DNS 解析
    echo ""
    print_info "检查 DNS 解析..."
    
    if command -v nslookup &> /dev/null; then
        if nslookup blog.changfeng.online &> /dev/null; then
            print_success "DNS 解析正常"
        else
            print_error "DNS 解析失败"
        fi
    else
        print_warning "nslookup 命令不存在"
    fi
    
    # 检查主页
    check_url "https://blog.changfeng.online/" "主页"
    
    # 检查 CSS 文件
    check_url "https://blog.changfeng.online/css/index.css" "CSS 文件"
    
    # 检查 JavaScript 文件
    check_url "https://blog.changfeng.online/js/main.js" "JavaScript 文件"
    
    # 检查文章页面
    check_url "https://blog.changfeng.online/2026/02/26/test/" "文章页面"
    
    # 总结
    echo ""
    print_header "诊断完成"
    
    echo ""
    print_info "如果看到 'Error from cloudfront'，请执行以下步骤："
    echo "  1. 进入 AWS CloudFront 控制台"
    echo "  2. 创建 Invalidation 清理缓存"
    echo "  3. 等待 1-5 分钟"
    echo "  4. 清理浏览器缓存（Ctrl+Shift+Delete）"
    echo "  5. 重新访问网站"
    echo ""
    print_info "或者参考 debug/sidebar-fix/cloudfront-cache-clear.md"
    echo ""
}

# 运行主函数
main
