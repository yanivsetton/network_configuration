#!/bin/bash
set -e

DEF_DOM="yourDomain.com"
DEF_IP="10.10.0."
DEF_NM="255.255.0.0"
DEF_GW="10.10.0.1"
DEF_DNS1="8.8.8.8"
DEF_DNS2="8.8.4.4"
DEF_ADMIN="admin@$DEF_DOM"
DEF_RELAY="mail.$DEF_DOM"


    read -e -p "Press enter for DHCP or N for static IP configuration [Y/n] " usedhcp
    echo ""
    ifconfig -s -a | awk '{print $1}'
    echo ""
    read -e -p "Type the interface you want to configure: " interface_name
    case "$usedhcp" in
        [Nn])
            read -ei "$DEF_DOM"  -p "Domain name: " dn
            read -ei "$DEF_IP"   -p "Primary IP address: " ipaddr
            read -ei "$DEF_NM"   -p "Subnet Mask: " nm
            read -ei "$DEF_GW"   -p "Gateway: " gw
            read -ei "$DEF_DNS1" -p "First DNS server: " dns1
            read -ei "$DEF_DNS2" -p "Second DNS server: " dns2

            echo "Adding /etc/hosts entry for $ipaddr $hn.$dn"
            echo "$ipaddr  $hn.$dn  $hn" >> /etc/hosts

            echo "Configuring /etc/resolv.conf with DNS servers $dns1 and $dns2 and search of $dn"
            cat /dev/null > /etc/resolv.conf
            echo "search $dn" >> /etc/resolv.conf
            echo "nameserver $dns1" >> /etc/resolv.conf
            echo "nameserver $dns2" >> /etc/resolv.conf

            echo "Reconfiguring interface eth0 via ifupdown..."
            
            of="/etc/network/interfaces"
            cat /dev/null > $of
            echo "auto lo" >> $of
            echo "iface lo inet loopback" >> $of
            echo "" >> $of
            echo "auto $interface_name" >> $of
            echo "iface $interface_name inet static" >> $of
            echo "        address $ipaddr" >> $of
            echo "        netmask $nm" >> $of
            echo "        gateway $gw" >> $of
        ;;
        [Yy]*)
            echo "Setting $interface_name as DHCP in /etc/network/interfaces..."
           
            rm -f /var/lib/dhcp3/*leases
            of="/etc/network/interfaces"
            cat /dev/null > $of
            echo "auto lo" >> $of
            echo "iface lo inet loopback" >> $of
            echo "" >> $of
            echo "auto $interface_name" >> $of
            echo "iface $interface_name inet dhcp" >> $of
        ;;    
    esac

echo "done."
