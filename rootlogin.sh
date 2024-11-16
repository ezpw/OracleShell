#!/bin/bash

# 设置 ROOT 密码
echo "设置你的ROOT密码"
echo -e "your_new_password\nyour_new_password" | sudo passwd root

# 启用 root 登录和密码认证
sudo sed -i 's/^\s*#\?\s*PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo sed -i 's/^\s*#\?\s*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# 删除不必要的 SSH 配置文件
sudo rm -rf /etc/ssh/sshd_config.d/* /etc/ssh/ssh_config.d/*

# 重启 SSH 服务
sudo systemctl restart sshd

# 完成提示
echo -e "ROOT登录设置完毕"
