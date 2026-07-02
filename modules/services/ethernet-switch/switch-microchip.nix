
# Copyright 2022-2023 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.ghaf.hardware.nvidia.orin;

  evbLan9646 = pkgs.fetchFromGitHub {
    owner  = "Microchip-Ethernet";
    repo   = "EVB-LAN9646";
    rev    = "main";     # pin to a commit you trust
    sha256 = "sha256-qqhGqraghXzIrdeVw6KiI2c3kuvT0Qsll218fRqYS5Q=";
  };

  # Patches for 5.15 kernels
  patchesDir_5_15 = "${evbLan9646}/ung_apps_external/patches/linux-linux4microchip-2023.04";
  # Patches for 6.6 kernels
  patchesDir_6_6 = "${evbLan9646}/ung_apps_external/patches/linux-linux4microchip-2024.04";
  # Patches for 6.12 kernels - for later use
  patchesDir_6_12 = "${evbLan9646}/ung_apps_external/patches/linux-linux4microchip-2025.04";

  # Patch series builder
  mkPatchSeries = dir:
    let
      include = [
        "003-ksz.patch"
        "004-ksz_cfg.patch"
        "009-bridge.patch"
        "104-ksz_dsa_add_ksz8567.patch"
        "105-ksz_dsa_eee_fix.patch"
        "106-ksz_dsa_ksz8795_static_mac_fix.patch"
        "107-ksz_dsa_lan937x_ibs_fix.patch"
        "108-ksz_dsa_add_ksz8895.patch"
        "110-ksz_dsa_ksz9477_detect_fix.patch"
        "113-ksz_dsa_add_lan9646.patch"
        "115-ksz_dsa_phylink_fix.patch"
        "117-ksz_dsa_ksz8795_fix.patch"
        "118-ksz_dsa_ksz8895_vlan_fix.patch"
        "121-ksz_dsa_ksz8863_rx_drop_fix.patch"
        "122-ksz_dsa_ksz8863_reset_fix.patch"
      ];

      names =
        lib.sort (a: b: a < b)
          (lib.filter (n: lib.elem n include)
            (builtins.attrNames (builtins.readDir dir)));
    in
      map (n: { name = "mchp-${n}"; patch = "${dir}/${n}"; }) names;

  kernelVersion = config.hardware.nvidia-jetpack.kernel.version or "bsp-default";

  # Needed for your original BSP patch mapping
  l4t = pkgs.nvidia-jetpack.l4tMajorMinorPatchVersion;

  selectedPatches =
    if kernelVersion == "bsp-default" then
      [
        {
          name = "microchip-kernel-patch";
          patch = {
            "36.4.3" = ./microchip-ksz9477s/36.4/0001-Disable-DSA-from-microchip-9477-switch.patch;
            "36.4.4" = ./microchip-ksz9477s/36.4/0001-Disable-DSA-from-microchip-9477-switch.patch;
            "36.5.0" = ./microchip-ksz9477s/36.5.0/0001-Disable-DSA-from-microchip-9477-switch.patch;
          }.${l4t};
        }
      ]
    else if kernelVersion == "upstream-6-6" then patchesDir_6_6
    /*else if kernelVersion == "upstream-6-12" then patchesDir_6_12*/ 
    else throw "Unsupported kernelVersion ${kernelVersion} for Microchip KSZ patches";

in {
  options.ghaf.hardware.nvidia.orin.ethernet-switch =
    lib.mkEnableOption "Enabling Microchip KSZ9477s ethernet switch for Orin NX";

  config = lib.mkIf cfg.ethernet-switch {
    # Just pass the list of patches directly
    boot.kernelPatches = selectedPatches;

    hardware.deviceTree.overlays = [
      {
        name = "Microchip KSZ9477s ethernet switch";
        dtsFile = ./microchip-ksz9477s/tegra234-p3767-p3768-ksz9477s.dts;
      }
    ];
  };
}
