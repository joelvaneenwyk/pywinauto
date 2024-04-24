#!/usr/bin/sh

set -eax

coverage run -m pytest pywinauto/unittests/test_atspi_element_info.py pywinauto/unittests/test_atspi_wrapper.py pywinauto/unittests/test_atspi_controls.py pywinauto/unittests/test_clipboard_linux.py pywinauto/unittests/test_keyboard.py pywinauto/unittests/test_application_linux.py
