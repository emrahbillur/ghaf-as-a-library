# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.cuda-enable-host;
in {
  options.services.cuda-enable-host = {
    enable = mkEnableOption "cuda-enable-host";
  };

  config = mkIf cfg.enable {
    #Enabling CUDA on any supported system requires below settings. 
    nixpkgs.config.allowUnfree = lib.mkForce true;
    nixpkgs.config.allowBroken = lib.mkForce false;
    nixpkgs.config.cudaSupport = lib.mkForce true;

    # Enable Opengl
    # Opengl enable is renamed to hardware.graphics.enable
    # This is needed for CUDA so set it if it is already not set
    hardware.graphics.enable = lib.mkForce true;
  };
}