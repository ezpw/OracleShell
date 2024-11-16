#!/bin/bash

# 检查 Docker 容器是否已存在
if docker ps -a | grep -q ghcr.io/yohann0617/oci-helper; then
    echo "已存在使用 ezpw-ocihelp 镜像的容器。"
    exit 0
fi

# 命令
sudo mkdir -p /app/oci-helper/keys && cd /app/oci-helper
wget https://github.com/ezpw/oci-helper/releases/download/v1.0.0/application.yml
wget https://github.com/ezpw/oci-helper/releases/download/v1.0.0/oci-helper.db
iptables -I INPUT -p tcp --dport 8898 -j ACCEPT

# 检查并安装 Docker
echo "检查 Docker..."
if ! command -v docker &> /dev/null; then
    echo "Docker 未安装，正在安装..."

    # 检测操作系统类型
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            centos|rhel)
                echo "安装 Docker for CentOS/RHEL..."
                sudo yum install -y yum-utils
                sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                sudo yum install -y docker-ce docker-ce-cli containerd.io
                ;;
            debian|ubuntu)
                echo "安装 Docker for Debian/Ubuntu..."
                sudo apt update
                sudo apt install -y docker.io
                ;;
            alpine)
                echo "安装 Docker for Alpine..."
                sudo apk add docker
                ;;
            *)
                echo "未识别的操作系统: $ID"
                exit 1
                ;;
        esac

        # 启动并启用 Docker 服务
        sudo systemctl start docker
        sudo systemctl enable docker
        echo "Docker 安装并启动成功。"
    else
        echo "无法识别操作系统，手动安装 Docker。"
        exit 1
    fi
else
    echo "Docker 已安装。"
fi

# 检查文件下载是否成功
if [ $? -eq 0 ]; then
    echo "文件下载成功到 /app/oci-helper 目录。"
else
    echo "文件下载失败，请检查网络连接或权限。"
    exit 1
fi

# 启动 Docker 容器
echo "启动 oci-helper 容器..."
sudo docker run -d --name oci-helper --restart=always \
    -p 8898:8898 \
    -v /app/oci-helper/application.yml:/app/oci-helper/application.yml \
    -v /app/oci-helper/oci-helper.db:/app/oci-helper/oci-helper.db \
    -v /app/oci-helper/keys:/app/oci-helper/keys \
    ghcr.io/yohann0617/oci-helper:master

# 检查容器是否启动成功
if [ $? -eq 0 ]; then
    echo "oci-helper 容器已成功启动。"
else
    echo "启动 oci-helper 容器失败，请检查 Docker 安装或权限。"
    exit 1
fi
