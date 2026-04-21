---
title: Hexo博客加密插件详解
tags:
  - Hexo
  - 插件
  - 加密
  - hexo-blog-encrypt
  - 内容保护
categories:
  - - Hexo
    - 插件
  - - Hexo
    - 安全
keywords: 'Hexo,博客加密,内容保护,密码访问,hexo-blog-encrypt'
description: 详细介绍如何使用hexo-blog-encrypt插件为Hexo博客添加密码保护功能，保护私密内容的安全
top_img: >-
  https://images.unsplash.com/photo-1614064641938-3bbee52942c7?ixlib=rb-4.0.3&auto=format&fit=crop&w=1600&h=400&q=80
cover: >-
  https://images.unsplash.com/photo-1555949963-ff9fe0c870eb?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=600&q=80
comments: true
toc: true
toc_number: true
auto_open: true
copyright: true
copyright_author: Zeek Zhao
copyright_info: 此文章版权归作者所有，如有转载，请注明来源
mathjax: false
abbrlink: 26803
date: 2023-12-15
updated: 2025-04-05
---

# Hexo博客加密插件详解

在博客写作中，有时我们需要保护某些私密或敏感内容，只允许特定的读者通过密码访问。Hexo-blog-encrypt 插件正是为此而设计，它可以帮助你轻松地为博客文章设置密码保护。本文将详细介绍该插件的安装、配置和使用方法。

> **注意**：本文介绍的加密方法是前端加密，意味着加密的内容仍会下载到用户的浏览器中，但需要正确的密码才能解密查看。这不适用于需要高安全级别的内容保护。

## 1. 插件简介

Hexo-blog-encrypt 是一个专为 Hexo 博客设计的文章加密插件，具有以下特点：

- 支持对单独文章进行密码保护
- 可配置全局默认密码
- 支持密码提示信息
- 支持自定义加密模板
- 兼容大多数 Hexo 主题
- 支持文章摘要显示
- 使用 AES 加密算法，安全可靠

## 2. 安装插件

通过 npm 安装插件非常简单，只需在 Hexo 博客的根目录下执行以下命令：

```bash
npm install --save hexo-blog-encrypt
```

## 3. 基本配置

### 3.1 全局配置

你可以在 Hexo 的主配置文件 `_config.yml` 中添加以下内容来设置全局加密选项：

```yaml
# Security
encrypt:
  enable: true
  default_abstract: 这是一篇受密码保护的文章，请输入密码继续阅读。
  default_message: 请输入密码访问此内容。
  default_template: <div id="hexo-blog-encrypt" data-wpm="{{hbeWrongPassMessage}}" data-whm="{{hbeWrongHashMessage}}"><div class="hbe-input-container"><input type="password" id="hbePass" placeholder="{{hbeMessage}}" /><label>{{hbeMessage}}</label><div class="bottom-line"></div></div><script id="hbeData" type="hbeData" data-hmacdigest="{{hbeHmacDigest}}">{{hbeEncryptedData}}</script></div>
  default_password: your_default_password  # 全局默认密码
```

> [!WARNING] 安全提示
> 不建议在全局配置中设置默认密码，特别是当你的博客源码是公开的情况下。最好为每篇需要加密的文章单独设置密码。

### 3.2 文章级别配置

要对单篇文章进行加密，只需在文章的 Front-matter 中添加 `password` 字段：

```yaml
---
title: 私密文章
date: 2023-12-15
tags: [私密, 笔记]
password: your_password_here
abstract: 这是一篇私密文章，请输入密码继续阅读。
message: 请输入访问密码
wrong_pass_message: 密码错误，请重试！
wrong_hash_message: 文章校验失败，可能已被篡改。
---
```

各字段说明：

| 参数 | 说明 |
| --- | --- |
| password | 访问密码 |
| abstract | 文章摘要，未解锁时显示 |
| message | 输入密码提示语 |
| wrong_pass_message | 密码错误提示语 |
| wrong_hash_message | 文章校验失败提示语 |

## 4. 使用示例

### 4.1 基本文章加密

{% hideToggle 文章加密示例 %}
添加以下 Front-matter 到你的文章：

```yaml
---
title: 我的私密日记
date: 2023-12-15
password: diary2023
abstract: 这是我的私密日记，需要密码访问。
---

这是文章的私密内容，只有输入正确密码才能查看。

## 今天的心情

今天天气晴朗，心情不错...
```

