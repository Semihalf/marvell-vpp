#!/bin/bash

#### Prepare environment
export ROOTDIR=${PWD}
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS=$CROSS_COMPILE
export KDIR=${ROOTDIR}/linux-marvell
export RTE_KERNELDIR=$KDIR
export RTE_TARGET=arm64-armv8a-linuxapp-gcc
export LIBMUSDK_PATH=${ROOTDIR}/musdk/usr/local
export DPDK_PATH=${ROOTDIR}/marvell-dpdk
export MUSDK_PATH=${ROOTDIR}/musdk
export VPP_PATH=${ROOTDIR}/marvell-vpp
export BOARD=a3k

export DATE=`date +%Y_%m_%d`

#### Fetch sources
if [ "${1}" == "initial" ]; then
git clone https://github.com/Semihalf/marvell-dpdk.git ${MUSDK_PATH} -b musdk-armada-17.10-mvneta
cd ${MUSDK_PATH}
git checkout origin/musdk-armada-17.10 -b musdk-armada-17.10
cd -
git clone https://github.com/Semihalf/marvell-dpdk.git ${DPDK_PATH} -b mrvl-dev-a3k
git clone https://github.com/MarvellEmbeddedProcessors/linux-marvell.git ${KDIR} -b linux-4.4.52-armada-17.10
git clone https://github.com/Semihalf/marvell-vpp.git ${VPP_PATH} -b marvell_on_18_01_old

#### Install tools
sudo apt install gcc-aarch64-linux-gnu
sudo apt install g++-aarch64-linux-gnu

sudo apt install libtool
sudo apt install automake
sudo apt install bc

#Prepare arm64 libraries
sudo dpkg --add-architecture arm64
sudo vi /etc/apt/sources.list.d/arm64.list
#Paste below (after uncommenting):
#deb [arch=arm64] http://ports.ubuntu.com/ xenial main restricted
#deb [arch=arm64] http://ports.ubuntu.com/ xenial-updates main restricted
#deb [arch=arm64] http://ports.ubuntu.com/ xenial universe
#deb [arch=arm64] http://ports.ubuntu.com/ xenial-updates universe
#deb [arch=arm64] http://ports.ubuntu.com/ xenial multiverse
#deb [arch=arm64] http://ports.ubuntu.com/ xenial-updates multiverse
#deb [arch=arm64] http://ports.ubuntu.com/ xenial-backports main restricted universe multiverse
sudo apt update
sudo apt install libnuma-dev:arm64 libmbedtls-dev:arm64 libssl-dev:arm64 libboost-thread-dev:arm64
fi

if [ "${BOARD}" == "a3k" ]; then
	cd ${MUSDK_PATH}
	git checkout musdk-armada-17.10-mvneta
	cd -
elif [ "${BOARD}" == "a8k" ]; then
	cd ${MUSDK_PATH}
	git checkout musdk-armada-17.10
	cd -
else
	echo "Specify the target board by exporting the BOARD variable"
	exit 1
fi
	


#### Linux
echo -e "\nBUILD KERNEL\n"
cd ${KDIR}
if [ "${1}" == "initial" ]; then
git am ${MUSDK_PATH}/patches/linux/000*
make mvebu_v8_lsp_defconfig
fi
if [ "${1}" == "clean" ]; then
make mrproper
make mvebu_v8_lsp_defconfig
fi
mv .git .git.b
make -j8 Image dtbs
make -j8 drivers/crypto/inside-secure/crypto_safexcel.ko
mv .git.b .git

#### MUSDK
cd $MUSDK_PATH
echo -e "\nBUILD MUSDK\n"

if [ "${1}" == "initial" ]; then
git am ${ROOTDIR}/patches/0001-musdk-add-compile-option-fPIC.PATCH
fi

if [ "${1}" == "clean" ]; then
make clean
fi

if [ DEBUG == "1" ]; then
	export DEBUG_FLAGS="--enable-debug-level=7 --enable-sam-debug"
else
	export DEBUG_FLAGS=""
fi

./bootstrap
if [ "${BOARD}" == "a3k" ]; then
./configure \
      --enable-pp2=no \
      --enable-neta \
      --enable-sam \
      --enable-bpool-dma=64 ${DEBUG_FLAGS}
else
./configure \
      --enable-sam \
      --enable-bpool-dma=64 ${DEBUG_FLAGS}
fi

make -j8
make install

