#!/usr/bin/env bash

# Copyright 2024 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

SELF=$(dirname "$(readlink -f "$0")")
. "$SELF/_common.sh"
ADB_FLAGS="-d"

require_root

user=$(_adb shell am get-current-user)

# Identify file to download
arch=$(with_root getprop ro.bionic.arch)
if [ ${arch} == "arm64" ]; then
  src=https://github.com/nix-community/nixos-avf/releases/download/nixos-unstable/image-unstable-aarch64.tar.gz
else
  src=https://github.com/nix-community/nixos-avf/releases/download/nixos-unstable/image-unstable-x86_64.tar.gz
fi

# Download
downloaded=$(mktemp)
# NOTE: wget can run on device where available, we can implement this later
wget ${src} -O ${downloaded}

# Push the file to the device
dst=/data/media/${user}/linux
_adb shell mkdir -p ${dst}
_adb push ${downloaded} ${dst}/images.tar.gz
