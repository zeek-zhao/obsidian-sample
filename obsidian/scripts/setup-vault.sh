#!/bin/bash

# Obsidian Vault 完整目录结构创建脚本
# 基于详细分类体系架构
# 支持中英文可选

set -e

# ==============================================
# 帮助信息
# ==============================================
show_help() {
  cat << EOF
🚀 Obsidian Vault 目录结构生成器

用法: $0 [选项] [目标目录]

选项:
  -l, --lang LANGUAGE    设置语言 (zh|en，默认: zh)
  -h, --help            显示此帮助信息

参数:
  目标目录               Vault 根目录路径（默认: 当前目录）

示例:
  $0                    # 在当前目录创建中文版
  $0 -l en              # 在当前目录创建英文版
  $0 -l zh ~/MyVault    # 在指定目录创建中文版
  $0 --lang en /tmp/vault  # 在指定目录创建英文版

EOF
  exit 0
}

# ==============================================
# 解析命令行参数
# ==============================================
LANG="zh"
VAULT_ROOT="."

while [[ $# -gt 0 ]]; do
  case $1 in
    -l | --lang)
      LANG="$2"
      shift 2
      ;;
    -h | --help)
      show_help
      ;;
    -*)
      echo "❌ 未知选项: $1"
      echo "使用 -h 或 --help 查看帮助"
      exit 1
      ;;
    *)
      VAULT_ROOT="$1"
      shift
      ;;
  esac
done

# 验证语言参数
if [[ "$LANG" != "zh" && "$LANG" != "en" ]]; then
  echo "❌ 不支持的语言: $LANG"
  echo "支持的语言: zh (中文), en (English)"
  exit 1
fi

if [[ "$LANG" == "zh" ]]; then
  echo "🚀 开始创建 Obsidian Vault 目录结构..."
  echo "🌍 语言: 中文"
else
  echo "🚀 Creating Obsidian Vault structure..."
  echo "🌍 Language: English"
fi

# 切换到目标目录
mkdir -p "$VAULT_ROOT"
cd "$VAULT_ROOT"

if [[ "$LANG" == "zh" ]]; then
  echo "📂 目标路径: $(pwd)"
else
  echo "📂 Target path: $(pwd)"
fi

# ==============================================
# 源文件路径函数（根据语言返回不同路径）
# ==============================================
get_path() {
  local key=$1
  if [[ "$LANG" == "zh" ]]; then
    case $key in
      "system") echo "00-系统管理" ;;
      "inbox") echo "01-收集箱" ;;
      "daily") echo "02-每日笔记" ;;
      "work") echo "03-工作领域" ;;
      "learning") echo "04-学习领域" ;;
      "life") echo "05-生活领域" ;;
      "knowledge") echo "06-知识构建" ;;
      "projects") echo "07-项目中心" ;;
      "resources") echo "08-资源库" ;;
      "archive") echo "09-归档" ;;
      "templates") echo "99-模板" ;;
    esac
  else
    case $key in
      "system") echo "00-System" ;;
      "inbox") echo "01-Inbox" ;;
      "daily") echo "02-Daily-Notes" ;;
      "work") echo "03-Work" ;;
      "learning") echo "04-Learning" ;;
      "life") echo "05-Life" ;;
      "knowledge") echo "06-Knowledge" ;;
      "projects") echo "07-Projects" ;;
      "resources") echo "08-Resources" ;;
      "archive") echo "09-Archive" ;;
      "templates") echo "99-Templates" ;;
    esac
  fi
}

# ==============================================
# 1. 创建主目录结构
# ==============================================
echo ""
if [[ "$LANG" == "zh" ]]; then
  echo "📁 创建主目录..."
else
  echo "📁 Creating directories..."
fi

# 根据语言设置目录名称
if [[ "$LANG" == "zh" ]]; then
  source_file="directories_zh.txt"
  cat > "$source_file" << 'DIREOF'
