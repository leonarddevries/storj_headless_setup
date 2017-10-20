#!/bin/bash

# Detect (and save) your tunnel's IP address, needed for building the URL to POST 
ifconfig tun0|grep -oE "inet *10\.[0-9]+\.[0-9]+\.[0-9]+"|tr -d "a-z :" > /tmp/vpn_ip

# Detect (and save) your world-visible IP, assuming the default assignment of vlan2 for VPN tunnel #1
echo $(wget -q -O - ipecho.net/plain) > /tmp/vpn_external_ip

# Extract (and save) the port number returned from the POST curl command which is suggested in the original post (replace [...] with the command, of course) 
curl -d "user=p5678409&pass=R47qDqi4HwuqQ6dQEPw6&client_id=$(cat /home/storj/storj/.pia_client_id)&local_ip=$(cat /tmp/vpn_ip)" https://www.privateinternetaccess.com/vpninfo/port_forward_assignment 2>/dev/null|grep -oE "[0-9]+" > /tmp/vpn_port_opened

VPN_EXT_IP=$(cat /tmp/vpn_external_ip)
VPN_IP=$(cat /tmp/vpn_ip)
OPEN_PORT=$(cat /tmp/vpn_port_opened)

echo "$(date) Remote IP: $VPN_EXT_IP  -- Forwarded port: $OPEN_PORT"


iptables -t nat -F
iptables -F
iptables -X



iptables -A INPUT -i enp2s0 -m state --state NEW -p udp --dport 1194 -j ACCEPT

iptables -A INPUT -i tun+ -j ACCEPT

iptables -A FORWARD -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -o enp2s0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i enp2s0 -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -t nat -A POSTROUTING -s 10.21.0.0/24 -o enp2s0 -j MASQUERADE



#Allow over VPN
iptables -A INPUT -i tun+ -j ACCEPT
iptables -A OUTPUT -o tun+ -j ACCEPT

#Localhost
iptables -A INPUT -s 127.0.0.1/8 -j ACCEPT
iptables -A OUTPUT -d 127.0.0.1/8 -j ACCEPT


/usr/local/bin/noip2 &> /dev/null
