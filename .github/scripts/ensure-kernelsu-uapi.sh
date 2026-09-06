#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <kernel-platform-root>" >&2
  exit 2
fi

kernel_root=$1
ksu_root="$kernel_root/KernelSU"
source_dir="$ksu_root/uapi"
include_dir="$ksu_root/kernel/include/uapi"

if [ ! -f "$source_dir/app_profile.h" ]; then
  echo "::warning::$source_dir/app_profile.h not found (variant may not ship UAPI headers); downloading from Official KernelSU upstream."
  mkdir -p "$source_dir"
  if ! curl -fsSL -o "$source_dir/app_profile.h" \
    "https://raw.githubusercontent.com/tiann/KernelSU/main/uapi/app_profile.h"; then
    echo "::error::Failed to download Official KernelSU UAPI app_profile.h" >&2
    exit 1
  fi
  echo "Downloaded Official KernelSU UAPI app_profile.h to $source_dir/"
fi

if [ ! -f "$include_dir/app_profile.h" ]; then
  echo "Official KernelSU UAPI symlink is unavailable; materializing UAPI headers."
  if [ -L "$include_dir" ] || [ -f "$include_dir" ]; then
    rm -f "$include_dir"
  fi
  mkdir -p "$include_dir"
  cp -a "$source_dir"/. "$include_dir"/
  echo "Official KernelSU UAPI headers materialized at $include_dir."
fi

if [ ! -f "$include_dir/app_profile.h" ]; then
  echo "::error::Unable to expose Official KernelSU UAPI headers at $include_dir" >&2
  exit 1
fi
