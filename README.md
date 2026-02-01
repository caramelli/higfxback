**HiGFXback** (**History of graphics backends**) is a Linux from scratch distribution whose aim is to preserve and maintain historical backends used for graphics on Linux system.

![](backends.png)

This Linux distribution has a set of characteristics that make it unique.

First, by its construction: **HiGFXback** is a fully **source-based distribution** (system built entirely from source code) that relies on the **C library of your choice** (_glibc_, _musl_, …).

Second, it is possible with **HiGFXback** to run components **natively based on the following graphics backends**:

* [Linux Framebuffer](Linux-Framebuffer.md)
* [DirectFB](DirectFB.md)
* [X11](X11.md)
* [Wayland](Wayland.md)
* [KMS/DRM](KMS-DRM.md)

Other characteristics specific to **HiGFXback** are also detailed in the installation and usage procedure that follows.

# Bootstrapping

The initial steps consist of creating and booting a minimal system that provides a shell environment for ordinary Unix-like tasks, in particular downloading and compiling source code.

Current versions of the GNU _C_ compiler are written in _C++_, which means that a _C++_ compiler (typically _**g++**_) is needed to build _**gcc**_ from source.
The GNU Compiler Collection **GCC 4.7** is the last version that can be built with only a _C_ compiler (even a simple one such as _**tcc**_, the Tiny _C_ compiler), thus it is used in the bootstrap process.

On the host system, enter the bootstrap directory, and optionally set `MAKEFLAGS` environment variable to speed up compilation:

```
$ cd bootstrap
$ export MAKEFLAGS=-j$(nproc)
```

The host system is used to build a cross-toolchain for the target system:

```
$ make toolchain
```

A single cross-toolchain capable of supporting multiple **C libraries** (_glibc_, _musl_, …) and based on **Binutils**, **GCC** (_C_ compiler only), the **Linux headers**, is generated in a staging directory.

The same cross-compiler is thus used to build the various **C libraries**, each placed in a dedicated directory within the staging directory:

```
	  .                                          .                                         .
	  |                                          |                                         |
	  |-- bin                                    |-- glibc                                 |-- musl
	  |    |-- x86_64-unknown-linux-as                |-- bin                                   |-- bin
	  |    |-- x86_64-unknown-linux-gcc               |    |-- getconf                          |    |-- getconf
	  |    |-- x86_64-unknown-linux-ld                |    |-- ldd                              |    |-- ldd
	  |    |-- ...                                    |    |-- ...                              |    |-- ...
	  |                                               |                                         |
	  |--  include                                    |-- include                               |-- include
	  |    |-- asm                                    |    |-- math.h                           |    |-- math.h
	  |    |-- linux                                  |    |-- stdio.h                          |    |-- stdio.h
	  |    |-- ...                                    |    |-- ...                              |    |-- ...
	  |                                               |                                         |
	  |-- lib                                         |-- lib                                   |-- lib
	       |-- gcc                                         |-- crt1.o                                |-- crt1.o
	            |-- x86_64-unknown-linux                   |-- ld-linux-x86-64.so.2                  |-- ld-musl-x86_64.so.1
	                 |-- 4.7.4                             |-- libc.so                               |-- libc.so
	                      |-- cc1                          |-- libc.so.6                             |-- libc.so.6
	                      |-- crtbegin.o                   |-- libpthread.so                         |-- libpthread.so
	                      |-- crtend.o                     |-- ...                                   |-- ...
	                      |-- libgcc.a
	                      |-- ...
	                      |-- include
	                           |-- float.h
	                           |-- stddef.h
	                           |-- ...
```

Selecting which **C library** the cross-compiler will use is done with the _**stow**_ command, which makes the headers and libraries of the chosen **C library** appear in the sysroot directory of the toolchain.

With the toolchain in place,  cross-compile a minimal set of software required for an ISO image and for the minimal system installed on the target hardware.

For a minimal _glibc-based_ system:

