1. Use ubuntu 16.04
2. Keep build-vpp.sh scripts and patches folders in one directory
3. When building for the first time execute:

./build-vpp.sh initial

The repositories will be cloned and necessary patches applied prior
to building the code. Although it's meant to be automatic,
it may require manual intervention of the user.

4. Once everything is completed successfully output files like
kernel images, modules and binaries will be placed in
'output' directory. Moreover it will also be automatically
packed to the 'vpp.tgz' file, that should be copied
to the destination board rootfs and unpacked with:

tar -xf vpp.tgz

5. Enter created directory and execute:

./start_with_crypto.sh

The VPP should successfully run and reach prompt.

6. Quick rebuild after musdk/dpdk modification:

Export the variables from the begining of the build-vpp.sh

cd ${MUSDK_PATH}
make -j8 && make install

cd ${DPDK_PATH}
make -j8 EXTRA_CFLAGS="-fPIC"

cd ${VPP_PATH}
touch src/plugins/dpdk/device/dpdk.h
make -j8 build-release PLATFORM=a3k

Now copy the shared library file:
build-root/install-a3k-aarch64/vpp/lib64/vpp_plugins/dpdk_plugin.so
to the vpp_plugins on the target board.

This procedure only rebuilds the parts of libraries which
are used inside VPP, no modules or kernel are rebuild.


Known issue: HW encrypted traffic will crash the application.
