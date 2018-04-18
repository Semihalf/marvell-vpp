#!/bin/bash

ROOT_DIR=$PWD
export LD_LIBRARY_PATH="$ROOT_DIR/lib64/"
export STARTUP_PARAMETERS="unix { interactive nodaemon log /tmp/vpp.log cli-listen /run/vpp/cli.sock } api-trace { on } cpu { workers 1 } dpdk { vdev eth_mvneta,iface=eth0,iface=eth1 vdev crypto_mrvl no-multi-seg num-mbufs 8192 socket-mem 64 }"

cat /proc/mounts | grep -q hugetlbfs || $(mkdir -p /dev/hugepages; mount -t hugetlbfs hugetlbfs /dev/hugepages)
echo 100 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

ip link set dev eth0 up
ifconfig eth0 promisc
ip link set dev eth1 up
ifconfig eth1 promisc

insmod ./modules/musdk_uio.ko
insmod ./modules/mv_neta_uio.ko
insmod ./modules/crypto_safexcel.ko rings=0,0
insmod ./modules/mv_sam_uio.ko


$ROOT_DIR/bin/vpp $STARTUP_PARAMETERS heapsize 50M plugin_path $ROOT_DIR/lib64/vpp_plugins/
