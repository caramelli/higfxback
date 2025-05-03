# This file is part of HiGFXback

MACHTYPE := x86_64-pc-linux-gnu
HOST := x86_64-unknown-linux-gnu

STAGING_DIR := $(PWD)/$(HOST)
PATH := $(STAGING_DIR)/bin:$(PATH)

BINUTILS := binutils-2.25.1
BUSYBOX := busybox-1.36.1
GCC := gcc-4.7.4
GLIBC := glibc-2.19
GMP := gmp-6.2.1
LINUX := linux-4.14.336
MPFR := mpfr-4.1.1
MPC := mpc-1.3.1
PKG_CONFIG_LITE := pkg-config-lite-0.28-1
SYSLINUX := syslinux-3.86

################################################################################

all:
	@echo "make toolchain rootfs initrd iso"

cross-binutils:
	@echo Build $@
	@test -d $(BINUTILS) || wget -qO- https://ftp.gnu.org/gnu/binutils/$(BINUTILS).tar.bz2 | tar xj
	@test -d $(BINUTILS)/cross || mkdir $(BINUTILS)/cross
	@test -f $(BINUTILS)/cross/config.status || ( cd $(BINUTILS)/cross; ../configure --build=$(MACHTYPE) --target=$(HOST) --with-sysroot=$(STAGING_DIR) --prefix= )
	$(MAKE) -C $(BINUTILS)/cross
	$(MAKE) DESTDIR=$(STAGING_DIR) -C $(BINUTILS)/cross install
	@rm -rf $(STAGING_DIR)/$(HOST)/lib
	@rm -rf $(STAGING_DIR)/share/info; rm -rf $(STAGING_DIR)/share/locale; rm -rf $(STAGING_DIR)/share/man
	@echo $(BINUTILS) > $(STAGING_DIR)/share/binutils-VERSION