00-系统管理
01-收集箱/临时想法
01-收集箱/待处理
01-收集箱/临时文件
02-每日笔记/周总结
02-每日笔记/月总结
02-每日笔记/年总结
03-工作领域/01-工作日志
03-工作领域/02-会议记录/项目会议
03-工作领域/02-会议记录/团队会议
03-工作领域/02-会议记录/客户会议
03-工作领域/03-项目文档/进行中
03-工作领域/03-项目文档/已计划
03-工作领域/03-项目文档/已完成
03-工作领域/04-客户资料
03-工作领域/05-工作总结/季度总结
03-工作领域/05-工作总结/年度总结
03-工作领域/05-工作总结/绩效回顾
03-工作领域/06-行业研究/市场分析
03-工作领域/06-行业研究/竞品研究
03-工作领域/06-行业研究/趋势报告
03-工作领域/07-职业技能/工具使用
03-工作领域/07-职业技能/方法学习
03-工作领域/07-职业技能/经验总结
04-学习领域/01-文献笔记/书籍笔记
04-学习领域/01-文献笔记/论文笔记
04-学习领域/01-文献笔记/文章笔记
04-学习领域/01-文献笔记/视频课程
04-学习领域/02-课程学习/专业课程
04-学习领域/02-课程学习/在线课程
04-学习领域/02-课程学习/培训资料
04-学习领域/03-技能学习/编程技能
04-学习领域/03-技能学习/语言学习
04-学习领域/03-技能学习/设计技能
04-学习领域/03-技能学习/其他技能
04-学习领域/04-考试复习/备考资料
04-学习领域/04-考试复习/错题整理
04-学习领域/04-考试复习/模拟测试
05-生活领域/01-健康管理/饮食记录
05-生活领域/01-健康管理/运动计划
05-生活领域/01-健康管理/体检报告
05-生活领域/01-健康管理/医疗记录
05-生活领域/02-财务管理/预算规划
05-生活领域/02-财务管理/投资理财
05-生活领域/02-财务管理/消费记录
05-生活领域/02-财务管理/税务管理
05-生活领域/03-家庭生活/家庭事务
05-生活领域/03-家庭生活/子女教育
05-生活领域/03-家庭生活/家庭活动
05-生活领域/03-家庭生活/重要日期
05-生活领域/04-旅行记录/旅行计划
05-生活领域/04-旅行记录/游记分享
05-生活领域/04-旅行记录/旅行攻略
05-生活领域/04-旅行记录/照片整理
05-生活领域/05-兴趣爱好/音乐
05-生活领域/05-兴趣爱好/摄影
05-生活领域/05-兴趣爱好/手工艺
05-生活领域/05-兴趣爱好/收藏
05-生活领域/06-个人成长/目标设定
05-生活领域/06-个人成长/习惯养成
05-生活领域/06-个人成长/反思日记
05-生活领域/06-个人成长/成就记录
06-知识构建/01-原子笔记
06-知识构建/02-概念笔记/专业概念
06-知识构建/02-概念笔记/通用概念
06-知识构建/02-概念笔记/方法论
06-知识构建/03-人物笔记/历史人物
06-知识构建/03-人物笔记/当代人物
06-知识构建/03-人物笔记/虚构人物
06-知识构建/04-永久笔记/理论体系
06-知识构建/04-永久笔记/知识框架
06-知识构建/04-永久笔记/深度思考
06-知识构建/05-地图笔记/主题地图
06-知识构建/05-地图笔记/领域地图
06-知识构建/05-地图笔记/索引地图
07-项目中心/活跃项目
07-项目中心/待启动项目
07-项目中心/已完成项目
07-项目中心/项目模板
08-资源库/编程开发/前端
08-资源库/编程开发/后端
08-资源库/编程开发/移动端
08-资源库/编程开发/数据库
08-资源库/设计创意/UI-UX
08-资源库/设计创意/平面设计
08-资源库/设计创意/插画
08-资源库/设计创意/摄影
08-资源库/商业管理/市场营销
08-资源库/商业管理/产品管理
08-资源库/商业管理/运营增长
08-资源库/商业管理/商业模式
08-资源库/心理学
08-资源库/哲学
08-资源库/历史
08-资源库/科学
09-归档/历史工作
09-归档/完成项目
09-归档/过期资料
09-归档/备份文件
09-归档/临时归档
99-模板/笔记模板
99-模板/工作模板
99-模板/学习模板
99-模板/生活模板
DIREOF
else
  source_file="directories_en.txt"
  cat > "$source_file" << 'DIREOF'
