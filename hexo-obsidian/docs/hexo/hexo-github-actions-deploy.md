---
title: hexo-github-actions-deploy
tags:
  - Hexo
  - GitHub Actions
  - SSH
  - CI/CD
categories:
  - - Hexo
    - 教程
keywords: 'Hexo,GitHub Actions,SSH,自动部署,CI/CD,持续集成'
description: 使用 GitHub Actions 和 SSH 密钥实现 Hexo 博客的自动部署和手动本地部署完整教程
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
abbrlink: 37926
date: 2023-12-15
updated: 2025-04-05
---

# Hexo 使用 GitHub Actions SSH 自动部署指南

本文将详细介绍如何使用 GitHub Actions 和 SSH 密钥来实现 Hexo 博客的自动部署，以及如何进行手动本地部署。通过这种方式，你可以实现博客内容更新后的自动化部署流程，大大提高工作效率。

## 1. 部署方案概述

在部署 Hexo 博客时，我们通常有两种选择：

1. **本地手动部署**：在本地生成静态文件并推送到服务器或 GitHub Pages
2. **GitHub Actions 自动部署**：提交代码到 GitHub 后自动触发构建和部署流程

本教程将同时介绍这两种方法，你可以根据自己的需求选择合适的方案。

## 2. 前期准备工作

### 2.1 生成 SSH 密钥对

我们需要生成专用的 SSH 密钥对用于部署：

```bash
# 创建目录确保安全
mkdir -p ~/.ssh/hexo_deploy

# 生成 SSH 密钥对，建议使用 Ed25519 算法（更安全，密钥更短）
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/hexo_deploy/github_actions_deploy

# 或者使用 RSA 算法（如果需要更广泛的兼容性）
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/hexo_deploy/github_actions_deploy
```

这将生成两个文件：
- `~/.ssh/hexo_deploy/github_actions_deploy`（私钥）
- `~/.ssh/hexo_deploy/github_actions_deploy.pub`（公钥）

> **注意**：请妥善保管私钥，不要将其提交到公共仓库中。

### 2.2 安装 Hexo 部署插件

确保已安装 Git 部署插件：

```bash
npm install hexo-deployer-git --save
```

### 2.3 配置 Hexo

修改 Hexo 配置文件 `_config.yml`，添加部署设置：

```yaml
deploy:
  type: git
  repo: git@github.com:用户名/用户名.github.io.git
  branch: main  # 或 master，取决于你的默认分支
```

## 3. GitHub 仓库配置

### 3.1 创建必要的仓库

对于 GitHub Pages 部署，你需要两个仓库：

1. **源码仓库**：存储 Hexo 博客的源文件（例如：`blog-source`）
2. **部署仓库**：存储生成的静态文件（例如：`username.github.io`）

如果你已有这些仓库，请跳过此步骤。

### 3.2 配置部署密钥

#### 为部署仓库添加部署密钥

1. 复制公钥文件的内容:

```bash
cat ~/.ssh/hexo_deploy/github_actions_deploy.pub
```

2. 前往你的 GitHub Pages 仓库（如 `username.github.io`）
3. 点击 `Settings` > `Deploy keys` > `Add deploy key`
4. 粘贴公钥内容，并为其命名（例如 "Hexo Deployment Key"）
5. **重要**：勾选 `Allow write access` 选项
6. 点击 `Add key` 保存

#### 为源码仓库添加 Secret

1. 复制私钥文件的内容:

```bash
cat ~/.ssh/hexo_deploy/github_actions_deploy
```

2. 前往你的 Hexo 源码仓库
3. 点击 `Settings` > `Secrets and variables` > `Actions` > `New repository secret`
4. 名称设为 `DEPLOY_KEY`
5. 值为私钥的完整内容
6. 点击 `Add secret` 保存

## 4. GitHub Actions 自动部署

### 4.1 创建工作流文件

在源码仓库的根目录下创建 `.github/workflows/deploy.yml` 文件：