当访问者打开此文章时，只会看到摘要内容和密码输入框。输入正确密码后，才能查看完整内容。
{% endhideToggle %}

### 4.2 带提示信息的加密

{% hideToggle 带提示信息的加密示例 %}
有时候，你可能希望给读者一些提示来帮助他们记忆密码：

```yaml
---
title: 团队会议记录
date: 2023-12-10
password: meeting2023
abstract: 此文章包含团队会议记录，仅团队成员可查看。
message: 请输入会议记录密码（提示：公司成立年份+team）
---

# 2023年12月团队会议记录

1. 项目进度回顾
2. 下季度目标设定
3. 团队建设计划
...
```

{% endhideToggle %}

## 5. 高级功能

### 5.1 显示部分文章内容

有时你可能想让文章的某些部分可以公开查看，而只对敏感内容进行加密。hexo-blog-encrypt 支持通过特殊标记来实现这一功能。

{% hideToggle 部分内容加密示例 %}
在文章中，你可以使用 `<!-- more -->` 标签来分隔公开内容和加密内容：

```markdown
---
title: 项目开发记录
date: 2023-12-05
password: project123
abstract: 本文包含项目开发的公开信息和私密内容。
---

## 项目简介

这是一个开源项目，主要功能是...

<!-- more -->

## 项目密钥和API信息

项目密钥: `xxxxxxxx`
API端点: `https://api.example.com/v1/`
...
```

这样，"项目简介"部分将作为摘要公开显示，而"项目密钥和API信息"部分则需要密码才能查看。
{% endhideToggle %}

### 5.2 多密码支持

从 v3.0.0 版本开始，hexo-blog-encrypt 支持设置多个密码，这在团队分享等场景下非常有用。

{% hideToggle 多密码配置示例 %}

```yaml
---
title: 团队资料共享
date: 2023-12-01
passwords:
  - adminpass  # 管理员密码
  - teampass   # 团队成员密码
  - guestpass  # 访客密码
abstract: 团队共享资料，请输入访问密码。
---
```

使用此配置，任何一个列出的密码都可以用来解锁文章。
{% endhideToggle %}

> [!NOTE] 版本兼容性
> 多密码功能需要 hexo-blog-encrypt v3.0.0 及以上版本。如果你使用的是较旧版本，请先更新。

### 5.3 自定义模板

如果你希望自定义密码输入界面的样式和行为，可以通过修改模板来实现。

{% hideToggle 自定义模板示例 %}
在 Hexo 的配置文件中:

```yaml
encrypt:
  enable: true
  template: |
    <div id="hexo-blog-encrypt" data-wpm="{{hbeWrongPassMessage}}" data-whm="{{hbeWrongHashMessage}}">
      <div class="hbe-input-container">
        <h2 style="text-align:center;">🔒 加密内容 🔒</h2>
        <input type="password" id="hbePass" placeholder="{{hbeMessage}}" />
        <label>{{hbeMessage}}</label>
        <div class="bottom-line"></div>
      </div>
      <script id="hbeData" type="hbeData" data-hmacdigest="{{hbeHmacDigest}}">{{hbeEncryptedData}}</script>
    </div>
  wrong_pass_message: 抱歉，密码错误！请重新输入。
  wrong_hash_message: 抱歉，这篇文章可能已被破坏，无法正常显示。
```

你也可以在单篇文章中通过 Front-matter 设置自定义模板。
{% endhideToggle %}

### 5.4 加密TOC和评论

默认情况下，文章的目录(TOC)和评论区不会被加密。如果你希望将它们也包含在加密范围内，可以进行以下设置：

{% hideToggle TOC和评论加密配置 %}
全局配置 (_config.yml):

```yaml
encrypt:
  enable: true
  default_abstract: 这是一篇受密码保护的文章。
  default_message: 请输入密码访问此内容。
  encrypt_tags: true      # 加密标签
  encrypt_toc: true       # 加密TOC
  encrypt_comments: true  # 加密评论区
