#!/bin/bash
# 获取当前用户和组信息用于Docker容器内的权限映射
USER_INFO=$(cat /etc/passwd | grep ^${USER}:) && export USER_INFO
GROUP_INFO=$(id | awk '{print $2}') && export GROUP_INFO
# 设置工作目录
cd docker

# 使用--build参数重新构建镜像，确保所有修改都被应用
# 使用-d参数在后台运行容器
echo "正在启动 Hexo 工作环境..."
docker compose up -d --build

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 15000 ${USER}@localhost