---
title: Butterfly-侧边栏实现Obsidian关系图谱
tags:
  - Hexo
  - Butterfly
  - Obsidian
  - 知识图谱
  - 可视化
categories:
  - - Hexo
    - Butterfly
keywords: 'Hexo,Butterfly,Obsidian,知识图谱,关系网络,可视化,侧边栏'
description: 如何在Butterfly主题侧边栏中实现类似Obsidian的知识关系图谱，展示文章间的连接关系，提升知识管理体验
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
abbrlink: 52861
date: 2023-12-10
updated: 2025-04-05
---

# Butterfly主题侧边栏实现Obsidian关系图谱

在知识管理领域，Obsidian的关系图谱功能因其直观地展示笔记间连接而广受欢迎。本文将详细介绍如何在Hexo的Butterfly主题侧边栏中实现类似的知识关系图谱，让你的博客不仅是文章的集合，更成为一个可视化的知识网络。

## 什么是Obsidian关系图谱

Obsidian关系图谱是一种可视化工具，它能够：

- 以图形方式展示文档间的链接关系
- 显示知识点之间的连接网络
- 帮助发现知识间的潜在关联
- 提供整体知识结构的宏观视角

在Butterfly主题中实现这一功能，可以极大提升读者浏览体验和内容导航效率。

## 实现方案概述

要在Butterfly主题侧边栏中实现Obsidian风格的关系图谱，我们需要：

1. 收集文章数据及其关联信息
2. 使用可视化库(如D3.js或vis.js)构建图谱
3. 将图谱组件集成到Butterfly侧边栏中
4. 添加交互功能和样式优化

整个实现过程不需要修改主题源码，而是通过Butterfly提供的注入功能和自定义侧边栏组件实现。

## 详细实现步骤

### 步骤一：准备数据收集脚本

首先，我们需要收集所有文章及其关联数据。在Hexo根目录创建`scripts/generate-graph-data.js`：

```javascript
const fs = require('fs');
const path = require('path');

// 在Hexo生成后执行
hexo.extend.filter.register('after_generate', function() {
  const posts = hexo.locals.get('posts').data;
  const tags = hexo.locals.get('tags').data;
  const categories = hexo.locals.get('categories').data;
  
  // 节点数据(文章、标签、分类)
  const nodes = [];
  // 连接数据
  const links = [];
  
  // 添加文章节点
  posts.forEach(post => {
    nodes.push({
      id: post._id,
      label: post.title,
      type: 'post',
      url: hexo.config.root + post.path,
      size: 10,
      color: '#3273dc'
    });
    
    // 添加文章与标签的连接
    if (post.tags && post.tags.length) {
      post.tags.forEach(tag => {
        links.push({
          source: post._id,
          target: 'tag-' + tag.name,
          value: 2
        });
      });
    }
    
    // 添加文章与分类的连接
    if (post.categories && post.categories.length) {
      post.categories.forEach(category => {
        links.push({
          source: post._id,
          target: 'category-' + category.name,
          value: 3
        });
      });
    }
    
    // 检测内部链接，建立文章间的连接
    // 简单实现：检测markdown格式的链接
    const linkRegex = /\[.*?\]\((\/\d{4}\/\d{2}\/\d{2}\/.*?\/|\/p\/[a-zA-Z0-9]+\/)\)/g;
    const content = post.raw;
    let match;
    
    while ((match = linkRegex.exec(content)) !== null) {
      const linkedPath = match[1];
      // 查找被链接的文章
      const linkedPost = posts.find(p => hexo.config.root + p.path === linkedPath);
      
      if (linkedPost) {
        links.push({
          source: post._id,
          target: linkedPost._id,
          value: 1
        });
      }
    }
  });
  
  // 添加标签节点
  Object.keys(tags).forEach(tagName => {
    const tag = tags[tagName];
    nodes.push({
      id: 'tag-' + tag.name,
      label: tag.name,
      type: 'tag',
      url: hexo.config.root + tag.path,
      size: 7 + tag.posts.length,
      color: '#ff7d73'
    });
  });
  
  // 添加分类节点
  Object.keys(categories).forEach(catName => {
    const category = categories[catName];
    nodes.push({
      id: 'category-' + category.name,
      label: category.name,
      type: 'category',
      url: hexo.config.root + category.path,
      size: 7 + category.posts.length,
      color: '#3bc970'
    });
  });
  
  // 保存数据为JSON文件
  const graphData = { nodes, links };
  const outputPath = path.join(hexo.public_dir, 'data', 'knowledge-graph.json');
  
  // 确保目录存在
  const dataDir = path.join(hexo.public_dir, 'data');
  if (!fs.existsSync(dataDir)) {
    fs.mkdirSync(dataDir, { recursive: true });
  }
  
  fs.writeFileSync(outputPath, JSON.stringify(graphData));
  
  hexo.log.info('知识图谱数据已生成');
});
```

