#!/bin/sh

# Deletes all data created by previous VMs

adb shell "su -c 'rm -rfv /data/data/com.android.virtualization.terminal/{files/nixos.log,files/debian.log,files/linux,vm/nixos,vm/debian}'"
