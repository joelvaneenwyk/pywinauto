#!/usr/bin/sh

set -eax

coverage run -m pytest \
    src/pywinauto/unittests/test_atspi_element_info.py \
    src/pywinauto/unittests/test_atspi_wrapper.py \
    src/pywinauto/unittests/test_atspi_controls.py \
    src/pywinauto/unittests/test_clipboard_linux.py \
    src/pywinauto/unittests/test_keyboard.py \
    src/pywinauto/unittests/test_application_linux.py