### 步骤二：创建图谱可视化组件

接下来，创建侧边栏图谱组件。我们将使用vis-network.js库来实现关系图谱可视化。

1. 首先，在Hexo的`source/js`目录下创建`knowledge-graph.js`文件：

```javascript
document.addEventListener('DOMContentLoaded', function() {
  initKnowledgeGraph();
});

function initKnowledgeGraph() {
  // 检查是否有图谱容器
  const graphContainer = document.getElementById('knowledge-graph-container');
  if (!graphContainer) return;
  
  // 加载图谱数据
  fetch('/data/knowledge-graph.json')
    .then(response => response.json())
    .then(data => {
      // 配置vis-network选项
      const options = {
        nodes: {
          shape: 'dot',
          scaling: {
            min: 5,
            max: 20,
            label: {
              enabled: true,
              min: 12,
              max: 24
            }
          },
          font: {
            size: 12,
            face: 'Tahoma'
          }
        },
        edges: {
          width: 0.15,
          color: { 
            color: '#7c7c7c', 
            highlight: '#3273dc' 
          },
          smooth: {
            type: 'continuous'
          }
        },
        physics: {
          stabilization: {
            iterations: 100
          },
          barnesHut: {
            gravitationalConstant: -80,
            springConstant: 0.01,
            springLength: 200
          }
        },
        interaction: {
          navigationButtons: true,
          keyboard: true,
          tooltipDelay: 200,
          hover: true
        }
      };
      
      // 创建网络图
      const network = new vis.Network(graphContainer, data, options);
      
      // 点击节点跳转到相应页面
      network.on("doubleClick", function(params) {
        if (params.nodes.length === 1) {
          const nodeId = params.nodes[0];
          const node = data.nodes.find(n => n.id === nodeId);
          if (node && node.url) {
            window.location.href = node.url;
          }
        }
      });
      
      // 悬停显示节点信息
      network.on("hoverNode", function(params) {
        const nodeId = params.node;
        const node = data.nodes.find(n => n.id === nodeId);
        if (node) {
          document.getElementById('graph-hover-info').innerHTML = `
            <div class="graph-hover-content">
              <div class="graph-hover-title">${node.label}</div>
              <div class="graph-hover-type">${getTypeLabel(node.type)}</div>
            </div>
          `;
          document.getElementById('graph-hover-info').style.display = 'block';
        }
      });
      
      network.on("blurNode", function(params) {
        document.getElementById('graph-hover-info').style.display = 'none';
      });
      
      // 添加图谱控制按钮
      addGraphControls(network, data);
    })
    .catch(error => {
      console.error('加载知识图谱数据失败:', error);
      graphContainer.innerHTML = '<div class="graph-error">加载知识图谱失败</div>';
    });
}

function getTypeLabel(type) {
  switch(type) {
    case 'post': return '文章';
    case 'tag': return '标签';
    case 'category': return '分类';
    default: return '未知';
  }
}

function addGraphControls(network, data) {
  // 创建控制按钮
  const controlsContainer = document.getElementById('knowledge-graph-controls');
  if (!controlsContainer) return;
  
  // 添加过滤按钮
  const filterTypes = ['全部', '仅文章', '仅标签', '仅分类'];
  const filterHtml = filterTypes.map(type => 
    `<button class="graph-filter-btn" data-type="${type}">${type}</button>`
  ).join('');
  
  controlsContainer.innerHTML = `
    <div class="graph-controls-group">
      <span class="graph-controls-label">过滤:</span>
      ${filterHtml}
    </div>
    <div class="graph-controls-group">
      <span class="graph-controls-label">视图:</span>
      <button class="graph-action-btn" data-action="center">居中</button>
      <button class="graph-action-btn" data-action="fit">适应</button>
    </div>
  `;
  
  // 绑定按钮事件
  document.querySelectorAll('.graph-filter-btn').forEach(btn => {
    btn.addEventListener('click', function() {
      const type = this.dataset.type;
      filterGraph(network, data, type);
      
      // 更新按钮状态
      document.querySelectorAll('.graph-filter-btn').forEach(b => 
        b.classList.remove('active'));
      this.classList.add('active');
    });
  });
  
  document.querySelectorAll('.graph-action-btn').forEach(btn => {
    btn.addEventListener('click', function() {
      const action = this.dataset.action;
      if (action === 'center') {
        network.moveTo({
          position: {x: 0, y: 0},
          scale: 1.0
        });
      } else if (action === 'fit') {
        network.fit();
      }
    });
  });
  
  // 默认选中"全部"
  document.querySelector('.graph-filter-btn[data-type="全部"]').classList.add('active');
}

function filterGraph(network, data, type) {
  const allNodes = new vis.DataSet(data.nodes);
  const allEdges = new vis.DataSet(data.links);
  
  if (type === '全部') {
    network.setData({nodes: allNodes, edges: allEdges});
    return;
  }
  
  // 根据类型筛选节点
  let nodeType = '';
  switch(type) {
    case '仅文章': nodeType = 'post'; break;
    case '仅标签': nodeType = 'tag'; break;
    case '仅分类': nodeType = 'category'; break;
  }
  
  const filteredNodes = data.nodes.filter(node => node.type === nodeType);
  const filteredNodeIds = filteredNodes.map(node => node.id);
  
  // 筛选包含这些节点的边
  const filteredEdges = data.links.filter(edge => 
    filteredNodeIds.includes(edge.source) && filteredNodeIds.includes(edge.target)
  );
  
  network.setData({
    nodes: new vis.DataSet(filteredNodes),
    edges: new vis.DataSet(filteredEdges)
  });
}
```

