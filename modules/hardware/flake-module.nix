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
    salukiv3-overlay.imports = [
      ./saluki/v3/salukiv3.nix
    ];

    salukiv3s-overlay.imports = [
      ./saluki/v3s/salukiv3s.nix
    ];

    salukiv3m-overlay.imports = [
      ./saluki/v3m/salukiv3m.nix
    ];

    salukiv3x-overlay.imports = [
      ./saluki/v3x/salukiv3x.nix
    ];

    camera-gmsl2-alvium.imports = [
      ../camera/camera-gmsl2-alvium.nix
    ];

    camera-toshiba-alvium.imports = [
      ../camera/camera-toshiba-alvium.nix
    ];

    hardware-nvidia-jetson-orin-agx-industrial-base.imports = [
      inputs.ghaf.nixosModules.jetpack
      inputs.ghaf.nixosModules.hardware-nvidia-jetson-orin-agx-industrial
      ./resources/agx-industrial-base.nix
      ./usb
    ];

    hardware-nvidia-jetson-orin-agx-industrial-salukiv3x.imports = [
      inputs.ghaf.nixosModules.jetpack
      inputs.ghaf.nixosModules.hardware-nvidia-jetson-orin-agx-industrial
      inputs.self.nixosModules.salukiv3x-overlay
      inputs.self.nixosModules.camera-gmsl2-alvium
      ./resources/agx-industrial-salukiv3x.nix
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

    hardware-nvidia-jetson-orin-nx-salukiv3.imports = [
      inputs.ghaf.nixosModules.jetpack
      inputs.ghaf.nixosModules.hardware-nvidia-jetson-orin-nx
      inputs.self.nixosModules.salukiv3-overlay
      inputs.self.nixosModules.camera-toshiba-alvium
      ./resources/nx-salukiv3.nix
      ./usb    
    ];

    hardware-nvidia-jetson-orin-nx-salukiv3s.imports = [
      inputs.ghaf.nixosModules.jetpack
      inputs.ghaf.nixosModules.hardware-nvidia-jetson-orin-nx
      inputs.self.nixosModules.salukiv3s-overlay
      inputs.self.nixosModules.camera-gmsl2-alvium
      ./resources/nx-salukiv3s.nix
      ./usb    
    ];

    hardware-nvidia-jetson-orin-nx-salukiv3m.imports = [
      inputs.ghaf.nixosModules.jetpack
      inputs.ghaf.nixosModules.hardware-nvidia-jetson-orin-nx
      inputs.self.nixosModules.salukiv3m-overlay
      inputs.self.nixosModules.camera-gmsl2-alvium
      ./resources/nx-salukiv3m.nix
      ./usb    
    ];

  };
}
