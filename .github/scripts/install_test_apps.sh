#!/usr/bin/env bash

set -eax

REPO_ROOT="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" &>/dev/null && cd ../../ && pwd)"

cd "$REPO_ROOT/apps/MouseTester/source"
qmake
make
chmod a+x mousebuttons
cp mousebuttons "$REPO_ROOT/apps/MouseTester"

cd "$REPO_ROOT/apps/SendKeysTester/source"
qmake
make
chmod a+x send_keys_test_app
cp send_keys_test_app "$REPO_ROOT/apps/SendKeysTester"

export XDG_RUNTIME_DIR=/tmp/runtime-runner