2. 创建相应的CSS样式文件`source/css/knowledge-graph.css`：

```css
/* 知识图谱容器样式 */
.card-knowledge-graph {
  margin-top: 1rem;
}

.knowledge-graph-container {
  width: 100%;
  height: 280px;
  border-radius: 8px;
  overflow: hidden;
  background-color: var(--card-bg);
  position: relative;
}

/* 暗色模式适配 */
[data-theme="dark"] .knowledge-graph-container {
  background-color: #2b2b2b;
}

/* 鼠标悬停信息 */
#graph-hover-info {
  position: absolute;
  top: 10px;
  left: 10px;
  background-color: rgba(255, 255, 255, 0.9);
  border-radius: 4px;
  padding: 5px 10px;
  font-size: 0.85rem;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
  z-index: 10;
  display: none;
}

[data-theme="dark"] #graph-hover-info {
  background-color: rgba(50, 50, 50, 0.9);
  color: #f1f1f1;
}

.graph-hover-title {
  font-weight: bold;
  margin-bottom: 2px;
}

.graph-hover-type {
  font-size: 0.75rem;
  color: #7a7a7a;
}

[data-theme="dark"] .graph-hover-type {
  color: #b0b0b0;
}

/* 控制按钮样式 */
.knowledge-graph-controls {
  display: flex;
  justify-content: space-between;
  padding: 5px 10px;
  border-top: 1px solid #eee;
  background-color: var(--card-bg);
}

[data-theme="dark"] .knowledge-graph-controls {
  border-top-color: #333;
}

.graph-controls-group {
  display: flex;
  align-items: center;
}

.graph-controls-label {
  font-size: 0.75rem;
  margin-right: 5px;
  color: #999;
}

.graph-filter-btn,
.graph-action-btn {
  border: none;
  background-color: transparent;
  padding: 2px 6px;
  margin: 0 2px;
  border-radius: 4px;
  font-size: 0.75rem;
  cursor: pointer;
  color: var(--font-color);
  transition: all 0.3s;
}

.graph-filter-btn:hover,
.graph-action-btn:hover {
  background-color: rgba(var(--theme-color-rgb), 0.1);
  color: var(--theme-color);
}

.graph-filter-btn.active {
  background-color: rgba(var(--theme-color-rgb), 0.2);
  color: var(--theme-color);
}

/* 错误提示 */
.graph-error {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  color: #ff4d4f;
  font-size: 0.9rem;
}
```

