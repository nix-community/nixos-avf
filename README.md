# nixos-avf

Android Virtualization Framework is a new virtualization environment for Android

Among others, it is used to provide the Terminal App starting from Android 15 QPR2

This profile contains the necesarry services and kernel configs to get it running under the Terminal app

The system changes have been taken from https://android.googlesource.com/platform/packages/modules/Virtualization/+/refs/heads/main/build/debian

[ » Chat on Matrix ](https://matrix.to/#/#nixos-avf:mkg20001.io)

# Installation using App

There is now an app that performs the installation steps for you.

Note that currently the guides in the README are out of sync as I'm busy with other things.

[ » App for easier installation ](https://github.com/mkg20001/nixos-avf-image-app/releases)

If you have any problems, feel free to join the Matrix Chat

# Downloading initial image

[ » Download nixos-unstable aarch64 image ](https://github.com/nix-community/nixos-avf/releases/download/nixos-unstable/image-unstable-aarch64.tar.gz)

[ » Other architectures/releases ](https://github.com/nix-community/nixos-avf/releases)

# Building initial image (optional, for development)

> [!IMPORTANT]
> You will need an arm64 image for most phones. To build an arm64 image on a x86_64 system, run `export CROSS_SYSTEM=aarch64_linux` before running nix-build
>
> You will need to either [ » emulate aarch64 ](https://nixos-and-flakes.thiscute.world/development/cross-platform-compilation#compile-through-emulated-system) or add [ » a remote builder ](https://nix.dev/tutorials/nixos/distributed-builds-setup.html#set-up-distributed-builds) that supports aarch64.

Assuming current folder is the root of this repo, build the following: `nix-build initial.nix -A config.system.build.avfImage`

Copy the result file to `/sdcard/linux/images.tar.gz` on your phone.

If the VM fails to start, include `./avf/debug.nix` and view the logs on a debuggable version of Android from the Terminal app (there is no better way currently)

# Enabling the Terminal App

If you don't have enabled the Terminal App already you need to enable it in the Developer Options.

Go to Settings > System > Developer Options > Linux development environment (it's close to USB Debugging in the list)

If you don't have Developer Options enabled [ » read how to do it here ](https://developer.android.com/studio/debug/dev-options)

# Using the image

> [!NOTE]
> After installation of the image you want to expand the disk as you will run into space problems during rebuild otherwise.
>
> You can resize the disk under "Settings (Gear) > Disk resize". We recommend 8 GB or more.

> [!IMPORTANT]
> The image only works on Android 16+ ([ » Beta Program ](https://www.google.com/android/beta)) and on Android 15 flavours that have the Android 16 Terminal patches backported (example: GrapheneOS)

## Debuggable android

You will need a debuggable android build also known as userdebug (eng build also works)

Place the image under /sdcard/linux/images.tar.gz or use scripts/android-download-vm.sh to download and copy the latest image.

Delete existing VM configuration either via app (Settings > Recovery) or via scripts/android-clean-vm.sh

Restart the terminal app. You should get a popup saying "Auto installing" and the Terminal should automatically use your image.

## Production android build

### Without root

_todo, help needed_

### With root

Magisk:

```sh
adb shell "su -c 'rm -rfv /data/data/com.android.virtualization.terminal/{files/nixos.log,files/debian.log,files/linux,vm/nixos,vm/debian}'" # clean
adb shell "su -c 'magisk resetprop ro.debuggable 1; stop; start;'" # enable debuggable
adb shell "su -c 'rm -f /data/media/0/linux/images.tar.gz'"
adb shell "su -c 'wget https://github.com/nix-community/nixos-avf/releases/download/nixos-unstable/image-unstable-aarch64.tar.gz -O /data/media/0/linux/images.tar.gz'"
```

Then launch the terminal app. It should auto-install.

After installation is finished you can revert the changes to ro.debuggable.

# Debugging/Common errors

## "Connection to terminal timed out"

Try restarting the app. Try re-installing the image if that doesn't help.

### With root

Check /data/data/com.android.virtualization.terminal/files/nixos.log

If the log contains `EFI boot manager: Cannot load any image` or is missing any systemd messages like "Started xyz.service..." then the image might be corrupted

Run `adb shell rm -rfv /data/data/com.android.virtualization.terminal/{files/nixos.log,files/debian.log,files/linux,vm/nixos,vm/debian}` to clear up any remnants of previous installs, then install the image again

## Terminal crashes on rebuild or other memory heavy activity

The VM has a 4 GB allocation of memory. This allocation does not represent the RAM the VM can actually physically use, only the maximum amount of memory it will be given from the host system under any condition.

That means while the VM may think it has 4 GB of RAM available, there may not be enough physical memory available on the Phone itself.

If the host memory runs full, the guest will crash.

For rebuilds you can split up the rebuild into evaluation and build+switch. Just run `sudo nixos-rebuild dry-build` and only afterwards `sudo nixos-rebuild switch`. This usually works even on low-memory systems.
