# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.docker-service-host;
in {
  options.services.docker-service-host = {
    enable = mkEnableOption "docker-service-host";
  };

    config = mkIf cfg.enable {
    # Just ensure containers are enabled by boot.
    boot.enableContainers = lib.mkForce true;

    # Enable Opengl renamed to hardware.graphics.enable
    hardware.graphics.enable = lib.mkForce true;

    # Enabling CDI NVIDIA devices in podman or docker (nvidia docker container)
    # For Orin devices this setting does not work as jetpack-nixos still does not support them.
    # jetpack-nixos uses enableNvidia = true; even though it is deprecated
    # For x86_64 the case is different it was introduced to be 
    # virtualisation.containers.cdi.dynamic.nvidia.enable = true;
    # but deprecated and changed to hardware.nvidia-container-toolkit.enable
    # We enable below setting if architecture ix x86_64 and if the video driver is nvidia set it true
    #hardware.nvidia-container-toolkit.enable = true;

    # Docker Daemon Settings
    virtualisation.docker = {
      # To force Docker package version settings need to import pkgs first
      # package = pkgs.docker_26;

      enable = true;
      # The enableNvidia option is still used in jetpack-nixos while it is obsolete in nixpkgs
      # but it is still only option for nvidia-orin devices. Added extra fix for CDI to 
      # make it run with docker.
      enableNvidia = true;
      daemon.settings.features.cdi = true;
      # The rootless docker fail after the latest nixpkgs changes.
      # rootless = {
      #   enable = true;
      #   setSocketVariable = true;
      #   daemon.settings.features.cdi = true;
      #   daemon.settings.cdi-spec-dirs = [ "/var/run/cdi/" ];
      # };

      # Container file and processor limits 
      daemon.settings = {
        mtu = 1372;
        default-ulimits = {
          nofile = {
          Name = "nofile";
            Hard = 1024;
            Soft = 1024;
          };
          nproc = {
            Name = "nproc";
            Soft = 65536;
            Hard = 65536;
          };
        };
      };
    };

    # Add user to docker group and dialout group for access to serial ports
    users.users."ghaf" = {
      extraGroups = [
        "docker"
        "dialout"
      ];
      # subUidRanges = [
      #   { startUid = 100000; count = 65536; }
      # ];
      # subGidRanges = [
      #   { startGid = 100000; count = 65536; }
      # ];
    };

    # users.users."root" = {
    #   isSystemUser = true;
    #   subUidRanges = [
    #     { startUid = 100000; count = 65536; }
    #   ];
    #   subGidRanges = [
    #     { startGid = 100000; count = 65536; }
    #   ];  
    # };
  };
}
