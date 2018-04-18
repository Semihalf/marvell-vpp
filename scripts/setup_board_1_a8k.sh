
export LD_LIBRARY_PATH=./lib64
export VPP_CTL=./bin/vppctl

export LAN_INTERFACE=TenGigabitEthernet0
export WAN_INTERFACE=TenGigabitEthernet1

$VPP_CTL "set int state $LAN_INTERFACE up"
$VPP_CTL "set int state $WAN_INTERFACE up"
$VPP_CTL "set interface ip address $LAN_INTERFACE 192.168.100.1/24"
$VPP_CTL "set interface ip address $WAN_INTERFACE 192.168.10.100/24"

$VPP_CTL "ip route add 0.0.0.0/0 via 192.168.10.200 $WAN_INTERFACE"
$VPP_CTL "ip route add 192.168.10.0/24 via 192.168.10.100 $WAN_INTERFACE"
$VPP_CTL "ip route add 192.168.100.0/24 via 192.168.100.1 $LAN_INTERFACE"

$VPP_CTL "ipsec sa add 10 spi 1001 esp crypto-alg aes-cbc-128 crypto-key 4a506a794f574265564551694d653768 integ-alg sha1-96 integ-key 4339314b55523947594d6d3547666b45764e6a58"
$VPP_CTL "ipsec sa add 20 spi 1000 esp crypto-alg aes-cbc-128 crypto-key 4a506a794f574265564551694d653768 integ-alg sha1-96 integ-key 4339314b55523947594d6d3547666b45764e6a58"
$VPP_CTL "ipsec spd add 1"
$VPP_CTL "set interface ipsec spd $WAN_INTERFACE 1"
$VPP_CTL "ipsec policy add spd 1 priority 100 inbound action bypass protocol 50"
$VPP_CTL "ipsec policy add spd 1 priority 100 outbound action bypass protocol 50"

## IPSec policies
$VPP_CTL "ipsec policy add spd 1 priority 10 inbound action protect sa 20 local-ip-range 192.168.100.1 - 192.168.100.10 remote-ip-range 192.168.200.1 - 192.168.200.10"
$VPP_CTL "ipsec policy add spd 1 priority 10 outbound action protect sa 10 local-ip-range 192.168.100.1 - 192.168.100.10 remote-ip-range 192.168.200.1 - 192.168.200.10"
