# Hexo + Obsidian 知识库展示平台

这是一个将Obsidian笔记转换为网站并部署到GitHub Pages的项目。通过Hexo静态网站生成器，我们可以优雅地展示个人知识库。

## 功能特点

- Obsidian笔记完整转换
- 保留内部链接结构
- 知识图谱可视化
- 响应式设计
- 深色/浅色模式
- 自动部署到GitHub Pages

## 快速开始

1. 克隆此仓库
```bash
git clone <repository-url>
cd <repository-name>
```

2. 运行初始化脚本（可能需要管理员权限）
```bash
chmod +x init.sh
# 如果遇到权限问题，请使用sudo
sudo ./init.sh
```

3. 将Obsidian笔记复制到`src/source/_posts`目录

4. 本地预览
```bash
cd src
hexo server
```

5. 推送到GitHub
```bash
git add .
git commit -m "Update content"
git push
```

GitHub Actions将自动构建并部署网站到GitHub Pages。

详细的仓库初始化和Hexo命令指南，请参考[仓库初始化指南](./docs/repository-setup.md)。

## GitHub Actions 部署说明

本项目使用GitHub Actions自动部署到GitHub Pages。确保在仓库设置中：

1. 进入仓库的"Settings" > "Pages"
2. 在"Build and deployment"部分选择"GitHub Actions"作为来源
3. 如果遇到Actions运行问题，可以检查工作流文件(.github/workflows/deploy.yml)中的版本兼容性

### SSH密钥部署

本项目使用SSH密钥进行部署。详细的设置和使用说明请参考 [使用GitHub Actions和SSH密钥部署](./docs/github-actions-ssh.md)。

主要步骤包括：
1. 生成专用SSH密钥对
2. 在GitHub Pages仓库添加部署密钥
3. 在源代码仓库添加私钥作为密钥
4. 配置工作流文件使用SSH密钥

### 常见问题解决

- **等待运行器问题**: 如果看到"Waiting for a runner to pick up this job..."消息长时间不变，请检查工作流文件中的`runs-on`值格式是否正确。应使用`ubuntu-22.04`或`ubuntu-latest`而不是`ubuntu:22.04`。
- **依赖安装失败**: 确保src目录中存在package-lock.json文件。可以在本地运行`cd src && npm install`生成锁定文件后再提交。
- **缓存问题**: 如果出现"Dependencies lock file is not found"错误，检查工作流文件中的cache-dependency-path设置。
- **SSH连接问题**: 检查SSH密钥是否正确配置，可参考文档中的故障排除部分。

## 配置说明

详细配置说明请参考`_config.yml`文件中的注释。

## 自定义主题

本项目默认使用Next主题，您可以根据需要更换或自定义主题。

## 贡献指南

欢迎提交Issue或Pull Request来改进此项目。

## 许可证

MIT