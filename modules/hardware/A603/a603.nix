# Copyright 2022-2026 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.ghaf.hardware.nvidia.orin;
  pkgsPerSystem = system: inputs.nixpkgs.legacyPackages.${system};
  buildpkgs = pkgsPerSystem "x86_64-linux";
in {
  options.ghaf.hardware.nvidia.orin.a603-overlay =
    lib.mkEnableOption
    "Enabling A603 overlay ";

  config = lib.mkIf cfg.a603-overlay {

    # Preserve other net-vm modules and override only the passthrough NIC.
    ghaf.hardware.definition.netvm.extraModules = lib.mkAfter [
      {
        microvm.devices = lib.mkForce [
          {
            bus = "pci";
            path = "0008:01:00.0";
          }
        ];
      }
    ];

    boot.modprobeConfig.enable = true;

    # A603 kernel patches
    boot.kernelPatches = [
      {
        /* I cannot reach A603 kernel patches yet. There is a compiled image only */
        name = "A603 kernel patches";
        patch =
          {
            "36.4.3" = null;
            "36.4.4" = null;
            "36.5.0" = null;
          }
          ."${pkgs.nvidia-jetpack.l4tMajorMinorPatchVersion}";      }
    ];

    hardware.deviceTree.overlays = [
      {
        name = "A603 overlays";
        dtsFile = ./dt/tegra234-p3768-0000+p3767-0000-nv-overlay.dts;
      }
      # {
      #   name = "any extra dts overlay net-vm ethernet passthrough";
      #   dtsFile = ./dt/nx-netvm-ethernet-pci-domain7-passthrough-overlay.dts;
      # }
    ];
    hardware.nvidia-jetpack.flashScriptOverrides.preFlashCommands = ''
      "${buildpkgs.pkgsBuildBuild.patch}/bin/patch" -p0 < ${./modules/hardware/A603/patches/boot/tegra234-mb1-bct-gpio-p3767-dp-a03.patch}
      "${buildpkgs.pkgsBuildBuild.patch}/bin/patch" -p0 < ${./modules/hardware/A603/patches/boot/tegra234-mb1-bct-pinmux-p3767-dp-a03.patch}
    '';     
  };
}
