#!/bin/bash
# ===============================
#  name: iptables_config.sh
#
#  Description: sets up a basic firewall with iptables
#
#  Please make sure that other firewalls are disabled before running this script
#
#  tested on: Debian GNU/Linux 12 (bookworm)
# ===============================

# uncomment next line for debugging
# set -x #tracing-option

IPT_CMD="sudo iptables"

#delete old rules
$IPT_CMD -F

#set Default Policy
$IPT_CMD -P INPUT DROP
$IPT_CMD -P OUTPUT DROP
$IPT_CMD -P FORWARD DROP

#enable Loopback 
$IPT_CMD -A INPUT -i lo -j ACCEPT
$IPT_CMD -A INPUT -i lo -j ACCEPT

#allow RELATED and ESTABLISHED connections for Input and Output
$IPT_CMD -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
$IPT_CMD -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

#open port 22 for ssh connections
$IPT_CMD -A INPUT -p tcp --dport ssh -j ACCEPT 

#allow DNS-queries for tcp and udp
$IPT_CMD -A OUTPUT -m state --state NEW -p tcp --dport domain -j ACCEPT
$IPT_CMD -A OUTPUT -m state --state NEW -p udp --dport domain -j ACCEPT

#allow certain icmp rules to receive useful network error messages
$IPT_CMD -A INPUT -m conntrack -p icmp --icmp-type 3 --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT #destination unreachable
$IPT_CMD -A INPUT -m conntrack -p icmp --icmp-type 11 --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT #TTL expiration date
$IPT_CMD -A INPUT -m conntrack -p icmp --icmp-type 11 --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT #bad ip header

#allow outgoing http and https
$IPT_CMD -A OUTPUT -m state --state NEW -m multiport -p tcp --dport http,https -j ACCEPT


