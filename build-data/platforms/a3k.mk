MACHINE = aarch64

a3k_arch = aarch64
a3k_os = linux-gnu
a3k_target = aarch64-linux-gnu
a3k_mtune = cortex-A57
a3k_march = "armv8-a+fp+simd+crc+crypto"
a3k_cross_ldflags = \
	-Wl,--dynamic-linker=/lib/ld-linux-aarch64.so.1 \
	-Wl,-rpath=/usr/lib64

a3k_native_tools = vppapigen
#a3k_root_packages = vpp vlib vlib-api vnet svm vpp-api-test
a3k_root_packages = vpp

# DPDK configuration parameters
a3k_uses_dpdk = yes
# Compile with external DPDK only if "DPDK_PATH" variable is defined where we have
# installed DPDK libraries and headers.
ifeq ($(PLATFORM),a3k)
a3k_uses_dpdk = yes
a3k_uses_external_dpdk = yes
a3k_dpdk_inc_dir = $(DPDK_PATH)/build/include
a3k_dpdk_lib_dir = $(DPDK_PATH)/build/lib
endif
a3k_dpdp_target = arm64-armv8a-linuxapp-gcc
#vpp_configure_args_a3k = --with-dpdk --without-libssl \
	--with-sysroot=$(SYSROOT)
#vnet_configure_args_a3k = --with-dpdk --without-libssl \
	--with-sysroot=$(SYSROOT)

# Set these parameters carefully. The vlib_buffer_t is 256 bytes, i.e.
#vlib_configure_args_a3k = --with-pre-data=256


a3k_debug_TAG_CFLAGS = -g -O2 -DCLIB_DEBUG  -fstack-protector-all \
			-march=$(MARCH) -fPIC -Werror
a3k_debug_TAG_CXXFLAGS = -g -O2 -DCLIB_DEBUG  -fstack-protector-all \
			-march=$(MARCH) -fPIC -Werror
a3k_debug_TAG_LDFLAGS = -g -O2 -DCLIB_DEBUG -fPIC -fstack-protector-all \
			-march=$(MARCH) -fPIC -Werror

# Use -rdynamic is for stack tracing, O0 for debugging....default is O2
# Use -DCLIB_LOG2_CACHE_LINE_BYTES to change cache line size
a3k_TAG_CFLAGS = -g -O2  -march=$(MARCH) -mcpu=$(a3k_mtune) \
		-mtune=$(a3k_mtune) -funroll-all-loops -fPIC -Werror
a3k_TAG_CXXFLAGS = -g -O2  -march=$(MARCH) -mcpu=$(a3k_mtune) \
		-mtune=$(a3k_mtune) -funroll-all-loops -fPIC -Werror
a3k_TAG_LDFLAGS = -g -O2 -march=$(MARCH) -mcpu=$(a3k_mtune) \
		-mtune=$(a3k_mtune) -funroll-all-loops -fPIC -Werror

a3k_clang_TAG_CFLAGS = -g -O2 -DFORTIFY_SOURCE=2 -fstack-protector -fPIC -Werror
a3k_clang_TAG_LDFLAGS = -g -O2 -DFORTIFY_SOURCE=2 -fstack-protector -fPIC -Werror

a3k_gcov_TAG_CFLAGS = -g -O0 -DCLIB_DEBUG -fPIC -Werror -fprofile-arcs -ftest-coverage
a3k_gcov_TAG_LDFLAGS = -g -O0 -DCLIB_DEBUG -fPIC -Werror -coverage

a3k_coverity_TAG_CFLAGS = -g -O2 -fPIC -Werror -D__COVERITY__
a3k_coverity_TAG_LDFLAGS = -g -O2 -fPIC -Werror -D__COVERITY__

