Welcome to [**HiGFXback**](README.md) with the _KMS/DRM_ graphics backend!

<a name="contents">

# Contents

* [Getting started](#getting-started)
  * [Kmscon](#kmscon)
  * [drm-tests, drm-howto](#drm-tests-drm-howto)
  * [evtest, libevdev-events](#evtest-libevdev-events)
* [OpenGL rendering](#opengl-rendering)

<a name="getting-started">

# Getting started

Components running on _KMS/DRM_ graphics backend just use the _DRM_ (Direct Rendering Manager) graphics driver interface (`/dev/dri/card0`) accessible through the _**libdrm.so** library_. As they directly access the memory of the display device, there is no compositing windowing system.

If the current graphics backend used on **HiGFXback** is not _KMS/DRM_, switch on it with `startdrm` command.

<p align="center"><img src="drm.png"></p>

Components running on _KMS/DRM_ graphics backend directly handle keyboard and mouse input events with the _event device_ input driver interface (`/dev/input/event0` and `/dev/input/event1`) available on **HiGFXback**.

But depending on the input peripheral, it's possible to use specific input driver interfaces if supported by the component running on the _KMS/DRM_ graphics backend.

Note that _event device_ input driver interface is also accessible through the _**libevdev.so** library_.

<a name="kmscon">

### Kmscon

When starting on _KMS/DRM_ graphics backend, _**kmscon**_ terminal emulator is displayed.
System informations about _KMS/DRM_ settings can be get with _**modetest**_.

![](kmscon.png)

[Back to Top](#contents)

<a name="drm-tests-drm-howto">

### drm-tests, drm-howto

Programs running on _KMS/DRM_ graphics backend are available as examples, tests or benchmarks.

> modetest -s 23:1024x768

> modeset

![](drm-tests-drm-howto.png)

[Back to Top](#contents)

<a name="evtest-libevdev-events">

### evtest, libevdev-events

Programs are available for testing _event device_ input interfaces used by components running on _KMS/DRM_ graphics backend.

![](evtest-libevdev-events.png)

[Back to Top](#contents)

<a name="opengl-rendering">

# OpenGL rendering

For display rendering with _KMS/DRM_ graphics backend, _OpenGL_ implementation in _**libGL.so** library_, but also _OpenGL ES 1.1 CM_ implementation in _**libGLESv1_CM.so** library_ and _OpenGL ES 2.0_ implementation in _**libGLESv2.so** library_, rely on _EGL for KMS/DRM_ interface through _GBM_ (Generic Buffer Management) with the _**libgbm.so** library_.

Loading libraries can be used:
  * _**libGLEW.so** library_ from _GLEW_ (OpenGL Extension Wrangler)
  * _**libepoxy.so** library_ from _Epoxy_

On **HiGFXback**, _EGL for KMS/DRM_ interfaces are used with one of the following implementation selected with `alternatives-GL` command:
  * _Mesa_ with _**libEGL.so `->` libmesaEGL.so**, **libGL.so `->` libmesaGL.so**, **libGLESv1_CM.so `->` libmesaGLESv1_CM.so**, **libGLESv2.so `->` libmesaGLESv2.so** libraries_
  * _SwiftShader_ with _**libEGL.so `->` libswiftshaderEGL.so**, **libGLESv1_CM.so `->` libswiftshaderGLESv1_CM.so**, **libGLESv2.so `->` libswiftshaderGLESv2.so** libraries_

But depending on the platform, specific implementation can be used.

<p align="center"><img src="drm-egl.png"></p>

_**mesa-demos**_ and _**yagears**_ programs are available as examples, tests or benchmarks.

> /drm/share/mesa-demos/eglkms

> yagears -b egl-drm -e gl

> yagears -b egl-drm -e glesv1_cm

> yagears -b egl-drm -e glesv2

![](egl-kms-drm.png)

[Back to Top](#contents)