00-System
01-Inbox/Quick-Capture
01-Inbox/To-Process
01-Inbox/Temp-Files
02-Daily-Notes/Weekly-Reviews
02-Daily-Notes/Monthly-Reviews
02-Daily-Notes/Annual-Reviews
03-Work/01-Work-Logs
03-Work/02-Meetings/Project-Meetings
03-Work/02-Meetings/Team-Meetings
03-Work/02-Meetings/Client-Meetings
03-Work/03-Project-Docs/In-Progress
03-Work/03-Project-Docs/Planned
03-Work/03-Project-Docs/Completed
03-Work/04-Client-Materials
03-Work/05-Work-Reviews/Quarterly
03-Work/05-Work-Reviews/Annual
03-Work/05-Work-Reviews/Performance
03-Work/06-Industry-Research/Market-Analysis
03-Work/06-Industry-Research/Competitor-Research
03-Work/06-Industry-Research/Trend-Reports
03-Work/07-Professional-Skills/Tools
03-Work/07-Professional-Skills/Methods
03-Work/07-Professional-Skills/Lessons-Learned
04-Learning/01-Literature-Notes/Books
04-Learning/01-Literature-Notes/Papers
04-Learning/01-Literature-Notes/Articles
04-Learning/01-Literature-Notes/Videos
04-Learning/02-Courses/Professional
04-Learning/02-Courses/Online
04-Learning/02-Courses/Training
04-Learning/03-Skills/Programming
04-Learning/03-Skills/Languages
04-Learning/03-Skills/Design
04-Learning/03-Skills/Others
04-Learning/04-Exam-Prep/Materials
04-Learning/04-Exam-Prep/Error-Log
04-Learning/04-Exam-Prep/Mock-Tests
05-Life/01-Health/Diet
05-Life/01-Health/Exercise
05-Life/01-Health/Medical-Records
05-Life/01-Health/Checkups
05-Life/02-Finance/Budget
05-Life/02-Finance/Investments
05-Life/02-Finance/Expenses
05-Life/02-Finance/Taxes
05-Life/03-Family/Affairs
05-Life/03-Family/Education
05-Life/03-Family/Activities
05-Life/03-Family/Important-Dates
05-Life/04-Travel/Plans
05-Life/04-Travel/Journals
05-Life/04-Travel/Guides
05-Life/04-Travel/Photos
05-Life/05-Hobbies/Music
05-Life/05-Hobbies/Photography
05-Life/05-Hobbies/Crafts
05-Life/05-Hobbies/Collections
05-Life/06-Personal-Growth/Goals
05-Life/06-Personal-Growth/Habits
05-Life/06-Personal-Growth/Reflections
05-Life/06-Personal-Growth/Achievements
06-Knowledge/01-Atomic-Notes
06-Knowledge/02-Concept-Notes/Professional
06-Knowledge/02-Concept-Notes/General
06-Knowledge/02-Concept-Notes/Methodologies
06-Knowledge/03-People-Notes/Historical
06-Knowledge/03-People-Notes/Contemporary
06-Knowledge/03-People-Notes/Fictional
06-Knowledge/04-Permanent-Notes/Theories
06-Knowledge/04-Permanent-Notes/Frameworks
06-Knowledge/04-Permanent-Notes/Deep-Thoughts
06-Knowledge/05-MOCs/Topic-Maps
06-Knowledge/05-MOCs/Domain-Maps
06-Knowledge/05-MOCs/Index-Maps
07-Projects/Active
07-Projects/Planned
07-Projects/Completed
07-Projects/Templates
08-Resources/Programming/Frontend
08-Resources/Programming/Backend
08-Resources/Programming/Mobile
08-Resources/Programming/Database
08-Resources/Design/UI-UX
08-Resources/Design/Graphics
08-Resources/Design/Illustration
08-Resources/Design/Photography
08-Resources/Business/Marketing
08-Resources/Business/Product-Management
08-Resources/Business/Growth
08-Resources/Business/Business-Models
08-Resources/Psychology
08-Resources/Philosophy
08-Resources/History
08-Resources/Science
09-Archive/Past-Work
09-Archive/Completed-Projects
09-Archive/Outdated
09-Archive/Backups
09-Archive/Temp-Archive
99-Templates/Note-Templates
99-Templates/Work-Templates
99-Templates/Learning-Templates
99-Templates/Life-Templates
DIREOF
fi

