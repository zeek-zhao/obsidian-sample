---
title: hexo-user-guide
tags:
  - Hexo
  - 博客
  - 教程
categories:
  - - Hexo
    - 教程
keywords: 'Hexo, 博客搭建, 插件配置'
description: 全面的Hexo博客搭建与插件配置指南，包含主题美化、插件使用和Live2D模型部署等实用技巧。
top_img: >-
  https://images.unsplash.com/photo-1517842645767-c639042777db?ixlib=rb-4.0.3&auto=format&fit=crop&w=1600&h=400&q=80
cover: >-
  https://images.unsplash.com/photo-1517694712202-14dd9538aa97?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=600&q=80
comments: true
toc: true
toc_number: true
copyright: true
mathjax: true
abbrlink: 49516
date: 2023-11-25
updated: 2025-04-05
---

# Hexo 用户完全指南

## 1. Hexo 简介

Hexo 是一个快速、简洁且高效的博客框架。Hexo 使用 Markdown（或其他渲染引擎）解析文章，在几秒内，即可利用靓丽的主题生成静态网页。本指南将帮助你了解如何充分利用 Hexo 及其丰富的插件生态系统来打造你的个人博客。

## 2. 基本安装与配置

### 2.1 安装前提

- Node.js (版本 10.13 或更高)
- Git

### 2.2 安装 Hexo

```bash
npm install -g hexo-cli
hexo init blog
cd blog
npm install
```

### 2.3 基本命令

```bash
hexo clean     # 清除缓存和已生成的静态文件
hexo generate  # 生成静态文件
hexo server    # 启动本地服务器
hexo deploy    # 部署网站
```

## 3. Hexo基础配置详解

Hexo的基础配置主要通过根目录下的`_config.yml`文件进行管理，下面详细介绍各部分配置项。

### 3.1 站点信息配置

这部分配置定义了网站的基本信息：

```yaml
# 站点信息
title: 我的博客           # 网站标题
subtitle: '副标题'        # 网站副标题
description: '网站描述'   # 网站描述
keywords: 关键词          # SEO关键词
author: 作者名           # 作者名称
language: zh-CN          # 网站语言，默认英文(en)
timezone: 'Asia/Shanghai' # 时区，默认电脑时区
```

### 3.2 网址配置

设置网站URL结构：

```yaml
# 网址配置
url: https://example.com        # 网站网址
root: /                         # 网站根目录
permalink: :year/:month/:day/:title/  # 文章永久链接格式
permalink_defaults:             # 永久链接中各部分的默认值
pretty_urls:                    # 改写permalink的值来美化URL
  trailing_index: true          # 是否在永久链接中保留尾部的index.html
  trailing_html: true           # 是否在永久链接中保留尾部的.html
```

### 3.3 目录配置

定义Hexo的工作目录结构：

```yaml
# 目录配置
source_dir: source              # 资源文件夹，存放内容
public_dir: public              # 公共文件夹，存放生成的站点文件
tag_dir: tags                   # 标签文件夹
archive_dir: archives           # 归档文件夹
category_dir: categories        # 分类文件夹
code_dir: downloads/code        # Include code文件夹
i18n_dir: :lang                 # 国际化文件夹
skip_render:                    # 跳过指定文件的渲染
```

### 3.4 文章配置

设置文章的默认属性：

```yaml
# 文章配置
new_post_name: :title.md        # 新文章的文件名称
default_layout: post            # 预设布局
titlecase: false                # 把标题转换为Title Case
external_link:                  # 在新标签中打开链接
  enable: true                  # 在新标签中打开链接
  field: site                   # 应用于整个网站
  exclude: ''                   # 不包括特定域名
filename_case: 0                # 把文件名称转换为小写(1)或大写(2)
render_drafts: false            # 显示草稿
post_asset_folder: false        # 启用Asset文件夹
relative_link: false            # 把链接改为与根目录的相对位址
future: true                    # 显示未来的文章
highlight:                      # 代码块的设置
  enable: true                  # 开启代码高亮
  line_number: true             # 显示行号
  auto_detect: false            # 自动检测语言
  tab_replace: ''               # 用n个空格替换TAB
  wrap: true                    # 自动换行
  hljs: false                   # 使用highlight.js
prismjs:                        # Prism代码高亮设置
  enable: false                 # 开启Prism
  preprocess: true              # 预处理
  line_number: true             # 显示行号
  tab_replace: ''               # 用n个空格替换TAB
```

