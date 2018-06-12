MACHINE = aarch64

mrvl_arch = aarch64
mrvl_os = linux-gnu
mrvl_target = aarch64-linux-gnu
mrvl_mtune = cortex-A57
mrvl_march = "armv8-a+fp+simd+crc+crypto"
mrvl_cross_ldflags = \
	-Wl,--dynamic-linker=/lib/ld-linux-aarch64.so.1 \
	-Wl,-lmusdk \
	-L$(LIBMUSDK_PATH)/lib \
	-Wl,-rpath=/usr/lib64

mrvl_native_tools = vppapigen
#mrvl_root_packages = vpp vlib vlib-api vnet svm vpp-api-test
mrvl_root_packages = vpp

# DPDK configuration parameters
mrvl_uses_dpdk = yes
# Compile with external DPDK only if "DPDK_PATH" variable is defined where we have
# installed DPDK libraries and headers.
ifeq ($(PLATFORM),mrvl)
mrvl_uses_dpdk = yes
mrvl_uses_external_dpdk = yes
mrvl_dpdk_inc_dir = $(DPDK_PATH)/build/include
mrvl_dpdk_lib_dir = $(DPDK_PATH)/build/lib
endif
mrvl_dpdk_target = arm64-armv8a-linuxapp-gcc
#vpp_configure_args_mrvl = --with-dpdk --without-libssl \
	--with-sysroot=$(SYSROOT)
#vnet_configure_args_mrvl = --with-dpdk --without-libssl \
	--with-sysroot=$(SYSROOT)

# Set these parameters carefully. The vlib_buffer_t is 256 bytes, i.e.
#vlib_configure_args_mrvl = --with-pre-data=256


mrvl_debug_TAG_CFLAGS = -g -O2 -DCLIB_DEBUG  -fstack-protector-all \
			-march=$(MARCH) -fPIC -Werror
mrvl_debug_TAG_CXXFLAGS = -g -O2 -DCLIB_DEBUG  -fstack-protector-all \
			-march=$(MARCH) -fPIC -Werror
mrvl_debug_TAG_LDFLAGS = -g -O2 -DCLIB_DEBUG -fPIC -fstack-protector-all \
			-march=$(MARCH) -fPIC -Werror \
			-Wl,-rpath $$PWD/.libs

# Use -rdynamic is for stack tracing, O0 for debugging....default is O2
# Use -DCLIB_LOG2_CACHE_LINE_BYTES to change cache line size
mrvl_TAG_CFLAGS = -g -O2  -march=$(MARCH) -mcpu=$(mrvl_mtune) \
		-mtune=$(mrvl_mtune) -funroll-all-loops -fPIC -Werror
mrvl_TAG_CXXFLAGS = -g -O2  -march=$(MARCH) -mcpu=$(mrvl_mtune) \
		-mtune=$(mrvl_mtune) -funroll-all-loops -fPIC -Werror
mrvl_TAG_LDFLAGS = -g -O2 -march=$(MARCH) -mcpu=$(mrvl_mtune) \
		-mtune=$(mrvl_mtune) -funroll-all-loops -fPIC -Werror \
		-Wl,-rpath=$$PWD/.libs

mrvl_clang_TAG_CFLAGS = -g -O2 -DFORTIFY_SOURCE=2 -fstack-protector -fPIC -Werror
mrvl_clang_TAG_LDFLAGS = -g -O2 -DFORTIFY_SOURCE=2 -fstack-protector -fPIC -Werror

mrvl_gcov_TAG_CFLAGS = -g -O0 -DCLIB_DEBUG -fPIC -Werror -fprofile-arcs -ftest-coverage
mrvl_gcov_TAG_LDFLAGS = -g -O0 -DCLIB_DEBUG -fPIC -Werror -coverage

mrvl_coverity_TAG_CFLAGS = -g -O2 -fPIC -Werror -D__COVERITY__
mrvl_coverity_TAG_LDFLAGS = -g -O2 -fPIC -Werror -D__COVERITY__

