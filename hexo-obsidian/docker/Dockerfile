FROM dockerproxy.net/library/ubuntu:22.04
ARG LC_ALL=C DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV TZ=Asia/Shanghai LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

USER root

# https://mirrors.ustc.edu.cn/help/ubuntu.html#__tabbed_2_1
RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list
RUN sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

RUN ( set -ex \
    && apt-get update \
    && apt-get install -y locales \
    && locale-gen en_US.UTF-8 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    )

# 安装必要的系统工具和依赖
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    vim \
    openssh-client \
    procps \
    python3 \
    zip \
    unzip \
    gnupg \
    ca-certificates \
    sudo \
    zsh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安装Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 配置npm使用淘宝镜像
RUN npm config set registry https://registry.npmmirror.com \
    && npm config set strict-ssl false

# 安装Hexo CLI和常用插件
RUN npm install -g hexo-cli \
    hexo-deployer-git \
    hexo-generator-searchdb \
    hexo-generator-feed \
    hexo-renderer-marked \
    hexo-renderer-stylus \
    hexo-server \
    hexo-renderer-pug \
    hexo-wordcount

# 设置工作目录
WORKDIR /app

# 创建目录结构
RUN mkdir -p /app/src

# 添加启动脚本
COPY entrypoint.sh /entrypoint.sh
RUN chown root:root /entrypoint.sh && chmod a=rx /entrypoint.sh

RUN ( set -ex \
    && apt-get update \
    && apt-get install -y \
        curl diffstat ethtool file gawk graphviz hdparm htop net-tools  \
        openssh-server lsb-release \
        pkg-config nload nmap nmon nvme-cli passwd rsync samba screen sed socat \
        ssh sudo tree tmux unzip xxd vim wget zip openssl ca-certificates gnupg inetutils-ping\
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    )
RUN ( set -ex \
    && apt-get update \
    && apt-get install -y \
        python3-pip  \
    && pip3 install beautifulsoup4 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
)
# Allow the root user to log in to the container via ssh without a password.
RUN ( set -ex \
    && sed -ri 's/^#PermitEmptyPasswords/PermitEmptyPasswords/' /etc/ssh/sshd_config \
    && sed -ri 's/PermitEmptyPasswords no/PermitEmptyPasswords yes/' /etc/ssh/sshd_config \
    && sed -ri 's/^#PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config \
    && sed -ri 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -ri 's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config \
    && mkdir -p /run/sshd && chown -R root:root /run/sshd && chmod -R 755 /run/sshd \
    && passwd -d root \
    )

# 设置默认命令
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 22/tcp
CMD ["/usr/sbin/sshd", "-D"]