```
$ make initrd-glibc
$ make rootfs-glibc
```

For a minimal _musl-based_ system:

```
$ make initrd-musl
$ make rootfs-musl
```

The initrd serves as an installer (and optionally as a rescue disk) for the distribution, and is composed of:

* _**busybox**_, which combines lightweight versions of many Unix utilities
* _**syslinux**_, with its EXTLINUX bootloader
*  the **C library** (_glibc_ or _musl_)

The generated root filesystem contains only:

* _**linux**_, the operating system kernel
* _**busybox**_, providing the shell environment with standard Unix-like commands (same binary as in the initrd)
* _**binutils**_, providing, among other tools, the assembler and linker used by the C compiler
* _**gcc**_, the GNU _C_ compiler
* _**pkg-config**_, a tool typically invoked when compiling applications and libraries, but whose usage is extended to manage packages and their dependencies on the system
* the **C library** (_glibc_ or _musl_)

> Since a common cross-compiler is used to build the source code regardless of the target **C library**, all binaries in the minimal system have the same dynamic linker/loader _**ld-linux.so.2**_ in the `PT_INTERP ELF` segment. But note that the compiler present in this minimal root filesystem, and used to build and install packages that will replace the initial minimal system binaries, compiles source code by setting the `PT_INTERP ELF` segment to the dynamic linker/loader name corresponding to the selected **C library** (i.e. _**ld-linux.so.2**_ for _glibc_ or _**ld-musl-x86_64.so.1**_ for _musl_).

Next, generate the ISO image used for installation:

```
$ make iso-glibc
```

or :

```
$ make iso-musl
```

The target machine can now boot from the ISO image.

To test it on a virtual machine with QEMU, first create a disk image, then boot the VM, for example from the _glibc-based_ ISO image, by attaching the created disk image to an ATA disk over a SATA AHCI controller:

```
$ qemu-img create disk-glibc-x86_64.img 64G
$ qemu-system-x86_64 -boot d -cdrom bootstrap-glibc-x86_64.iso -device ahci -drive id=disk,file=disk-glibc-x86_64.img,format=raw,if=none -device ide-hd,drive=disk
```

Or from the _musl-based_ ISO image:

```
$ qemu-img create disk-musl-x86_64.img 64G
$ qemu-system-x86_64 -boot d -cdrom bootstrap-musl-x86_64.iso -device ahci -drive id=disk,file=disk-musl-x86_64.img,format=raw,if=none -device ide-hd,drive=disk
```

Once the VM has started, perform the installation from the guest system’s shell prompt:

```
# setup
```
The VM can now boot on the freshly installed minimal system (located on the disk image).

# Installing packages

The package installation process relies on a specific tool named _**pkg-build**_, which starts by downloading the package source code from the Internet (if it has not already been downloaded).

When testing with a QEMU virtual machine, set up a virtual network interface on the host system (a TAP interface) to allow the VM to connect to the real network:

```
$ sudo ip tuntap add dev tap0 mode tap
$ sudo ip addr add 192.168.0.1/24 dev tap0
$ sudo ip link set tap0 up
```

If the _**dnsmasq**_ DHCP server is not installed on the host system, install it and edit its _**/etc/dnsmasq.conf**_ configuration file to include the following settings, then restart _**dnsmasq**_:

```
port=5353
interface=tap0
dhcp-option=option:dns-server,8.8.8.8
dhcp-range=192.168.0.101,192.168.0.200
```

As a final step on the host system, enable IP forwarding and configure NAT so that traffic from the VM is passed to the Internet and replies from the Internet can reach the VM:

```
$ sudo sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
$ sudo iptables -t nat -A POSTROUTING -o $(ip -o link show up | awk -F': ' '{print $2}' | grep -E '^(en|eth|wl)' | head -n1) -j MASQUERADE
```

With the host system network fully configured, launch the VM, for example, the _glibc-based_ VM:

