#!/bin/bash


# Ping
echo "Ping 192.168.0.0/27"
ip=192.168.0.
	for((i=1;i<30;i++))
        do
	result=$(ping -i 0.2 -c 1 -W 1 -q $ip$i | grep transmitted)
        pattern="0 received";
        if [[ $result =~ $pattern ]]; then
                echo "$ip$i is down"
        else
            	echo "$ip$i is UP"
        fi
	done
# Arp-table print.

echo "Arp table:"

touch arp_log.txt
arp -e | grep C | grep -v "gateway" | tee -a arp_log.txt > /dev/null 2>&1
arp_r=$(awk '{print $1,$3}' arp_log.txt)
echo "$arp_r"
rm -f arp_log.txt
echo " "

# Uplink definition

touch walker.log.txt
ip route | grep -v "192.168" | tee -a walker.log.txt > /dev/null 2>&1
uplink=$(sed -n 1p walker.log.txt | awk '{print $5}')
echo "Uplink: $uplink"
rm -f walker.log.txt

# Firewall

fw_up=$(sed -n 10p /etc/firewall.conf | awk '{print $4}')
echo "Uplink in file firewall.conf: $fw_up"
if [ "$fw_up" = "$uplink" ]; then
        echo "Allready right uplink in firewall.conf file"
else
    	sed -i "s/$fw_up/$uplink/g" /etc/firewall.conf
        echo "File firewall.conf edited!"
fi
