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

Known issue: HW encrypted traffic will crash the application.
