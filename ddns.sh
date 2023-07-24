#!/bin/bash

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
NC="\033[0m"

mainmenu() {
	echo ""
	read -rp "请输入“y”退出, 或按任意键回到主菜单：" mainmenu
	case "$mainmenu" in
		y) exit 1 ;;
		*) menu ;;
	esac
}

install_base(){
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
	echo -e "${RED}无法确定操作系统类型，无法自动安装Python3。${NC}" mainmenu
    fi
	fi

# 检查Python3是否安装成功
if command -v python3 &> /dev/null; then
	echo -e "${GREEN}Python3安装成功。${NC}"
else
	echo -e "${RED}Python3安装失败，或尝试手动安装Python3。${NC}"
	mainmenu
fi
}

install_ddns(){
	install_base
	# 安装Ddns
	if [ -d "/etc/ddns" ]; then
		echo -e "${GREEN}已检测到已安装ddns，不需要再次安装。${NC}"
	else
		echo -e "${GREEN}开始安装 Ddns...${NC}"
		if git clone https://github.com/RyanY610/Ddns.git /etc/ddns; then
			echo -e "${GREEN}Ddns 安装成功。${NC}"
		else
			echo -e "${RED}Ddns 安装失败，请检查/var下是否存在dnmp目录。${NC}" && mainmenu
		fi
	fi
	mainmenu
}

set_ddns(){
	# 修改配置
	cd /etc/ddns && rm -rf confog.json
	if ! command -v python3 &> /dev/null; then
		echo -e "${GREEN}未安装 Python 3，请安装 Python 3${NC}" && mainmenu
	fi

	wget -qP /etc/ddns/ https://raw.githubusercontent.com/RyanY610/Ddns/main/config.json
	read -rp "请输入解析的 ipv4 域名: " ipv4_domain
	[[ -z $ipv4_domain ]] && echo -e "${RED}未输入域名，无法执行操作！${NC}" && mainmenu
	IPV4_DOMAIN="$ipv4_domain"
	sed -i "s/cloudflare.com/${IPV4_DOMAIN}/g" /etc/ddns/config.json
	echo -e "你的 ${GREEN}ipv4 域名${NC}：${GREEN}${IPV4_DOMAIN}${NC}"

	read -rp "请输入解析的 IPv6 域名（没有可留空）： " ipv6_domain

	if [ -z "$ipv6_domain" ]; then
		IPV6_ENTRY='"ipv6": []'
	else
		IPV6_ENTRY='"ipv6": ["'"$ipv6_domain"'"]'
	fi

	sed -i 's/"ipv6": \[.*\]/'"$IPV6_ENTRY"'/g' /etc/ddns/config.json

	echo -e "你的 ${GREEN}IPv6 域名${NC}：${GREEN}${ipv6_domain}${NC}"

	read -rp "请输入 dns 服务商(例如：cloudflare dnspod alidns): " dnsserver
	[[ -z $dnsserver ]] && echo -e "${RED}未输入 dns 服务商，无法执行操作！${NC}" && mainmenu
	DNSSERVER="$dnsserver"
	sed -i "s/server/${DNSSERVER}/g" /etc/ddns/config.json
	echo -e "你的 ${GREEN}dns 服务商${NC}：${GREEN}${DNSSERVER}${NC}"

	read -rp "请输入你的 api_id(cloudflare 为邮箱): " api_id
	[[ -z $api_id ]] && echo -e "${RED}未输入 api_id，无法执行操作！${NC}" && mainmenu
	API_ID="$api_id"
	sed -i "s/12345678/${API_ID}/g" /etc/ddns/config.json
	echo -e "你的 ${GREEN}api id${NC}：${GREEN}${API_ID}${NC}"

	read -rp "请输入你的 token(cloudflare 为 api_key): " token
	[[ -z $token ]] && echo -e "${RED}未输入 token，无法执行操作！${NC}" && mainmenu
	API_TOKEN="$token"
	sed -i "s/abcd1234/${API_TOKEN}/g" /etc/ddns/config.json
	echo -e "你的 ${GREEN}token${NC}：${GREEN}${API_TOKEN}${NC}"
	mainmenu
}

run_ddns(){
	service='[Unit]
	Description=RyanY610 ddns
	After=network.target

	[Service]
	Type=simple
	WorkingDirectory=/etc/ddns
	ExecStart=python3 /etc/ddns/ddns -c /etc/ddns/config.json

	[Install]
	WantedBy=multi-user.target'

	timer='[Unit]
	Description=RyanY610 ddns timer

	[Timer]
	OnUnitActiveSec=5m
	Unit=ddns.service

	[Install]
	WantedBy=multi-user.target'

	if [ ! -f "/etc/systemd/system/ddns.service" ] || [ ! -f "/etc/systemd/system/ddns.timer" ]; then
		echo -e "${GREEN}创建ddns定时任务...${NC}"
		echo "$service" > /etc/systemd/system/ddns.service
		echo "$timer" > /etc/systemd/system/ddns.timer
		echo -e "${GREEN}ddns定时任务已创建，每5分钟执行一次.${NC}"
	else
		echo -e "${YELLOW}服务和定时器单元文件已存在，无需再次创建.${NC}"
	fi
	systemctl enable ddns.timer
	systemctl restart ddns.timer
	mainmenu
}

uninstall_ddns(){
	read -p "确认卸载 Ddns 吗？(y/[N] 默认不卸载): " confirm
	if [ "$confirm" == "y" ]; then
		systemctl disable ddns.timer
		systemctl stop ddns.timer
		rm -rf /etc/systemd/system/ddns.service
		rm -rf /etc/systemd/system/ddns.timer
		rm -rf /etc/ddns
		echo -e "${GREEN}ddns 已彻底卸载!${NC}"
	else
		echo -e "${YELLOW}ddns卸载操作取消.${NC}"
	fi
	mainmenu
}

menu(){
	clear
	echo "#############################################################"
	echo -e "#                     ${RED}动态Ddns一键脚本${NC}                      #"
	echo -e "#                     ${GREEN}作者${NC}: 你挺能闹啊🍏                    #"
	echo "#############################################################"
	echo ""
	echo -e " ${GREEN}1.${NC} ${GREEN}安装 Ddns${NC}"
	echo -e " ${GREEN}2.${NC} ${RED}卸载 Ddns${NC}"
	echo -e " ${GREEN}3.${NC} 设置 Ddns 参数"
	echo -e " ${GREEN}4.${NC} ${GREEN}启动 Ddns${NC}"
	echo -e " ${GREEN}0.${NC} 退出脚本"
	read -rp "请输入选项 [0-4]: " meun
        echo ""
	echo ""
	case "$meun" in
		1) install_ddns ;;
		2) uninstall_ddns ;;
		3) set_ddns ;;
		4) run_ddns ;;
		*) exit 1 ;;
	esac
}

menu
