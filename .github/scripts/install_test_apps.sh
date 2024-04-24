#!/usr/bin/sh

set -eax

git init apps
cd apps
git remote add -f origin https://github.com/pywinauto/PywinautoTestapps/
git config core.sparseCheckout true
echo "MouseTester/source" >>.git/info/sparse-checkout
echo "SendKeysTester/source" >>.git/info/sparse-checkout
git pull origin master
cd MouseTester/source
qmake
make
chmod a+x mousebuttons
cp mousebuttons ../
cd ../..
cd SendKeysTester/source
qmake
make
chmod a+x send_keys_test_app
cp send_keys_test_app ../
export XDG_RUNTIME_DIR=/tmp/runtime-runner
