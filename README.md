# nixos-avf

Android Virtualization Framework is a new virtualization environment for Android

Among others, it is used to provide the Terminal App starting from Android 15 QPR2

This profile contains the necesarry services and kernel configs to get it running under the Terminal app

The system changes have been taken from https://android.googlesource.com/platform/packages/modules/Virtualization/+/refs/heads/main/build/debian

[ » Chat on Matrix ](https://matrix.to/#/#nixos-avf:mkg20001.io)

# Downloading initial image

[ » Download nixos-unstable aarch64 image ](https://github.com/nix-community/nixos-avf/releases/download/nixos-unstable/image-unstable-aarch64.tar.gz)

[ » Other architectures/releases ](https://github.com/nix-community/nixos-avf/releases)

# Building initial image

Assuming current folder is the root of this repo, build the following: `nix-build initial.nix -A config.system.build.toplevel`

If the VM fails to start, include `./avf/debug.nix` and view the logs on a debuggable version of Android from the Terminal app (there is no better way currently)

# Using the image

NOTE: After installation of the image you want to expand the disk as you will run into space problems during rebuild otherwise.

You can resize the disk under "Settings (Gear) > Disk resize". We recommend 8 GB or more.

## Debuggable android

You will need a debuggable android build also known as userdebug (eng build also works)

Place the image under /sdcard/linux/images.tar.gz or use scripts/android-download-vm.sh to download and copy the latest image.

Delete existing VM configuration either via app (Settings > Recovery) or via scripts/android-clean-vm.sh

Restart the terminal app. You should get a popup saying "Auto installing" and the Terminal should automatically use your image.

## Production android build

### Without root

_todo, help needed_

### With root

_todo, help needed_
