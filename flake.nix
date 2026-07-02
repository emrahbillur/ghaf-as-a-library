# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  description = "FOG Ghaf";

  nixConfig = {
    substituters = [
      "https://ghaf-dev.cachix.org"
      "https://cache.nixos.org"
    ];
    extra-trusted-substituters = [
      "https://ghaf-dev.cachix.org"
      "https://cache.nixos.org"
    ];
    extra-trusted-public-keys = [
      "ghaf-dev.cachix.org-1:S3M8x3no8LFQPBfHw1jl6nmP8A7cVWKntoMKN3IsEQY="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];

    allow-import-from-derivation = false;
  };

  inputs = {
    # Ghaf is the source of truth for nixpkgs version
    ghaf.url = "github:tiiuae/ghaf";

    # Follow ghaf's nixpkgs - no manual version tracking needed
    nixpkgs.follows = "ghaf/nixpkgs";

    # Jetpack NixOS for Nvidia Orin targets
    jetpack-nixos = {url = "github:tiiuae/jetpack-nixos/hotfix-ghaf-bump";};

    # Tooling you already had
    device-assembly-toolset = {
      url = "git+ssh://git@github.com/tiiuae/device_assembly_toolset?rev=42ed39a35b755f73ddb2e769147ebf22820848b7";
      inputs = {
        flake-utils.follows = "ghaf/flake-utils";
      };
    };

    kms-enrollment = {
      url = "git+ssh://git@github.com/tiiuae/enroll-mc?rev=5161656f6fbf373ff5ee09077d50d87026465c0c";
      inputs = {
        flake-utils.follows = "ghaf/flake-utils";
      };
    };

    ###
    # Flake and repo structuring configurations
    ###
    # Format all the things
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "ghaf/nixpkgs";
    };

    # For preserving compatibility with non-Flake users
    flake-compat = {
      url = "github:nix-community/flake-compat";
      flake = false;
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    # To ensure that checks are run locally to enforce cleanliness
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "ghaf/nixpkgs";
    };

    flake-root.url = "github:srid/flake-root";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "ghaf/nixpkgs";
    };

    # A set of useful nix packages and utilities for ghaf
    ghafpkgs = {
      url = "github:tiiuae/ghafpkgs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
        git-hooks-nix.follows = "git-hooks-nix";
        flake-compat.follows = "flake-compat";
        crane.follows = "givc/crane";
        devshell.follows = "devshell";
      };
    };

    # Ghaf Inter VM communication and control library
    givc = {
      url = "github:tiiuae/ghaf-givc";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        flake-root.follows = "flake-root";
        ghafpkgs.follows = "ghafpkgs";
        treefmt-nix.follows = "treefmt-nix";
        devshell.follows = "devshell";
        pre-commit-hooks-nix.follows = "git-hooks-nix";
      };
    };
    ###
    ### End of Flake and repo structuring configurations
  };

  outputs = inputs @ {flake-parts, ...}: let
    inherit (inputs.ghaf) lib;
  in
    flake-parts.lib.mkFlake
    {
      inherit inputs;
      specialArgs = {inherit lib;};
    }
    {
      systems = [
        "x86_64-linux"
      ];
      imports = [
        ./modules/flake-module.nix
        ./nix/flake-module.nix
        ./overlays/flake-module.nix
        ./targets/flake-module.nix
        ./packages/flake-module.nix
      ];
      flake.lib = lib;
    };
}
