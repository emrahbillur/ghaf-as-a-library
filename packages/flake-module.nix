# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{inputs, ...}: {
  flake.overlays.own-pkgs-overlay = final: _prev: {
    jetson-stats = final.callPackage ./jetson-stats/jetson-stats.nix {};
  };
}