### 步骤三：添加侧边栏组件

现在，我们需要创建一个JavaScript文件来将关系图谱组件添加到侧边栏中。创建`source/js/add-knowledge-graph.js`：

```javascript
document.addEventListener('DOMContentLoaded', function() {
  // 获取侧边栏元素
  const asideContent = document.querySelector('#aside-content');
  if (!asideContent) return;
  
  // 创建知识图谱卡片
  const knowledgeGraphCard = document.createElement('div');
  knowledgeGraphCard.className = 'card-widget card-knowledge-graph';
  knowledgeGraphCard.innerHTML = `
    <div class="card-content">
      <div class="item-headline">
        <i class="fas fa-project-diagram"></i>
        <span>知识关系图谱</span>
      </div>
      <div class="knowledge-graph-container" id="knowledge-graph-container"></div>
      <div id="graph-hover-info"></div>
      <div class="knowledge-graph-controls" id="knowledge-graph-controls"></div>
    </div>
  `;
  
  // 将知识图谱卡片插入到侧边栏
  // 可以根据需要调整插入位置
  const webinfoCard = asideContent.querySelector('.card-webinfo');
  if (webinfoCard) {
    asideContent.insertBefore(knowledgeGraphCard, webinfoCard);
  } else {
    asideContent.appendChild(knowledgeGraphCard);
  }
});
```

### 步骤四：在主题配置文件中注入必要文件

在`_config.butterfly.yml`的inject部分添加以下内容：

```yaml
# Inject
inject:
  head:
    - <link rel="stylesheet" href="/css/knowledge-graph.css">
    - <script src="https://cdn.jsdelivr.net/npm/vis-network@9.1.2/dist/vis-network.min.js"></script>
  bottom:
    - <script src="/js/knowledge-graph.js"></script>
    - <script src="/js/add-knowledge-graph.js"></script>
```

## 高级定制与优化

### 节点样式自定义

可以根据不同的文章类型或重要性，自定义节点的样式：

```javascript
// 在generate-graph-data.js中
posts.forEach(post => {
  // 根据文章访问量、评论数或更新时间确定节点大小
  let nodeSize = 10; // 默认大小
  
  // 如果是重要文章，增大节点尺寸
  if (post.sticky) {
    nodeSize = 15;
  }
  
  // 可以根据文章分类决定颜色
  let nodeColor = '#3273dc'; // 默认颜色
  if (post.categories.find(cat => cat.name === '教程')) {
    nodeColor = '#23d160';
  } else if (post.categories.find(cat => cat.name === '随笔')) {
    nodeColor = '#ff3860';
  }
  
  nodes.push({
    id: post._id,
    label: post.title,
    type: 'post',
    url: hexo.config.root + post.path,
    size: nodeSize,
    color: nodeColor
  });
});
```

### 增加文章间内容关联

除了显式链接外，我们还可以基于内容相似度建立文章间的隐式关联：

