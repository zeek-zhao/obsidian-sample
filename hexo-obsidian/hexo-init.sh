#!/bin/bash
#########################################################################
# Hexo + Obsidian 项目初始化脚本
# 功能: 自动安装Hexo并配置Butterfly主题与相关插件
# 作者: Zeek Zhao
#########################################################################

# 严格模式，命令失败立即退出，并启用调试输出
set -e
# 注释下面这行可以关闭调试输出
set -x

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 辅助函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# 检查命令是否存在
check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "命令 '$1' 未找到，请先安装"
    fi
}

# 主函数
main() {
    log_info "开始初始化Hexo项目..."
    
    # 检查必要命令
    check_command npm
    check_command node
    
    # 配置NPM
    log_info "配置NPM环境..."
    npm config set registry https://registry.npm.taobao.org
    npm config set strict-ssl false
    
    # 安装Hexo CLI
    log_info "安装Hexo CLI..."
    install_hexo_cli
    
    # 初始化项目
    log_info "创建Hexo项目结构..."
    initialize_hexo_project
    
    # 安装主题和插件
    log_info "安装主题和必要插件..."
    install_themes_and_plugins
    
    # 启动服务器
    log_info "启动Hexo服务器进行预览..."
    start_hexo_server
    
    log_info "Hexo项目初始化完成！"
    log_info "您可以使用 'cd src && hexo server' 重新启动本地预览"
}

# 安装Hexo CLI
install_hexo_cli() {
    if [ "$(id -u)" != "0" ]; then
        log_warn "需要提升权限来安装全局包，请输入密码："
        
        # 方法1：使用sudo安装全局包
        if sudo npm install -g hexo-cli; then
            log_info "Hexo CLI 安装成功"
        else
            log_error "Hexo CLI 安装失败"
        fi
        
        # 方法2（备选）：配置npm使用用户目录安装全局包
        # 如果需要使用此方法，请取消注释下面的代码并注释掉上面的方法1
        
        # mkdir -p ~/.npm-global
        # npm config set prefix '~/.npm-global'
        # echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.profile
        # source ~/.profile
        # npm install -g hexo-cli
    else
        npm install -g hexo-cli
    fi
}

# 初始化Hexo项目
initialize_hexo_project() {
    # 创建项目目录
    mkdir -p src
    
    # 初始化Hexo
    if ! hexo init src; then
        log_error "Hexo初始化失败"
    fi
    
    # 进入项目目录
    cd src || log_error "无法进入项目目录"
}

# 安装主题和插件
install_themes_and_plugins() {
    # 安装基础插件
    log_info "安装基础Hexo插件..."
    npm install --save \
        hexo-generator-feed \
        hexo-tag-aplayer \
        hexo-renderer-kramed \
        hexo-renderer-ejs \
        hexo-generator-archive \
        hexo-generator-category \
        hexo-generator-index \
        hexo-generator-tag \
        hexo-server \
        hexo-generator-searchdb \
        hexo-abbrlink \
        hexo-link-obsidian \
        hexo-deployer-git

    # 安装Obsidian支持插件
    log_info "安装Obsidian支持插件..."
    npm install --save \
        hexo-filter-mathjax \
        hexo-related-popular-posts

    # 安装Butterfly主题
    log_info "安装Butterfly主题及依赖..."
    npm install --save \
        hexo-theme-butterfly \
        hexo-renderer-pug \
        hexo-renderer-stylus \
        hexo-wordcount

    # 配置Butterfly主题
    log_info "配置Butterfly主题..."
    sed -i 's/theme: landscape/theme: butterfly/g' _config.yml
    
    # 复制主题配置文件
    if [ -f "node_modules/hexo-theme-butterfly/_config.yml" ]; then
        cp node_modules/hexo-theme-butterfly/_config.yml _config.butterfly.yml
        log_info "主题配置文件已复制到 _config.butterfly.yml"
    else
        log_warn "找不到主题配置文件，请手动配置"
    fi

    # 安装Live2D模型（可选）
    log_info "安装Live2D模型和支持..."
    npm install --save \
        hexo-helper-live2d \
        live2d-widget-model-hijiki \
        live2d-widget-model-miku \
        live2d-widget-model-tororo

    # 确保生成完整的package-lock.json
    npm install
}

# 启动Hexo服务器
start_hexo_server() {
    # 清理、生成和启动服务器
    log_info "生成静态文件并启动预览服务器..."
    hexo clean && hexo generate && hexo server
}

# 执行主函数
main "$@"