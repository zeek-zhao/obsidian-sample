---
title: Butterfly-不改动主题源码实现自定义侧边栏
tags:
  - Hexo
  - Butterfly
  - 侧边栏
  - 自定义
categories:
  - - Hexo
    - Butterfly
keywords: 'Hexo,Butterfly,侧边栏,自定义,不改源码'
description: 如何不修改Butterfly主题源码实现侧边栏的个性化自定义，包括添加自定义内容、修改样式以及增强功能
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
abbrlink: 58598
date: 2023-12-05
updated: 2025-04-05
---

# Butterfly主题不改动源码实现自定义侧边栏

Butterfly主题的侧边栏是博客的重要组成部分，但有时我们希望对其进行个性化定制，又不想直接修改主题源码（这样可以避免在主题更新时丢失自定义内容）。本文将介绍几种不改动源码实现侧边栏自定义的方法。

## 为什么不建议直接修改主题源码

在Hexo中，如果直接修改主题的源代码：

1. 当主题更新时，你的修改会被覆盖
2. 难以追踪和管理自定义更改
3. 可能导致与主题未来版本的兼容性问题

因此，本文介绍的方法都是通过Hexo和Butterfly提供的扩展机制来实现自定义，而不直接修改主题源文件。

## 方法一：使用Butterfly提供的inject注入功能

Butterfly主题提供了强大的注入功能，可以在不修改源码的情况下注入自定义内容。

### 1. 配置inject功能

在Butterfly的主题配置文件`_config.butterfly.yml`中找到`inject`部分：

```yaml
# Inject
# Insert the code to head (before '</head>' tag) and the bottom (before '</body>' tag)
# 插入代码到头部 </head> 之前 和 底部 </body> 之前
inject:
  head:
    # - <link rel="stylesheet" href="/xxx.css">
  bottom:
    # - <script src="xxxx"></script>
```

### 2. 创建自定义侧边栏小部件

在Hexo根目录的`source`文件夹下创建一个新的目录用于存放自定义JavaScript和CSS，例如`/source/js`和`/source/css`。

#### 创建自定义侧边栏JS文件

创建文件：`/source/js/custom-aside.js`

```javascript
document.addEventListener('DOMContentLoaded', function() {
  // 获取侧边栏元素
  const asideContent = document.querySelector('#aside-content');
  if (!asideContent) return;
  
  // 创建自定义卡片
  const customCard = document.createElement('div');
  customCard.className = 'card-widget card-custom';
  customCard.innerHTML = `
    <div class="card-content">
      <div class="item-headline">
        <i class="fas fa-star"></i>
        <span>自定义小部件</span>
      </div>
      <div class="custom-content">
        <p>这是我的自定义小部件内容</p>
        <ul>
          <li><a href="https://example.com">链接1</a></li>
          <li><a href="https://example.com">链接2</a></li>
          <li><a href="https://example.com">链接3</a></li>
        </ul>
      </div>
    </div>
  `;
  
  // 将自定义卡片插入到侧边栏
  // 可以根据需要调整插入位置
  const authorCard = asideContent.querySelector('.card-author');
  if (authorCard && authorCard.nextSibling) {
    asideContent.insertBefore(customCard, authorCard.nextSibling);
  } else {
    asideContent.appendChild(customCard);
  }
});
```

#### 创建自定义样式文件

创建文件：`/source/css/custom-aside.css`

```css
/* 自定义侧边栏卡片样式 */
.card-custom {
  margin-top: 1rem;
  border-radius: 8px;
  background: var(--card-bg);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.05);
  transition: all 0.3s;
}

.card-custom:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.card-custom .custom-content {
  padding: 0.5rem 1rem;
}

.card-custom .custom-content ul {
  margin-top: 0.5rem;
  padding-left: 1.2rem;
}

.card-custom .custom-content a {
  color: var(--font-color);
  transition: all 0.3s;
}

.card-custom .custom-content a:hover {
  color: var(--theme-color);
  text-decoration: underline;
}
```

