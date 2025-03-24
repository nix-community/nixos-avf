#!/bin/sh

# Deletes all data created by previous VMs
# Requires debuggable build

adb root
adb shell rm -rfv /data/data/com.android.virtualization.terminal/{files/nixos.log,files/debian.log,files/linux,vm/nixos,vm/debian}

