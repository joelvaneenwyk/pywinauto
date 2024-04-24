#!/usr/bin/sh

python -m pip install --upgrade pip
sudo apt update -y
sudo apt upgrade
sudo apt install -y --no-install-recommends python-setuptools tk-dev python-tk
sudo apt install -y --no-install-recommends python3 python3-pip python3-setuptools
sudo apt install -y --no-install-recommends python-xlib
sudo apt install -y --no-install-recommends xsel
sudo apt install -y libjavascriptcoregtk-4.0-18
pip install coverage codecov
pip install python-xlib --upgrade
pip install mock --upgrade
python -m pip install pytest
sudo apt install -y build-essential libssl-dev
sudo apt install -y qt5-default
sudo apt install -y libxkbcommon-x11-0
sudo apt install -y python3-gi gobject-introspection gir1.2-gtk-3.0
sudo apt install -y at-spi2-core
sudo apt install -y python3-pyatspi
sudo apt install -y xvfb x11-utils libxkbcommon-x11-0 \
    libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 \
    libxcb-render-util0 libxcb-xinerama0 libxcb-xfixes0 xdotool
#pip3 install scikit-build # required for cmake>=3.23.0
pip3 install cmake==3.22.6