#### 在主题配置文件中注入自定义文件

修改`_config.butterfly.yml`中的`inject`部分：

```yaml
inject:
  head:
    - <link rel="stylesheet" href="/css/custom-aside.css">
  bottom:
    - <script src="/js/custom-aside.js"></script>
```

### 3. 使用pug模板创建侧边栏小部件

Butterfly支持使用pug模板创建自定义侧边栏小部件。

1. 在Hexo根目录创建`source/_data/widget`文件夹
2. 在此文件夹中创建pug文件，例如`custom_widget.pug`

```pug
.card-widget.card-custom-pug
  .card-content
    .item-headline
      i.fas.fa-award
      span 自定义Pug小部件
    .custom-content
      p 这是通过pug模板创建的自定义小部件
      ul
        li
          a(href='https://example.com/1') 自定义链接1
        li
          a(href='https://example.com/2') 自定义链接2
        li
          a(href='https://example.com/3') 自定义链接3
```

3. 在`_config.butterfly.yml`中启用自定义小部件：

```yaml
aside:
  enable: true
  hide: false
  button: true
  mobile: true
  position: right
  display:
    archive: true
    tag: true
    category: true
  card_author:
    enable: true
    description:
    button:
      enable: true
      icon: fab fa-github
      text: Follow Me
      link: https://github.com/yourusername
  card_announcement:
    enable: true
    content: 欢迎来到我的博客！
  card_recent_post:
    enable: true
    limit: 5
    sort: date
    sort_order: 
  card_categories:
    enable: true
    limit: 8
    expand: none
    sort: name
  card_tags:
    enable: true
    limit: 40
    color: false
    orderby: random
  card_archives:
    enable: true
    type: monthly
    format: MMMM YYYY
    order: -1
    limit: 8
    sort_order: 
  card_webinfo:
    enable: true
    post_count: true
    last_push_date: true
    sort_order: 
  # 自定义小部件
  card_custom_pug:
    enable: true
    sort_order: 4 # 位置排序，数字越小越靠前
```

## 方法二：使用自定义布局文件

Hexo支持在`source/_data`目录下创建自定义布局文件，可以复写主题的部分布局。

### 1. 创建自定义侧边栏布局

首先需要安装相关插件：

```bash
npm install hexo-inject --save
```

然后在站点根目录创建文件：`source/_data/sidebar.swig`

```swig
<div class="card-widget card-custom-widget">
  <div class="card-content">
    <div class="item-headline">
      <i class="fas fa-magic"></i>
      <span>自定义布局小部件</span>
    </div>
    <div class="custom-content">
      <p>这是通过自定义布局文件创建的小部件</p>
      <div class="custom-links">
        {% for link in theme.custom_links %}
          <a href="{{ link.url }}" target="_blank">{{ link.title }}</a>
        {% endfor %}
      </div>
    </div>
  </div>
</div>
```

### 2. 使用hexo-inject插件注入

在站点配置文件`_config.yml`中添加以下配置：

```yaml
custom_links:
  - title: 友情链接1
    url: https://example.com/1
  - title: 友情链接2
    url: https://example.com/2
  - title: 友情链接3
    url: https://example.com/3
```

创建JavaScript文件：`source/js/inject-sidebar.js`

```javascript
document.addEventListener('DOMContentLoaded', function() {
  fetch('/sidebar.swig')
    .then(response => response.text())
    .then(html => {
      const parser = new DOMParser();
      const doc = parser.parseFromString(html, 'text/html');
      const customWidget = doc.querySelector('.card-custom-widget');
      
      if (customWidget) {
        const asideContent = document.querySelector('#aside-content');
        const insertAfter = asideContent.querySelector('.card-info');
        
        if (insertAfter) {
          insertAfter.parentNode.insertBefore(customWidget, insertAfter.nextSibling);
        } else {
          asideContent.appendChild(customWidget);
        }
      }
    })
    .catch(error => console.error('加载自定义侧边栏失败:', error));
});
```