cross-gcc: cross-binutils
	@echo Build $@
	@test -d $(GCC) || ( wget -qO- https://ftp.gnu.org/gnu/gcc/$(GCC)/$(GCC).tar.bz2 | tar xj && patch -d $(GCC) -p1 < $(GCC).patch )
	@test -d $(GCC)/gmp || ( wget -qO- https://ftp.gnu.org/gnu/gmp/$(GMP).tar.xz | tar xJ && mv $(GMP) $(GCC)/gmp )
	@test -d $(GCC)/mpc || ( wget -qO- https://ftp.gnu.org/gnu/mpc/$(MPC).tar.gz | tar xz && mv $(MPC) $(GCC)/mpc )
	@test -d $(GCC)/mpfr || ( wget -qO- https://ftp.gnu.org/gnu/mpfr/$(MPFR).tar.xz | tar xJ && mv $(MPFR) $(GCC)/mpfr )
	@test -d $(GCC)/cross || mkdir $(GCC)/cross
	@test -f $(GCC)/cross/config.status || ( cd $(GCC)/cross; ../configure --build=$(MACHTYPE) --target=$(HOST) --enable-languages=c --with-newlib --disable-decimal-float --disable-lto --disable-plugin --disable-threads --disable-shared --with-sysroot=$(STAGING_DIR) --prefix= --libexecdir=/lib --with-local-prefix=/ )
	$(MAKE) -C $(GCC)/cross all-gcc all-target-libgcc
	$(MAKE) DESTDIR=$(STAGING_DIR) -C $(GCC)/cross install-gcc install-target-libgcc
	cat $(GCC)/gcc/limitx.h $(GCC)/gcc/glimits.h $(GCC)/gcc/limity.h > $(STAGING_DIR)/lib/gcc/$(HOST)/`echo $(GCC) | cut -d- -f2`/include-fixed/limits.h
	@rm -rf $(STAGING_DIR)/share/info; rm -rf $(STAGING_DIR)/share/locale; rm -rf $(STAGING_DIR)/share/man
	@echo $(GCC) > $(STAGING_DIR)/share/gcc-VERSION

linux-headers:
	@echo Build $@
	@test -d $(LINUX) || ( wget -qO- https://mirrors.edge.kernel.org/pub/linux/kernel/v4.x/$(LINUX).tar.xz | tar xJ && patch -d $(LINUX) -p1 < $(LINUX).patch )
	$(MAKE) INSTALL_HDR_PATH=$(STAGING_DIR) -C $(LINUX) headers_install

glibc: cross-gcc linux-headers
	@echo Build $@
	@test -d $(GLIBC) || wget -qO- https://ftp.gnu.org/gnu/glibc/$(GLIBC).tar.bz2 | tar xj
	@test -d $(GLIBC)/build || mkdir $(GLIBC)/build
	@test -f $(GLIBC)/build/config.status || ( cd $(GLIBC)/build; ac_cv_path_BASH_SHELL=no libc_cv_ssp=no ../configure --build=$(MACHTYPE) --host=$(HOST) --enable-obsolete-rpc --prefix= --libexecdir=/lib )
	$(MAKE) -C $(GLIBC)/build
	$(MAKE) install_root=$(STAGING_DIR) -C $(GLIBC)/build install
	@rm -rf $(STAGING_DIR)/share/locale
	@echo $(GLIBC) > $(STAGING_DIR)/share/glibc-VERSION

toolchain: glibc
	@echo Create cross-toolchain

################################################################################

linux:
	@echo Build $@
	@test -d $(LINUX) || ( wget -qO- https://mirrors.edge.kernel.org/pub/linux/kernel/v4.x/$(LINUX).tar.xz | tar xJ && patch -d $(LINUX) -p1 < $(LINUX).patch )
	@test -f $(LINUX)/.config || ( cp $(LINUX)-fragment-x86_64.config $(LINUX)/arch/x86/configs/fragment-x86_64.config; $(MAKE) -C $(LINUX) x86_64_defconfig fragment-x86_64.config )
	$(MAKE) CROSS_COMPILE=$(HOST)- -C $(LINUX)

busybox:
	@echo Build $@
	@test -d $(BUSYBOX) || ( wget -qO- https://busybox.net/downloads/$(BUSYBOX).tar.bz2 | tar xj && patch -d $(BUSYBOX) -p1 < $(BUSYBOX).patch )
	@test -f $(BUSYBOX)/.config || cp $(BUSYBOX).config $(BUSYBOX)/.config
	$(MAKE) CROSS_COMPILE=$(HOST)- -C $(BUSYBOX)
	$(MAKE) -C $(BUSYBOX) busybox.links

binutils:
	@echo Build $@
	@test -d $(BINUTILS) || wget -qO- https://ftp.gnu.org/gnu/binutils/$(BINUTILS).tar.bz2 | tar xj
	@test -d $(BINUTILS)/build || mkdir $(BINUTILS)/build
	@test -f $(BINUTILS)/build/config.status || ( cd $(BINUTILS)/build; ../configure --build=$(MACHTYPE) --host=$(HOST) --prefix= )
	$(MAKE) -C $(BINUTILS)/build

gcc:
	@echo Build $@
	@test -d $(GCC) || ( wget -qO- https://ftp.gnu.org/gnu/gcc/$(GCC)/$(GCC).tar.bz2 | tar xj && patch -d $(GCC) -p1 < $(GCC).patch )
	@test -d $(GCC)/gmp || ( wget -qO- https://ftp.gnu.org/gnu/gmp/$(GMP).tar.xz | tar xJ && mv $(GMP) $(GCC)/gmp )
	@test -d $(GCC)/mpc || ( wget -qO- https://ftp.gnu.org/gnu/mpc/$(MPC).tar.gz | tar xz && mv $(MPC) $(GCC)/mpc )
	@test -d $(GCC)/mpfr || ( wget -qO- https://ftp.gnu.org/gnu/mpfr/$(MPFR).tar.xz | tar xJ && mv $(MPFR) $(GCC)/mpfr )
	@test -d $(GCC)/build || mkdir $(GCC)/build
	@test -f $(GCC)/build/config.status || ( cd $(GCC)/build; ../configure --build=$(MACHTYPE) --host=$(HOST) --target=$(HOST) --disable-libgomp --disable-libmudflap --disable-libquadmath --disable-libssp --disable-lto --disable-multilib --disable-plugin --enable-languages=c --with-native-system-header-dir=/include --libexecdir=/lib --prefix= )
	$(MAKE) -C $(GCC)/build

pkg-config-lite:
	@echo Build $@
	@test -d $(PKG_CONFIG_LITE) || ( wget -qO- https://sourceforge.net/projects/pkgconfiglite/files/0.28-1/$(PKG_CONFIG_LITE).tar.gz | tar xz && patch -d $(PKG_CONFIG_LITE) -p1 < $(PKG_CONFIG_LITE).patch )
	@test -f $(PKG_CONFIG_LITE)/config.status || ( cd $(PKG_CONFIG_LITE); ./configure --host=$(HOST) --prefix= )
	$(MAKE) -C $(PKG_CONFIG_LITE)

syslinux:
	@echo Build $@
	@test -d $(SYSLINUX) || wget -qO- https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/3.xx/$(SYSLINUX).tar.xz | tar xJ
	$(MAKE) CC=$(HOST)-gcc -C $(SYSLINUX) installer

################################################################################

rootfs: linux busybox binutils gcc pkg-config-lite syslinux
	@echo Create rootfs tarball
	@install -d rootfs/bin
	@install $(BUSYBOX)/busybox rootfs/bin
	@for l in `sort $(BUSYBOX)/busybox.links`; do ln -sf busybox rootfs$$l; done
	@echo 'loadkmap < /share/busybox/$$1.kmap' > rootfs/bin/loadkeys
	@chmod 755 rootfs/bin/loadkeys
	@echo mdev -d > rootfs/bin/mdevd
	@chmod 755 rootfs/bin/mdevd
	@install $(BINUTILS)/build/binutils/addr2line rootfs/bin
	@install $(BINUTILS)/build/binutils/ar rootfs/bin
	@install $(BINUTILS)/build/binutils/cxxfilt rootfs/bin/c++filt
	@install $(BINUTILS)/build/binutils/elfedit rootfs/bin
	@install $(BINUTILS)/build/binutils/nm-new rootfs/bin/nm
	@install $(BINUTILS)/build/binutils/objcopy rootfs/bin
	@install $(BINUTILS)/build/binutils/objdump rootfs/bin
	@install $(BINUTILS)/build/binutils/ranlib rootfs/bin
	@install $(BINUTILS)/build/binutils/readelf rootfs/bin
	@install $(BINUTILS)/build/binutils/size rootfs/bin
	@install $(BINUTILS)/build/binutils/strings rootfs/bin
	@install $(BINUTILS)/build/binutils/strip-new rootfs/bin/strip
	@install $(BINUTILS)/build/gas/as-new rootfs/bin/as
	@install $(BINUTILS)/build/ld/ld-new rootfs/bin/ld
	@install $(BINUTILS)/build/gprof/gprof rootfs/bin
	@install $(GCC)/build/gcc/xgcc rootfs/bin/gcc
	@ln -sf gcc rootfs/bin/cc
	@install $(GCC)/build/gcc/cpp rootfs/bin
	@install $(GCC)/build/gcc/gcov rootfs/bin
	@install $(PKG_CONFIG_LITE)/pkg-config rootfs/bin
	@install $(STAGING_DIR)/bin/getconf rootfs/bin
	@install $(STAGING_DIR)/bin/ldd rootfs/bin
	@install $(SYSLINUX)/extlinux/extlinux rootfs/bin
	@install -d rootfs/boot
	@install $(LINUX)/arch/x86/boot/bzImage rootfs/boot
	@install -d rootfs/dev
	@install -d rootfs/etc
	@echo proc /proc proc defaults 0 0 > rootfs/etc/fstab
	@echo sysfs /sys sysfs defaults 0 0 >> rootfs/etc/fstab
	@echo tmpfs /run tmpfs defaults 0 0 >> rootfs/etc/fstab
	@echo tmpfs /tmp tmpfs defaults 0 0 >> rootfs/etc/fstab
	@echo root::0:root > rootfs/etc/group
	@echo root::0:0:root:/root:/bin/sh > rootfs/etc/passwd
	@echo null:2345:sysinit:/etc/init.d/rcS > rootfs/etc/inittab
	@echo tty1:2345:respawn:getty tty1 9600 >> rootfs/etc/inittab
	@echo tty2:2345:respawn:getty tty2 9600 >> rootfs/etc/inittab
	@echo tty3:2345:respawn:getty tty3 9600 >> rootfs/etc/inittab
	@echo tty4:2345:respawn:getty tty4 9600 >> rootfs/etc/inittab
	@echo tty5:2345:respawn:getty tty5 9600 >> rootfs/etc/inittab
	@echo tty6:2345:respawn:getty tty6 9600 >> rootfs/etc/inittab
	@install -d rootfs/etc/init.d
	@echo '#!/bin/sh' > rootfs/etc/init.d/rcS
	@echo mount -a >> rootfs/etc/init.d/rcS
	@echo mkdir /dev/pts >> rootfs/etc/init.d/rcS
	@echo mount -t devpts none /dev/pts >> rootfs/etc/init.d/rcS
	@echo mdevd >> rootfs/etc/init.d/rcS
	@echo mdev -s >> rootfs/etc/init.d/rcS
	@echo ln -sf /proc/self/fd /dev/fd >> rootfs/etc/init.d/rcS
	@echo ln -sf /proc/self/fd/0 /dev/stdin >> rootfs/etc/init.d/rcS
	@echo ln -sf /proc/self/fd/1 /dev/stdout >> rootfs/etc/init.d/rcS
	@echo ln -sf /proc/self/fd/2 /dev/stderr >> rootfs/etc/init.d/rcS
	@echo loadkeys fr >> rootfs/etc/init.d/rcS
	@chmod 755 rootfs/etc/init.d/rcS
	@install -d rootfs/include
	@install -m 644 $(STAGING_DIR)/include/_G_config.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/aio.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/alloca.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/ar.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/argp.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/argz.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/assert.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/byteswap.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/complex.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/cpio.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/crypt.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/ctype.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/dirent.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/dlfcn.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/elf.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/endian.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/err.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/errno.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/error.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/fcntl.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/features.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/fenv.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/fmtmsg.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/fnmatch.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/fts.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/ftw.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/gconv.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/getopt.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/glob.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/grp.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/iconv.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/ifaddrs.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/inttypes.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/langinfo.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/lastlog.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/libgen.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/libintl.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/libio.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/limits.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/link.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/locale.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/malloc.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/math.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/memory.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/mntent.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/monetary.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/mqueue.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/netdb.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/nl_types.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/obstack.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/paths.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/poll.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/pthread.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/pty.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/pwd.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/regex.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/resolv.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/sched.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/search.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/semaphore.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/setjmp.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/shadow.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/signal.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/spawn.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/stdc-predef.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/stdint.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/stdio.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/stdio_ext.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/stdlib.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/string.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/strings.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/stropts.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/syscall.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/sysexits.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/syslog.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/tar.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/termios.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/tgmath.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/time.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/ttyent.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/uchar.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/ucontext.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/ulimit.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/unistd.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/utime.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/utmp.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/utmpx.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/values.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/wait.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/wchar.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/wctype.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/wordexp.h rootfs/include
	@install -m 644 $(STAGING_DIR)/include/xlocale.h rootfs/include
	@cp -r $(STAGING_DIR)/include/arpa rootfs/include
	@cp -r $(STAGING_DIR)/include/asm rootfs/include
	@cp -r $(STAGING_DIR)/include/asm-generic rootfs/include
	@cp -r $(STAGING_DIR)/include/bits rootfs/include
	@cp -r $(STAGING_DIR)/include/gnu rootfs/include
	@cp -r $(STAGING_DIR)/include/linux rootfs/include
	@cp -r $(STAGING_DIR)/include/mtd rootfs/include
	@cp -r $(STAGING_DIR)/include/net rootfs/include
	@cp -r $(STAGING_DIR)/include/netinet rootfs/include
	@cp -r $(STAGING_DIR)/include/netpacket rootfs/include
	@cp -r $(STAGING_DIR)/include/rpc rootfs/include
	@cp -r $(STAGING_DIR)/include/scsi rootfs/include
	@cp -r $(STAGING_DIR)/include/sys rootfs/include
	@install -d rootfs/lib
	@install $(STAGING_DIR)/lib/ld-*.so rootfs/lib/ld-linux-x86-64.so.2
	@install $(STAGING_DIR)/lib/libc-*.so rootfs/lib/libc.so.6
	@install $(STAGING_DIR)/lib/libc.so rootfs/lib
	@install -m 644 $(STAGING_DIR)/lib/libc_nonshared.a rootfs/lib
	@install $(STAGING_DIR)/lib/libcrypt-*.so rootfs/lib/libcrypt.so.1
	@ln -sf libcrypt.so.1 rootfs/lib/libcrypt.so
	@install $(STAGING_DIR)/lib/libdl-*.so rootfs/lib/libdl.so.2
	@ln -sf libdl.so.2 rootfs/lib/libdl.so
	@install $(STAGING_DIR)/lib/libm-*.so rootfs/lib/libm.so.6
	@ln -sf libm.so.6 rootfs/lib/libm.so
	@install $(STAGING_DIR)/lib/libnsl-*.so rootfs/lib/libnsl.so.1
	@ln -sf libnsl.so.1 rootfs/lib/libnsl.so
	@install $(STAGING_DIR)/lib/libnss_dns-*.so rootfs/lib/libnss_dns.so.2
	@ln -sf libnss_dns.so.2 rootfs/lib/libnss_dns.so
	@install $(STAGING_DIR)/lib/libnss_files-*.so rootfs/lib/libnss_files.so.2
	@ln -sf libnss_files.so.2 rootfs/lib/libnss_files.so
	@install $(STAGING_DIR)/lib/libpthread-*.so rootfs/lib/libpthread.so.0
	@install $(STAGING_DIR)/lib/libpthread.so rootfs/lib
	@install -m 644 $(STAGING_DIR)/lib/libpthread_nonshared.a rootfs/lib
	@install $(STAGING_DIR)/lib/libresolv-*.so rootfs/lib/libresolv.so.2
	@ln -sf libresolv.so.2 rootfs/lib/libresolv.so
	@install $(STAGING_DIR)/lib/librt-*.so rootfs/lib/librt.so.1
	@ln -sf librt.so.1 rootfs/lib/librt.so
	@install $(STAGING_DIR)/lib/libutil-*.so rootfs/lib/libutil.so.1
	@ln -sf libutil.so.1 rootfs/lib/libutil.so
	@install -m 644 $(STAGING_DIR)/lib/crt1.o rootfs/lib
	@install -m 644 $(STAGING_DIR)/lib/crti.o rootfs/lib
	@install -m 644 $(STAGING_DIR)/lib/crtn.o rootfs/lib
	@install -m 644 $(STAGING_DIR)/lib/gcrt1.o rootfs/lib
	@install -m 644 $(STAGING_DIR)/lib/Scrt1.o rootfs/lib
	@ln -sf ../bin/cpp rootfs/lib/cpp
	@install $(GCC)/build/gcc/libgcc_s.so.1 rootfs/lib
	@ln -sf libgcc_s.so.1 rootfs/lib/libgcc_s.so
	@install -d rootfs/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`
	@install $(GCC)/build/gcc/cc1 rootfs/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`
	@install -m 644 $(GCC)/build/gcc/crtbegin.o rootfs/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`
	@install -m 644 $(GCC)/build/gcc/crtbeginS.o rootfs/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`
	@install -m 644 $(GCC)/build/gcc/crtend.o rootfs/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`
	@install -m 644 $(GCC)/build/gcc/crtendS.o rootfs/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`
	@install -m 644 $(GCC)/build/gcc/crtfastmath.o rootfs/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`
	@install -m 644 $(GCC)/build/gcc/libgcc.a rootfs/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`
	@install -d rootfs/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include
	@install -m 644 $(GCC)/build/gcc/include/emmintrin.h rootfs/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include
	@install -m 644 $(GCC)/build/gcc/include/float.h rootfs/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include
	@install -m 644 $(GCC)/build/gcc/include/mm_malloc.h rootfs/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include
	@install -m 644 $(GCC)/build/gcc/include/mmintrin.h rootfs/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include
	@install -m 644 $(GCC)/build/gcc/include/stdarg.h rootfs/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include
	@install -m 644 $(GCC)/build/gcc/include/stdbool.h rootfs/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include
	@install -m 644 $(GCC)/build/gcc/include/stddef.h rootfs/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include
	@install -m 644 $(GCC)/build/gcc/include/xmmintrin.h rootfs/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include
	@install -d rootfs/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include-fixed
	@install -m 644 $(GCC)/build/gcc/include-fixed/limits.h rootfs/lib/gcc/$(HOST)/`cat $(GCC)/gcc/BASE-VER`/include-fixed
	@install -d rootfs/mnt/cdrom
	@install -d rootfs/mnt/disk
	@install -d rootfs/mnt/share
	@install -d rootfs/proc
	@install -d rootfs/root
	@install -d rootfs/run
	@install -d rootfs/share/aclocal
	@install -m 644 $(PKG_CONFIG_LITE)/pkg.m4 rootfs/share/aclocal
	@install -d rootfs/share/busybox
	@install $(BUSYBOX)/busybox.links rootfs/share/busybox
	@echo '#!/bin/sh' > rootfs/share/busybox/default.script
	@echo 'case $$1 in' >> rootfs/share/busybox/default.script
	@echo '  deconfig)' >> rootfs/share/busybox/default.script
	@echo '    ifconfig $$interface 0.0.0.0 ;;' >> rootfs/share/busybox/default.script
	@echo '  renew|bound)' >> rootfs/share/busybox/default.script
	@echo '    ifconfig $$interface $$ip netmask $$subnet ;;' >> rootfs/share/busybox/default.script
	@echo '    ifconfig $$interface $$ip netmask $$subnet' >> rootfs/share/busybox/default.script
	@echo '    route add default gw $$router' >> rootfs/share/busybox/default.script
	@echo '    > /etc/resolv.conf' >> rootfs/share/busybox/default.script
	@echo '    for i in $$dns; do echo nameserver $$i >> /etc/resolv.conf; done ;;' >> rootfs/share/busybox/default.script
	@echo 'esac' >> rootfs/share/busybox/default.script
	@chmod 755 rootfs/share/busybox/default.script
	@install keymaps/fr.kmap rootfs/share/busybox
	@install -d rootfs/share/syslinux
	@install -m 644 $(SYSLINUX)/core/isolinux.bin rootfs/share/syslinux
	@install -m 644 $(SYSLINUX)/mbr/mbr.bin rootfs/share/syslinux
	@install -d rootfs/sys
	@install -d rootfs/tmp
	@install -d rootfs/var
	@rm -f rootfs/var/run; ln -s /run rootfs/var/run
	@find rootfs -type f -exec file {} \; | grep -v crt | grep ELF | cut -d: -f1 | xargs $(HOST)-strip
	@tar -C rootfs -czf rootfs.tgz .

################################################################################

initrd: busybox syslinux
	@echo Create initrd
	@install -d initrd/bin
	@install $(BUSYBOX)/busybox initrd/bin
	@for l in `sort $(BUSYBOX)/busybox.links`; do ln -sf busybox initrd$$l; done
	@echo 'loadkmap < /share/busybox/$$1.kmap' > initrd/bin/loadkeys
	@chmod 755 initrd/bin/loadkeys
	@install $(SYSLINUX)/extlinux/extlinux initrd/bin
	@install setup initrd/bin
	@install -d initrd/dev
	@install -d initrd/etc
	@echo root::0:0:root:/root:/bin/sh > initrd/etc/passwd
	@echo null:2345:sysinit:/etc/init.d/rcS > initrd/etc/inittab
	@echo tty1:2345:respawn:getty tty1 9600 >> initrd/etc/inittab
	@install -d initrd/etc/init.d
	@echo '#!/bin/sh' > initrd/etc/init.d/rcS
	@echo mount -t proc proc /proc >> initrd/etc/init.d/rcS
	@echo loadkeys fr >> initrd/etc/init.d/rcS
	@chmod 755 initrd/etc/init.d/rcS
	@install -d initrd/lib
	@install $(STAGING_DIR)/lib/ld-*.so initrd/lib/ld-linux-x86-64.so.2
	@install $(STAGING_DIR)/lib/libc-*.so initrd/lib/libc.so.6
	@install -d initrd/mnt/cdrom
	@install -d initrd/mnt/disk
	@install -d initrd/proc
	@install -d initrd/root
	@install -d initrd/share/busybox
	@install $(BUSYBOX)/busybox.links rootfs/share/busybox
	@install keymaps/fr.kmap initrd/share/busybox
	@install -d initrd/share/syslinux
	@install -m 644 $(SYSLINUX)/mbr/mbr.bin initrd/share/syslinux
	@$(HOST)-strip initrd/bin/busybox initrd/lib/ld-linux-x86-64.so.2 initrd/lib/libc.so.6
	@genext2fs -b 8192 -d initrd initrd.ext2

################################################################################

.PHONY: iso
iso:
	@echo Create ISO image
	@test -d iso || mkdir iso
	@install -m 644 $(LINUX)/arch/x86/boot/bzImage iso
	@gzip -c initrd.ext2 > iso/initrd.gz
	@install -m 644 $(SYSLINUX)/core/isolinux.bin iso
	@echo default linux > iso/isolinux.cfg
	@echo label linux >> iso/isolinux.cfg
	@echo kernel bzImage >> iso/isolinux.cfg
	@echo append initrd=initrd.gz root=/dev/ram0 rw >> iso/isolinux.cfg
	@cp rootfs.tgz iso
	@genisoimage -input-charset iso8859-1 -b isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -c boot.cat -o bootstrap-x86_64.iso iso
