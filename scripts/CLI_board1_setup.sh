## Interface Configuration

export LAN_INTERFACE=Two_FiveGigabitEthernet0
export WAN_INTERFACE=Two_FiveGigabitEthernet1

export LAN_MAC=00:54:32:00:00:01
export WAN_MAC=00:54:32:00:00:04

echo "set int state $LAN_INTERFACE up"
echo "set int state $WAN_INTERFACE up"
echo "set interface ip address $LAN_INTERFACE 192.168.100.1/24"
echo "set interface ip address $WAN_INTERFACE 192.168.10.100/24"

## Static ARP Entries
echo "set ip arp $LAN_INTERFACE 192.168.100.2 $LAN_MAC"
echo "set ip arp $WAN_INTERFACE 192.168.10.200 $WAN_MAC"
echo "set ip arp $WAN_INTERFACE 192.168.200.2 $WAN_MAC"

## Static Routing Entries
# The first entry is the default rule for all to-WAN traffic (e.g., default gateway. Here, it indicates the next hop to route to the remote IXIA port)
# The second entry is the rule for IP tunnel (not sure if it's mandotory or not)
# The third entry is the rule for to-LAN traffic
echo "ip route add 0.0.0.0/0 via 192.168.10.200 $WAN_INTERFACE"
echo "ip route add 192.168.10.0/24 via 192.168.10.100 $WAN_INTERFACE"
echo "ip route add 192.168.100.0/24 via 192.168.100.1 $LAN_INTERFACE"

echo "ipsec sa add 10 spi 1001 esp crypto-alg aes-cbc-128 crypto-key 4a506a794f574265564551694d653768 integ-alg sha1-96 integ-key 4339314b55523947594d6d3547666b45764e6a58"
echo "ipsec sa add 20 spi 1000 esp crypto-alg aes-cbc-128 crypto-key 4a506a794f574265564551694d653768 integ-alg sha1-96 integ-key 4339314b55523947594d6d3547666b45764e6a58"
echo "ipsec spd add 1"
echo "set interface ipsec spd $WAN_INTERFACE 1"
echo "ipsec policy add spd 1 priority 100 inbound action bypass protocol 50"
echo "ipsec policy add spd 1 priority 100 outbound action bypass protocol 50"

## IPSec policies
echo "ipsec policy add spd 1 priority 10 inbound action protect sa 20 local-ip-range 192.168.100.1 - 192.168.100.10 remote-ip-range 192.168.200.1 - 192.168.200.10"
echo "ipsec policy add spd 1 priority 10 outbound action protect sa 10 local-ip-range 192.168.100.1 - 192.168.100.10 remote-ip-range 192.168.200.1 - 192.168.200.10"
