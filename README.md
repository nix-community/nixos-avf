# nixos-avf

Android Virtualization Framework is a new virtualization environment for Android

Among others, it is used to provide the Terminal App starting from Android 15 QPR2

This profile contains the necesarry services and kernel configs to get it running under the Terminal app

The system changes have been taken from https://android.googlesource.com/platform/packages/modules/Virtualization/+/refs/heads/main/build/debian

# Downloading initial image

An initial image is currently provided under https://mkg20001.io/tmp/terminal/latest/aarch64/images.tar.gz

Proper CI will follow

# Building initial image

Assuming current folder is the root of this repo, build the following initial.nix

If the VM fails to start, include `./avf/debug.nix` and view the logs on a debuggable version of Android from the Terminal app (there is no better way currently)

# Using the image

You will need a debuggable android build. Place the image under /sdcard/linux/images.tar.gz

Currently Google doesn't provide a way to use custom images on production builds

If you have a way to get it working on a production build using root, open a PR
