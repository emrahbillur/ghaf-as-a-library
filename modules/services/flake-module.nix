# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
#
# FOG service modules
# These define service options (e.g., services.jtop-service.enable)
#
{
  flake.nixosModules = {
    # Combined module for host (all services)
    fog-services.imports = [
      ./avahi-service
      ./jtop-service
      ./cuda-enable-host
      ./docker-service-host
      ./podman-service-host
      ./prune-docker-containers-host
      ./ethernet-switch/switch-microchip.nix
    ];
  };
}