然后在主题配置中注入此脚本：

```yaml
inject:
  bottom:
    - <script src="/js/inject-sidebar.js"></script>
```

## 方法三：使用自定义主题配置文件

Butterfly主题允许使用自定义配置文件添加额外的功能。

### 1. 创建自定义配置文件

在站点根目录创建`_config.butterfly.yml`文件（如果已存在则编辑它）：

```yaml
# 自定义侧边栏配置
aside:
  enable: true
  hide: false
  button: true
  mobile: true
  position: right
  card_author:
    enable: true
    description: 这是我的个人描述，可以在这里介绍自己。
    button:
      enable: true
      icon: fab fa-github
      text: 关注我
      link: https://github.com/yourusername
  # 自定义公告栏内容
  card_announcement:
    enable: true
    content: |
      <div class="announcement-content">
        <p>欢迎访问我的博客！</p>
        <p>这是一个<span style="color: #ff7800;">自定义样式</span>的公告栏</p>
        <div class="announcement-links">
          <a href="/about/">关于我</a>
          <a href="/friends/">友链</a>
          <a href="/contact/">联系方式</a>
        </div>
      </div>
```

### 2. 添加自定义CSS样式

创建样式文件：`source/css/custom-announcement.css`

```css
/* 自定义公告栏样式 */
.announcement-content {
  line-height: 1.6;
}

.announcement-links {
  display: flex;
  justify-content: space-around;
  margin-top: 10px;
}

.announcement-links a {
  display: inline-block;
  padding: 4px 10px;
  background: rgba(var(--theme-color-rgb), 0.1);
  border-radius: 4px;
  color: var(--theme-color);
  transition: all 0.3s;
}

.announcement-links a:hover {
  background: rgba(var(--theme-color-rgb), 0.2);
  transform: translateY(-2px);
}
```

注入CSS文件：

```yaml
inject:
  head:
    - <link rel="stylesheet" href="/css/custom-announcement.css">
```

## 方法四：添加新的侧边栏组件

你可以通过JavaScript完全添加新的侧边栏组件。

### 1. 创建动态侧边栏组件

创建文件：`source/js/dynamic-sidebar.js`

```javascript
document.addEventListener('DOMContentLoaded', function() {
  const asideContent = document.querySelector('#aside-content');
  if (!asideContent) return;
  
  // 创建天气组件
  const weatherWidget = document.createElement('div');
  weatherWidget.className = 'card-widget card-weather';
  weatherWidget.innerHTML = `
    <div class="card-content">
      <div class="item-headline">
        <i class="fas fa-cloud-sun"></i>
        <span>天气预报</span>
      </div>
      <div id="weather-container">
        <div class="loading">加载中...</div>
      </div>
    </div>
  `;
  
  // 插入天气组件
  const webinfoCard = asideContent.querySelector('.card-webinfo');
  if (webinfoCard) {
    asideContent.insertBefore(weatherWidget, webinfoCard);
  } else {
    asideContent.appendChild(weatherWidget);
  }
  
  // 这里可以添加获取天气API的代码
  // 为简化示例，使用静态内容替代
  setTimeout(() => {
    document.getElementById('weather-container').innerHTML = `
      <div class="weather-info">
        <div class="weather-location">北京</div>
        <div class="weather-temp">23°C</div>
        <div class="weather-desc">晴朗</div>
      </div>
    `;
  }, 1000);
});
```

### 2. 添加相应的CSS样式

创建文件：`source/css/dynamic-sidebar.css`