```

或在单篇文章中配置:

```yaml
---
title: 私密笔记
date: 2023-12-15
password: secret123
abstract: 私密内容，请输入密码。
tags: [私密, 笔记]
encrypt_tags: true    # 加密标签
encrypt_toc: true     # 加密TOC
encrypt_comments: true # 加密评论区
---
```

{% endhideToggle %}

## 6. 主题兼容性

Hexo-blog-encrypt 插件在大多数主题下都能正常工作，包括 Butterfly 主题。但由于主题实现的差异，可能需要进行一些调整。

### 6.1 Butterfly主题兼容性

在 Butterfly 主题中使用本插件通常没有兼容性问题，但你可能需要注意以下几点：

1. **文章封面显示**：加密文章的封面图仍会正常显示
2. **目录问题**：如果启用了 `encrypt_toc`，确保主题的 TOC 设置不会干扰加密功能
3. **自定义样式**：可能需要调整一些 CSS 样式以匹配主题的整体风格

{% hideToggle Butterfly主题下的自定义样式示例 %}
你可以在 Butterfly 主题的自定义 CSS 文件中添加以下样式，使加密表单更好地融入主题风格：

```css
/* 加密表单样式 */
#hexo-blog-encrypt {
  margin: 2rem auto;
  max-width: 400px;
  padding: 2rem;
  border-radius: 12px;
  background-color: var(--card-bg);
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.05);
}

#hexo-blog-encrypt h2 {
  color: var(--text-highlight-color);
  margin-bottom: 1rem;
}

#hexo-blog-encrypt .hbe-input-container input {
  width: 100%;
  padding: 10px;
  border: 1px solid var(--border-color);
  border-radius: 6px;
  margin-bottom: 1rem;
  background-color: var(--background-color);
  color: var(--text-color);
  transition: all 0.3s ease;
}

#hexo-blog-encrypt .hbe-input-container input:focus {
  border-color: var(--text-highlight-color);
  box-shadow: 0 0 0 2px rgba(111, 66, 193, 0.2);
  outline: none;
}

#hexo-blog-encrypt .hbe-input-container label {
  color: var(--text-color);
  font-size: 0.9rem;
}
```

这些样式会自动适应 Butterfly 主题的明暗模式。
{% endhideToggle %}

## 7. 常见问题与解决方案

### 7.1 加密后文章无法显示

> [!FAQ]- 问题：加密后文章完全无法显示或出现错误
>
> 可能的原因和解决方案：
>
> 1. **插件版本问题**：确保使用最新版本的插件
> ```bash
>    npm update hexo-blog-encrypt
>    ```
>
> 2. **主题冲突**：某些主题可能与插件有冲突
>    - 尝试切换到基础主题测试
>    - 检查主题是否有自己的加密功能，可能需要禁用
>
> 3. **其他插件冲突**：一些优化页面的插件可能与加密插件冲突
>    - 尝试临时禁用其他插件进行测试
>    - 特别注意那些修改HTML结构的插件

### 7.2 密码输入后无响应

> [!FAQ]- 问题：输入正确密码后页面无响应或不显示内容
>
> 可能的原因和解决方案：
>
> 1. **JavaScript错误**：打开浏览器控制台检查错误
>    - 通常是由于主题或其他插件的JS与加密插件冲突
>
> 2. **缓存问题**：
>    - 清除浏览器缓存
>    - 使用隐私浏览模式测试
>
> 3. **解密问题**：
>    - 确保没有使用特殊字符作为密码
>    - 重新生成文章并测试

### 7.3 移动设备兼容性问题

> [!FAQ]- 问题：在移动设备上无法正常解密或显示
>
> 可能的原因和解决方案：
>
> 1. **响应式设计问题**：
>    - 检查移动设备的控制台错误
>    - 添加移动设备特定的CSS样式
>
> 2. **性能问题**：
>    - 在某些低端设备上，解密过程可能很慢
>    - 尝试减少加密内容的大小
>
> 3. **浏览器兼容性**：
>    - 某些老旧的移动浏览器可能不支持所需的加密API
>    - 建议使用现代浏览器访问

### 7.4 与其他插件的冲突

> [!WARNING] 注意
>
> 以下插件可能与hexo-blog-encrypt产生冲突：
>
> 1. **hexo-asset-image**：可能会干扰加密内容中的图片处理
> 2. **hexo-math**：某些情况下会影响LaTeX公式的加密
> 3. **hexo-filter-cleanup**：可能会改变HTML结构导致解密失败
>
> 如果遇到问题，可以尝试临时禁用这些插件进行测试，或者查看各自的GitHub issues寻找解决方案。

## 8. 安全性说明

> [!DANGER] 重要安全提示
>
> Hexo-blog-encrypt 是一种**前端加密**方式，它有以下限制：
>
> 1. 加密的内容仍会下载到用户的浏览器中，只是以加密形式存在
> 2. 解密过程在浏览器中进行，理论上可以被有足够技术能力的人破解
> 3. 不适合用于保护真正敏感或机密的信息
>
> 该插件适用于：
> - 防止内容被随意浏览和索引
> - 为非关键信息提供基本保护
> - 隐藏不希望公开但又需要分享的内容
>
> 如果你需要高级别的安全保护，应考虑服务器端身份验证和加密方案。

## 9. 高级应用场景

### 9.1 分级内容保护

对不同级别的内容设置不同的密码保护：

{% hideToggle 分级内容保护示例 %}

```markdown
---
title: 项目文档集合
date: 2023-12-01
password: level1pass  # 基本访问密码
abstract: 多级项目文档，不同部分需要不同权限访问。
---

