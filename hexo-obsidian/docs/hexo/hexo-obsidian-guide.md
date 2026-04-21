---
title: hexo-obsidian-guide
tags:
  - Hexo
  - Obsidian
  - Docker
  - Ubuntu
categories:
  - - Hexo
    - 教程
keywords: 'Hexo,Obsidian,知识库,Docker,Ubuntu'
description: 在 Ubuntu 22.04 上使用 Docker 搭建 Hexo + Obsidian 知识库仓库的完整指南
top_img: >-
  https://images.unsplash.com/photo-1516414447565-b14be0adf13e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1600&h=400&q=80
cover: >-
  https://images.unsplash.com/photo-1499750310107-5fef28a66643?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=600&q=80
comments: true
toc: true
toc_number: true
auto_open: true
copyright: true
copyright_author: Zeek Zhao
copyright_info: 此文章版权归作者所有，如有转载，请注明来源
mathjax: false
katex: false
aplayer: false
highlight_shrink: false
aside: true
abcjs: false
abbrlink: 22158
date: 2023-12-10
updated: 2025-04-05
---

# Hexo + Obsidian 知识库仓库初始化指南

本文将指导你如何在 Ubuntu 22.04 上搭建一个结合 Hexo 和 Obsidian 的知识库系统，使用 Docker 进行开发环境的隔离和管理。

## 1. Ubuntu 22.04 环境准备

### 1.1 安装必要依赖

首先，我们需要在 Ubuntu 22.04 上安装一些基本依赖：

```bash
# 更新软件包索引
sudo apt update

# 安装基本工具
sudo apt install -y git curl wget build-essential

# 安装 Node.js 和 npm
sudo apt install -y nodejs npm

# 更新到较新版本的 Node.js (可选但推荐)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# 验证安装
node -v
npm -v
git --version
```

### 1.2 安装 Docker

Docker 可以帮助我们创建一个隔离的开发环境：

```bash
# 安装必要的依赖
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# 添加 Docker 的官方 GPG 密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 设置 Docker 存储库
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 更新 apt 包索引
sudo apt update

# 安装 Docker
sudo apt install -y docker-ce docker-ce-cli containerd.io

# 将当前用户添加到 docker 组以避免使用 sudo
sudo usermod -aG docker $USER

# 验证 Docker 安装
docker --version

# 启动 Docker 服务
sudo systemctl start docker
sudo systemctl enable docker
```

**注意**：添加用户到 docker 组后，你需要注销并重新登录才能生效。

### 1.3 安装 Docker Compose (可选)

Docker Compose 可以帮助我们管理多容器应用：

```bash
sudo apt install -y docker-compose

# 验证安装
docker-compose --version
```

## 2. 使用 Docker 进行 Hexo 开发

### 2.1 创建 Dockerfile

在你的项目根目录下创建一个 `Dockerfile`：

```bash
mkdir -p ~/hexo-obsidian-project
cd ~/hexo-obsidian-project
touch Dockerfile
```

编辑 Dockerfile 内容：

```dockerfile
FROM node:18-alpine

WORKDIR /app

RUN apk add --no-cache git openssh-client

# 全局安装 Hexo CLI
RUN npm install -g hexo-cli

# 设置容器的默认命令
CMD ["sh", "-c", "if [ -f package.json ]; then npm install && hexo server -p 4000 --ip=0.0.0.0; else hexo init . && npm install && hexo server -p 4000 --ip=0.0.0.0; fi"]

EXPOSE 4000
```

### 2.2 创建 Docker Compose 配置

创建 `docker-compose.yml` 文件：

```bash
touch docker-compose.yml
```

编辑文件内容：

```yaml
version: '3'
services:
  hexo:
    build: .
    ports:
      - "4000:4000"
    volumes:
      - .:/app
    working_dir: /app
    environment:
      - NODE_ENV=development
    command: sh -c "if [ -f package.json ]; then npm install && hexo server -p 4000 --ip=0.0.0.0; else hexo init . && npm install && hexo server -p 4000 --ip=0.0.0.0; fi"
```

### 2.3 构建并启动 Docker 容器

```bash
# 构建 Docker 镜像
docker-compose build

# 启动 Hexo 服务
docker-compose up
```

首次启动时，如果目录为空，Docker 会自动执行 `hexo init` 初始化一个新的 Hexo 项目。

## 3. Hexo 仓库初始化及常用命令

### 3.1 手动初始化 Hexo 仓库

如果你想手动初始化 Hexo 项目（不使用 Docker 自动初始化），可以执行：

```bash
# 进入 Docker 容器
docker-compose exec hexo sh

# 在容器内初始化 Hexo
hexo init .
npm install
```

### 3.2 Hexo 常用命令

以下是一些 Hexo 的常用命令，你可以在 Docker 容器内执行这些命令：

```bash
# 创建新文章
hexo new "My New Post"

# 创建新页面
hexo new page "about"

# 生成静态文件
hexo generate # 或简写为 hexo g

# 启动本地服务器
hexo server # 或简写为 hexo s

# 生成并部署
hexo deploy # 或简写为 hexo d

# 清除缓存和生成的文件
hexo clean

# 查看帮助
hexo help
```