while IFS= read -r dir; do
  [[ -z "$dir" ]] && continue
  mkdir -p "$dir"
  echo "  ✓ $dir"
done < "$source_file"

rm "$source_file"

# ==============================================
# 2. 创建文档内容函数
# ==============================================
echo ""
if [[ "$LANG" == "zh" ]]; then
  echo "📝 创建系统文档和模板..."
else
  echo "📝 Creating system documents and templates..."
fi

# 现在创建文档 - 这里只包含关键文档，使用条件语句选择语言
if [[ "$LANG" == "zh" ]]; then
  # 中文版本的文档
  bash -c "$(
    cat << 'DOCEOF'
cat > "00-系统管理/分类体系说明.md" << 'EOF'
---
tags: [系统, 说明]
created: 2025-12-14
---

# 分类体系说明

本 Vault 采用完整的笔记分类体系，涵盖工作、学习、生活各个方面。

## 📂 主目录结构

- **00-系统管理**：系统配置、流程指南
- **01-收集箱**：临时想法、待处理事项（Inbox）
- **02-每日笔记**：Daily Notes、周/月/年总结
- **03-工作领域**：工作相关的所有内容
- **04-学习领域**：学习笔记、课程、技能
- **05-生活领域**：健康、财务、家庭、旅行等
- **06-知识构建**：原子笔记、永久笔记、MOC
- **07-项目中心**：项目管理、任务跟踪
- **08-资源库**：按主题分类的参考资料
- **09-归档**：已完成、过期的内容
- **99-模板**：各类笔记模板

## 🔄 使用流程

1. 新想法 → `01-收集箱/临时想法/`
2. 每日整理 → 分配到对应领域
3. 深度加工 → `06-知识构建/永久笔记/`
4. 项目相关 → `07-项目中心/`
5. 完成内容 → `09-归档/`

## 🏷️ 标签体系

### 状态标签
- `#状态/进行中` `#状态/已完成` `#状态/已归档`

### 优先级标签
- `#优先级/高` `#优先级/中` `#优先级/低`

### 类型标签
- `#类型/想法` `#类型/任务` `#类型/参考`

### 来源标签
- `#来源/书籍` `#来源/文章` `#来源/视频`
EOF
DOCEOF
  )"

  cat > "00-系统管理/使用流程指南.md" << 'EOF'
---
tags: [系统, 流程]
---

# 使用流程指南

## ⚡ 快速开始

### 每日工作流
1. 打开 `02-每日笔记/` 今日笔记（或通过快捷键自动创建）
2. 查看 `01-收集箱/今日收集.md` 处理昨日收集
3. 在每日笔记中记录今日重要事项
4. 睡前整理：将收集箱内容分类到对应领域

### 学习工作流
1. 阅读/观看内容时 → `04-学习领域/01-文献笔记/`
2. 提炼关键概念 → `06-知识构建/01-原子笔记/`
3. 形成深度思考 → `06-知识构建/04-永久笔记/`
4. 创建索引地图 → `06-知识构建/05-地图笔记/`

### 项目工作流
1. 新项目 → `07-项目中心/活跃项目/` 创建项目文件夹
2. 使用 `99-模板/项目计划模板.md`
3. 项目完成 → 移至 `07-项目中心/已完成项目/`
4. 归档 → 移至 `09-归档/完成项目/`

## 🔍 搜索技巧

```markdown
# 查找进行中的项目
path:07-项目中心/ tag:#状态/进行中

# 查找本周工作日志
path:03-工作领域/01-工作日志/ "本周"

# 查找所有待处理事项
tag:#类型/任务 tag:#状态/进行中
```

## 🧹 定期维护