# 项目文档集合

## 1. 公开信息

这部分内容使用基本密码即可查看，包含项目概述。

<!-- HBE-ID: level2 HBE-PASS: level2pass -->
## 2. 团队成员信息

这部分需要团队成员密码才能查看，包含团队联系方式和职责分工。
<!-- HBE-END: level2 -->

<!-- HBE-ID: level3 HBE-PASS: adminpass -->
## 3. 管理员信息

这部分需要管理员密码才能查看，包含服务器信息和关键密钥。
<!-- HBE-END: level3 -->
```

> **注意**：此功能需要在模板中添加自定义代码支持，并且目前尚未官方支持，您可能需要修改插件代码或使用其他方法实现。
{% endhideToggle %}

### 9.2 临时访问链接

为特定用户生成带有自动填充密码的临时访问链接：

{% hideToggle 临时访问链接示例 %}
你可以生成类似以下格式的链接：

```
https://yourblog.com/encrypted-post/#密码
```

当用户访问此链接时，密码会自动填充（需要在页面中添加处理URL hash的JavaScript代码）。

JavaScript示例（添加到自定义模板或网站脚本中）：

```javascript
document.addEventListener('DOMContentLoaded', function() {
  if(window.location.hash.length > 1) {
    // 从URL hash中获取密码
    const password = decodeURIComponent(window.location.hash.substring(1));
    // 查找密码输入框
    const passInput = document.getElementById('hbePass');
    if(passInput) {
      // 填充密码
      passInput.value = password;
      // 模拟按下回车键自动提交
      const event = new KeyboardEvent('keydown', {
        key: 'Enter',
        code: 'Enter',
        keyCode: 13,
        which: 13,
        bubbles: true
      });
      passInput.dispatchEvent(event);
    }
  }
});
```

> **安全警告**：这种方法会将密码显示在URL中，有泄露风险，谨慎使用。
{% endhideToggle %}

## 10. 总结

Hexo-blog-encrypt 插件为 Hexo 博客提供了一种简单而有效的内容保护方式，适合保护不希望公开但又不是绝对机密的内容。通过本文的介绍，你应该已经掌握了插件的安装、配置和使用方法，以及一些高级功能和常见问题的解决方案。

使用该插件时，请记住以下关键点：

1. 这是一种前端加密方式，不适合保护真正敏感的信息
2. 定期更新插件以获取安全改进和新功能
3. 根据自己的需求选择合适的加密级别和配置
4. 遇到问题时，可以查阅GitHub仓库的issues或本文的常见问题部分

> [!TIP] 建议
> 为提供更好的用户体验，可以在加密文章的摘要中明确说明这是一篇需要密码访问的文章，以及如何获取密码（如需联系你获取密码等信息）。

### 10.1 安装和配置检查清单

- [ ] 安装插件：`npm install --save hexo-blog-encrypt`
- [ ] 配置全局设置（可选）
- [ ] 测试基本文章加密功能
- [ ] 确认主题兼容性
- [ ] 自定义样式和提示信息（可选）
- [ ] 备份密码（以防忘记）

### 10.2 相关资源

- [hexo-blog-encrypt GitHub仓库](https://github.com/D0n9X1n/hexo-blog-encrypt)
- [Hexo官方网站](https://hexo.io/)
- [Butterfly主题文档](https://butterfly.js.org/)

{% note success %}
通过合理使用hexo-blog-encrypt插件，你可以为博客添加一层保护，只向特定读者分享某些内容，同时保持其他内容的公开访问！
{% endnote %}
