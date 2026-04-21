#!/bin/bash
set -e  # 遇到错误立即停止脚本执行

echo "开始本地部署Hexo网站..."

# 进入Hexo项目目录
cd src

# 检查必要的依赖
if ! npm list hexo-deployer-git > /dev/null 2>&1; then
    echo "安装hexo-deployer-git插件..."
    npm install hexo-deployer-git --save
fi

# 清理旧的构建文件
hexo clean

# 生成静态文件
hexo generate

# 部署到GitHub Pages
hexo deploy

# 检查部署结果
if [ $? -eq 0 ]; then
    echo "✅ 部署成功！请检查您的GitHub Pages网站。"
    echo "🌐 网站地址: $(grep "url:" _config.yml | sed 's/url: //')"
else
    echo "❌ 部署失败，请检查错误信息。"
    exit 1
fi
