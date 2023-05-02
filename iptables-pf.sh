#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS/Debian/Ubuntu
#	Description: iptables Port forwarding
#	Version: 1.1.1
#	Author: Toyo
#	Blog: https://doub.io/wlzy-20/
#=================================================
sh_ver="1.1.1"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[Information]${Font_color_suffix}"
Error="${Red_font_prefix}[Mistake]${Font_color_suffix}"
Tip="${Green_font_prefix}[Notice]${Font_color_suffix}"

check_iptables(){
	iptables_exist=$(iptables -V)
	[[ ${iptables_exist} = "" ]] && echo -e "${Error} iptables is not installed, please check !" && exit 1
}
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
	#bit=`uname -m`
}
install_iptables(){
	iptables_exist=$(iptables -V)
	if [[ ${iptables_exist} != "" ]]; then
		echo -e "${Info} iptables has been installed, continue..."
	else
		echo -e "${Info} iptables not installed detected, starting installation..."
		if [[ ${release}  == "centos" ]]; then
			yum update
			yum install -y iptables
		else
			apt-get update
			apt-get install -y iptables
		fi
		iptables_exist=$(iptables -V)
		if [[ ${iptables_exist} = "" ]]; then
			echo -e "${Error} Failed to install iptables, please check !" && exit 1
		else
			echo -e "${Info} iptables installation complete!"
		fi
	fi
	echo -e "${Info} Let's configure iptables!"
	Set_iptables
	echo -e "${Info} iptables configuration complete!"
}
Set_forwarding_port(){
	read -e -p "Please enter the remote port [1-65535] to be forwarded to by iptables (support port range such as 2333-6666, to be forwarded to the server):" forwarding_port
	[[ -z "${forwarding_port}" ]] && echo "Cancel..." && exit 1
	echo && echo -e "	To forward ports: ${Red_font_prefix}${forwarding_port}${Font_color_suffix}" && echo
}
Set_forwarding_ip(){
		read -e -p "Please enter the remote IP to be forwarded to by iptables (forwarded server):" forwarding_ip
		[[ -z "${forwarding_ip}" ]] && echo "Cancel..." && exit 1
		echo && echo -e "	To forward server IP : ${Red_font_prefix}${forwarding_ip}${Font_color_suffix}" && echo
}
Set_local_port(){
	echo -e "Please enter the iptables local listening port [1-65535] (support port segment such as 2333-6666)"
	read -e -p "(Default port: ${forwarding_port}):" local_port
	[[ -z "${local_port}" ]] && local_port="${forwarding_port}"
	echo && echo -e "	Local listening port : ${Red_font_prefix}${local_port}${Font_color_suffix}" && echo
}
Set_local_ip(){
	read -e -p "Please enter the network card IP of this server (note that it is the IP bound to the network card, not just the public network IP, press Enter to automatically detect the external network IP):" local_ip
	if [[ -z "${local_ip}" ]]; then
		local_ip=$(wget -qO- -t1 -T2 ipinfo.io/ip)
		if [[ -z "${local_ip}" ]]; then
			echo "${Error} The public IP of this server cannot be detected, please enter it manually"
			read -e -p "Please enter the network card IP of this server (note that it is the IP bound to the network card, not just the public network IP):" local_ip
			[[ -z "${local_ip}" ]] && echo "Cancel..." && exit 1
		fi
	fi
	echo && echo -e "	This server IP: ${Red_font_prefix}${local_ip}${Font_color_suffix}" && echo
}
Set_forwarding_type(){
	echo -e "Please enter a number to select the iptables forwarding type:
 1. TCP
 2. UDP
 3. TCP+UDP\n"
	read -e -p "(default: TCP+UDP):" forwarding_type_num
	[[ -z "${forwarding_type_num}" ]] && forwarding_type_num="3"
	if [[ ${forwarding_type_num} == "1" ]]; then
		forwarding_type="TCP"
	elif [[ ${forwarding_type_num} == "2" ]]; then
		forwarding_type="UDP"
	elif [[ ${forwarding_type_num} == "3" ]]; then
		forwarding_type="TCP+UDP"
	else
		forwarding_type="TCP+UDP"
	fi
}
Set_Config(){
	Set_forwarding_port
	Set_forwarding_ip
	Set_local_port
	Set_local_ip
	Set_forwarding_type
	echo && echo -e "——————————————————————————————
	Please check whether the configuration of iptables port forwarding rules is wrong !\n
	local listening port    : ${Green_font_prefix}${local_port}${Font_color_suffix}
	Server IP\t: ${Green_font_prefix}${local_ip}${Font_color_suffix}\n
	Port to forward    : ${Green_font_prefix}${forwarding_port}${Font_color_suffix}
	To forward IP\t: ${Green_font_prefix}${forwarding_ip}${Font_color_suffix}
	Forwarding type\t: ${Green_font_prefix}${forwarding_type}${Font_color_suffix}
——————————————————————————————\n"
	read -e -p "Please press any key to continue, or use Ctrl+C to exit if there is a configuration error." var
}
Add_forwarding(){
	check_iptables
	Set_Config
	local_port=$(echo ${local_port} | sed 's/-/:/g')
	forwarding_port_1=$(echo ${forwarding_port} | sed 's/-/:/g')
	if [[ ${forwarding_type} == "TCP" ]]; then
		Add_iptables "tcp"
	elif [[ ${forwarding_type} == "UDP" ]]; then
		Add_iptables "udp"
	elif [[ ${forwarding_type} == "TCP+UDP" ]]; then
		Add_iptables "tcp"
		Add_iptables "udp"
	fi
	Save_iptables
	clear && echo && echo -e "——————————————————————————————
	iptables The port forwarding rules are configured !\n
	Local listening port    : ${Green_font_prefix}${local_port}${Font_color_suffix}
	Server IP\t: ${Green_font_prefix}${local_ip}${Font_color_suffix}\n
	Port to forward    : ${Green_font_prefix}${forwarding_port_1}${Font_color_suffix}
	To forward IP\t: ${Green_font_prefix}${forwarding_ip}${Font_color_suffix}
	Forwarding type\t: ${Green_font_prefix}${forwarding_type}${Font_color_suffix}
——————————————————————————————\n"
}
View_forwarding(){
	check_iptables
	forwarding_text=$(iptables -t nat -vnL PREROUTING|tail -n +3)
	[[ -z ${forwarding_text} ]] && echo -e "${Error} No iptables port forwarding rules found, please check!" && exit 1
	forwarding_total=$(echo -e "${forwarding_text}"|wc -l)
	forwarding_list_all=""
	for((integer = 1; integer <= ${forwarding_total}; integer++))
	do
		forwarding_type=$(echo -e "${forwarding_text}"|awk '{print $4}'|sed -n "${integer}p")
		forwarding_listen=$(echo -e "${forwarding_text}"|awk '{print $11}'|sed -n "${integer}p"|awk -F "dpt:" '{print $2}')
		[[ -z ${forwarding_listen} ]] && forwarding_listen=$(echo -e "${forwarding_text}"| awk '{print $11}'|sed -n "${integer}p"|awk -F "dpts:" '{print $2}')
		forwarding_fork=$(echo -e "${forwarding_text}"| awk '{print $12}'|sed -n "${integer}p"|awk -F "to:" '{print $2}')
		forwarding_list_all=${forwarding_list_all}"${Green_font_prefix}"${integer}".${Font_color_suffix} Type: ${Green_font_prefix}"${forwarding_type}"${Font_color_suffix} Listening port: ${Red_font_prefix}"${forwarding_listen}"${Font_color_suffix} Forward IP and port: ${Red_font_prefix}"${forwarding_fork}"${Font_color_suffix}\n"
	done
	echo && echo -e "Currently have ${Green_background_prefix} "${forwarding_total}" ${Font_color_suffix} 个 iptables port forwarding rules。"
	echo -e ${forwarding_list_all}
}
Del_forwarding(){
	check_iptables
	while true
	do
	View_forwarding
	read -e -p "Please enter a number to select the iptables port forwarding rule to be deleted (by default press Enter to cancel):" Del_forwarding_num
	[[ -z "${Del_forwarding_num}" ]] && Del_forwarding_num="0"
	echo $((${Del_forwarding_num}+0)) &>/dev/null
	if [[ $? -eq 0 ]]; then
		if [[ ${Del_forwarding_num} -ge 1 ]] && [[ ${Del_forwarding_num} -le ${forwarding_total} ]]; then
			forwarding_type=$(echo -e "${forwarding_text}"| awk '{print $4}' | sed -n "${Del_forwarding_num}p")
			forwarding_listen=$(echo -e "${forwarding_text}"| awk '{print $11}' | sed -n "${Del_forwarding_num}p" | awk -F "dpt:" '{print $2}' | sed 's/-/:/g')
			[[ -z ${forwarding_listen} ]] && forwarding_listen=$(echo -e "${forwarding_text}"| awk '{print $11}' |sed -n "${Del_forwarding_num}p" | awk -F "dpts:" '{print $2}')
			Del_iptables "${forwarding_type}" "${Del_forwarding_num}"
			Save_iptables
			echo && echo -e "${Info} iptables Port forwarding rule deletion complete!" && echo
		else
			echo -e "${Error} Please enter the correct number!"
		fi
	else
		break && echo "Cancel..."
	fi
	done
}
Uninstall_forwarding(){
	check_iptables
	echo -e "Are you sure you want to clear all port forwarding rules in iptables? [y/N]"
	read -e -p "(default: n):" unyn
	[[ -z ${unyn} ]] && unyn="n"
	if [[ ${unyn} == [Yy] ]]; then
		forwarding_text=$(iptables -t nat -vnL PREROUTING|tail -n +3)
		[[ -z ${forwarding_text} ]] && echo -e "${Error} No iptables port forwarding rules found, please check !" && exit 1
		forwarding_total=$(echo -e "${forwarding_text}"|wc -l)
		for((integer = 1; integer <= ${forwarding_total}; integer++))
		do
			forwarding_type=$(echo -e "${forwarding_text}"|awk '{print $4}'|sed -n "${integer}p")
			forwarding_listen=$(echo -e "${forwarding_text}"|awk '{print $11}'|sed -n "${integer}p"|awk -F "dpt:" '{print $2}')
			[[ -z ${forwarding_listen} ]] && forwarding_listen=$(echo -e "${forwarding_text}"| awk '{print $11}'|sed -n "${integer}p"|awk -F "dpts:" '{print $2}')
			# echo -e "${forwarding_text} ${forwarding_type} ${forwarding_listen}"
			Del_iptables "${forwarding_type}" "${integer}"
		done
		Save_iptables
		echo && echo -e "${Info} iptables 已清空 所有端口转发规则 !" && echo
	else
		echo && echo "清空已取消..." && echo
	fi
}
Add_iptables(){
	iptables -t nat -A PREROUTING -p "$1" --dport "${local_port}" -j DNAT --to-destination "${forwarding_ip}":"${forwarding_port}"
	iptables -t nat -A POSTROUTING -p "$1" -d "${forwarding_ip}" --dport "${forwarding_port_1}" -j SNAT --to-source "${local_ip}"
	echo "iptables -t nat -A PREROUTING -p $1 --dport ${local_port} -j DNAT --to-destination ${forwarding_ip}:${forwarding_port}"
	echo "iptables -t nat -A POSTROUTING -p $1 -d ${forwarding_ip} --dport ${forwarding_port_1} -j SNAT --to-source ${local_ip}"
	echo "${local_port}"
	iptables -I INPUT -m state --state NEW -m "$1" -p "$1" --dport "${local_port}" -j ACCEPT
}
Del_iptables(){
	iptables -t nat -D POSTROUTING "$2"
	iptables -t nat -D PREROUTING "$2"
	iptables -D INPUT -m state --state NEW -m "$1" -p "$1" --dport "${forwarding_listen}" -j ACCEPT
}
Save_iptables(){
	if [[ ${release} == "centos" ]]; then
		service iptables save
	else
		iptables-save > /etc/iptables.up.rules
	fi
}
Set_iptables(){
	echo -e "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
	sysctl -p
	if [[ ${release} == "centos" ]]; then
		service iptables save
		chkconfig --level 2345 iptables on
	else
		iptables-save > /etc/iptables.up.rules
		echo -e '#!/bin/bash\n/sbin/iptables-restore < /etc/iptables.up.rules' > /etc/network/if-pre-up.d/iptables
		chmod +x /etc/network/if-pre-up.d/iptables
	fi
}
Update_Shell(){
	sh_new_ver=$(wget --no-check-certificate -qO- -t1 -T3 "https://raw.githubusercontent.com/pouyaam/iptables-pf/main/iptables-pf.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1)
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} unable to link to Github !" && exit 0
	wget -N --no-check-certificate "https://raw.githubusercontent.com/pouyaam/iptables-pf/main/iptables-pf.sh" && chmod +x iptables-pf.sh
	echo -e "The script has been updated to the latest version[ ${sh_new_ver} ] !(Note: Because the update method is to directly overwrite the currently running script, some errors may be prompted below, just ignore it)" && exit 0
}
check_sys
echo && echo -e " iptables Port forwarding one-click management script ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  -- Toyo | doub.io/wlzy-20 --
  
 ${Green_font_prefix}0.${Font_color_suffix} Upgrade script
————————————
 ${Green_font_prefix}1.${Font_color_suffix} Install iptables
 ${Green_font_prefix}2.${Font_color_suffix} Clear iptables port forwarding
————————————
 ${Green_font_prefix}3.${Font_color_suffix} View iptables port forwarding
 ${Green_font_prefix}4.${Font_color_suffix} Add iptables port forwarding
 ${Green_font_prefix}5.${Font_color_suffix} Remove iptables port forwarding
————————————
Note: Please be sure to execute before the first use ${Green_font_prefix}1. Install iptables${Font_color_suffix}(not just install)" && echo
read -e -p " Please enter the number [0-5]:" num
case "$num" in
	0)
	Update_Shell
	;;
	1)
	install_iptables
	;;
	2)
	Uninstall_forwarding
	;;
	3)
	View_forwarding
	;;
	4)
	Add_forwarding
	;;
	5)
	Del_forwarding
	;;
	*)
	echo "Please enter the correct number [0-5]"
	;;
esac