```javascript
// 在generate-graph-data.js中添加内容相似度分析
const contentSimilarity = {};

// 简单的词频分析（实际应用中可以使用更复杂的算法）
posts.forEach(post => {
  const words = post.content
    .toLowerCase()
    .replace(/[^\w\s]/g, '')
    .split(/\s+/)
    .filter(word => word.length > 2);
    
  contentSimilarity[post._id] = {};
  
  // 计算词频
  const wordFreq = {};
  words.forEach(word => {
    wordFreq[word] = (wordFreq[word] || 0) + 1;
  });
  
  // 存储词频向量
  contentSimilarity[post._id].wordFreq = wordFreq;
});

// 计算文章间的相似度并添加边
posts.forEach((post1, i) => {
  posts.slice(i + 1).forEach(post2 => {
    const vec1 = contentSimilarity[post1._id].wordFreq;
    const vec2 = contentSimilarity[post2._id].wordFreq;
    
    // 计算余弦相似度
    let dotProduct = 0;
    let mag1 = 0;
    let mag2 = 0;
    
    const allWords = new Set([...Object.keys(vec1), ...Object.keys(vec2)]);
    
    allWords.forEach(word => {
      const val1 = vec1[word] || 0;
      const val2 = vec2[word] || 0;
      
      dotProduct += val1 * val2;
      mag1 += val1 * val1;
      mag2 += val2 * val2;
    });
    
    const similarity = dotProduct / (Math.sqrt(mag1) * Math.sqrt(mag2) || 1);
    
    // 如果相似度超过阈值，添加关联边
    if (similarity > 0.3) {
      links.push({
        source: post1._id,
        target: post2._id,
        value: similarity * 5, // 边的粗细由相似度决定
        color: {color: '#ff9800', opacity: 0.6},
        dashes: true,
        title: '内容相似'
      });
    }
  });
});
```

### 增加图谱分析功能

可以添加网络分析工具来突出显示知识图谱中的重要节点和社区：

```javascript
// 在knowledge-graph.js中添加分析功能

// 添加中心度分析按钮
function addAnalysisTools(network, data) {
  const analysisBtn = document.createElement('button');
  analysisBtn.className = 'graph-action-btn';
  analysisBtn.textContent = '中心度分析';
  analysisBtn.addEventListener('click', function() {
    analyzeCentrality(network, data);
  });
  
  document.getElementById('knowledge-graph-controls')
    .querySelector('.graph-controls-group:last-child')
    .appendChild(analysisBtn);
}

// 简单的度中心性分析
function analyzeCentrality(network, data) {
  // 计算每个节点的连接数量
  const degreeMap = {};
  data.links.forEach(link => {
    degreeMap[link.source] = (degreeMap[link.source] || 0) + 1;
    degreeMap[link.target] = (degreeMap[link.target] || 0) + 1;
  });
  
  // 找出连接数最高的前5个节点
  const centralNodes = Object.keys(degreeMap)
    .sort((a, b) => degreeMap[b] - degreeMap[a])
    .slice(0, 5);
  
  // 高亮这些中心节点
  const updatedNodes = data.nodes.map(node => {
    if (centralNodes.includes(node.id)) {
      return {...node, borderWidth: 3, borderColor: '#ff0000', size: node.size * 1.5};
    }
    return node;
  });
  
  network.setData({
    nodes: new vis.DataSet(updatedNodes),
    edges: new vis.DataSet(data.links)
  });
  
  // 显示分析结果
  let resultHtml = '<div class="analysis-result"><h4>中心度分析结果</h4><ul>';
  centralNodes.forEach(nodeId => {
    const node = data.nodes.find(n => n.id === nodeId);
    if (node) {
      resultHtml += `<li>${node.label} (${degreeMap[nodeId]}连接)</li>`;
    }
  });
  resultHtml += '</ul></div>';
  
  // 在页面中显示结果
  const resultContainer = document.createElement('div');
  resultContainer.className = 'graph-analysis-result';
  resultContainer.innerHTML = resultHtml;
  
  const existingResult = document.querySelector('.graph-analysis-result');
  if (existingResult) {
    existingResult.remove();
  }
  
  document.getElementById('knowledge-graph-container').appendChild(resultContainer);
  
  // 3秒后自动隐藏
  setTimeout(() => {
    resultContainer.classList.add('fade-out');
    setTimeout(() => resultContainer.remove(), 500);
  }, 3000);
}
```

### 针对移动设备的优化

在移动设备上，侧边栏空间有限，我们可以优化显示：

