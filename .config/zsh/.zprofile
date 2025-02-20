# shellcheck shell=bash

# Alacritty (Wayland, Nvidia)
#  - Hotfix based on https://github.com/NVIDIA/egl-wayland/issues/41
#  - See also this issue: https://github.com/alacritty/alacritty/issues/3587
#  - https://wiki.archlinux.org/title/wayland
[[ "$(command -v alacritty)" ]] &&
  [[ "${XDG_SESSION_TYPE:-}" == wayland ]] &&
  [[ "$(command -v nvidia-smi)" ]] &&
  [[ -f /usr/share/glvnd/egl_vendor.d/50_mesa.json ]] &&
  #export GBM_BACKEND=nvidia-drm &&
  #export __NV_PRIME_RENDER_OFFLOAD=1 &&
  #export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0 &&
  #export __GLX_VENDOR_LIBRARY_NAME=nvidia &&
  export __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json
