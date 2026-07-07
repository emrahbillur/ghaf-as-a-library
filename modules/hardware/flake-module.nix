# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
#
# FOG hardware modules extend ghaf's hardware modules with:
# - USB passthrough configuration
# - Resource overrides (where needed)
#
{ inputs, lib, ... }:
{
  flake.nixosModules = {
    a603-overlay.imports = [
      ./A603/a603.nix
    ];

    hardware-nvidia-jetson-orin-agx-industrial-base.imports = [
      inputs.ghaf.nixosModules.jetpack
      inputs.ghaf.nixosModules.hardware-nvidia-jetson-orin-agx-industrial
      ./resources/agx-industrial-base.nix
      ./usb
    ];

    hardware-nvidia-jetson-orin-agx-base.imports = [
      inputs.ghaf.nixosModules.jetpack
      inputs.ghaf.nixosModules.hardware-nvidia-jetson-orin-agx
      ./resources/agx-base.nix
      ./usb
    ];

    hardware-nvidia-jetson-orin-agx64-base.imports = [
      inputs.ghaf.nixosModules.jetpack
      inputs.ghaf.nixosModules.hardware-nvidia-jetson-orin-agx64
      ./resources/agx64-base.nix
      ./usb    
    ];

    hardware-nvidia-jetson-orin-nx-base.imports = [
      inputs.ghaf.nixosModules.jetpack
      inputs.ghaf.nixosModules.hardware-nvidia-jetson-orin-nx
      ./resources/nx-base.nix
      ./usb    
    ];

    hardware-nvidia-jetson-orin-nx-a603.imports = [
      inputs.ghaf.nixosModules.jetpack
      inputs.ghaf.nixosModules.hardware-nvidia-jetson-orin-nx
      inputs.self.nixosModules.a603-overlay
      ./resources/nx-a603.nix
      ./usb    
    ];
  };
}
