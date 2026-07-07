# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{ inputs, ... }:
{
  config,
  options,
  lib,
  ...
}:
let
  inherit (lib) optionals;
  inherit (pkgs.nvidia-jetpack) opteeClient;
  pkgs = config._module.args.pkgs;
  hostGlobalConfig = config.ghaf.global-config;
  ghafInputs = inputs.ghaf.inputs // {
    self = inputs.ghaf;
  };
in
{
  imports = [
    inputs.ghaf.nixosModules.disko-debug-partition
    inputs.ghaf.nixosModules.reference-appvms
    inputs.ghaf.nixosModules.reference-passthrough
    inputs.ghaf.nixosModules.reference-programs
    inputs.ghaf.nixosModules.reference-services
    inputs.ghaf.nixosModules.reference-desktop
    inputs.self.nixosModules.gal-services
    inputs.self.nixosModules.gal-personalize
  ];

  config = {
    ghaf = {
      profiles = {
        orin.enable = true;
      };

      # Enable local user creation in the first-boot wizard
      users.profile.homed-user.enable = true;
    
      services = {
        power-manager = {
          enable = true;
          suspend.enable = false;
        };
        kill-switch.enable = true;
      };

      virtualization.microvm = {
        netvm.evaluatedConfig = config.ghaf.profiles.orin.netvmBase.extendModules {
          modules = [
            inputs.ghaf.nixosModules.reference-services
            inputs.ghaf.nixosModules.reference-personalize
            inputs.self.nixosModules.netvm-services
            inputs.self.nixosModules.gal-personalize
            { ghaf.reference.personalize.keys.enable = true; }
          ]
          ++ lib.ghaf.vm.applyVmConfig {
            inherit config;
            vmName = "netvm";
          }
          ++ inputs.self.nixosModules.netvm; 
        };

        adminvm.evaluatedConfig = config.ghaf.profiles.orin.adminvmBase.extendModules {
          modules = [
            ({ config, ... }:
              let
                net = config.ghaf.hardware.network.adminvm or {};
              in
              {
                systemd.network.links = lib.mkForce (net.links or {});
                systemd.network.networks = lib.mkForce (net.networks or {});
              })
            {
              microvm.writableStoreOverlay = "/nix/.rw-store";

              networking.nat = {
                enable = false;
                internalInterfaces = [ "ethint0" ];
              };
            }
          ];  
        };
      };

      logging = {
        enable = false;
        server.endpoint = "https://loki.ghaflogs.vedenemo.dev/loki/api/v1/push";
        listener.address = config.ghaf.networking.hosts.admin-vm.ipv4;
      };

      # virtualization.microvm-host.sharedVmDirectory.vms = optionals (
      #   config.ghaf.virtualization.microvm.appvm.enable
      #   && config.ghaf.virtualization.microvm.appvm.vms.chrome.enable
      # ) [ "chrome-vm" ];

      reference = {
        desktop.applications.enable = false;
        services = {
          enable = true;
          google-chromecast.enable = false;
        };
      };

      partitioning.disko.enable = false;

      storage.encryption = {
        enable = false;
        deferred = false;
      };

      # fog-hyper has built-in SSH server. this would conflict with it.
      # `mkForce` because I could not find how to specify this from ghaf's own config
      #development.ssh.daemon.enable = lib.mkForce false;

      # TODO: Adjust count of tokens / slots and heap size below
      #       heap size ~ storage size
      hardware.nvidia.orin.optee.pkcs11 = {
        heapSize = 1048576;
        tokenCount = 50;
      };

      # Disable bluetooth
      services.bluetooth.enable = false;

      # Enable Orin Device
      hardware.nvidia.orin = {
        enable = true;
      };
      
      # Bootloader dtb enable
      systemd.boot.enable = true;

      # TEMPORARILY Disable vhotplug of x86
      #hardware.passthrough.vhotplug.enable = lib.mkForce false;

      # Create admin home folder; temporary solutionvariant
      users.admin.createHome = true;

      # TODO: Set these based on how you want to do networking in
      #       fog-ghaf
      hardware.nvidia = {
        virtualization.enable = true;
        virtualization.host.bpmp.enable = false;
        passthroughs.host.uarta.enable = false;
        #passthroughs.uarti_net_vm.enable = som == "agx";
      };

      # Disable givc
      givc.enable = lib.mkForce false;

      # Disable demo applications
      reference.host-demo-apps.demo-apps.enableDemoApplications = lib.mkForce false;
      
      # reference.programs.chromium.enable = lib.mkForce false;
      # reference.programs.element-desktop.enable = lib.mkForce false;
      # reference.programs.google-chrome.enable = lib.mkForce false;
      # reference.programs.zathura.enable = lib.mkForce false;
      # reference.programs.windows-launcher.enable = lib.mkForce false;
      # reference.programs.firefox.enable = lib.mkForce false;

      virtualization.microvm-host.enable = true;
      virtualization.microvm-host.networkSupport = true;
    };
  };
}
