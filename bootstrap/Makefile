# This file is part of HiGFXback

MACHTYPE := $(shell bash -c 'echo $$MACHTYPE')
HOST := x86_64-unknown-linux

STAGING_DIR := $(PWD)/$(HOST)
PATH := $(STAGING_DIR)/bin:$(PATH)

BINUTILS        := binutils-2.25.1
BUSYBOX         := busybox-1.36.1
GCC             := gcc-4.7.4
GLIBC           := glibc-2.19
GMP             := gmp-6.2.1
LINUX           := linux-4.14.336
MPFR            := mpfr-4.1.1
MPC             := mpc-1.3.1
MUSL            := musl-1.2.5
PKG_CONFIG_LITE := pkg-config-lite-0.28-1
SYSLINUX        := syslinux-3.86

LIBC_IMPLEMENTATIONS ?= glibc musl

################################################################################

all:
	@echo "make toolchain"
	@echo "make initrd-'libc'"
	@echo "make rootfs-'libc'"
	@echo "make iso-'libc'"

cross-binutils:
	@echo Build $@
	@test -d $(BINUTILS) || { ( test -f $(BINUTILS).tar.bz2 || wget -q https://ftp.gnu.org/gnu/binutils/$(BINUTILS).tar.bz2 ) && tar xjf $(BINUTILS).tar.bz2; }
	@test -d $(BINUTILS)/cross-build || mkdir $(BINUTILS)/cross-build
	@test -f $(BINUTILS)/cross-build/config.status || ( cd $(BINUTILS)/cross-build; ../configure --build=$(MACHTYPE) --target=$(HOST) --with-sysroot=$(STAGING_DIR) --prefix= )
	$(MAKE) -C $(BINUTILS)/cross-build
	$(MAKE) DESTDIR=$(STAGING_DIR) -C $(BINUTILS)/cross-build install
	@rm -rf $(STAGING_DIR)/$(HOST)/lib
	@rm -rf $(STAGING_DIR)/share/info; rm -rf $(STAGING_DIR)/share/locale; rm -rf $(STAGING_DIR)/share/man
	@echo $(BINUTILS) > $(STAGING_DIR)/share/binutils-VERSION

cross-gcc: cross-binutils
	@echo Build $@
	@test -d $(GCC) || { ( test -f $(GCC).tar.bz2 || wget -q https://ftp.gnu.org/gnu/gcc/$(GCC)/$(GCC).tar.bz2 ) && tar xjf $(GCC).tar.bz2 && patch -d $(GCC) -p1 < $(GCC).patch; }
	@test -d $(GCC)/gmp || { ( test -f $(GMP).tar.bz2 || wget -q https://gmplib.org/download/gmp/$(GMP).tar.bz2 ) && tar xjf $(GMP).tar.bz2 && mv $(GMP) $(GCC)/gmp; }
	@test -d $(GCC)/mpc || { ( test -f $(MPC).tar.gz || wget -q https://ftp.gnu.org/gnu/mpc/$(MPC).tar.gz ) && tar xzf $(MPC).tar.gz && mv $(MPC) $(GCC)/mpc; }
	@test -d $(GCC)/mpfr || { ( test -f $(MPFR).tar.bz2 || wget -q https://mpfr.org/$(MPFR)/$(MPFR).tar.bz2 ) && tar xjf $(MPFR).tar.bz2 && mv $(MPFR) $(GCC)/mpfr; }
	@test -d $(GCC)/cross-build || mkdir $(GCC)/cross-build
	@test -f $(GCC)/cross-build/config.status || ( cd $(GCC)/cross-build; ../configure --build=$(MACHTYPE) --target=$(HOST) --enable-languages=c --with-newlib --disable-decimal-float --disable-lto --disable-plugin --disable-threads --disable-shared --with-sysroot=$(STAGING_DIR) --prefix= --libexecdir=/lib --with-local-prefix=/ )
	$(MAKE) -C $(GCC)/cross-build all-gcc all-target-libgcc
	$(MAKE) DESTDIR=$(STAGING_DIR) -C $(GCC)/cross-build install-gcc install-target-libgcc
	cat $(GCC)/gcc/limitx.h $(GCC)/gcc/glimits.h $(GCC)/gcc/limity.h > $(STAGING_DIR)/lib/gcc/$(HOST)/`echo $(GCC) | cut -d- -f2`/include-fixed/limits.h
	@rm -rf $(STAGING_DIR)/share/info; rm -rf $(STAGING_DIR)/share/locale; rm -rf $(STAGING_DIR)/share/man
	@echo $(GCC) > $(STAGING_DIR)/share/gcc-VERSION

linux-headers:
	@echo Build $@
	@test -d $(LINUX) || { ( test -f $(LINUX).tar.xz || wget -q https://mirrors.edge.kernel.org/pub/linux/kernel/v4.x/$(LINUX).tar.xz ) && tar xJf $(LINUX).tar.xz && patch -d $(LINUX) -p1 < $(LINUX).patch; }
	$(MAKE) INSTALL_HDR_PATH=$(STAGING_DIR) -C $(LINUX) headers_install

glibc: cross-gcc linux-headers
	@echo Build $@
	@test -d $(GLIBC) || { ( test -f $(GLIBC).tar.bz2 || wget -q https://ftp.gnu.org/gnu/glibc/$(GLIBC).tar.bz2 ) && tar xjf $(GLIBC).tar.bz2 && patch -d $(GLIBC) -p1 < $(GLIBC).patch; }
	@test -d $(GLIBC)/build || mkdir $(GLIBC)/build
	@test -f $(GLIBC)/build/config.status || ( cd $(GLIBC)/build; ac_cv_path_BASH_SHELL=no libc_cv_ssp=no ../configure --build=$(MACHTYPE) --host=$(HOST) --enable-obsolete-rpc --prefix= --libexecdir=/lib )
	$(MAKE) -C $(GLIBC)/build
	$(MAKE) install_root=$(STAGING_DIR)/glibc -C $(GLIBC)/build install
	@rm -rf $(STAGING_DIR)/glibc/share/locale
	@echo $(GLIBC) > $(STAGING_DIR)/glibc/share/libc-VERSION

musl: cross-gcc linux-headers
	@echo Build $@
	@test -d $(MUSL) || { ( test -f $(MUSL).tar.gz || wget -q https://musl.libc.org/releases/$(MUSL).tar.gz ) && tar xzf $(MUSL).tar.gz && patch -d $(MUSL) -p1 < $(MUSL).patch; }
	@test -d $(MUSL)/build || mkdir $(MUSL)/build
	@test -f $(MUSL)/build/config.mak || ( cd $(MUSL)/build; ../configure --host=$(HOST) --prefix= )
	$(MAKE) -C $(MUSL)/build
	$(MAKE) DESTDIR=$(STAGING_DIR)/musl -C $(MUSL)/build install
	@test -d $(MUSL)/utils || { ( test -f musl-utils.tar.gz || wget -q https://github.com/boltlinux/musl-utils/archive/master/musl-utils.tar.gz ) && tar xzf musl-utils.tar.gz && mv musl-utils-master $(MUSL)/utils && patch -d $(MUSL)/utils -p1 < musl-utils.patch; }
	@test -d $(MUSL)/build/bin || mkdir $(MUSL)/build/bin
	$(MAKE) -C $(MUSL)/build/bin -f ../../utils/src/makefile
	$(MAKE) DESTDIR=$(STAGING_DIR)/musl -C $(MUSL)/build/bin -f ../../utils/src/makefile install
	@ln -sf ../lib/ld-musl-x86_64.so.1 $(STAGING_DIR)/musl/bin/ldd
	@test -d $(STAGING_DIR)/musl/share || ( mkdir $(STAGING_DIR)/musl/share; echo $(MUSL) > $(STAGING_DIR)/musl/share/libc-VERSION )

toolchain: $(LIBC_IMPLEMENTATIONS)
	@echo Create cross-toolchain

################################################################################

libc-%:
	@test -f $(STAGING_DIR)/share/gcc-VERSION || { echo "'cross-gcc' build required"; exit 1; }
	@test -f $(STAGING_DIR)/$*/share/libc-VERSION || { echo "'$*' build required"; exit 1; }
	@if ! [ $(STAGING_DIR)/share/libc-VERSION -ef $(STAGING_DIR)/$*/share/libc-VERSION ]; then \
	  for i in $(LIBC_IMPLEMENTATIONS); do \
	    stow -D -d $(STAGING_DIR)/$$i . -t $(STAGING_DIR) 2>/dev/null; \
	  done; \
	  stow -S -d $(STAGING_DIR)/$* . -t $(STAGING_DIR); \
	fi

linux:
	@test -f $(STAGING_DIR)/share/gcc-VERSION || { echo "'cross-gcc' build required"; exit 1; }
	@echo Build $@
	@test -d $(LINUX) || { ( test -f $(LINUX).tar.xz || wget -q https://mirrors.edge.kernel.org/pub/linux/kernel/v4.x/$(LINUX).tar.xz ) && tar xJf $(LINUX).tar.xz && patch -d $(LINUX) -p1 < $(LINUX).patch; }
	@test -f $(LINUX)/.config || ( cp $(LINUX)-fragment-x86_64.config $(LINUX)/arch/x86/configs/fragment-x86_64.config; $(MAKE) -C $(LINUX) x86_64_defconfig fragment-x86_64.config )
	$(MAKE) CROSS_COMPILE=$(HOST)- -C $(LINUX)

busybox-%: libc-%
	@echo Build $@
	@test -d $(BUSYBOX) || { ( test -f $(BUSYBOX).tar.bz2 || wget -q https://busybox.net/downloads/$(BUSYBOX).tar.bz2 ) && tar xjf $(BUSYBOX).tar.bz2 && patch -d $(BUSYBOX) -p1 < $(BUSYBOX).patch; }
	@test -d $(BUSYBOX)/$*-build || mkdir $(BUSYBOX)/$*-build
	@test -f $(BUSYBOX)/$*-build/.config || cp $(BUSYBOX).config $(BUSYBOX)/$*-build/.config
	$(MAKE) CROSS_COMPILE=$(HOST)- O=$*-build -C $(BUSYBOX)
	$(MAKE) O=$*-build -C $(BUSYBOX) busybox.links

binutils-%: libc-%
	@echo Build $@
	@test -d $(BINUTILS) || { ( test -f $(BINUTILS).tar.bz2 || wget -q https://ftp.gnu.org/gnu/binutils/$(BINUTILS).tar.bz2 ) && tar xjf $(BINUTILS).tar.bz2; }
	@test -d $(BINUTILS)/$*-build || mkdir $(BINUTILS)/$*-build
	@test -f $(BINUTILS)/$*-build/config.status || ( cd $(BINUTILS)/$*-build; ../configure --build=$(MACHTYPE) --host=$(HOST) --prefix= )
	$(MAKE) -C $(BINUTILS)/$*-build

gcc-%: libc-%
	@echo Build $@
	@test -d $(GCC) || { ( test -f $(GCC).tar.bz2 || wget -q https://ftp.gnu.org/gnu/gcc/$(GCC)/$(GCC).tar.bz2 ) && tar xjf $(GCC).tar.bz2 && patch -d $(GCC) -p1 < $(GCC).patch; }
	@test -d $(GCC)/gmp || { ( test -f $(GMP).tar.bz2 || wget -q https://gmplib.org/download/gmp/$(GMP).tar.bz2 ) && tar xjf $(GMP).tar.bz2 && mv $(GMP) $(GCC)/gmp; }
	@test -d $(GCC)/mpc || { ( test -f $(MPC).tar.gz || wget -q https://ftp.gnu.org/gnu/mpc/$(MPC).tar.gz ) && tar xzf $(MPC).tar.gz && mv $(MPC) $(GCC)/mpc; }
	@test -d $(GCC)/mpfr || { ( test -f $(MPFR).tar.bz2 || wget -q https://mpfr.org/$(MPFR)/$(MPFR).tar.bz2 ) && tar xjf $(MPFR).tar.bz2 && mv $(MPFR) $(GCC)/mpfr; }
	@test -d $(GCC)/$*-build || mkdir $(GCC)/$*-build
	@test -f $(GCC)/$*-build/config.status || ( cd $(GCC)/$*-build; sed -i "s/DEFAULT_LIBC=LIBC_GLIBC/DEFAULT_LIBC=LIBC_$(shell echo $* | tr a-z A-Z)/" ../gcc/config.gcc; ../configure --build=$(MACHTYPE) --host=$(HOST) --target=$(HOST) --disable-libgomp --disable-libmudflap --disable-libquadmath --disable-libssp --disable-lto --disable-multilib --disable-plugin --enable-languages=c --with-native-system-header-dir=/include --libexecdir=/lib --prefix= )
	$(MAKE) -C $(GCC)/$*-build

pkg-config-lite-%: libc-%
	@echo Build $@
	@test -d $(PKG_CONFIG_LITE) || { ( test -f $(PKG_CONFIG_LITE).tar.gz || wget -q https://sourceforge.net/projects/pkgconfiglite/files/0.28-1/$(PKG_CONFIG_LITE).tar.gz ) && tar xzf $(PKG_CONFIG_LITE).tar.gz && patch -d $(PKG_CONFIG_LITE) -p1 < $(PKG_CONFIG_LITE).patch; }
	@test -d $(PKG_CONFIG_LITE)/$*-build || mkdir $(PKG_CONFIG_LITE)/$*-build
	@test -f $(PKG_CONFIG_LITE)/$*-build/config.status || ( cd $(PKG_CONFIG_LITE)/$*-build; ../configure --host=$(HOST) --prefix= )
	$(MAKE) -C $(PKG_CONFIG_LITE)/$*-build

syslinux-%: libc-%
	@echo Build $@
	@test -d $(SYSLINUX) || { ( test -f $(SYSLINUX).tar.xz || wget -q https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/3.xx/$(SYSLINUX).tar.xz ) && tar xJf $(SYSLINUX).tar.xz && patch -d $(SYSLINUX) -p1 < $(SYSLINUX).patch; }
	@test -d $(SYSLINUX)/$*-build || mkdir $(SYSLINUX)/$*-build
	$(MAKE) -C $(SYSLINUX)/libinstaller
	$(MAKE) CC=$(HOST)-gcc -C $(SYSLINUX)/$*-build -f ../extlinux/Makefile

################################################################################

rootfs-%: linux busybox-% binutils-% gcc-% pkg-config-lite-% syslinux-%
	@echo Create $*-based rootfs tarball
	@install -d                                                                                  rootfs-$*/bin
	@install $(BUSYBOX)/$*-build/busybox                                                         rootfs-$*/bin/busybox
	@for l in `sort $(BUSYBOX)/$*-build/busybox.links`; do ln -sf busybox                        rootfs-$*$$l; done
	@echo 'loadkmap < /share/busybox/$$1.kmap'                                                >  rootfs-$*/bin/loadkeys
	@chmod 755                                                                                   rootfs-$*/bin/loadkeys
	@echo mdev -d                                                                             >  rootfs-$*/bin/mdevd
	@chmod 755                                                                                   rootfs-$*/bin/mdevd
	@install $(BINUTILS)/$*-build/binutils/addr2line                                             rootfs-$*/bin/addr2line
	@install $(BINUTILS)/$*-build/binutils/ar                                                    rootfs-$*/bin/ar
	@install $(BINUTILS)/$*-build/binutils/cxxfilt                                               rootfs-$*/bin/c++filt
	@install $(BINUTILS)/$*-build/binutils/elfedit                                               rootfs-$*/bin/elfedit
	@install $(BINUTILS)/$*-build/binutils/nm-new                                                rootfs-$*/bin/nm
	@install $(BINUTILS)/$*-build/binutils/objcopy                                               rootfs-$*/bin/objcopy
	@install $(BINUTILS)/$*-build/binutils/objdump                                               rootfs-$*/bin/objdump
	@install $(BINUTILS)/$*-build/binutils/ranlib                                                rootfs-$*/bin/ranlib
	@install $(BINUTILS)/$*-build/binutils/readelf                                               rootfs-$*/bin/readelf
	@install $(BINUTILS)/$*-build/binutils/size                                                  rootfs-$*/bin/size
	@install $(BINUTILS)/$*-build/binutils/strings                                               rootfs-$*/bin/strings
	@install $(BINUTILS)/$*-build/binutils/strip-new                                             rootfs-$*/bin/strip
	@install $(BINUTILS)/$*-build/gas/as-new                                                     rootfs-$*/bin/as
	@install $(BINUTILS)/$*-build/ld/ld-new                                                      rootfs-$*/bin/ld
	@install $(GCC)/$*-build/gcc/cpp                                                             rootfs-$*/bin/cpp
	@install $(GCC)/$*-build/gcc/xgcc                                                            rootfs-$*/bin/gcc
	@ln -sf  gcc                                                                                 rootfs-$*/bin/cc
	@install $(PKG_CONFIG_LITE)/$*-build/pkg-config                                              rootfs-$*/bin/pkg-config
	@install $(STAGING_DIR)/$*/bin/getconf                                                       rootfs-$*/bin/getconf
	@cp -P $(STAGING_DIR)/$*/bin/ldd                                                             rootfs-$*/bin/ldd
	@install $(SYSLINUX)/$*-build/extlinux                                                       rootfs-$*/bin/extlinux
	@install pkg-build                                                                           rootfs-$*/bin/pkg-build
	@install pkg-get                                                                             rootfs-$*/bin/pkg-get
	@install -d                                                                                  rootfs-$*/boot
	@install $(LINUX)/arch/x86/boot/bzImage                                                      rootfs-$*/boot/bzImage
	@install -d                                                                                  rootfs-$*/dev
	@install -d                                                                                  rootfs-$*/etc
	@echo proc /proc proc defaults 0 0                                                        >  rootfs-$*/etc/fstab
	@echo sysfs /sys sysfs defaults 0 0                                                       >> rootfs-$*/etc/fstab
	@echo tmpfs /run tmpfs defaults 0 0                                                       >> rootfs-$*/etc/fstab
	@echo tmpfs /tmp tmpfs defaults 0 0                                                       >> rootfs-$*/etc/fstab
	@echo root::0:root                                                                        >  rootfs-$*/etc/group
	@echo root::0:0:root:/root:/bin/sh                                                        >  rootfs-$*/etc/passwd
	@echo null:2345:sysinit:/etc/init.d/rcS                                                   >  rootfs-$*/etc/inittab
	@echo tty1:2345:respawn:getty tty1 9600                                                   >> rootfs-$*/etc/inittab
	@echo tty2:2345:respawn:getty tty2 9600                                                   >> rootfs-$*/etc/inittab
	@echo tty3:2345:respawn:getty tty3 9600                                                   >> rootfs-$*/etc/inittab
	@echo tty4:2345:respawn:getty tty4 9600                                                   >> rootfs-$*/etc/inittab
	@echo tty5:2345:respawn:getty tty5 9600                                                   >> rootfs-$*/etc/inittab
	@echo tty6:2345:respawn:getty tty6 9600                                                   >> rootfs-$*/etc/inittab
	@install -d                                                                                  rootfs-$*/etc/init.d
	@echo '#!/bin/sh'                                                                         >  rootfs-$*/etc/init.d/rcS
	@echo mount -a                                                                            >> rootfs-$*/etc/init.d/rcS
	@echo mkdir /dev/pts                                                                      >> rootfs-$*/etc/init.d/rcS
	@echo mount -t devpts none /dev/pts                                                       >> rootfs-$*/etc/init.d/rcS
	@echo mdevd                                                                               >> rootfs-$*/etc/init.d/rcS
	@echo mdev -s                                                                             >> rootfs-$*/etc/init.d/rcS
	@echo ln -sf /proc/self/fd /dev/fd                                                        >> rootfs-$*/etc/init.d/rcS
	@echo ln -sf /proc/self/fd/0 /dev/stdin                                                   >> rootfs-$*/etc/init.d/rcS
	@echo ln -sf /proc/self/fd/1 /dev/stdout                                                  >> rootfs-$*/etc/init.d/rcS
	@echo ln -sf /proc/self/fd/2 /dev/stderr                                                  >> rootfs-$*/etc/init.d/rcS
	@echo loadkeys fr                                                                         >> rootfs-$*/etc/init.d/rcS
	@chmod 755                                                                                   rootfs-$*/etc/init.d/rcS
	@install -d                                                                                  rootfs-$*/include
	@install 2>/dev/null -m 644 $(STAGING_DIR)/$*/include/_G_config.h                            rootfs-$*/include/_G_config.h        || true # glibc
	@install -m 644 $(STAGING_DIR)/$*/include/aio.h                                              rootfs-$*/include/aio.h
	@install -m 644 $(STAGING_DIR)/$*/include/alloca.h                                           rootfs-$*/include/alloca.h
	@install -m 644 $(STAGING_DIR)/$*/include/ar.h                                               rootfs-$*/include/ar.h
	@install 2>/dev/null -m 644 $(STAGING_DIR)/$*/include/argp.h                                 rootfs-$*/include/argp.h             || true # glibc
	@install 2>/dev/null -m 644 $(STAGING_DIR)/$*/include/argz.h                                 rootfs-$*/include/argz.h             || true # glibc
	@install -m 644 $(STAGING_DIR)/$*/include/assert.h                                           rootfs-$*/include/assert.h
	@install -m 644 $(STAGING_DIR)/$*/include/byteswap.h                                         rootfs-$*/include/byteswap.h
	@install -m 644 $(STAGING_DIR)/$*/include/complex.h                                          rootfs-$*/include/complex.h
	@install -m 644 $(STAGING_DIR)/$*/include/cpio.h                                             rootfs-$*/include/cpio.h
	@install -m 644 $(STAGING_DIR)/$*/include/crypt.h                                            rootfs-$*/include/crypt.h
	@install -m 644 $(STAGING_DIR)/$*/include/ctype.h                                            rootfs-$*/include/ctype.h
	@install -m 644 $(STAGING_DIR)/$*/include/dirent.h                                           rootfs-$*/include/dirent.h
	@install -m 644 $(STAGING_DIR)/$*/include/dlfcn.h                                            rootfs-$*/include/dlfcn.h
	@install -m 644 $(STAGING_DIR)/$*/include/elf.h                                              rootfs-$*/include/elf.h
	@install -m 644 $(STAGING_DIR)/$*/include/endian.h                                           rootfs-$*/include/endian.h
	@install -m 644 $(STAGING_DIR)/$*/include/err.h                                              rootfs-$*/include/err.h
	@install -m 644 $(STAGING_DIR)/$*/include/errno.h                                            rootfs-$*/include/errno.h
	@install 2>/dev/null -m 644 $(STAGING_DIR)/$*/include/error.h                                rootfs-$*/include/error.h            || true # glibc
	@install 2>/dev/null -m 644 $(STAGING_DIR)/$*/include/execinfo.h                             rootfs-$*/include/execinfo.h         || true # glibc
	@install -m 644 $(STAGING_DIR)/$*/include/fcntl.h                                            rootfs-$*/include/fcntl.h
	@install -m 644 $(STAGING_DIR)/$*/include/features.h                                         rootfs-$*/include/features.h
	@install -m 644 $(STAGING_DIR)/$*/include/fenv.h                                             rootfs-$*/include/fenv.h
	@install -m 644 $(STAGING_DIR)/$*/include/fmtmsg.h                                           rootfs-$*/include/fmtmsg.h
	@install -m 644 $(STAGING_DIR)/$*/include/fnmatch.h                                          rootfs-$*/include/fnmatch.h
	@install 2>/dev/null -m 644 $(STAGING_DIR)/$*/include/fts.h                                  rootfs-$*/include/fts.h              || true # glibc
	@install -m 644 $(STAGING_DIR)/$*/include/ftw.h                                              rootfs-$*/include/ftw.h
	@install 2>/dev/null -m 644 $(STAGING_DIR)/$*/include/gconv.h                                rootfs-$*/include/gconv.h            || true # glibc
	@install -m 644 $(STAGING_DIR)/$*/include/getopt.h                                           rootfs-$*/include/getopt.h
	@install -m 644 $(STAGING_DIR)/$*/include/glob.h                                             rootfs-$*/include/glob.h
	@install 2>/dev/null -m 644 $(STAGING_DIR)/$*/include/gnu-versions.h                         rootfs-$*/include/gnu-versions.h     || true # glibc
	@install -m 644 $(STAGING_DIR)/$*/include/grp.h                                              rootfs-$*/include/grp.h
	@install -m 644 $(STAGING_DIR)/$*/include/iconv.h                                            rootfs-$*/include/iconv.h
	@install -m 644 $(STAGING_DIR)/$*/include/ifaddrs.h                                          rootfs-$*/include/ifaddrs.h
	@install -m 644 $(STAGING_DIR)/$*/include/inttypes.h                                         rootfs-$*/include/inttypes.h
	@install -m 644 $(STAGING_DIR)/$*/include/langinfo.h                                         rootfs-$*/include/langinfo.h
	@install -m 644 $(STAGING_DIR)/$*/include/lastlog.h                                          rootfs-$*/include/lastlog.h
	@install -m 644 $(STAGING_DIR)/$*/include/libgen.h                                           rootfs-$*/include/libgen.h
	@install -m 644 $(STAGING_DIR)/$*/include/libintl.h                                          rootfs-$*/include/libintl.h
	@install 2>/dev/null -m 644 $(STAGING_DIR)/$*/include/libio.h                                rootfs-$*/include/libio.h            || true # glibc
	@install -m 644 $(STAGING_DIR)/$*/include/limits.h                                           rootfs-$*/include/limits.h
	@install -m 644 $(STAGING_DIR)/$*/include/link.h                                             rootfs-$*/include/link.h
	@install -m 644 $(STAGING_DIR)/$*/include/locale.h                                           rootfs-$*/include/locale.h
	@install -m 644 $(STAGING_DIR)/$*/include/malloc.h                                           rootfs-$*/include/malloc.h
	@install -m 644 $(STAGING_DIR)/$*/include/math.h                                             rootfs-$*/include/math.h
	@install -m 644 $(STAGING_DIR)/$*/include/memory.h                                           rootfs-$*/include/memory.h
	@install -m 644 $(STAGING_DIR)/$*/include/mntent.h                                           rootfs-$*/include/mntent.h
	@install -m 644 $(STAGING_DIR)/$*/include/monetary.h                                         rootfs-$*/include/monetary.h
	@install -m 644 $(STAGING_DIR)/$*/include/mqueue.h                                           rootfs-$*/include/mqueue.h
	@install -m 644 $(STAGING_DIR)/$*/include/netdb.h                                            rootfs-$*/include/netdb.h
	@install -m 644 $(STAGING_DIR)/$*/include/nl_types.h                                         rootfs-$*/include/nl_types.h
	@install 2>/dev/null -m 644 $(STAGING_DIR)/$*/include/obstack.h                              rootfs-$*/include/obstack.h          || true # glibc
	@install -m 644 $(STAGING_DIR)/$*/include/paths.h                                            rootfs-$*/include/paths.h
	@install -m 644 $(STAGING_DIR)/$*/include/poll.h                                             rootfs-$*/include/poll.h
	@install -m 644 $(STAGING_DIR)/$*/include/pthread.h                                          rootfs-$*/include/pthread.h
	@install -m 644 $(STAGING_DIR)/$*/include/pty.h                                              rootfs-$*/include/pty.h
	@install -m 644 $(STAGING_DIR)/$*/include/pwd.h                                              rootfs-$*/include/pwd.h
	@install -m 644 $(STAGING_DIR)/$*/include/regex.h                                            rootfs-$*/include/regex.h
	@install -m 644 $(STAGING_DIR)/$*/include/resolv.h                                           rootfs-$*/include/resolv.h
	@install -m 644 $(STAGING_DIR)/$*/include/sched.h                                            rootfs-$*/include/sched.h
	@install -m 644 $(STAGING_DIR)/$*/include/search.h                                           rootfs-$*/include/search.h
	@install -m 644 $(STAGING_DIR)/$*/include/semaphore.h                                        rootfs-$*/include/semaphore.h
	@install -m 644 $(STAGING_DIR)/$*/include/setjmp.h                                           rootfs-$*/include/setjmp.h
	@install -m 644 $(STAGING_DIR)/$*/include/shadow.h                                           rootfs-$*/include/shadow.h
	@install -m 644 $(STAGING_DIR)/$*/include/signal.h                                           rootfs-$*/include/signal.h
	@install -m 644 $(STAGING_DIR)/$*/include/spawn.h                                            rootfs-$*/include/spawn.h
	@install -m 644 $(STAGING_DIR)/$*/include/stdc-predef.h                                      rootfs-$*/include/stdc-predef.h
	@install -m 644 $(STAGING_DIR)/$*/include/stdint.h                                           rootfs-$*/include/stdint.h
	@install -m 644 $(STAGING_DIR)/$*/include/stdio.h                                            rootfs-$*/include/stdio.h
	@install -m 644 $(STAGING_DIR)/$*/include/stdio_ext.h                                        rootfs-$*/include/stdio_ext.h
	@install -m 644 $(STAGING_DIR)/$*/include/stdlib.h                                           rootfs-$*/include/stdlib.h
	@install -m 644 $(STAGING_DIR)/$*/include/string.h                                           rootfs-$*/include/string.h
	@install -m 644 $(STAGING_DIR)/$*/include/strings.h                                          rootfs-$*/include/strings.h
	@install -m 644 $(STAGING_DIR)/$*/include/stropts.h                                          rootfs-$*/include/stropts.h
	@install -m 644 $(STAGING_DIR)/$*/include/syscall.h                                          rootfs-$*/include/syscall.h
	@install -m 644 $(STAGING_DIR)/$*/include/sysexits.h                                         rootfs-$*/include/sysexits.h
	@install -m 644 $(STAGING_DIR)/$*/include/syslog.h                                           rootfs-$*/include/syslog.h
	@install -m 644 $(STAGING_DIR)/$*/include/tar.h                                              rootfs-$*/include/tar.h
	@install -m 644 $(STAGING_DIR)/$*/include/termios.h                                          rootfs-$*/include/termios.h
	@install -m 644 $(STAGING_DIR)/$*/include/tgmath.h                                           rootfs-$*/include/tgmath.h
	@install -m 644 $(STAGING_DIR)/$*/include/time.h                                             rootfs-$*/include/time.h
	@install 2>/dev/null -m 644 $(STAGING_DIR)/$*/include/ttyent.h                               rootfs-$*/include/ttyent.h           || true # glibc
	@install -m 644 $(STAGING_DIR)/$*/include/uchar.h                                            rootfs-$*/include/uchar.h
	@install -m 644 $(STAGING_DIR)/$*/include/ucontext.h                                         rootfs-$*/include/ucontext.h
	@install -m 644 $(STAGING_DIR)/$*/include/ulimit.h                                           rootfs-$*/include/ulimit.h
	@install -m 644 $(STAGING_DIR)/$*/include/unistd.h                                           rootfs-$*/include/unistd.h
	@install -m 644 $(STAGING_DIR)/$*/include/utime.h                                            rootfs-$*/include/utime.h
	@install -m 644 $(STAGING_DIR)/$*/include/utmp.h                                             rootfs-$*/include/utmp.h
	@install -m 644 $(STAGING_DIR)/$*/include/utmpx.h                                            rootfs-$*/include/utmpx.h
	@install -m 644 $(STAGING_DIR)/$*/include/values.h                                           rootfs-$*/include/values.h
	@install -m 644 $(STAGING_DIR)/$*/include/wait.h                                             rootfs-$*/include/wait.h
	@install -m 644 $(STAGING_DIR)/$*/include/wchar.h                                            rootfs-$*/include/wchar.h
	@install -m 644 $(STAGING_DIR)/$*/include/wctype.h                                           rootfs-$*/include/wctype.h
	@install -m 644 $(STAGING_DIR)/$*/include/wordexp.h                                          rootfs-$*/include/wordexp.h
	@install 2>/dev/null -m 644 $(STAGING_DIR)/$*/include/xlocale.h                              rootfs-$*/include/xlocale.h          || true # glibc
	@install -d rootfs-$*/include/arpa;        cp $(STAGING_DIR)/$*/include/arpa/*               rootfs-$*/include/arpa
	@install -d rootfs-$*/include/asm;         cp $(STAGING_DIR)/include/asm/*                   rootfs-$*/include/asm
	@install -d rootfs-$*/include/asm-generic; cp $(STAGING_DIR)/include/asm-generic/*           rootfs-$*/include/asm-generic
	@install -d rootfs-$*/include/bits;        cp $(STAGING_DIR)/$*/include/bits/*               rootfs-$*/include/bits
	@install -d rootfs-$*/include/gnu;         cp 2>/dev/null $(STAGING_DIR)/$*/include/gnu/*    rootfs-$*/include/gnu                || true # glibc
	@install -d rootfs-$*/include/linux;       cp -r $(STAGING_DIR)/include/linux/*              rootfs-$*/include/linux
	@install -d rootfs-$*/include/mtd;         cp $(STAGING_DIR)/include/mtd/*                   rootfs-$*/include/mtd
	@install -d rootfs-$*/include/net;         cp $(STAGING_DIR)/$*/include/net/*                rootfs-$*/include/net
	@install -d rootfs-$*/include/netinet;     cp $(STAGING_DIR)/$*/include/netinet/*            rootfs-$*/include/netinet
	@install -d rootfs-$*/include/netpacket;   cp $(STAGING_DIR)/$*/include/netpacket/*          rootfs-$*/include/netpacket
	@install -d rootfs-$*/include/rpc;         cp 2>/dev/null $(STAGING_DIR)/$*/include/rpc/*    rootfs-$*/include/rpc                || true # glibc
	@install -d rootfs-$*/include/scsi;        cp $(STAGING_DIR)/$*/include/scsi/*               rootfs-$*/include/scsi
	@install -d rootfs-$*/include/sys;         cp $(STAGING_DIR)/$*/include/sys/*                rootfs-$*/include/sys
	@install -d                                                                                  rootfs-$*/lib
	@ln -sf ../bin/cpp                                                                           rootfs-$*/lib/cpp
	@install -m 644 $(STAGING_DIR)/$*/lib/crt1.o                                                 rootfs-$*/lib/crt1.o
	@install -m 644 $(STAGING_DIR)/$*/lib/crti.o                                                 rootfs-$*/lib/crti.o
	@install -m 644 $(STAGING_DIR)/$*/lib/crtn.o                                                 rootfs-$*/lib/crtn.o
	@set -- $(STAGING_DIR)/$*/lib/ld-*.so*; cp -P $$1                                            rootfs-$*/lib/ld-linux-x86-64.so.2
	@set -- $(STAGING_DIR)/$*/lib/ld-*.so*; [ -L $(STAGING_DIR)/$*/lib/ld-linux-x86-64.so.2 ] || ln -sf ld-linux-x86-64.so.2 rootfs-$*/lib/$${1##*/}
	@cp -P $(STAGING_DIR)/$*/lib/libc.so                                                         rootfs-$*/lib/libc.so
	@install $(STAGING_DIR)/$*/lib/libc.so.6                                                     rootfs-$*/lib/libc.so.6
	@install 2>/dev/null -m 644 $(STAGING_DIR)/$*/lib/libc_nonshared.a                           rootfs-$*/lib/libc_nonshared.a       || true # glibc
	@install 2>/dev/null $(STAGING_DIR)/$*/lib/libcrypt.so.1                                     rootfs-$*/lib/libcrypt.so.1          || true # glibc
	@cp -P $(STAGING_DIR)/$*/lib/libcrypt.so                                                     rootfs-$*/lib/libcrypt.so
	@install 2>/dev/null $(STAGING_DIR)/$*/lib/libdl.so.2                                        rootfs-$*/lib/libdl.so.2             || true # glibc
	@cp -P $(STAGING_DIR)/$*/lib/libdl.so                                                        rootfs-$*/lib/libdl.so
	@install 2>/dev/null $(STAGING_DIR)/$*/lib/libm.so.6                                         rootfs-$*/lib/libm.so.6              || true # glibc
	@cp -P $(STAGING_DIR)/$*/lib/libm.so                                                         rootfs-$*/lib/libm.so
	@install 2>/dev/null $(STAGING_DIR)/$*/lib/libnsl.so.1                                       rootfs-$*/lib/libnsl.so.1            || true # glibc
	@cp 2>/dev/null -P $(STAGING_DIR)/$*/lib/libnsl.so                                           rootfs-$*/lib/libnsl.so              || true # glibc
	@install 2>/dev/null $(STAGING_DIR)/$*/lib/libnss_dns.so.2                                   rootfs-$*/lib/libnss_dns.so.2        || true # glibc
	@cp 2>/dev/null -P $(STAGING_DIR)/$*/lib/libnss_dns.so                                       rootfs-$*/lib/libnss_dns.so          || true # glibc
	@install 2>/dev/null $(STAGING_DIR)/$*/lib/libnss_files.so.2                                 rootfs-$*/lib/libnss_files.so.2      || true # glibc
	@cp 2>/dev/null -P $(STAGING_DIR)/$*/lib/libnss_files.so                                     rootfs-$*/lib/libnss_files.so        || true # glibc
	@install 2>/dev/null $(STAGING_DIR)/$*/lib/libpthread.so.0                                   rootfs-$*/lib/libpthread.so.0        || true # glibc
	@cp -P $(STAGING_DIR)/$*/lib/libpthread.so                                                   rootfs-$*/lib/libpthread.so
	@install 2>/dev/null -m 644 $(STAGING_DIR)/lib/libpthread_nonshared.a                        rootfs-$*/lib/libpthread_nonshared.a || true # glibc
	@install 2>/dev/null $(STAGING_DIR)/$*/lib/libresolv.so.2                                    rootfs-$*/lib/libresolv.so.2         || true # glibc
	@cp -P $(STAGING_DIR)/$*/lib/libresolv.so                                                    rootfs-$*/lib/libresolv.so
	@install 2>/dev/null $(STAGING_DIR)/$*/lib/librt.so.1                                        rootfs-$*/lib/librt.so.1             || true # glibc
	@cp -P $(STAGING_DIR)/$*/lib/librt.so                                                        rootfs-$*/lib/librt.so
	@install 2>/dev/null $(STAGING_DIR)/$*/lib/libutil.so.1                                      rootfs-$*/lib/libutil.so.1           || true # glibc
	@cp -P $(STAGING_DIR)/$*/lib/libutil.so                                                      rootfs-$*/lib/libutil.so
	@install -m 644 $(STAGING_DIR)/$*/lib/Scrt1.o                                                rootfs-$*/lib/Scrt1.o
	@install $(GCC)/$*-build/gcc/libgcc_s.so.1                                                   rootfs-$*/lib/libgcc_s.so.1
	@ln -sf libgcc_s.so.1                                                                        rootfs-$*/lib/libgcc_s.so
	@install -d                                                                                  rootfs-$*/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`
	@install $(GCC)/$*-build/gcc/cc1                                                             rootfs-$*/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/cc1
	@install -m 644 $(GCC)/$*-build/gcc/crtbegin.o                                               rootfs-$*/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/crtbegin.o
	@install -m 644 $(GCC)/$*-build/gcc/crtbeginS.o                                              rootfs-$*/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/crtbeginS.o
	@install -m 644 $(GCC)/$*-build/gcc/crtend.o                                                 rootfs-$*/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/crtend.o
	@install -m 644 $(GCC)/$*-build/gcc/crtendS.o                                                rootfs-$*/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/crtendS.o
	@install -m 644 $(GCC)/$*-build/gcc/crtfastmath.o                                            rootfs-$*/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/crtfastmath.o
	@install -m 644 $(GCC)/$*-build/gcc/libgcc.a                                                 rootfs-$*/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/libgcc.a
	@install -d                                                                                  rootfs-$*/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include
	@install -m 644 $(GCC)/$*-build/gcc/include/emmintrin.h                                      rootfs-$*/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include/emmintrin.h
	@install -m 644 $(GCC)/$*-build/gcc/include/float.h                                          rootfs-$*/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include/float.h
	@install -m 644 $(GCC)/$*-build/gcc/include/immintrin.h                                      rootfs-$*/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include/immintrin.h
	@install -m 644 $(GCC)/$*-build/gcc/include/mm_malloc.h                                      rootfs-$*/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include/mm_malloc.h
	@install -m 644 $(GCC)/$*-build/gcc/include/mmintrin.h                                       rootfs-$*/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include/mmintrin.h
	@install -m 644 $(GCC)/$*-build/gcc/include/stdarg.h                                         rootfs-$*/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include/stdarg.h
	@install -m 644 $(GCC)/$*-build/gcc/include/stdbool.h                                        rootfs-$*/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include/stdbool.h
	@install -m 644 $(GCC)/$*-build/gcc/include/stddef.h                                         rootfs-$*/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include/stddef.h
	@install -m 644 $(GCC)/$*-build/gcc/include/xmmintrin.h                                      rootfs-$*/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include/xmmintrin.h
	@install -d                                                                                  rootfs-$*/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include-fixed
	@install -m 644 $(GCC)/$*-build/gcc/include-fixed/limits.h                                   rootfs-$*/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include-fixed/limits.h
	@install -d                                                                                  rootfs-$*/mnt/cdrom
	@install -d                                                                                  rootfs-$*/mnt/disk
	@install -d                                                                                  rootfs-$*/mnt/share
	@install -d                                                                                  rootfs-$*/proc
	@install -d                                                                                  rootfs-$*/root
	@install -d                                                                                  rootfs-$*/run
	@install -d                                                                                  rootfs-$*/share/aclocal
	@install -m 644 $(PKG_CONFIG_LITE)/pkg.m4                                                    rootfs-$*/share/aclocal/pkg.m4
	@install -d                                                                                  rootfs-$*/share/busybox
	@install $(BUSYBOX)/$*-build/busybox.links                                                   rootfs-$*/share/busybox/busybox.links
	@echo '#!/bin/sh'                                                                         >  rootfs-$*/share/busybox/default.script
	@echo 'case $$1 in'                                                                       >> rootfs-$*/share/busybox/default.script
	@echo '  deconfig)'                                                                       >> rootfs-$*/share/busybox/default.script
	@echo '    ifconfig $$interface 0.0.0.0 ;;'                                               >> rootfs-$*/share/busybox/default.script
	@echo '  renew|bound)'                                                                    >> rootfs-$*/share/busybox/default.script
	@echo '    ifconfig $$interface $$ip netmask $$subnet'                                    >> rootfs-$*/share/busybox/default.script
	@echo '    route add default gw $$router'                                                 >> rootfs-$*/share/busybox/default.script
	@echo '    > /etc/resolv.conf'                                                            >> rootfs-$*/share/busybox/default.script
	@echo '    for i in $$dns; do echo nameserver $$i >> /etc/resolv.conf; done ;;'           >> rootfs-$*/share/busybox/default.script
	@echo 'esac'                                                                              >> rootfs-$*/share/busybox/default.script
	@chmod 755                                                                                   rootfs-$*/share/busybox/default.script
	@install keymaps/fr.kmap                                                                     rootfs-$*/share/busybox/fr.kmap
	@install -d                                                                                  rootfs-$*/share/syslinux
	@install -m 644 $(SYSLINUX)/core/isolinux.bin                                                rootfs-$*/share/syslinux/isolinux.bin
	@install -m 644 $(SYSLINUX)/mbr/mbr.bin                                                      rootfs-$*/share/syslinux/mbr.bin
	@install -d                                                                                  rootfs-$*/sys
	@install -d                                                                                  rootfs-$*/tmp
	@install -d                                                                                  rootfs-$*/var
	@rm -f rootfs-$*/var/run; ln -s /run                                                         rootfs-$*/var/run
	@find rootfs-$* -type f -exec file {} + | awk -F: '/ELF/ && !/crt/ { print $$1 }' | xargs $(HOST)-strip
	@tar -C rootfs-$* -czf rootfs-$*.tgz .

################################################################################

initrd_deps:
	@command -v genext2fs >/dev/null || { echo "'genext2fs' command not found"; exit 1; }

initrd-%: initrd_deps busybox-% syslinux-%
	@echo Create $*-based initrd
	@install -d                                                              initrd-$*/bin
	@install $(BUSYBOX)/$*-build/busybox                                     initrd-$*/bin/busybox
	@for l in `sort $(BUSYBOX)/$*-build/busybox.links`; do ln -sf busybox    initrd-$*$$l; done
	@echo 'loadkmap < /share/busybox/$$1.kmap'                            >  initrd-$*/bin/loadkeys
	@chmod 755                                                               initrd-$*/bin/loadkeys
	@install $(SYSLINUX)/$*-build/extlinux                                   initrd-$*/bin/extlinux
	@install setup                                                           initrd-$*/bin/setup
	@install -d                                                              initrd-$*/dev
	@install -d                                                              initrd-$*/etc
	@echo root::0:0:root:/root:/bin/sh                                    >  initrd-$*/etc/passwd
	@echo null:2345:sysinit:/etc/init.d/rcS                               >  initrd-$*/etc/inittab
	@echo tty1:2345:respawn:getty tty1 9600                               >> initrd-$*/etc/inittab
	@install -d                                                              initrd-$*/etc/init.d
	@echo '#!/bin/sh'                                                     >  initrd-$*/etc/init.d/rcS
	@echo mount -t proc proc /proc                                        >> initrd-$*/etc/init.d/rcS
	@echo loadkeys fr                                                     >> initrd-$*/etc/init.d/rcS
	@chmod 755                                                               initrd-$*/etc/init.d/rcS
	@install -d                                                              initrd-$*/lib
	@set -- $(STAGING_DIR)/$*/lib/ld-*.so*; cp -P $$1                        initrd-$*/lib/ld-linux-x86-64.so.2
	@install $(STAGING_DIR)/$*/lib/libc.so.6                                 initrd-$*/lib/libc.so.6
	@install -d                                                              initrd-$*/mnt/cdrom
	@install -d                                                              initrd-$*/mnt/disk
	@install -d                                                              initrd-$*/proc
	@install -d                                                              initrd-$*/root
	@install -d                                                              initrd-$*/share/busybox
	@install $(BUSYBOX)/$*-build/busybox.links                               initrd-$*/share/busybox/busybox.links
	@install keymaps/fr.kmap                                                 initrd-$*/share/busybox/fr.kmap
	@install -d                                                              initrd-$*/share/syslinux
	@install -m 644 $(SYSLINUX)/mbr/mbr.bin                                  initrd-$*/share/syslinux/mbr.bin
	@$(HOST)-strip initrd-$*/bin/busybox initrd-$*/lib/*.so.*
	@genext2fs -b 8192 -d initrd-$* initrd-$*.ext2

################################################################################

iso_deps:
	@command -v genisoimage >/dev/null || { echo "'genisoimage' command not found"; exit 1; }

iso-%: iso_deps
	@test -f $(LINUX)/arch/x86/boot/bzImage || { echo "'linux' build required"; exit 1; }
	@test -f initrd-$*.ext2                 || { echo "'initrd-$*' image required"; exit 1; }
	@echo Create $*-based ISO image
	@test -d iso-$* || mkdir                           iso-$*
	@install -m 644 $(LINUX)/arch/x86/boot/bzImage     iso-$*/bzImage
	@gzip -c initrd-$*.ext2                         >  iso-$*/initrd.gz
	@install -m 644 $(SYSLINUX)/core/isolinux.bin      iso-$*/isolinux.bin
	@echo default linux                             >  iso-$*/isolinux.cfg
	@echo label linux                               >> iso-$*/isolinux.cfg
	@echo kernel bzImage                            >> iso-$*/isolinux.cfg
	@echo append initrd=initrd.gz root=/dev/ram0 rw >> iso-$*/isolinux.cfg
	@cp rootfs-$*.tgz iso-$*/rootfs.tgz 2>/dev/null || true
	@genisoimage -input-charset iso8859-1 -b isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -c boot.cat -o bootstrap-$*-x86_64.iso iso-$*