```javascript
// 在add-knowledge-graph.js中添加响应式调整
function adjustForMobile() {
  const isMobile = window.innerWidth <= 768;
  
  if (isMobile) {
    // 在移动设备上减小图谱高度
    const container = document.getElementById('knowledge-graph-container');
    if (container) {
      container.style.height = '200px';
    }
    
    // 简化控制按钮
    const controls = document.getElementById('knowledge-graph-controls');
    if (controls) {
      // 只保留最重要的按钮
      const actionBtns = controls.querySelectorAll('.graph-action-btn:not([data-action="fit"])');
      actionBtns.forEach(btn => btn.style.display = 'none');
    }
  }
}

// 监听窗口大小变化
window.addEventListener('resize', adjustForMobile);
document.addEventListener('DOMContentLoaded', adjustForMobile);
```

## 常见问题与解决方案

### 图谱加载缓慢

对于内容丰富的博客，关系图谱可能包含大量节点和边，导致加载缓慢。解决方法：

1. **限制节点数量**：在数据生成脚本中限制只显示最近的文章或最有关联的内容：

```javascript
// 在generate-graph-data.js中
// 只使用最近的50篇文章
const recentPosts = posts.sort((a, b) => b.date - a.date).slice(0, 50);
```

2. **优化物理引擎**：减少物理模拟的复杂度：

```javascript
// 在knowledge-graph.js中
const options = {
  // ...其他选项
  physics: {
    enabled: true,
    solver: 'forceAtlas2Based', // 更适合大型图谱
    forceAtlas2Based: {
      gravitationalConstant: -50,
      centralGravity: 0.01,
      springLength: 100,
      springConstant: 0.08
    },
    stabilization: {
      iterations: 50 // 减少稳定化迭代次数
    }
  }
};
```

### 浏览器兼容性问题

某些旧版浏览器可能不支持ES6特性或vis.js库：

```javascript
// 在knowledge-graph.js顶部添加
function checkBrowserSupport() {
  // 检查是否支持ES6和vis.js
  if (typeof vis === 'undefined') {
    const container = document.getElementById('knowledge-graph-container');
    if (container) {
      container.innerHTML = '<div class="graph-error">您的浏览器不支持知识图谱功能，请使用现代浏览器访问。</div>';
    }
    return false;
  }
  return true;
}

// 在initKnowledgeGraph函数的开始调用
function initKnowledgeGraph() {
  if (!checkBrowserSupport()) return;
  // 其余代码
}
```

### 图谱过于杂乱

对于连接密集的图谱，节点可能堆积在一起导致难以辨认：

```javascript
// 在knowledge-graph.js中添加节点间距离调整
const options = {
  // ...其他选项
  nodes: {
    // ...其他节点选项
    scaling: {
      min: 5,
      max: 20
    }
  },
  physics: {
    // ...其他物理选项
    repulsion: {
      nodeDistance: 120, // 增加节点间距
      centralGravity: 0.2,
      springLength: 200,
      springConstant: 0.05
    }
  }
};
```

## 总结

通过本文介绍的方法，我们可以在Butterfly主题的侧边栏中实现类似Obsidian的关系图谱功能，为博客增添知识网络可视化能力。这不仅提升了读者的浏览体验，也为站点提供了一种全新的内容导航方式。

实现这一功能的核心步骤包括：

1. 收集和分析文章数据，生成知识网络结构
2. 使用可视化库构建交互式关系图谱
3. 将图谱组件集成到Butterfly主题侧边栏
4. 添加样式和交互功能，优化用户体验

值得注意的是，这一实现完全不需要修改Butterfly主题的源码，而是通过Hexo和Butterfly提供的扩展机制实现，保证了主题更新时的兼容性。

## 参考资料

1. [Obsidian Graph View Documentation](https://help.obsidian.md/Plugins/Graph+view)
2. [vis-network.js API Documentation](https://visjs.github.io/vis-network/docs/network/)
3. [Hexo文档 - 注入器](https://hexo.io/zh-cn/api/injector.html)
4. [Butterfly主题自定义侧边栏教程](https://blog.uuanqin.top/p/f6c0daf3/)
5. [COSMA - Conceptual Systems Mapping Application](https://cosma.arthurperret.fr/examples.html)
6. [D3.js Force-Directed Graph](https://observablehq.com/@d3/force-directed-graph)
