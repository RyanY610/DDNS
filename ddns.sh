#!/bin/bash

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
NC="\033[0m"

# 检测是否已安装 Python3
if ! command -v python3 &> /dev/null; then
        echo -e "${GREEN}未安装 Python3，正在安装...${NC}"

    # 检测操作系统类型
    if [ -f /etc/os-release ]; then

        # CentOS
        if grep -qiE "centos" /etc/os-release; then
                echo -e "${GREEN}CentOS 操作系统，开始安装Python3...${NC}"
                yum install epel-release -y
                yum install python3 -y
        fi

        # Debian
        if grep -qiE "debian" /etc/os-release; then
                echo -e "${GREEN}Debian 操作系统，开始安装Python3...${NC}"
                apt install python3 -y
        fi

        # Ubuntu
        if grep -qiE "ubuntu" /etc/os-release; then
                echo -e "${GREEN}Ubuntu 操作系统，开始安装Python3...${NC}"
                apt install python3 -y
        fi
else
        echo -e "${RED}无法确定操作系统类型，无法自动安装Python3。${NC}" && exit 1 
    fi
fi

# 检查Python3是否安装成功
if command -v python3 &> /dev/null; then
        echo -e "${GREEN}Python3安装成功。${NC}"
else
        echo -e "${RED}Python3安装失败，或尝试手动安装Python3。${NC}" && exit 1
fi

echo -e "${GREEN}开始安装 Ddns...${NC}"
	if git clone https://github.com/RyanY610/Ddns.git /etc/ddns; then
		echo -e "${GREEN}Ddns 安装成功。${NC}"
	else
		echo -e "${RED}Ddns 安装失败，请检查/var下是否存在dnmp目录。${NC}" && exit 1
	fi
