#!/usr/bin/sh

set -eax

_install() {
    sudo apt-get update -y && sudo apt-get upgrade -y

    sudo apt-get install -y --no-install-recommends \
        python-setuptools tk-dev python-tk \
        python3 python3-pip python3-setuptools

    sudo apt-get install -y --no-install-recommends \
        xsel \
        libjavascriptcoregtk-4.0-18 \
        build-essential libssl-dev mesa-common-dev \
        libxkbcommon-x11-0 \
        python3-gi gobject-introspection gir1.2-gtk-3.0 \
        at-spi2-core \
        xvfb x11-utils libxkbcommon-x11-0 \
        libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 \
        libxcb-render-util0 libxcb-xinerama0 libxcb-xfixes0 xdotool

    # 'qt5-default' is deprecated and no longer available in Ubuntu 21.04+
    sudo apt-get install -y --no-install-recommends \
        qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools

    sudo apt-get install -y --no-install-recommends python3-pyatspi
    sudo apt-get update -y && sudo apt-get upgrade -y
}

_install_python_packages() {
    python3 -m pip install --upgrade \
        pip python-xlib mock

    # 'scikit-build' is required for cmake>=3.23.0
    python3 -m pip install \
        coverage codecov \
        pytest \
        scikit-build cmake==3.22.6
}

_install
_install_python_packages
