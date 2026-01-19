#!/bin/bash

set -euxo pipefail

if [ -e /sdcard ]; then
  echo "DO NOT RUN THIS SCRIPT DIRECTLY ON ANDROID"
  echo "IT IS ONLY INTENDED TO BE RAN IN THE AVF VM"
  exit 2
fi

IMG_LOC=/mnt/shared/image
if [ -e "/mnt/shared/Download/image" ]; then
  IMG_LOC=/mnt/shared/Download/image
fi
VM_LOC=/mnt/internal/linux
LOGFILE=/mnt/shared/nixos-avf.log

: >> "$LOGFILE"

if command -v perl >/dev/null; then
  exec \
    1> >(tee >(perl '-MPOSIX' -ne '$|++; print strftime("%m.%d.%Y %H:%M:%S %z: ", localtime()), "stdout: ", $_;' >> "$LOGFILE")) \
    2> >(tee >(perl '-MPOSIX' -ne '$|++; print strftime("%m.%d.%Y %H:%M:%S %z: ", localtime()), "stderr: ", $_;' >> "$LOGFILE") >&2)
else
  exec \
    1> >(tee >(awk '{ system(""); print strftime("%m.%d.%Y %H:%M:%S %z:"), "stdout:", $0; system(""); }' >> "$LOGFILE")) \
    2> >(tee >(awk '{ system(""); print strftime("%m.%d.%Y %H:%M:%S %z:"), "stderr:", $0; system(""); }' >> "$LOGFILE") >&2)
fi

echo "deploy running, VM_LOC=$VM_LOC, IMG_LOC=$IMG_LOC"

STEP_MARKER="$HOME/step_2"
SELF=$(readlink -f $0)

# Only adds vda3
step_1() {
  echo "deploy step 1"

  BEFORE=$(echo -e '],\n            "writable": true')
  # variables are from crosvm not bash
  # shellcheck disable=SC2016
  AFTER=$(echo -e ',{"label":"nixos", "path": "$PAYLOAD_DIR/nixos_root", "writable": true, "guid": "13ac699a-4b83-4618-923d-b69fe90e379e"}],\n            "writable": true')

  sudo truncate -s 12GiB "$VM_LOC/nixos_root"

  if sudo test -e "$VM_LOC/root_part_backup"; then
    sudo mv -v "$VM_LOC/root_part_backup" "$VM_LOC/root_part_backup_"
  fi

  # TODO: use deterministic nixos root guid
  VM_CONFIG=$(sudo cat "$VM_LOC/vm_config.json")
  VM_REPLACED=${VM_CONFIG/"$BEFORE"/"$AFTER"}
  echo "$VM_REPLACED" | sudo tee "$VM_LOC/vm_config.json"

  echo "flock -w 1 /tmp/install-lock bash $SELF" >> "$HOME/.bashrc"
  echo "tail -f $LOGFILE" >> "$HOME/.bashrc"

  touch "$STEP_MARKER"

  sudo reboot
}

# This replaces uefi, etc
step_2() {
  echo "deploy step 2"
  VDA_ROOT=/dev/vda3
  if [ ! -e "$VDA_ROOT" ]; then
    VDA_ROOT=/dev/vda2
  fi

  echo "=== debug ==="
  lsblk
  cat "$VM_LOC/vm_config.json"
  echo "=/= debug =/="

  sudo chmod 777 "$VDA_ROOT"
  size=$(du "$IMG_LOC/root_part" | grep -o "[0-9]*")
  iters=$(( size / ( 1024 * 250 ) ))
  for i in $(seq 0 $iters); do
    dd "if=$IMG_LOC/root_part" "of=$VDA_ROOT" bs=250M count=1 "seek=$i" "skip=$i"
    sync
  done
  # dd "if=$IMG_LOC/root_part" "of=$VDA_ROOT" bs=250M oflag=sync

  cp "$IMG_LOC/efi_part" .
  sudo umount /boot/efi || true
  sudo umount /kernel_extras || true
  sudo rm -f "$VM_LOC/efi_part" "$VM_LOC/kernel_extras" "$VM_LOC/vmlinuz" "$VM_LOC/initrd.img"
  sync
  sleep 3s
  sudo dd if=efi_part bs=1G oflag=direct "of=$VM_LOC/efi_part"
  sync

  # NOTE: we can't just copy root_part as virtiofs from crosvm seems to
  # magically break in most circumstances that involve larger writes
  # We somehow made it work for efi and

  cp "$IMG_LOC/vm_config.json" .
  sudo cp vm_config.json "$VM_LOC/vm_config.json"

  cp "$IMG_LOC/build_id" .
  sudo cp build_id "$VM_LOC/build_id"

  sudo rm "$VM_LOC/root_part"
  sudo mv "$VM_LOC/nixos_root" "$VM_LOC/root_part"

  rm -rfv "$IMG_LOC"

  if sudo test -e "$VM_LOC/root_part_backup_"; then
    sudo mv -v "$VM_LOC/root_part_backup_" "$VM_LOC/root_part_backup"
  fi

  sudo reboot
}

if [ ! -e "$STEP_MARKER" ]; then
  step_1
else
  step_2
fi