### 3.5 首页配置

控制首页文章摘要和阅读更多功能：

```yaml
# 首页设置
index_generator:
  path: ''                      # 首页路径
  per_page: 10                  # 每页显示的文章数
  order_by: -date               # 文章排序方式
  
# 摘要设置
auto_excerpt:
  enable: true                  # 启用自动摘要
  length: 150                   # 摘要长度(字数)
```

### 3.6 分类和标签

设置默认分类和标签：

```yaml
# 分类和标签
default_category: uncategorized # 默认分类
category_map:                   # 分类别名
tag_map:                        # 标签别名
```

### 3.7 日期/时间格式

设置日期和时间的显示格式：

```yaml
# 日期/时间格式
date_format: YYYY-MM-DD         # 日期格式
time_format: HH:mm:ss           # 时间格式
updated_option: mtime           # 文件更新时间的选项
```

### 3.8 分页配置

控制分页行为：

```yaml
# 分页配置
per_page: 10                    # 每页显示的文章数量
pagination_dir: page            # 分页目录
```

### 3.9 主题配置

选择并配置主题：

```yaml
# 主题配置
theme: landscape                # 当前主题名称
theme_config:                   # 主题的配置
  # 这里可以放置任何主题特定的配置
```

### 3.10 部署配置

设置博客部署方式：

```yaml
# 部署配置
deploy:
  type: git                     # 部署类型
  repo: <repository url>        # 仓库地址
  branch: [branch]              # 部署分支
  message: [message]            # 自定义提交消息
```

## 4. 核心插件介绍与配置

### 4.1 站点地图生成 (hexo-generator-sitemap)

用于生成站点地图，有助于搜索引擎索引你的博客。

```bash
npm install hexo-generator-sitemap --save
```

在站点配置文件 `_config.yml` 中添加配置：

```yaml
sitemap:
  path: sitemap.xml
  rel: false
  tags: true
  categories: true
```

### 4.2 RSS Feed 生成 (hexo-generator-feed)

为博客生成 RSS 订阅源。

```bash
npm install hexo-generator-feed --save
```

配置示例：

```yaml
feed:
  type: atom
  path: atom.xml
  limit: 20
  hub:
  content:
  content_limit: 140
  content_limit_delim: ' '
  order_by: -date
```

### 4.3 文章归档生成 (hexo-generator-archive)

生成博客文章归档页面。

```bash
npm install hexo-generator-archive --save
```

配置示例：

```yaml
archive_generator:
  per_page: 10
  yearly: true
  monthly: true
  daily: false
```

### 4.4 分类生成 (hexo-generator-category)

生成文章分类页面。

```bash
npm install hexo-generator-category --save
```

配置：

```yaml
category_generator:
  per_page: 10
```

### 4.5 标签生成 (hexo-generator-tag)

生成标签归档页面。

```bash
npm install hexo-generator-tag --save
```

配置：

```yaml
tag_generator:
  per_page: 10
```

### 4.6 首页生成 (hexo-generator-index)

生成博客首页。

```bash
npm install hexo-generator-index --save
```

配置：

```yaml
index_generator:
  path: ''
  per_page: 10
  order_by: -date
```

### 4.7 本地服务器 (hexo-server)

提供本地预览功能。

```bash
npm install hexo-server --save
```

使用：`hexo server` 启动本地服务器。

### 4.8 搜索功能 (hexo-generator-searchdb)

为博客添加本地搜索功能。

```bash
npm install hexo-generator-searchdb --save
```

配置：

```yaml
search:
  path: search.xml
  field: post
  content: true
  format: html
```

### 4.9 Git 部署 (hexo-deployer-git)

使用 Git 部署博客到远程仓库。

```bash
npm install hexo-deployer-git --save
```

配置：

```yaml
deploy:
  type: git
  repo: https://github.com/username/username.github.io.git
  branch: master
```

## 5. 高级功能插件

### 5.1 音乐播放器 (hexo-tag-aplayer)

在文章中嵌入音乐播放器。

```bash
npm install hexo-tag-aplayer --save
```

使用示例：

```markdown
{% aplayer "歌名" "歌手" "音乐文件链接" "封面图片链接" "autoplay" %}
```