```css
/* 天气组件样式 */
.card-weather {
  margin-top: 1rem;
}

.card-weather .loading {
  text-align: center;
  padding: 10px;
  color: #999;
}

.weather-info {
  padding: 10px;
  text-align: center;
}

.weather-location {
  font-weight: bold;
  margin-bottom: 5px;
}

.weather-temp {
  font-size: 1.5rem;
  color: var(--theme-color);
  margin-bottom: 3px;
}

.weather-desc {
  color: #666;
}
```

### 3. 注入文件

在主题配置文件中注入自定义文件：

```yaml
inject:
  head:
    - <link rel="stylesheet" href="/css/dynamic-sidebar.css">
  bottom:
    - <script src="/js/dynamic-sidebar.js"></script>
```

## 常见自定义需求示例

### 自定义侧边栏顺序

你可以通过CSS调整侧边栏各组件的顺序：

```css
/* 调整侧边栏组件顺序 */
#aside-content {
  display: flex;
  flex-direction: column;
}

#aside-content .card-info {
  order: 1;
}

#aside-content .card-announcement {
  order: 2;
}

#aside-content .card-recent-post {
  order: 3;
}

#aside-content .card-categories {
  order: 4;
}

#aside-content .card-tags {
  order: 5;
}

#aside-content .card-archives {
  order: 6;
}

#aside-content .card-webinfo {
  order: 7;
}

/* 自定义组件可以指定位置 */
#aside-content .card-custom {
  order: 3.5; /* 在最近文章和分类之间 */
}
```

### 添加访客统计组件

创建访客统计JavaScript：

```javascript
document.addEventListener('DOMContentLoaded', function() {
  const asideContent = document.querySelector('#aside-content');
  if (!asideContent) return;
  
  // 创建访客统计组件
  const visitorWidget = document.createElement('div');
  visitorWidget.className = 'card-widget card-visitor-map';
  visitorWidget.innerHTML = `
    <div class="card-content">
      <div class="item-headline">
        <i class="fas fa-map-marker-alt"></i>
        <span>访客地图</span>
      </div>
      <div class="visitor-map">
        <script type="text/javascript" id="clustrmaps" src="//clustrmaps.com/map_v2.js?d=YOUR_ID&cl=ffffff&w=300"></script>
      </div>
    </div>
  `;
  
  // 插入到合适的位置
  asideContent.appendChild(visitorWidget);
});
```

### 自定义社交媒体链接

通过修改主题配置文件：

```yaml
# Social Settings (社交图标设置)
social:
  fab fa-github: https://github.com/yourusername || Github
  fas fa-envelope: mailto:your.email@example.com || Email
  fab fa-twitter: https://twitter.com/yourusername || Twitter
  # 自定义图标
  fas fa-blog: https://your-blog-url.com || Blog
  fas fa-code: https://your-coding-platform.com || Projects
```

## 注意事项与技巧

1. **兼容性考虑**：在添加自定义代码时，确保与不同浏览器和设备兼容。
2. **性能优化**：避免在侧边栏加载过多的大型组件或脚本，这会影响网站加载速度。
3. **调试技巧**：使用浏览器开发者工具调试CSS和JavaScript问题。
4. **主题更新**：在主题更新后，检查自定义功能是否仍然正常工作。
5. **模块化**：将自定义代码模块化，便于管理和更新。

## 总结

通过本文介绍的方法，你可以不修改Butterfly主题源码，就能实现侧边栏的个性化定制：

1. 使用Butterfly提供的inject功能注入自定义代码
2. 创建和使用自定义布局文件
3. 通过自定义配置文件调整侧边栏内容
4. 使用JavaScript动态添加新组件

这些方法不仅可以保持主题的可更新性，还能让你的博客拥有独特的个性化外观。

## 参考资料

1. [Butterfly官方文档 - 进阶教程](https://butterfly.js.org/posts/ea33ab97/)
2. [Hexo官方文档 - 注入器](https://hexo.io/zh-cn/api/injector.html)
3. [自定义Butterfly主题示例](https://blog.uuanqin.top/p/568ad08/)