if [ "${BOARD}" == "a3k" ]; then
	make -C modules/neta
else
	make -C modules/pp2
	cd ${ROOTDIR}/mvpp2x-marvell/sysfs/
	mv Makefile_sysfs Makefile
	make -j8
	cd -
fi

make -C modules/sam
make -C modules/uio

#### DPDK
echo -e "\nBUILD DPDK\n"
cd $DPDK_PATH
if [ "${1}" == "clean" ]; then
make clean
fi
make config T=${RTE_TARGET}

if [ "${BOARD}" == "a3k" ]; then
	sed -i "s/MVNETA_PMD=n/MVNETA_PMD=y/" build/.config
	sed -i "s/MRVL_PMD=y/MRVL_PMD=n/" build/.config
else
	sed -i "s/MVNETA_PMD=y/MVNETA_PMD=n/" build/.config
	sed -i "s/MRVL_PMD=n/MRVL_PMD=y/" build/.config
fi

sed -i "s/MRVL_CRYPTO=n/MRVL_CRYPTO=y/" build/.config
sed -i "s/VHOST_NUMA=y/VHOST_NUMA=n/" build/.config
sed -i "s/NUMA_AWARE_HUGEPAGES=y/NUMA_AWARE_HUGEPAGES=n/" build/.config
sed -i "s/PMD_TAP=y/PMD_TAP=n/" build/.config
sed -i "s/DPAA_EVENTDEV=y/DPAA_EVENTDEV=n/" build/.config
sed -i "s/DPAA_BUS=y/DPAA_BUS=n/" build/.config
sed -i "s/DPAA_MEMPOOL=y/DPAA_MEMPOOL=n/" build/.config
sed -i "s/DPAA_PMD=y/DPAA_PMD=n/" build/.config
sed -i "s/PMD_DPAA_SEC=y/PMD_DPAA_SEC=n/" build/.config
make -j8 EXTRA_CFLAGS="-fPIC"
ln -s build arm64-armv8a-linuxapp-gcc
make -j8 examples T=arm64-armv8a-linuxapp-gcc

#### VPP
echo -e "\nBUILD VPP\n"
cd $VPP_PATH
if [ "${1}" == "clean" ]; then
git clean -xdf
fi

make install-dep

if [ "${1}" == "initial" ]; then
#Apply patch and create tag
git am ${ROOTDIR}/patches/0001-vpp-add-cross-compile-for-a3k.patch
git tag -a ${BOARD}_${DATE} -m ${BOARD}
fi

make bootstrap PLATFORM=a3k
make -j8 build-release PLATFORM=a3k

#### Prepare package
echo -e "\nPREPARE OUTPUT DIRECTORY\n"
cd ${ROOTDIR}
rm -rf output

mkdir -p output/modules
cp ${MUSDK_PATH}/modules/uio/musdk_uio.ko output/modules
cp ${MUSDK_PATH}/modules/sam/mv_sam_uio.ko output/modules
cp ${KDIR}/drivers/crypto/inside-secure/crypto_safexcel.ko output/modules

if [ "${BOARD}" == "a3k" ]; then
	cp ${MUSDK_PATH}/modules/neta/mv_neta_uio.ko output/modules
else
	cp ${MUSDK_PATH}/modules/pp2/mv_pp_uio.ko output/modules
fi

mkdir -p output/lib64/vpp_plugins/
cp ${VPP_PATH}/build-root/install-a3k-aarch64/vpp/lib64/vpp_plugins/dpdk_plugin.so output/lib64/vpp_plugins/

cp ${VPP_PATH}/build-root/install-a3k-aarch64/vpp/lib64/lib* output/lib64

mkdir -p output/images
cp ${KDIR}/arch/arm64/boot/Image output/images

if [ "${BOARD}" == "a3k" ]; then
	cp ${KDIR}/arch/arm64/boot/dts/marvell/armada-37*.dtb output/images
else
	cp ${KDIR}/arch/arm64/boot/dts/marvell/armada-8040*.dtb output/images
fi

mkdir -p output/bin
cp ${VPP_PATH}/build-root/install-a3k-aarch64/vpp/bin/vpp* output/bin

if [ "${BOARD}" == "a3k" ]; then
	cp scripts/*a3k* output/
else
	cp scripts/*a8k* output/
fi

tar -czf vpp.tgz output/*

echo -e "\nBUILD COMPLETE\n"
