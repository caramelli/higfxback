Welcome to [**HiGFXback**](README.md) with the _Linux Framebuffer_ graphics backend!

<a name="contents"></a>

# Contents

* [Getting started](#getting-started)
    * [Fbpad](#fbpad)
    * [fb-test-app, fbmark](#fb-test-app-fbmark)
    * [showkey, input-events](#showkey-input-events)
    * [test-mouse, input-events](#test-mouse-input-events)
* [Vulkan rendering](#vulkan-rendering)
* [OpenGL rendering](#opengl-rendering)
    * [GLFBDev](#glfbdev)
    * [EGL for Linux Framebuffer](#egl-for-linux-framebuffer)
* [Drawing libraries](#drawing-libraries)
    * [Cairo](#cairo)
    * [Evas](#evas)
* [Multimedia frameworks](#multimedia-frameworks)
    * [FFmpeg](#ffmpeg)
    * [GStreamer](#gstreamer)
    * [Xine](#xine)
    * [VLC](#vlc)
* [Tools](#tools)
    * [Fbi, FIM](#fbi-fim)
    * [Fbpdf](#fbpdf)
    * [NetSurf, Links](#netsurf-links)
    * [Fbff, MPlayer](#fbff-mplayer)
* [Graphics abstraction layers](#graphics-abstraction-layers)
    * [GLUT](#glut)
    * [SDL](#sdl)
* [User interface toolkits](#user-interface-toolkits)
    * [GTK+](#gtk)
    * [Qt](#qt)
    * [EFL](#efl)
* [Applications](#applications)

<a name="getting-started"></a>

# Getting started

Components running on _Linux Framebuffer_ graphics backend just use the _Linux Framebuffer_ graphics driver interface (`/dev/fb0`). As they directly access the memory of the display device, there is no compositing windowing system.

If the current graphics backend used on **HiGFXback** is not _Linux Framebuffer_, switch on it with `startfb` command.

<p align="center"><img src="diagrams/fb.png"></p>

Components running on _Linux Framebuffer_ graphics backend directly handle keyboard and mouse input events with one of the following input driver interface available on **HiGFXback**:

* _console_ interface (`/dev/tty0`)
* _PS/2 mouse_ interface (`/dev/psaux`)
* _event device_ interface (`/dev/input/event0` and `/dev/input/event1`)

But depending on the input peripheral, it's possible to use specific input driver interfaces if supported by the component running on the _Linux Framebuffer_ graphics backend.

Note that input driver interfaces used for mouse input events are also accessible through the _**gpm**_ (General Purpose Mouse) mouse server.

<a name="fbpad"></a>

### Fbpad

When starting on _Linux Framebuffer_ graphics backend, _**fbpad**_ terminal emulator is displayed.
System informations about _Linux Framebuffer_ settings can be get with _**fbset**_.

![](screenshots/fbpad.png)

[Back to Top](#contents)

<a name="fb-test-app-fbmark"></a>

### fb-test-app, fbmark

Programs running on _Linux Framebuffer_ graphics backend are available as examples, tests or benchmarks.

![](screenshots/fb-test-app-fbmark.png)

[Back to Top](#contents)

<a name="showkey-input-events"></a>

### showkey, input-events

Programs are available for testing keyboard input interfaces used by components running on _Linux Framebuffer_ graphics backend.

![](screenshots/showkey-input-events.png)

[Back to Top](#contents)

<a name="test-mouse-input-events"></a>

### test-mouse, input-events

Programs are available for testing mouse input interfaces used by components running on _Linux Framebuffer_ graphics backend.

![](screenshots/test-mouse-input-events.png)

[Back to Top](#contents)

<a name="vulkan-rendering"></a>

# Vulkan rendering

For display rendering with _Linux Framebuffer_ graphics backend, _Vulkan_ implementation in _**libvulkan.so** library_ (loading library from _Vulkan-Loader_) and its ICD (Installable Client Driver) relies on _FBDev WSI_ interface.

On **HiGFXback**, _FBDev WSI_ interfaces (Window System Integration for _Linux Framebuffer_) are used with one of the following ICD selected with `VK_ICD_FILENAMES` environment variable:

* _Mesa_ associated to _**lvp_icd.json** manifest file_
* _SwiftShader_ associated to _**swiftshader_icd.json** manifest file_

But depending on the platform, specific ICD can be used.

<p align="center"><img src="diagrams/fb-vulkan.png"></p>

_**Vulkan-Tools**_, _**Vulkan-Examples**_, _**vkcube2**_ and _**yagears2**_ programs are available as examples, tests or benchmarks.

![](screenshots/vulkan-linux-framebuffer.png)

[Back to Top](#contents)

<a name="opengl-rendering"></a>

# OpenGL rendering

For display rendering with _Linux Framebuffer_ graphics backend, _OpenGL_ implementation in _**libGL.so** library_, but also _OpenGL ES 1.1 CM_ implementation in _**libGLESv1_CM.so** library_ and _OpenGL ES 2.0_ implementation in _**libGLESv2.so** library_, rely on _GLFBDev_ or _EGL for Linux Framebuffer_ interfaces.

Loading libraries can be used:

* _**libGLEW.so** library_ from _GLEW_ (OpenGL Extension Wrangler)
* _**libepoxy.so** library_ from _Epoxy_

<a name="glfbdev"></a>

### GLFBDev

On **HiGFXback**, _GLFBDev_ interfaces (_OpenGL_ extension for _Linux Framebuffer_) are used with one of the following implementation selected with `alternatives-GL` command:

* _Mesa_ with _**libGL.so `->` libmesaGL.so**, **libGLESv1_CM.so `->` libmesaGLESv1_CM.so**, **libGLESv2.so `->` libmesaGLESv2.so** libraries_
* _TinyGL_ with _**libGL.so `->` libtinyGL.so** library_

But depending on the platform, specific implementation can be used.

<p align="center"><img src="diagrams/fb-glfbdev.png"></p>

_**mesa-demos**_ and _**yagears**_ programs are available as examples, tests or benchmarks.

![](screenshots/glfbdev.png)

[Back to Top](#contents)

<a name="egl-for-linux-framebuffer"></a>

### EGL for Linux Framebuffer

On **HiGFXback**, EGL for _Linux Framebuffer_ interfaces are used with one of the following implementation selected with `alternatives-GL` command:

* _Mesa_ with _**libEGL.so `->` libmesaEGL.so**, **libGL.so `->` libmesaGL.so**, **libGLESv1_CM.so `->` libmesaGLESv1_CM.so**, **libGLESv2.so `->` libmesaGLESv2.so** libraries_
* _SwiftShader_ with _**libEGL.so `->` libswiftshaderEGL.so**, **libGLESv1_CM.so `->` libswiftshaderGLESv1_CM.so**, **libGLESv2.so `->` libswiftshaderGLESv2.so** libraries_

But depending on the platform, specific implementation can be used.

<p align="center"><img src="diagrams/fb-egl.png"></p>

_**mesa-demos**_ and _**yagears**_ programs are available as examples, tests or benchmarks.

![](screenshots/egl-linux-framebuffer.png)

[Back to Top](#contents)

<a name="drawing-libraries"></a>

# Drawing libraries

<a name="cairo"></a>

### Cairo

On **HiGFXback**, _Cairo_ interfaces for _Linux Framebuffer_ graphics backend are provided by _**libcairo.so** library_.

<p align="center"><img src="diagrams/fb-cairo-fbdev.png"></p>

_**cairo-demos**_ programs are available as examples, tests or benchmarks.

![](screenshots/cairo-linux-framebuffer.png)

[Back to Top](#contents)

<a name="evas"></a>

### Evas

On **HiGFXback**, _Evas_ interfaces for _Linux Framebuffer_ graphics backend are provided by _**libevas.so** library_.

<p align="center"><img src="diagrams/fb-evas-fbdev.png"></p>

_**expedite**_ program is available as examples, tests or benchmarks.

![](screenshots/evas-linux-framebuffer.png)

[Back to Top](#contents)

<a name="multimedia-frameworks"></a>

# Multimedia frameworks

<a name="ffmpeg"></a>

### FFmpeg

On **HiGFXback**, _FFmpeg_ interfaces for _Linux Framebuffer_ graphics backend are provided by _**libavformat.so, libavcodec.so, libswscale.so** libraries_ and rely on _**libavdevice.so** library_ for output.

_**ffmpeg**_ program is available as example.

![](screenshots/ffmpeg-linux-framebuffer.png)

[Back to Top](#contents)

<a name="gstreamer"></a>

### GStreamer

On **HiGFXback**, _GStreamer_ interfaces for _Linux Framebuffer_ graphics backend are provided by:

* _**libgstreamer-0.10.so** library_ on _GStreamer 0.10_
* _**libgstreamer-1.0.so** library_ on _GStreamer 1_

and rely on _**libgstfbdevsink.so** plugin_ for output.

_**gst-launch-0.10**_ program is available as example on _GStreamer 0.10_.

![](screenshots/gstreamer-0.10-linux-framebuffer.png)

_**gst-launch-1.0**_ program is available as example on _GStreamer 1_.

![](screenshots/gstreamer-1.0-linux-framebuffer.png)

[Back to Top](#contents)

<a name="xine"></a>

### Xine

On **HiGFXback**, _Xine_ interfaces for _Linux Framebuffer_ graphics backend are provided by _**libxine.so** library_ and rely on _**xineplug_vo_out_fb.so** plugin_ for output.

_**xine-ui**_ program is available as example.

![](screenshots/xine-linux-framebuffer.png)

[Back to Top](#contents)

<a name="vlc"></a>

### VLC

On **HiGFXback**, _VLC_ interfaces for _Linux Framebuffer_ graphics backend are provided by _**libvlc.so** library_ and rely on _**libfb_plugin.so** plugin_ for output.

_**vlc**_ program is available as example.

![](screenshots/vlc-linux-framebuffer.png)

[Back to Top](#contents)

<a name="tools"></a>

# Tools

<a name="fbi-fim"></a>

### Fbi, FIM

![](screenshots/fbi-fim.png)

<a name="fbpdf"></a>

### Fbpdf

![](screenshots/fbpdf.png)

<a name="netsurf-links"></a>

### NetSurf, Links

![](screenshots/netsurf-links-linux-framebuffer.png)

<a name="fbff-mplayer"></a>

### Fbff, MPlayer

![](screenshots/fbff-mplayer-linux-framebuffer.png)

[Back to Top](#contents)

<a name="graphics-abstraction-layers"></a>

# Graphics abstraction layers

<a name="glut"></a>

### GLUT

On **HiGFXback**, _GLUT (openGL Utility Toolkit)_ interfaces running on _Linux Framebuffer_ graphics backend are provided by one of the following implementation selected with `alternatives-glut` command:

* _MesaGLUT_ with _**libglut.so `->` libmesaglut.so** library_
* _TinyGLUT_ with _**libglut.so `->` libtinyglut.so** library_

<p align="center"><img src="diagrams/fb-glut.png"></p>

For _OpenGL_ rendering, note that _EGL for Linux Framebuffer_ interfaces can also be used internally by _GLUT_ implementations instead of _GLFBDev_ interfaces.

_**mesa-demos**_ and _**yagears**_ programs are available as examples, tests or benchmarks.

![](screenshots/glut-linux-framebuffer.png)

[Back to Top](#contents)

<a name="sdl"></a>

### SDL

On **HiGFXback**, _SDL (Simple Directmedia Layer)_ interfaces running on _Linux Framebuffer_ graphics backend are provided by _**libSDL.so** library_.

<p align="center"><img src="diagrams/fb-sdl.png"></p>

For _OpenGL_ rendering, note that _EGL for Linux Framebuffer_ interfaces can also be used internally by _SDL_ instead of _GLFBDev_ interfaces.

_**SDL-test**_ and _**yagears**_ programs are available as examples, tests or benchmarks.

![](screenshots/sdl-linux-framebuffer.png)

[Back to Top](#contents)

<a name="user-interface-toolkits"></a>

# User interface toolkits

<a name="gtk"></a>

### GTK+

Graphical user interfaces can rely on _GTK+_ (Gimp ToolKit) using the port for _Linux Framebuffer_ graphics backend.
Web rendering can then rely on _WebKitGTK+_, a port of the WebKit browser engine for _GTK+_.

On **HiGFXback**, _GTK+_ interfaces running on _Linux Framebuffer_ graphics backend are provided by _**libgtk-2.0.so** and **libgtkgl-2.0.so** libraries_.

<p align="center"><img src="diagrams/fb-gtk.png"></p>

For _OpenGL_ rendering, note that _EGL for Linux Framebuffer_ interfaces can also be used internally by _GTK+_ instead of _GLFBDev_ interfaces.

_**gtk-demo**_, _**gtk-tests**_, _**gtkperf**_ and _**yagears**_ programs are available as examples, tests or benchmarks.

![](screenshots/gtk-linux-framebuffer.png)

On **HiGFXback**, _WebKitGTK+_ interfaces for _GTK+_ with _Linux Framebuffer_ graphics backend are provided by _**libwebkitgtk-2.0.so** library_.

<p align="center"><img src="diagrams/fb-webkitgtk.png"></p>

For _WebGL_ rendering, note that _EGL for Linux Framebuffer_ interfaces can also be used instead of _GLFBDev_ interfaces.

_**GtkLauncher**_ program is available as example.

![](screenshots/webkitgtk-linux-framebuffer.png)

[Back to Top](#contents)

<a name="qt"></a>

### Qt

Graphical user interfaces can rely on _Qt_ (Q toolKit) using the port for _Linux Framebuffer_ graphics backend.
Web rendering can then rely on _QtWebKit_, a port of the WebKit browser engine for _Qt_.

On **HiGFXback**, _Qt_ interfaces running on _Linux Framebuffer_ graphics backend are provided by _**libQtGui.so** and **libQtOpenGL.so** libraries_.

<p align="center"><img src="diagrams/fb-qt.png"></p>

For _OpenGL_ rendering, note that _EGL for Linux Framebuffer_ interfaces can also be used internally by _Qt_ instead of _GLFBDev_ interfaces.

_**qtdemo**_, _**qt-examples**_, _**qtperf**_ and _**yagears**_ programs are available as examples, tests or benchmarks.

![](screenshots/qt-linux-framebuffer.png)

On **HiGFXback**, _QtWebKit_ interfaces for _Qt_ with _Linux Framebuffer_ graphics backend are provided by _**libQtWebKit.so** library_.

<p align="center"><img src="diagrams/fb-qtwebkit.png"></p>

For _WebGL_ rendering, note that _EGL for Linux Framebuffer_ interfaces can also be used instead of _GLFBDev_ interfaces.

_**QtTestBrowser**_ program is available as example.

![](screenshots/qtwebkit-linux-framebuffer.png)

[Back to Top](#contents)

<a name="efl"></a>

### EFL

Graphical user interfaces can rely on _EFL_ (Enlightenment Foundation Libraries) with _Elementary_ using the port for _Linux Framebuffer_ graphics backend.

On **HiGFXback**, _EFL_ with _Elementary_ interfaces running on _Linux Framebuffer_ graphics backend are provided by _**libelementary.so** library_.

<p align="center"><img src="diagrams/fb-efl.png"></p>

For _OpenGL_ rendering, note that _EGL for Linux Framebuffer_ interfaces can also be used internally by _EFL_ with _Elementary_ instead of _GLFBDev_ interfaces.

_**elementary-test**_, _**elementary-examples**_ and _**yagears**_ programs are available as examples, tests or benchmarks.

![](screenshots/efl-elementary-linux-framebuffer.png)

[Back to Top](#contents)

<a name="applications"></a>

# Applications

| | |
--|--
![](diagrams/ffplay.png) | _**ffplay**_ multimedia player

![](screenshots/ffplay-linux-framebuffer.png)

| | |
--|--
![](diagrams/qemu.png) | _**qemu**_ machine emulator

![](screenshots/qemu-linux-framebuffer.png)

| | |
--|--
![](diagrams/midori.png) | _**midori**_ web browser

![](screenshots/midori-linux-framebuffer.png)

| | |
--|--
![](diagrams/qupzilla.png) | _**qupzilla**_ web browser

![](screenshots/qupzilla-linux-framebuffer.png)

| | |
--|--
![](diagrams/billardgl-gtktetris-pinball.png) | _**BillardGL, gtktetris, pinball**_ games

![](screenshots/billardgl-gtktetris-pinball-linux-framebuffer.png)

| | |
--|--
![](diagrams/chocolate-doom.png) | _**chocolate-doom**_ game engine

![](screenshots/chocolate-doom-linux-framebuffer.png)

[Back to Top](#contents)