- **每周**：清空收集箱，整理临时笔记
- **每月**：回顾项目进展，更新地图笔记
- **每季度**：归档已完成内容，调整分类体系
EOF

  cat > "01-收集箱/今日收集.md" << 'EOF'
---
tags: [收集箱]
date: 2025-12-14
---

# 今日收集

## 💡 临时想法

-

## 📌 待处理事项

- [ ]

## 🔗 稍后阅读

-

---
**提示**：每日整理，将内容移至对应领域
EOF

  cat > "README.md" << 'EOF'
# Obsidian Vault - 完整笔记体系

这是一个基于完整分类体系的 Obsidian Vault 模板。

## 🚀 快速开始

1. 用 Obsidian 打开本文件夹
2. 阅读 `00-系统管理/分类体系说明.md`
3. 查看 `00-系统管理/使用流程指南.md`
4. 从 `01-收集箱/今日收集.md` 开始使用

## 📂 目录结构

```
📂 Obsidian Vault/
├── 📁 00-系统管理/          # 系统配置和流程
├── 📁 01-收集箱/            # Inbox
├── 📁 02-每日笔记/          # Daily Notes
├── 📁 03-工作领域/          # Work
├── 📁 04-学习领域/          # Study/Learning
├── 📁 05-生活领域/          # Life/Personal
├── 📁 06-知识构建/          # Knowledge Building
├── 📁 07-项目中心/          # Projects
├── 📁 08-资源库/            # Resources
├── 📁 09-归档/              # Archive
└── 📁 99-模板/              # Templates
```

## 🏷️ 标签体系

### 状态标签
`#状态/进行中` `#状态/已完成` `#状态/已归档`

### 优先级标签
`#优先级/高` `#优先级/中` `#优先级/低`

### 类型标签
`#类型/想法` `#类型/任务` `#类型/参考`

### 来源标签
`#来源/书籍` `#来源/文章` `#来源/视频`

## 🎯 核心理念

1. **快速捕获** - 先记录，后整理
2. **定期处理** - 不让收集箱堆积
3. **链接思考** - 建立笔记之间的联系
4. **持续迭代** - 系统随使用不断优化

---

**祝你使用愉快！🎉**
EOF

else
  # 英文版本的文档
  cat > "00-System/Classification-System.md" << 'EOF'
---
tags: [system, guide]
created: 2025-12-14
---

# Classification System Guide

This Vault uses a comprehensive note classification system covering work, learning, and life.

## 📂 Main Directory Structure

- **00-System**: System configuration and workflow guides
- **01-Inbox**: Temporary ideas, pending items
- **02-Daily-Notes**: Daily notes, weekly/monthly/annual reviews
- **03-Work**: All work-related content
- **04-Learning**: Learning notes, courses, skills
- **05-Life**: Health, finance, family, travel, etc.
- **06-Knowledge**: Atomic notes, permanent notes, MOCs
- **07-Projects**: Project management and tracking
- **08-Resources**: Reference materials by topic
- **09-Archive**: Completed and outdated content
- **99-Templates**: Various note templates

## 🔄 Workflow

1. New idea → `01-Inbox/Quick-Capture/`
2. Daily review → Assign to appropriate domain
3. Deep processing → `06-Knowledge/04-Permanent-Notes/`
4. Project-related → `07-Projects/`
5. Completed → `09-Archive/`

## 🏷️ Tag System

### Status Tags
- `#status/active` `#status/done` `#status/archived`

### Priority Tags
- `#priority/high` `#priority/medium` `#priority/low`

### Type Tags
- `#type/idea` `#type/task` `#type/reference`

### Source Tags
- `#source/book` `#source/article` `#source/video`
EOF

  cat > "00-System/Workflow-Guide.md" << 'EOF'
---
tags: [system, workflow]
---

# Workflow Guide

## ⚡ Quick Start

### Daily Workflow
1. Open today's note in `02-Daily-Notes/`
2. Review `01-Inbox/Today.md` and process yesterday's captures
3. Record today's important items
4. Evening review: Categorize inbox content to appropriate domains

