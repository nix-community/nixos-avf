#!/usr/bin/env bash

HAS_ROOT=false
USE_SU=false
ROOT_CHECKED=false

_log_cmd() {
  echo " \$ $*" >&2
  "$@"
}

_adb() {
  _log_cmd adb ${ADB_FLAGS:-} "$@"
}

_enable_root() {
  if $ROOT_CHECKED; then
    return
  fi
  ROOT_CHECKED=true
  # check if debuggable, run "adb root" then
  _adb root || true
  if _adb shell id | grep "root" >/dev/null 2>/dev/null; then
    HAS_ROOT=true
    return
  fi
  # check if su exists, set USE_SU then
  if _adb shell "su -c id" | grep "root" >/dev/null 2>/dev/null; then
    HAS_ROOT=true
    USE_SU=true
    return
  fi
}

enable_root() {
  _enable_root >/dev/null
}

require_root() {
  enable_root
  if ! $HAS_ROOT; then
    echo "ERROR: no root found but script requires it" >&2
    exit 2
  fi
}

with_root() {
  require_root
  if $USE_SU; then
    _adb shell "su -c '$*'"
  else
    _adb shell "$@"
  fi
}