```
$ qemu-system-x86_64 -monitor stdio -enable-kvm -cpu host -smp 8 -m 8G -device ahci -drive id=disk,file=disk-glibc-x86_64.img,format=raw,if=none -device ide-hd,drive=disk -netdev tap,id=net0,ifname=tap0,script=no -device e1000,netdev=net0 -usb -device usb-tablet -device intel-hda -device hda-duplex
```

Or the _musl-based_ VM:

```
$ qemu-system-x86_64 -monitor stdio -enable-kvm -cpu host -smp 8 -m 8G -device ahci -drive id=disk,file=disk-musl-x86_64.img,format=raw,if=none -device ide-hd,drive=disk -netdev tap,id=net0,ifname=tap0,script=no -device e1000,netdev=net0 -usb -device usb-tablet -device intel-hda -device hda-duplex
```

QEMU options used:

* `-monitor stdio` to redirect the QEMU monitor to the host console.
* `-enable-kvm -cpu host` to enable KVM acceleration with the host CPU exposed to the guest system.
* `-smp 8 -m 8G_ to set 8 CPUs and 8 GiB of RAM.
* `-netdev tap,id=net0,ifname=tap0,script=no -device e1000,netdev=net0` to add an Intel e1000 network device connected to the host networking via the TAP interface.
* `-usb -device usb-tablet` to add a USB controller with a USB tablet pointing device.
* `-device intel-hda -device hda-duplex` to add an Intel High Definition Audio controller with microphone and speakers devices.

The VM is by default launched with a VGA-compatible display device, allowing the  _**vesafb**_ guest driver to expose a _Linux Framebuffer_ device interface (`/dev/fb0`).
To enable a _KMS/DRM_ device interface (`/dev/dri/card0`), launch the VM with a VirtIO display device by adding the `-device virtio-vga` option to the QEMU command line, which is handled by the  _**virtio_gpu**_ guest driver.

Once the VM has started, run the DHCP client from the guest system’s shell prompt to automatically configure its network interface:

```
# udhcpc eth0
```

Then, enter the sources directory to begin installing packages, and optionally set the `MAKEFLAGS` environment variable to speed up compilation:

```
# cd sources
# export MAKEFLAGS=-j$(nproc)
```

### Installing core system components packages

Most packages are built using a build system such as **Autoconf**, **Meson**, or **CMake**.

The **Autoconf** build system is partly written in the _M4_ and _Perl_ languages, the _**perl**_ package itself depending on the _**bzip2**_ and _**zlib**_ compression libraries.
The _**m4**_ package, as well as the _**bzip2**_ and _**zlib**_ packages, are built using the _**make**_ utility, which is therefore the first package added to the system:

```
# pkg-build make
```

Once _**make**_ is available:

```
# pkg-build m4
# pkg-build bzip2 zlib
# pkg-build perl
# pkg-build autotools-wrappers-ac autotools-wrappers-am mawk autotools-wrappers-lt
```

>Note that building _**autotools-wrappers-lt**_ requires _**mawk**_, as an _awk-based_ script named _inline-source_, involved in the generation of _libtoolize_, fails when executed with _**busybox**_ _awk_.

It is often convenient to have mouse support in virtual consoles to allow copy-and-paste operations instead of typing everything by hand, which is provided by the _**gpm**_ daemon:

```
# pkg-build byacc gpm
# gpm -m /dev/input/event2 -t usbtablet
```

The **Meson** build system is written in _Python 3_ language and relies by default on _**ninja**_, an utility written in _C++_ which controls the generation of non-source files from source files (like the _**make**_ utility).
If _**ninja**_ is missing on the system, meson fallback to _**samurai**_, a _ninja-compatible_ implementation written in _C_ that is installed to avoid a dependancy with _**g++**_ and _**libstdc++**_ packages:

```
# pkg-build expat python3
# pkg-build samurai
# pkg-build meson
```

The **CMake** build system is written in _C++_ language so depends on the availibility of _**g++**_ and _**libstdc++**_ packages.
These are not required for installing and starting core graphics components, but if _C++_ compiler is needed by other components:

```
# pkg-build gmp mpfr mpc g++ libstdc++
```

Then, if the **CMake** build system is required to build a package:

```
# pkg-build curl
# pkg-build expat lz4 xz zstd libarchive
# pkg-build libuv
# pkg-build rhash
# pkg-build jsoncpp cmake3
```

Note that the **CMake** build system has support for both _**make**_ (used by default) and _**ninja**_/_**samurai**_ as non-source files generators from source files.

If the _C++_ compiler is available on the system, _**ninja**_ can easiy be installed to replace _**samurai**_:

```
# pkg-build ninja
```

When launching the VM with the default VGA-compatible display device, the guest can also expose a _KMS/DRM_ device interface (`/dev/dri/card0`) if the _Linux kernel_ includes support for the _**simpledrm**_ driver.
Since the _**simpledrm**_ driver is only available in _Linux kernels_ requiring a _**gcc**_ version newer than 4.7 (and therefore _Linux kernels_ more recent than the one used in the bootstrap), this introduces an indirect dependency of the _Linux kernel_ on _**g++**_ and _**libstdc++**_ packages. Assuming these packages are present, the following command can be used to update the _Linux kernel_:

```
# pkg-build byacc flex bison diffutils findutils elfutils openssl ncurses linux
```

> Note that building _**linux**_ requires _diff_ command from _**diffutils**_ package, as it is invoked with the `-I` option, which is not supported by _**busybox**_ _diff_, and _find_ command from _**findutils**_ package, as it is invoked with the `-printf` option, which is not supported by _**busybox**_ _find_.

### Installing core graphics components packages

For the _Linux Framebuffer_ graphics backend:

```
# pkg-build byacc flex bison fbset
# pkg-build util-macros libfontenc freetype mkfontscale mkfontdir
# pkg-build ttf-bitstream-vera
# pkg-build fb/ft2tf fb/fbpad
```

For the _KMS/DRM_ graphics backend graphics backend:
```
# pkg-build libdrm
# pkg-build byacc flex bison
# pkg-build util-macros xkeyboard-config libxkbcommon
# pkg-build libudev-zero libtsm kmscon
```

For the _DirectFB_ graphics backend:

```
# pkg-build dfb/directfb2 dfb/directfb2-tools
# pkg-build dfb/lite dfb/dfbterm
```

For the _X11_ graphics backend:

```
# pkg-build util-macros x11/xproto x11/libxau
# pkg-build x11/xtrans
# pkg-build libfontenc freetype
# pkg-build x11/fontsproto x11/libxfont
# pkg-build x11/bigreqsproto x11/inputproto x11/kbproto x11/xcmiscproto
# pkg-build x11/renderproto x11/videoproto x11/xextproto x11/fixesproto x11/damageproto x11/randrproto
# pkg-build libmd pixman xkeyboard-config x11/libpciaccess x11/xorg-server
# pkg-build x11/xf86-video-fbdev x11/xf86-input-evdev
# pkg-build x11/libx11
# pkg-build x11/libxkbfile x11/xkbcomp
# pkg-build x11/libxext
# pkg-build x11/libxrender x11/xdpyinfo
# pkg-build util-linux x11/libice x11/libsm x11/libxt
# pkg-build x11/libxmu x11/twm
# pkg-build mkfontscale mkfontdir ttf-bitstream-vera
# pkg-build x11/libxpm x11/libxaw
# pkg-build expat fontconfig x11/libxft
# pkg-build ncurses x11/xterm
```

For the _Wayland_ graphics backend:

```
# pkg-build libffi expat
# pkg-build wl/wayland wl/wayland-protocols
# pkg-build byacc flex bison
# pkg-build util-macros xkeyboard-config libxkbcommon
# pkg-build libevdev libudev-zero mtdev libinput
# pkg-build pcre util-linux python3 glib freetype fontconfig libpng pixman wl/cairo
# pkg-build jpeg wl/weston
```
