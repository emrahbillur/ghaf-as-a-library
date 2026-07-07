# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{inputs, ...}: {
  imports = [
    ./hardware/flake-module.nix
    ./services/flake-module.nix
    ./profile/flake-module.nix
  ];

  flake.nixosModules = {
    netvm-services.imports = [
      ./services/avahi-service
    ];
  };
}
