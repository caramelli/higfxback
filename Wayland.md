Welcome to [**HiGFXback**](README.md) with the _Wayland_ graphics backend!

<a name="contents">

# Contents

* [Getting started](#getting-started)
  * [weston-terminal](#weston-terminal)
  * [weston-clients](#weston-clients)
* [Vulkan rendering](#vulkan-rendering)
* [OpenGL rendering](#opengl-rendering)
* [Drawing libraries](#drawing-libraries)
  * [Cairo](#cairo)
  * [Evas](#evas)
* [Tools](#tools)
  * [weston-image](#weston-image)
  * [NetSurf](#netsurf)
  * [mpv](#mpv)
* [Graphics abstraction layers](#graphics-abstraction-layers)
  * [GLUT](#glut)
  * [SDL](#sdl)
  * [GLFW](#glfw)
* [User interface toolkits](#user-interface-toolkits)
  * [GTK+](#gtk)
  * [Qt](#qt)
  * [EFL](#efl)
* [Applications](#applications)

<a name="getting-started">

# Getting started

Components running on _Wayland_ graphics backend are based on _**libwayland-client.so** library_ for the communication with _**weston**_, the _Wayland_ compositor.

If the current graphics backend used on **HiGFXback** is not _Wayland_, switch on it with `startwl` command. Select one of the following graphics driver interface available on **HiGFXback** and used by _**weston**_ for the display:
  * _Linux Framebuffer_ interface (`/dev/fb0`) with _**weston fbdev-backend.so** plugin_
  * _KMS/DRM_ interface with (`/dev/dri/card0`) _**weston drm-backend.so** plugin_

But depending on the platform, it's possible to use specific graphics driver interfaces based on the _**weston** backend module_ architecture.

<p align="center"><img src="wl.png"></p>

Keyboard and mouse are managed by _**weston**_ with _**libinput.so** library_ which provides a generic input abstraction layer of the _event device_ input driver interface (`/dev/input/event0` and `/dev/input/event1`) available on **HiGFXback**.

<a name="weston-terminal">

### weston-terminal

When starting on _Wayland_ graphics backend, _**weston-terminal**_ terminal emulator is displayed.
System informations about _Wayland_ settings can be get with _**weston-info**_.

![](weston-terminal.png)

[Back to Top](#contents)

<a name="weston-clients">

### weston-clients

Programs running on _Wayland_ graphics backend are available as examples, tests or benchmarks.

![](weston-clients.png)

[Back to Top](#contents)

<a name="vulkan-rendering">

# Vulkan rendering

For display rendering with _Wayland_ graphics backend, _Vulkan_ implementation in _**libvulkan.so** library_ (loading library from _Vulkan-Loader_) and its ICD (Installable Client Driver) relies on _Wayland WSI_ interface.

On **HiGFXback**, _Wayland WSI_ interfaces (Window System Integration for _Wayland_) are used with one of the following ICD selected with `VK_ICD_FILENAMES` environment variable:
  * _SwiftShader_ associated to _**swiftshader_icd.json** manifest file_
  * _Kazan_ associated to _**kazan_icd.json** manifest file_

But depending on the platform, specific ICD can be used.

<p align="center"><img src="wl-vulkan.png"></p>

_**Vulkan-Tools**_, _**Vulkan-Examples**_ and _**yagears2**_ programs are available as examples, tests or benchmarks.

![](vulkan-wayland.png)

[Back to Top](#contents)

<a name="opengl-rendering">

# OpenGL rendering

For display rendering with _Wayland_ graphics backend, _OpenGL_ implementation in _**libGL.so** library_, but also _OpenGL ES 1.1 CM_ implementation in _**libGLESv1_CM.so** library_ and _OpenGL ES 2.0_ implementation in _**libGLESv2.so** library_, rely on _EGL for Wayland_ interface.

Loading libraries can be used:
  * _**libGLEW.so** library_ from _GLEW_ (OpenGL Extension Wrangler)
  * _**libepoxy.so** library_ from _Epoxy_

On **HiGFXback**, _EGL for Wayland_ interfaces are used with one of the following implementation selected with `alternatives-GL` command:
  * _Mesa_ with _**libEGL.so `->` libmesaEGL.so**, **libGL.so `->` libmesaGL.so**, **libGLESv1_CM.so `->` libmesaGLESv1_CM.so**, **libGLESv2.so `->` libmesaGLESv2.so** libraries_
  * _SwiftShader_ with _**libEGL.so `->` libswiftshaderEGL.so**, **libGLESv1_CM.so `->` libswiftshaderGLESv1_CM.so**, **libGLESv2.so `->` libswiftshaderGLESv2.so** libraries_

But depending on the platform, specific implementation can be used.

<p align="center"><img src="wl-egl.png"></p>

_**mesa-demos**_ and _**yagears**_ programs are available as examples, tests or benchmarks.

![](egl-wayland.png)

[Back to Top](#contents)

<a name="drawing-libraries">

# Drawing libraries

<a name="cairo">

### Cairo

On **HiGFXback**, _Cairo_ interfaces for _Wayland_ graphics backend are provided by _**libcairo.so** library_.

<p align="center"><img src="wl-cairo-wayland-shm.png"></p>

_**cairo-demos**_ programs are available as examples, tests or benchmarks.

![](cairo-wayland.png)

[Back to Top](#contents)

<a name="evas">

### Evas

On **HiGFXback**, _Evas_ interfaces for _Wayland_ graphics backend are provided by _**libevas.so** library_.

<p align="center"><img src="wl-evas-wayland-shm.png"></p>

_**expedite**_ program is available as examples, tests or benchmarks.

![](evas-wayland.png)

[Back to Top](#contents)

<a name="tools">

# Tools

<a name="weston-image">

### weston-image

![](weston-image.png)

<a name="netsurf">

### NetSurf

![](netsurf-wayland.png)

<a name="mpv">

### mpv

![](mpv-wayland.png)

[Back to Top](#contents)

<a name="graphics-abstraction-layers">

# Graphics abstraction layers

<a name="glut">

### GLUT

On **HiGFXback**, _GLUT (openGL Utility Toolkit)_ interfaces running on _Wayland_ graphics backend are provided by one of the following implementation selected with `alternatives-glut` command:
  * _FreeGLUT_ with _**libglut.so `->` libfreeglut.so** library_
  * _TinyGLUT_ with _**libglut.so `->` libtinyglut.so** library_

<p align="center"><img src="wl-glut.png"></p>

_**mesa-demos**_ and _**yagears**_ programs are available as examples, tests or benchmarks.

![](glut-wayland.png)

[Back to Top](#contents)

<a name="sdl">

### SDL

On **HiGFXback**, _SDL (Simple Directmedia Layer)_ interfaces running on _Wayland_ graphics backend are provided by _**libSDL2.so** library_.

<p align="center"><img src="wl-sdl.png"></p>

_**SDL2-test**_ and _**yagears2**_ programs are available as examples, tests or benchmarks.

![](sdl2-wayland.png)

[Back to Top](#contents)

<a name="glfw">

### GLFW

On **HiGFXback**, _GLFW (Graphics Library FrameWork)_ interfaces running on _Wayland_ graphics backend are provided by _**libglfw.so** library_.

<p align="center"><img src="wl-glfw.png"></p>

_**GLFW-examples**_ and _**yagears2**_ programs are available as examples, tests or benchmarks.

![](glfw-wayland.png)

[Back to Top](#contents)

<a name="user-interface-toolkits">

# User interface toolkits

<a name="gtk">

### GTK+

Graphical user interfaces can rely on _GTK+_ (Gimp ToolKit) using the port for _Wayland_ graphics backend.
Web rendering can then rely on _WebKitGTK+_, a port of the WebKit browser engine for _GTK+_.

On **HiGFXback**, _GTK+_ interfaces running on _Wayland_ graphics backend are provided by _**libgtk-3.0.so** library_ (which also integrates OpenGL rendering interfaces).

<p align="center"><img src="wl-gtk.png"></p>

_**gtk-demo**_, _**gtk-tests**_, _**gtkperf**_ and _**yagears**_ programs are available as examples, tests or benchmarks.

![](gtk-wayland.png)

On **HiGFXback**, _WebKitGTK+_ interfaces for _GTK+_ with _Wayland_ graphics backend are provided by _**libwebkitgtk-3.0.so** library_.

<p align="center"><img src="wl-webkitgtk.png"></p>

_**GtkLauncher**_ program is available as example.

![](webkitgtk-wayland.png)

[Back to Top](#contents)

<a name="qt">

### Qt

Graphical user interfaces can rely on _Qt_ (Q toolKit) using the port for _Wayland_ graphics backend.
Web rendering can then rely on _QtWebKit_, a port of the WebKit browser engine for _Qt_.

On **HiGFXback**, _Qt_ interfaces running on _Wayland_ graphics backend are provided by _**libQt5Gui.so** and **libQt5OpenGL.so** libraries_.

<p align="center"><img src="wl-qt.png"></p>

_**qtdemo**_, _**qt-examples**_, _**qtperf**_ and _**yagears**_ programs are available as examples, tests or benchmarks.

![](qt-wayland.png)

On **HiGFXback**, _QtWebKit_ interfaces for _Qt_ with _Wayland_ graphics backend are provided by _**libQt5WebKit.so** library_.

<p align="center"><img src="wl-qtwebkit.png"></p>

_**QtTestBrowser**_ program is available as example.

![](qtwebkit-wayland.png)

[Back to Top](#contents)

<a name="efl">

### EFL

Graphical user interfaces can rely on _EFL_ (Enlightenment Foundation Libraries) with _Elementary_ using the port for _Wayland_ graphics backend.

On **HiGFXback**, _EFL_ with _Elementary_ interfaces running on _Wayland_ graphics backend are provided by _**libelementary.so** library_.

<p align="center"><img src="wl-efl.png"></p>

_**elementary-test**_, _**elementary-examples**_ and _**yagears**_ programs are available as examples, tests or benchmarks.

![](efl-elementary-wayland.png)

[Back to Top](#contents)

<a name="applications">

# Applications

| | |
--|--
![](ffplay.png) | _**ffplay**_ multimedia player

![](ffplay-wayland.png)

| | |
--|--
![](qemu.png) | _**qemu**_ machine emulator

![](qemu-wayland.png)

| | |
--|--
![](midori.png) | _**midori**_ web browser

![](midori-wayland.png)

| | |
--|--
![](qupzilla.png) | _**qupzilla**_ web browser

![](qupzilla-wayland.png)

[Back to Top](#contents)
