#!/bin/bash

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

set -e

user=$(adb -d shell am get-current-user)

# Identify file to download
arch=$(adb -d shell getprop ro.bionic.arch)
if [ ${arch} == "arm64" ]; then
  src=https://mkg20001.io/tmp/terminal/latest/aarch64/images.tar.gz
else
  src=https://mkg20001.io/tmp/terminal/latest/x86_64/images.tar.gz
fi

# Download
downloaded=$(mktemp)
wget ${src} -O ${downloaded}

# Push the file to the device
dst=/data/media/${user}/linux
adb -d shell mkdir -p ${dst}
adb -d push ${downloaded} ${dst}/images.tar.gz