```bash
mkdir -p .github/workflows
touch .github/workflows/deploy.yml
```

### 4.2 配置工作流文件

将以下内容添加到 `deploy.yml` 文件中：

```yaml
name: Deploy Hexo Site

on:
  push:
    branches: [main]  # 当推送到 main 分支时触发
  workflow_dispatch:  # 允许手动触发

jobs:
  build-and-deploy:
    runs-on: ubuntu-22.04
    
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3
        with:
          submodules: true  # 同时克隆子模块（主题可能是子模块）
          fetch-depth: 0    # 获取完整历史以便获取上次提交信息
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '16'
          cache: 'npm'
      
      - name: Install Dependencies
        run: npm ci || npm install
      
      - name: Configure Git and SSH
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
        run: |
          sudo timedatectl set-timezone "Asia/Shanghai"
          mkdir -p ~/.ssh/
          echo "$DEPLOY_KEY" | tr -d '\r' > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
          ssh-keyscan github.com >> ~/.ssh/known_hosts
          git config --global user.name "devops.zeek"
          git config --global user.email "devops.zeek@devops.com"
      
      - name: Generate and Deploy
        run: |
          npm install hexo-cli -g
          npm install hexo-deployer-git --save
          hexo clean
          hexo generate
          hexo deploy
```

### 4.3 自定义部署配置

针对不同的项目结构，你可能需要对工作流文件进行调整：

#### 4.3.1 多级目录结构

如果你的 Hexo 源文件在子目录中（例如 `src/`），请修改工作流文件：

```yaml
- name: Generate and Deploy
  run: |
    cd src  # 进入包含 Hexo 文件的目录
    npm install hexo-cli -g
    npm install hexo-deployer-git --save
    hexo clean
    hexo generate
    hexo deploy
```

#### 4.3.2 使用 peaceiris/actions-gh-pages 进行部署

如果你希望使用专用的 GitHub Pages 部署 Action，可以替换部署步骤：

```yaml
- name: Deploy to GitHub Pages
  uses: peaceiris/actions-gh-pages@v3
  with:
    deploy_key: ${{ secrets.DEPLOY_KEY }}
    publish_dir: ./public  # Hexo 生成的静态文件目录
    publish_branch: main   # 要部署到的分支
    commit_message: ${{ github.event.head_commit.message }}
```

## 5. 手动本地部署

### 5.1 配置 SSH 配置文件

创建或编辑 `~/.ssh/config` 文件：

```bash
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/hexo_deploy/github_actions_deploy
    IdentitiesOnly yes
```

### 5.2 创建便捷部署脚本

在博客根目录下创建 `deploy.sh` 脚本：

```bash
#!/bin/bash

echo "====== 开始部署 Hexo 博客 ======"

# 清理并生成静态文件
echo "1. 清理缓存..."
hexo clean

echo "2. 生成静态文件..."
hexo generate

echo "3. 部署到远程仓库..."
hexo deploy

# 检查部署结果
if [ $? -eq 0 ]; then
    echo "✅ 部署成功！请等待几分钟，然后检查您的网站。"
    echo "🌐 网站地址: $(grep "url:" _config.yml | sed 's/url: //')"
else
    echo "❌ 部署失败，请检查错误信息。"
    exit 1
fi

echo "====== 部署完成 ======"
```

添加执行权限：

```bash
chmod +x deploy.sh
```

### 5.3 执行部署

```bash
./deploy.sh
```

## 6. 高级配置与优化

### 6.1 自定义触发条件

你可以根据需求自定义工作流触发条件：

```yaml
on:
  push:
    branches:
      - main
    paths:
      - 'source/**'    # 只有当 source 目录下文件变更时触发
      - 'themes/**'    # 只有当主题文件变更时触发
      - '_config.yml'  # 只有当配置文件变更时触发
  schedule:
    - cron: '0 2 * * *'  # 每天 UTC 时间 2:00 自动构建（对应北京时间 10:00）
  workflow_dispatch:     # 允许从 GitHub UI 手动触发
```

