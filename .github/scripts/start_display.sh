#!/usr/bin/env bash

set -eax

sudo /usr/bin/Xvfb "${DISPLAY:-":0"}" -screen 0 1280x1024x24 &
sleep 5

set +eE

sudo apt install -y gdm3
sudo service gdm start
sleep 5
