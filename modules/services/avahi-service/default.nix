# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.avahi-service;
in {
  options.services.avahi-service = {
    enable = mkEnableOption "avahi-service";
  };

  config = mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      # so that mDNS can be used to discover services
      reflector = true;
    };
  };
}