### 6.2 提高构建速度

使用缓存加速依赖安装：

```yaml
- name: Cache Node Modules
  uses: actions/cache@v3
  with:
    path: |
      **/node_modules
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

### 6.3 构建状态通知

通过电子邮件或 Telegram 接收构建状态通知：

```yaml
- name: Send Notification on Failure
  if: failure()
  uses: appleboy/telegram-action@master
  with:
    to: ${{ secrets.TELEGRAM_TO }}
    token: ${{ secrets.TELEGRAM_TOKEN }}
    message: |
      ❌ Hexo 部署失败！
      仓库: ${{ github.repository }}
      查看详情: https://github.com/${{ github.repository }}/actions/runs/${{ github.run_id }}
```

## 7. 故障排除指南

### 7.1 常见部署问题

#### SSH 密钥问题

如果遇到 SSH 连接问题：

```bash
# 测试 SSH 连接
ssh -i ~/.ssh/hexo_deploy/github_actions_deploy -T git@github.com

# 确保私钥权限正确
chmod 600 ~/.ssh/hexo_deploy/github_actions_deploy

# 检查 SSH 代理
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/hexo_deploy/github_actions_deploy
```

#### 部署仓库问题

如果 GitHub Pages 没有正确更新：

1. 检查仓库设置中的 Pages 配置
2. 确认已正确设置部署分支
3. 检查部署分支上是否有 `.nojekyll` 文件（防止 GitHub Pages 使用 Jekyll 处理）

### 7.2 GitHub Actions 调试

如果 Actions 执行失败：

1. 查看详细的 Actions 日志
2. 临时添加调试步骤：

```yaml
- name: Debug Information
  run: |
    echo "GitHub 上下文:"
    echo '${{ toJson(github) }}'
    echo "环境变量:"
    env
    echo "工作目录内容:"
    ls -la
```

### 7.3 Hexo 生成问题

如果 Hexo 生成静态文件时出错：

```bash
# 清理缓存
hexo clean

# 检查依赖项
npm install

# 调试模式运行
hexo generate --debug

# 检查插件冲突
npm ls --depth=0
```

## 8. 安全最佳实践

### 8.1 使用专用部署密钥

不要使用你的个人 SSH 密钥：

```bash
# 创建仅用于部署的密钥
ssh-keygen -t ed25519 -C "deploy-key" -f ~/.ssh/hexo_deploy/github_actions_deploy -N ""
```

### 8.2 定期轮换密钥

定期更换部署密钥提高安全性：

```bash
# 生成新密钥
ssh-keygen -t ed25519 -C "deploy-key-new" -f ~/.ssh/hexo_deploy/github_actions_deploy_new

# 在 GitHub 上更新密钥
# 1. 更新部署仓库的 Deploy Key
# 2. 更新源码仓库的 Secret
```

### 8.3 限制 GitHub Actions 权限

在工作流文件中明确定义权限：

```yaml
permissions:
  contents: read  # 对内容的读取权限
  pages: write    # 对 Pages 的写入权限
  id-token: write # 用于身份验证
```

## 总结

本文详细介绍了使用 GitHub Actions 和 SSH 密钥实现 Hexo 博客自动部署的完整流程。通过这个设置，你可以专注于创作内容，将部署工作交给自动化工具处理。

无论你选择本地手动部署还是 GitHub Actions 自动部署，这两种方法都能有效地将你的 Hexo 博客发布到网络上。根据自己的工作习惯和团队需求选择合适的方案，让博客维护变得更加高效和愉快。

如有问题，请参考 [Hexo 文档](https://hexo.io/docs/) 或 [GitHub Actions 文档](https://docs.github.com/en/actions)，也欢迎在评论区留言交流。

祝你的博客之旅愉快！
