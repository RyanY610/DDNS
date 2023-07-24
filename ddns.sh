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

# 安装Ddns
echo -e "${GREEN}开始安装 Ddns...${NC}"
	if git clone https://github.com/RyanY610/Ddns.git /etc/ddns; then
		echo -e "${GREEN}Ddns 安装成功。${NC}"
	else
		echo -e "${RED}Ddns 安装失败，请检查/etc下是否存在ddns目录。${NC}" && exit 1
	fi

# 修改配置
chmod +x ddns
read -rp "请输入解析的ipv4域名: " ipv4_domain
[[ -z $ipv4_domain ]] && echo -e "${RED}未输入域名，无法执行操作！${NC}" && exit 1
IPV4_DOMAIN="$ipv4_domain"
sed -i "s/cloudflare.com/${IPV4_DOMAIN}/g" /etc/ddns/config.json
echo -e "你的${GREEN}ipv4域名${NC}：${GREEN}${IPV4_DOMAIN}${NC}"
	
read -rp "请输入解析的IPv6域名（留空则为空）： " ipv6_domain

if [ -z "$ipv6_domain" ]; then
  IPV6_ENTRY='"ipv6": []'
else
  IPV6_ENTRY='"ipv6": ["'"$ipv6_domain"'"]'
fi

sed -i 's/"ipv6": \[.*\]/'"$IPV6_ENTRY"'/g' /etc/ddns/config.json

echo -e "你的${GREEN}IPv6域名${NC}：${GREEN}${ipv6_domain}${NC}"

	read -rp "请输入dns服务商(例如：cloudflare dnspod alidns): " dnsserver
	[[ -z $dnsserver ]] && echo -e "${RED}未输入dns服务商，无法执行操作！${NC}" && exit 1
	DNSSERVER="$dnsserver"
	sed -i "s/server/${DNSSERVER}/g" /etc/ddns/config.json
	echo -e "你的${GREEN}dns服务商${NC}：${GREEN}${DNSSERVER}${NC}"
	
	read -rp "请输入你的api_id(cloudflare为邮箱): " api_id
	[[ -z $api_id ]] && echo -e "${RED}未输入api_id，无法执行操作！${NC}" && exit 1
	API_ID="$api_id"
	sed -i "s/12345678/${API_ID}/g" /etc/ddns/config.json
	echo -e "你的${GREEN}api id${NC}：${GREEN}${API_ID}${NC}"
	
	read -rp "请输入你的token(cloudflare为api_key): " token
	[[ -z $token ]] && echo -e "${RED}未输入token，无法执行操作！${NC}" && exit 1
	API_TOKEN="$token"
	sed -i "s/abcd1234/${API_TOKEN}/g" /etc/ddns/config.json
	echo -e "你的${GREEN}token${NC}：${GREEN}${API_TOKEN}${NC}"