### 5.2 Markdown 渲染 (hexo-renderer-kramed)

增强的 Markdown 渲染器。

```bash
npm install hexo-renderer-kramed --save
```

### 5.3 EJS 模板渲染 (hexo-renderer-ejs)

EJS 模板引擎。

```bash
npm install hexo-renderer-ejs --save
```

### 5.4 Pug 模板渲染 (hexo-renderer-pug)

Pug 模板引擎，一些主题（如 Butterfly）需要。

```bash
npm install hexo-renderer-pug --save
```

### 5.5 Stylus CSS 预处理 (hexo-renderer-stylus)

Stylus CSS 预处理器，一些主题需要。

```bash
npm install hexo-renderer-stylus --save
```

### 5.6 字数统计 (hexo-wordcount)

统计文章字数和阅读时间。

```bash
npm install hexo-wordcount --save
```

在主题配置中启用：

```yaml
wordcount:
  enable: true
  post_wordcount: true
  min2read: true
  total_wordcount: true
```

### 5.7 数学公式支持 (hexo-filter-mathjax)

为博客添加 MathJax 支持，展示数学公式。

```bash
npm install hexo-filter-mathjax --save
```

配置：

```yaml
mathjax:
  tags: none
  single_dollars: true
  cjk_width: 0.9
  normal_width: 0.6
  append_css: true
  every_page: false
```

在需要使用数学公式的文章前添加：

```yaml
---
mathjax: true
---
```

### 5.8 相关文章推荐 (hexo-related-popular-posts)

在文章底部显示相关文章推荐。

```bash
npm install hexo-related-popular-posts --save
```

配置：

```yaml
popularPosts:
  eyeCatcherLimit: 5
  rankingLimit: 6
```

## 6. Butterfly 主题配置

### 6.1 安装 Butterfly 主题

```bash
npm install hexo-theme-butterfly --save
```

修改站点配置文件：

```yaml
theme: butterfly
```

### 6.2 主题配置文件

Butterfly 主题有丰富的配置选项，包括：
- 导航菜单
- 侧边栏设置
- 页脚设置
- 文章页面设置
- 代码高亮
- 社交图标
- 第三方评论系统
- 数据统计
- 搜索功能

详细配置请参考 Butterfly 官方文档。

## 7. Live2D 看板娘配置

### 7.1 安装基础插件

```bash
npm install hexo-helper-live2d --save
```

### 7.2 安装模型包

```bash
# 安装 hijiki 模型
npm install live2d-widget-model-hijiki --save

# 安装 miku 模型
npm install live2d-widget-model-miku --save

# 安装 tororo 模型
npm install live2d-widget-model-tororo --save
```

### 7.3 配置 Live2D

在站点配置文件中添加：

```yaml
live2d:
  enable: true
  scriptFrom: local
  pluginRootPath: live2dw/
  pluginJsPath: lib/
  pluginModelPath: assets/
  tagMode: false
  debug: false
  model:
    use: live2d-widget-model-miku  # 可以更换为其他模型
  display:
    position: right
    width: 150
    height: 300
  mobile:
    show: false
  react:
    opacity: 0.7
```

## 8. 性能优化技巧

- 使用 `hexo-all-minifier` 压缩静态资源
- 启用浏览器缓存
- 使用 CDN 加速静态资源
- 延迟加载图片和脚本
- 减少 HTTP 请求数量

## 9. 常见问题与解决方案

### 9.1 部署失败

检查 Git 配置和仓库权限，确保 SSH 密钥设置正确。

### 9.2 插件冲突

如遇插件冲突，尝试更新或重新安装有问题的插件。

### 9.3 主题显示异常

检查主题配置文件，确保语法正确，使用兼容的插件版本。

## 10. 结语

Hexo 提供了丰富的插件生态系统，可以帮助你打造一个功能完善、美观大方的个人博客。希望本指南能够帮助你充分利用 Hexo 的各项功能，创建一个独特的个人网站！

---

## 扩展阅读

- [Butterfly 主题文档](https://butterfly.js.org/)
- [Obsidian 官方文档](https://help.obsidian.md/Obsidian/Index)

> 更多 Hexo 相关教程和资源，请访问 [Hexo 官方文档](https://hexo.io/zh-cn/docs/)