### Learning Workflow
1. While reading/watching → `04-Learning/01-Literature-Notes/`
2. Extract key concepts → `06-Knowledge/01-Atomic-Notes/`
3. Form deep thoughts → `06-Knowledge/04-Permanent-Notes/`
4. Create index maps → `06-Knowledge/05-MOCs/`

### Project Workflow
1. New project → Create folder in `07-Projects/Active/`
2. Use `99-Templates/Project-Template.md`
3. Project complete → Move to `07-Projects/Completed/`
4. Archive → Move to `09-Archive/Completed-Projects/`

## 🔍 Search Tips

```markdown
# Find active projects
path:07-Projects/ tag:#status/active

# Find this week's work logs
path:03-Work/01-Work-Logs/ "this week"

# Find all pending tasks
tag:#type/task tag:#status/active
```

## 🧹 Regular Maintenance

- **Weekly**: Clear inbox, organize temporary notes
- **Monthly**: Review project progress, update MOCs
- **Quarterly**: Archive completed content, adjust system
EOF

  cat > "01-Inbox/Today.md" << 'EOF'
---
tags: [inbox]
date: 2025-12-14
---

# Today's Captures

## 💡 Quick Ideas

-

## 📌 To-Do Items

- [ ]

## 🔗 Read Later

-

---
**Tip**: Review daily and move content to appropriate domains
EOF

  cat > "README.md" << 'EOF'
# Obsidian Vault - Complete Note System

This is an Obsidian Vault template based on a comprehensive classification system.

## 🚀 Quick Start

1. Open this folder with Obsidian
2. Read `00-System/Classification-System.md`
3. Check `00-System/Workflow-Guide.md`
4. Start with `01-Inbox/Today.md`

## 📂 Directory Structure

```
📂 Obsidian Vault/
├── 📁 00-System/            # System configuration
├── 📁 01-Inbox/             # Inbox
├── 📁 02-Daily-Notes/       # Daily Notes
├── 📁 03-Work/              # Work
├── 📁 04-Learning/          # Learning
├── 📁 05-Life/              # Life/Personal
├── 📁 06-Knowledge/         # Knowledge Building
├── 📁 07-Projects/          # Projects
├── 📁 08-Resources/         # Resources
├── 📁 09-Archive/           # Archive
└── 📁 99-Templates/         # Templates
```

## 🏷️ Tag System

### Status Tags
`#status/active` `#status/done` `#status/archived`

### Priority Tags
`#priority/high` `#priority/medium` `#priority/low`

### Type Tags
`#type/idea` `#type/task` `#type/reference`

### Source Tags
`#source/book` `#source/article` `#source/video`

## 🎯 Core Principles

1. **Quick Capture** - Record first, organize later
2. **Regular Processing** - Don't let inbox pile up
3. **Link Thinking** - Build connections between notes
4. **Continuous Iteration** - System evolves with use

---

**Happy note-taking! 🎉**
EOF

fi

# ==============================================
# 完成
# ==============================================
echo ""
if [[ "$LANG" == "zh" ]]; then
  echo "✅ Vault 目录结构创建完成！"
  echo ""
  echo "📊 统计信息："
  echo "  - 主目录数量: 10 个"
  echo "  - 总文件夹数: $(find . -type d | wc -l) 个"
  echo "  - 创建的文档: $(find . -type f -name "*.md" | wc -l) 个"
  echo ""
  echo "🎯 下一步："
  echo "  1. 用 Obsidian 打开: $VAULT_ROOT"
  echo "  2. 阅读 00-系统管理/分类体系说明.md"
  echo "  3. 查看 README.md 了解完整使用指南"
  echo ""
  echo "🚀 开始你的笔记之旅吧！"
else
  echo "✅ Vault structure created successfully!"
  echo ""
  echo "📊 Statistics:"
  echo "  - Main directories: 10"
  echo "  - Total folders: $(find . -type d | wc -l)"
  echo "  - Documents created: $(find . -type f -name "*.md" | wc -l)"
  echo ""
  echo "🎯 Next Steps:"
  echo "  1. Open with Obsidian: $VAULT_ROOT"
  echo "  2. Read 00-System/Classification-System.md"
  echo "  3. Check README.md for complete guide"
  echo ""
  echo "🚀 Start your note-taking journey!"
fi
