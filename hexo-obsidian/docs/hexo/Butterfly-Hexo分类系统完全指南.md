---
title: Butterfly-Hexo分类系统完全指南
tags:
  - Hexo
  - 分类
  - 教程
  - 网站结构
categories:
  - - Hexo
    - 内容组织
  - - Hexo
    - example
keywords: 'Hexo分类,分类系统,内容组织,博客结构'
description: 详解Hexo的分类系统，包括创建、嵌套、自定义和最佳实践，帮助您更好地组织博客内容。
top_img: >-
  https://images.unsplash.com/photo-1516414447565-b14be0adf13e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1600&h=400&q=80
cover: >-
  https://images.unsplash.com/photo-1499750310107-5fef28a66643?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=600&q=80
comments: true
toc: true
abbrlink: 11354
date: 2023-09-01
updated: 2025-04-05
---

# Hexo分类系统完全指南

分类是Hexo中组织内容的重要方式，可以帮助读者更轻松地浏览和找到相关文章。本文将详细介绍Hexo分类系统的使用方法和最佳实践。

## 分类基础概念

在Hexo中，分类和标签是两种不同的内容组织方式：

- **分类(Categories)**: 具有层级关系，一篇文章可以属于多个分类，但通常反映了文章的主要内容类型
- **标签(Tags)**: 平行结构，用于标记文章的各个方面，一篇文章通常有多个标签

分类的关键特点：

1. 分类可以有层级关系（类似目录结构）
2. 一篇文章可以属于多个分类
3. 每个分类都有专门的归档页面

## 在文章中使用分类

### 基本用法

在文章的Front Matter部分使用`categories`字段定义分类：

```yaml
---
title: 文章标题
categories: 技术
---
```

这样会将文章归类到"技术"分类下。

### 多个分类

一篇文章可以属于多个分类，使用数组语法：

```yaml
---
title: 文章标题
categories: 
  - 技术
  - 教程
---
```

这样文章会同时出现在"技术"和"教程"两个分类中。

### 嵌套分类（多级分类）

Hexo支持嵌套分类，形成层级结构：

```yaml
---
title: 文章标题
categories:
  - [技术, 前端, JavaScript]
  - [编程, Web开发]
---
```

上面的设置会创建以下分类结构：
- 技术 > 前端 > JavaScript
- 编程 > Web开发

文章会同时归属于这两个分类路径。

## 创建分类页面

要使用分类功能，需要先创建分类页面：

```bash
hexo new page categories
```

这将创建`source/categories/index.md`文件，然后修改这个文件：

```yaml
---
title: 分类
date: 2023-09-01
type: "categories"
layout: "categories"
---
```

添加`type: "categories"`是关键，它告诉Hexo这是一个分类页面。

## 分类的URL结构

默认情况下，分类的URL格式为：

```
https://yoursite.com/categories/分类名/
```

嵌套分类的URL：

```
https://yoursite.com/categories/父分类/子分类/
```

您可以在`_config.yml`中自定义这个路径：

```yaml
category_dir: categories
```

## 在主题中显示分类

### 文章中显示分类

大多数主题会在文章页面显示其所属分类，通常位于标题下方或侧边栏。

### 添加分类导航链接

在主题的导航菜单中添加分类页面链接：

```yaml
# Butterfly主题示例
menu:
  Home: / || fas fa-home
  Archives: /archives/ || fas fa-archive
  Categories: /categories/ || fas fa-folder-open
  Tags: /tags/ || fas fa-tags
```

## 分类的最佳实践

### 建立清晰的分类体系

在开始写博客前，规划一个清晰的分类体系，例如：

- 技术
  - 前端
  - 后端
  - 移动开发
- 教程
- 随笔
- 读书笔记

### 避免过多的顶级分类

顶级分类不宜过多，通常5-10个较为合适，太多会导致导航混乱。

### 保持分类名称简洁

使用简短、明确的分类名称，避免使用长句子作为分类名。

### 分类VS标签

- 分类：用于大的内容方向划分，反映文章的主要归属
- 标签：用于标记文章的各个方面的关键词，可以更灵活

## 分类的高级应用

### 使用分类筛选文章

生成特定分类的文章列表：

```
{% set category_posts = site.categories.findOne({name: '技术'}).posts.sort('date', -1).limit(5).toArray() %}
{% for post in category_posts %}
  <a href="{{ url_for(post.path) }}">{{ post.title }}</a>
{% endfor %}
```

### 分类文章数量统计

显示每个分类的文章数量：

```
{% for cat in site.categories %}
  <li>
    <a href="{{ url_for(cat.path) }}">{{ cat.name }}</a>
    <span>({{ cat.length }})</span>
  </li>
{% endfor %}
```

### 自定义分类页面

您可以通过修改主题模板自定义分类页面的显示方式，例如添加分类描述、自定义排序或分组展示。

## 常见问题解答

### 分类名称中有空格怎么办？

分类名称中的空格在URL中会被转换为`-`，例如"Web 开发"会变成`/categories/Web-开发/`。

### 中文分类名称是否有问题？

Hexo支持中文分类名称，但在某些服务器或系统上可能需要进行URL编码。大多数情况下没有问题。

### 如何修改已有文章的分类？

直接修改文章Front Matter中的`categories`字段，然后重新生成网站即可。

### 如何删除不再使用的分类？

Hexo会自动处理，当没有文章使用该分类时，它在重新生成后会自动消失。

## 总结

分类系统是组织Hexo博客内容的强大工具，通过合理设置分类，可以让您的网站结构更清晰，访问者能更轻松地找到感兴趣的内容。

建议：
- 在开始写作前规划好分类体系
- 合理使用嵌套分类来构建层级结构
- 将分类与标签结合使用，实现多维度的内容组织

通过本文的指导，您应该能够充分利用Hexo的分类系统，创建一个组织良好的知识库网站。
