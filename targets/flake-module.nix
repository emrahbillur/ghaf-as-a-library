# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{inputs, ...}: let
  inherit (inputs) jetpack-nixos;
  system = "aarch64-linux";

  nixMods = inputs.self.nixosModules;
  inherit (inputs.ghaf) lib;

  versionRev =
    if (inputs.self ? shortRev)
    then inputs.self.shortRev
    else if (inputs.self ? dirtyShortRev)
    then inputs.self.dirtyShortRev
    else "unknown-dirty-rev";

  ghafInputs =
    inputs.ghaf.inputs
    // {
      self = inputs.ghaf;
    };

  mkGhafConfiguration = inputs.ghaf.builders.mkGhafConfiguration {
    self = inputs.ghaf;
    inputs = ghafInputs;
    inherit lib;
  };

  mkGhafInstaller = inputs.ghaf.builders.mkGhafInstaller {
    self = inputs.ghaf;
    inherit lib system;
  };

  # Orin-specific modules (UEFI patches, OP-TEE, format modules)
  orinSpecificModules = [
    # inputs.ghaf.nixosModules.format-module
    #
  ];

  # Common modules shared across all Orin configurations
  commonModule = [
    jetpack-nixos.nixosModules.default
    (inputs.ghaf
      + "/modules/reference/hardware/jetpack/nvidia-jetson-orin/format-module.nix")
    inputs.ghaf.nixosModules.reference-host-demo-apps
    inputs.ghaf.nixosModules.reference-profiles-orin
    inputs.ghaf.nixosModules.profiles
    {
      nixpkgs.overlays = [
        inputs.self.overlays.custom-packages
        inputs.self.overlays.own-pkgs-overlay
      ];
      system = {
        configurationRevision = versionRev;
        nixos.label = versionRev;
      };
    }
  ];

  ghaf-configuration = {
    basename,
    hardwareModule,
    somvar ? "base",
    variant ? "debug",
    extraModules ? [],
    extraConfig ? {},
    vmConfig ? {},
  }: let
    inherit basename somvar;
    name = basename + "-" + somvar;
    self = inputs.ghaf;
    baseConfig = mkGhafConfiguration {
      inherit
        name
        system
        vmConfig
        extraConfig
        ;
      profile = "orin";
      inherit hardwareModule;
      extraModules =
        commonModule
        ++ extraModules;
    };
  in {
    hostConfig = baseConfig.hostConfiguration;
    inherit (baseConfig) package variant name;
  };

  # installer-config =
  #   targetName: imagePath: extraModules:
  #   let
  #     installerResult = mkGhafInstaller {
  #       name = targetName;
  #       inherit imagePath extraModules;
  #     };
  #   in
  #   {
  #     hostConfig = installerResult.hostConfiguration;
  #     inherit (installerResult) name package;
  #   };

  # installerModules = [
  #   (
  #     { config, ... }:
  #     {
  #       imports = [
  #         inputs.ghaf.nixosModules.common
  #         inputs.ghaf.nixosModules.givc
  #         inputs.ghaf.nixosModules.development
  #         inputs.ghaf.nixosModules.reference-personalize
  #       ];
  #       users.users.nixos.openssh.authorizedKeys.keys =
  #         config.ghaf.reference.personalize.keys.authorizedSshKeys;
  #     }
  #   )
  # ];
  target-configs = [
    (ghaf-configuration {
      basename = "nvidia-jetson-orin-agx-industrial";
      somvar = "base";
      variant = "debug";
      hardwareModule = nixMods.hardware-nvidia-jetson-orin-agx-industrial-base;
      extraConfig = {
        reference.profiles.mvp-orinuser-trial.enable = true;
      };
    })
    (ghaf-configuration {
      basename = "nvidia-jetson-orin-agx";
      somvar = "base";
      variant = "debug";
      hardwareModule = nixMods.hardware-nvidia-jetson-orin-agx-base;
      extraConfig = {
        reference.profiles.mvp-orinuser-trial.enable = true;
      };
    })
    (ghaf-configuration {
      basename = "nvidia-jetson-orin-agx64";
      somvar = "base";
      variant = "debug";
      hardwareModule = nixMods.hardware-nvidia-jetson-orin-agx64-base;
      extraConfig = {
        reference.profiles.mvp-orinuser-trial.enable = true;
      };
    })
    (ghaf-configuration {
      basename = "nvidia-jetson-orin-nx";
      somvar = "base";
      variant = "debug";
      hardwareModule = nixMods.hardware-nvidia-jetson-orin-nx-base;
      extraConfig = {
        reference.profiles.mvp-orinuser-trial.enable = true;
      };
    })
    (ghaf-configuration {
      basename = "nvidia-jetson-orin-nx";
      somvar = "a603";
      variant = "debug";
      hardwareModule = nixMods.hardware-nvidia-jetson-orin-nx-a603;
      extraConfig = {
        reference.profiles.mvp-orinuser-trial.enable = true;
        # Enable Orin Device
        hardware.nvidia.orin = {
          somType = "nx";
          carrierBoard = lib.mkForce "devkit";

          # Kernel version 5.15 till 6.6 camera drivers are fixed.
          kernelVersion = lib.mkForce "bsp-default";

          # Ethernet passthrough
          nx.enableNetvmEthernetPCIPassthrough = lib.mkForce true;

          # A603 specific setup
          a603-overlay = true;
        };
      };
    })
  ];

  # generate-graphics =
  #   tgt:
  #   tgt
  #   // rec {
  #     name = tgt.name + "-graphics";
  #     hostConfig = tgt.hostConfig.extendModules {
  #       modules = [
  #         {
  #           fog.enableGraphics = true;
  #           ghaf.profiles.graphics.enable = lib.mkForce true;
  #           ghaf.graphics.login-manager.enable = lib.mkForce true;
  #           ghaf.graphics.cosmic.enable = lib.mkForce true;
  #           ghaf.graphics.boot.enable = lib.mkForce false;
  #         }
  #       ];
  #     };
  #     package = hostConfig.config.system.build.ghafImage;
  #   };

  generate-cross-from-x86_64 = tgt:
    tgt
    // rec {
      name = tgt.name + "-from-x86_64";
      hostConfig = tgt.hostConfig.extendModules {
        modules = [
          inputs.ghaf.nixosModules.cross-compilation-from-x86_64
          /*
          May later add the local cross compile overlay from fog-ghaf
          */
        ];
      };
      package = hostConfig.config.system.build.ghafImage;
    };

  # target-installers = map (
  #   t: installer-config t.name inputs.self.packages.x86_64-linux.${t.name} installerModules
  # ) target-configs;

  #targets = target-configs ++ target-installers;
  #graphic-targets = map generate-graphics target-configs;
  #targets = (target-configs ++ graphic-targets);
  targets = target-configs;
  crossTargets = map generate-cross-from-x86_64 targets;
in {
  flake = {
    nixosConfigurations = builtins.listToAttrs (map (t: lib.nameValuePair t.name t.hostConfig) (targets ++ crossTargets));
    /*
    packages.${system} = builtins.listToAttrs (map (t: lib.nameValuePair t.name t.package) targets);
    */
    packages = {
      aarch64-linux = builtins.listToAttrs (map (t: lib.nameValuePair t.name t.package) targets);
      x86_64-linux =
        builtins.listToAttrs (map (t: lib.nameValuePair t.name t.package) crossTargets)
        // builtins.listToAttrs (
          map (
            t:
              lib.nameValuePair "${t.name}-flash-script" t.hostConfig.pkgs.nvidia-jetpack.legacyFlashScript
          )
          crossTargets
        )
        // builtins.listToAttrs (
          map (
            t:
              lib.nameValuePair "${t.name}-flash-qspi"
              (t.hostConfig.extendModules {
                modules = [{ghaf.hardware.nvidia.orin.flashScriptOverrides.onlyQSPI = true;}];
              }).pkgs.nvidia-jetpack.legacyFlashScript
          )
          crossTargets
        );
    };
  };
}
