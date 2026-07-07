# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{ config, lib, ... }:
let
  cfg = config.gal.personalize.debug;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in
{
  options.gal.personalize.debug = {
    enable = mkEnableOption "Enable the GAL debug personalization module.";

    authorizedSshKeys = mkOption {
      description = "List of authorized ssh keys for the development team.";
      type = types.listOf types.str;
      default = [
        # Add your SSH Public Keys here
        # NOTE: adding your pub ssh key here will make accessing and "nixos-rebuild switching" development mode
        # builds easy but still secure. Given that you protect your private keys. Do not share your keypairs across hosts.
        #
        # Shared authorized keys access poses a minor risk for developers in the same network (e.g. office) cross-accessing
        # each others development devices if:
        # - the ip addresses from dhcp change between the developers without the noticing AND
        # - you ignore the server fingerprint checks
        # You have been helped and you have been warned.
        #
        # Example:
        #"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICwsW+YJw6ukhoWPEBLN93EFiGhN7H2VJn5yZcKId56W mb@mmm"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFGzGy5vw2+bdwcGpQ7gwyiNvZ1HlolSHTP3tEUpzpoC emrah.billur@unikie.com"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL6Mt+STPKhCLPoMf+CqSlnFD9TA2veK8wrNeItLWSCo build-server-key"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINt+3IkYGd4DYE6kK/J15ZhEIo2dRITlR+m3MjZ0nC0b github-key"
      ];
    };
  };

  config = mkIf cfg.enable {
    users.users.root.openssh.authorizedKeys.keys = cfg.authorizedSshKeys;
    users.users.${config.ghaf.users.admin.name}.openssh.authorizedKeys.keys = cfg.authorizedSshKeys;
  };
}