### 3.3 安装和配置主题

以 Butterfly 主题为例：

```bash
# 进入容器
docker-compose exec hexo sh

# 安装 Butterfly 主题
npm install hexo-theme-butterfly

# 安装必要的依赖
npm install hexo-renderer-pug hexo-renderer-stylus
```

然后修改 Hexo 的 `_config.yml` 文件，将主题设置为 butterfly：

```yaml
theme: butterfly
```

## 4. Obsidian 设置

### 4.1 安装 Obsidian

Obsidian 是一个本地 Markdown 知识库软件，需要在你的本地机器上安装：

1. 访问 [Obsidian 官网](https://obsidian.md/) 下载适用于 Ubuntu 的版本
2. 或使用以下命令安装：

```bash
# 下载最新版本的 Obsidian (替换 URL 为最新版本)
wget https://github.com/obsidianmd/obsidian-releases/releases/download/v0.15.9/obsidian_0.15.9_amd64.deb

# 安装
sudo apt install ./obsidian_*.deb
```

### 4.2 将 Obsidian 库指向 Hexo 的 source/_posts 目录

1. 打开 Obsidian
2. 选择 "Open folder as vault"
3. 导航到你的 Hexo 项目目录下的 `source/_posts` 文件夹
4. 点击 "Open"

现在，你已经将 Obsidian 设置为直接编辑 Hexo 博客的文章文件夹。

### 4.3 配置 Obsidian 插件

推荐安装以下插件以增强 Hexo 与 Obsidian 的集成体验：

1. **Templater** - 用于创建符合 Hexo front-matter 格式的文章模板
2. **Calendar** - 方便按日期查看和组织文章
3. **Obsidian Git** - 直接在 Obsidian 中进行 Git 操作

## 5. Hexo 与 Obsidian 工作流整合

### 5.1 创建 Hexo 文章模板

在 Obsidian 中，创建一个新的模板文件 `hexo-post.md`：

```markdown
---
title: {{title}}
date: {{date:YYYY-MM-DD HH:mm:ss}}
tags:
  - 
categories:
  - 
keywords: ''
description: ''
top_img: 
cover: 
---

# {{title}}

```

### 5.2 使用 Obsidian 编写文章

1. 在 Obsidian 中创建新的 Markdown 文件
2. 应用 Hexo 文章模板
3. 编写文章内容
4. 保存文件 (自动保存到 Hexo 的 source/_posts 目录)

### 5.3 使用 Hexo 生成和预览

```bash
# 在 Docker 容器中生成站点
docker-compose exec hexo hexo generate

# 或者重启 Docker 容器以预览
docker-compose restart
```

## 6. 自动化部署流程

### 6.1 安装 Git 部署插件

```bash
docker-compose exec hexo npm install hexo-deployer-git --save
```

### 6.2 配置 _config.yml 文件

编辑 Hexo 的 `_config.yml` 文件：

```yaml
deploy:
  type: git
  repo: https://github.com/username/username.github.io.git
  branch: main
```

### 6.3 创建部署脚本

创建一个 `deploy.sh` 脚本：

```bash
#!/bin/bash
cd ~/hexo-obsidian-project
docker-compose exec -T hexo hexo clean
docker-compose exec -T hexo hexo generate
docker-compose exec -T hexo hexo deploy
```

给脚本添加执行权限：

```bash
chmod +x deploy.sh
```

## 7. 备份和维护

### 7.1 使用 Git 管理整个项目

```bash
cd ~/hexo-obsidian-project
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/username/hexo-obsidian-project.git
git push -u origin main
```

### 7.2 创建定期备份脚本

```bash
#!/bin/bash
cd ~/hexo-obsidian-project
git add .
git commit -m "Backup $(date +'%Y-%m-%d %H:%M:%S')"
git push origin main
```

## 8. 故障排除

### 8.1 Docker 相关问题

- **容器无法启动**: 检查日志 `docker-compose logs`
- **端口冲突**: 修改 docker-compose.yml 中的端口映射

### 8.2 Hexo 相关问题

- **生成错误**: 尝试 `hexo clean` 然后重新生成
- **主题问题**: 确保主题正确安装和配置

### 8.3 Obsidian 相关问题

- **同步问题**: 确保 Obsidian 库正确指向 Hexo 的 source/_posts 目录
- **文件格式问题**: 确保 front-matter 符合 Hexo 的要求

## 总结

通过本指南，你已经成功地在 Ubuntu 22.04 上搭建了一个基于 Docker 的 Hexo 和 Obsidian 集成知识库系统。这个系统结合了 Hexo 的博客生成能力和 Obsidian 的知识管理功能，为你提供了一个强大的个人知识管理和分享平台。

记得定期备份你的数据，并根据需要调整配置以满足你的个性化需求。

祝你在知识管理和分享的旅程中取得成功！
