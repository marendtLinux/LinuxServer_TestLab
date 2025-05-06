#!/bin/bash
# ===============================
#  name: iptables_config.sh
#
#  Description: sets up a basic firewall with iptables for ipv4 and ipv6
#
#  Please make sure that other firewalls are disabled before running this script
#  
#
#  tested on: Debian GNU/Linux 12 (bookworm)
# ===============================

# uncomment next line for debugging
#set -x #tracing-option

IPT_CMD_IPV4="sudo iptables"
IPT_CMD_IPV6="sudo ip6tables"

ICMP_ALLOWED_TYPES_IPV4=(3 11 12) #destination unreachable, TTL expiration date and bad ip header
ICMP_ALLOWED_TYPES_IPV6=(1 2 3 4 128 129 130 131 132 134 135 136 141 142 143 148 149 151 152 153) #see https://datatracker.ietf.org/doc/html/rfc4890#section-1



basic_config() {

	#first two parameter is iptables-command
	local ipt_cmd="$1 $2"

	#delete old rules
	$ipt_cmd -F
	$ipt_cmd -X

	#set Default Policy
	$ipt_cmd -P INPUT DROP
	$ipt_cmd -P OUTPUT DROP
	$ipt_cmd -P FORWARD DROP

	#enable Loopback 
	$ipt_cmd -A INPUT -i lo -j ACCEPT
	$ipt_cmd -A INPUT -i lo -j ACCEPT

	#allow RELATED and ESTABLISHED connections for Input and Output
	$ipt_cmd -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
	$ipt_cmd -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

	#open port 22 for ssh connections
	$ipt_cmd -A INPUT -p tcp --dport ssh -j ACCEPT 

	#allow DNS-queries for tcp and udp
	$ipt_cmd -A OUTPUT -m state --state NEW -p tcp --dport domain -j ACCEPT
	$ipt_cmd -A OUTPUT -m state --state NEW -p udp --dport domain -j ACCEPT

	#allow outgoing http and https
	$ipt_cmd -A OUTPUT -m state --state NEW -m multiport -p tcp --dport http,https -j ACCEPT
}


configure_allowed_icmp_for_ipv4() {
	
	#save all function parametes in variable
	local icmp_allowd_types=("$@")

	#iterate over allowed ICMP-Types
	for icmp_type in ${icmp_allowd_types[*]}
	do
		$IPT_CMD_IPV4 -A INPUT -m conntrack -p icmp --icmp-type $icmp_type --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
	done
}


configure_allowed_icmp_for_ipv6() {
	
	#save all function parametes in variable
	local icmp_allowd_types=("$@")

	#iterate over allowed ICMP-Types
	for icmp_type in ${icmp_allowd_types[*]}
	do
		$IPT_CMD_IPV6 -A INPUT -m conntrack -p icmpv6 --icmpv6-type $icmp_type --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
	done
}



basic_config $IPT_CMD_IPV4
basic_config $IPT_CMD_IPV6

#expand array ICMP_ALLOWED_TYPES_IPV4 when calling function
configure_allowed_icmp_for_ipv4 "${ICMP_ALLOWED_TYPES_IPV4[@]}"

#expand array ICMP_ALLOWED_TYPES_IPV6 when calling function
configure_allowed_icmp_for_ipv6 "${ICMP_ALLOWED_TYPES_IPV6[@]}"



