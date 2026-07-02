#NETRC_FILE := "$HOME/.netrc"

_default:
    @just --list --unsorted

_nixos-rebuild-install:
    nix profile add nixpkgs#nixos-rebuild

show:
    nix flake show

# Convenience wrapper for building targets
# because of the dependency on the .netrc file
# we do no currently support remote builds
# build target +rest:
#     install -m 644 {{NETRC_FILE}} /tmp/.netrc
#     nix build {{target}} --option builders '' --option extra-sandbox-paths "/tmp/.netrc" {{rest}}
#     rm -f /tmp/.netrc

# rebuild ip target +rest:
#     install -m 644 {{NETRC_FILE}} /tmp/.netrc
#     fog-build-helper {{ip}} {{target}} --option builders '' --option extra-sandbox-paths "/tmp/.netrc" {{rest}}
#     rm -f /tmp/.netrc
build target *extra:
    nix build {{target}} {{extra}}

# Saluki v3 targets
build-saluki-v3-image-native *extra:
    nix build .#packages.aarch64-linux.nvidia-jetson-orin-nx-salukiv3-debug {{extra}}

build-saluki-v3-image-cross-compile *extra:
    nix build .#packages.x86_64-linux.nvidia-jetson-orin-nx-salukiv3-debug-from-x86_64 {{extra}}

build-saluki-v3-qspi-flashing-tool *extra:
    nix build .#packages.x86_64-linux.nvidia-jetson-orin-nx-salukiv3-debug-from-x86_64-flash-qspi {{extra}}

# Saluki v3s targets
build-saluki-v3s-image-native *extra:
    nix build .#packages.aarch64-linux.nvidia-jetson-orin-nx-salukiv3s-debug {{extra}}

build-saluki-v3s-image-cross-compile *extra:
    nix build .#packages.x86_64-linux.nvidia-jetson-orin-nx-salukiv3s-debug-from-x86_64 {{extra}}

build-saluki-v3s-qspi-flashing-tool *extra:
    nix build .#packages.x86_64-linux.nvidia-jetson-orin-nx-salukiv3s-debug-from-x86_64-flash-qspi {{extra}}

# Saluki v3m targets
build-saluki-v3m-image-native *extra:
    nix build .#packages.aarch64-linux.nvidia-jetson-orin-nx-salukiv3m-debug {{extra}}

build-saluki-v3m-image-cross-compile *extra:
    nix build .#packages.x86_64-linux.nvidia-jetson-orin-nx-salukiv3m-debug-from-x86_64 {{extra}}

build-saluki-v3m-qspi-flashing-tool *extra:
    nix build .#packages.x86_64-linux.nvidia-jetson-orin-nx-salukiv3m-debug-from-x86_64-flash-qspi {{extra}}

# Saluki v3x targets
build-saluki-v3x-image-native *extra:
    nix build .#packages.aarch64-linux.nvidia-jetson-orin-agx-industrial-salukiv3x-debug {{extra}}

build-saluki-v3x-image-cross-compile *extra:
    nix build .#packages.x86_64-linux.nvidia-jetson-orin-agx-industrial-salukiv3x-debug-from-x86_64 {{extra}}

build-saluki-v3x-qspi-flashing-tool *extra:
    nix build .#packages.x86_64-linux.nvidia-jetson-orin-agx-industrial-salukiv3x-debug-from-x86_64-flash-qspi {{extra}}

# nixos-rebuild commands
rebuild-switch ip target *extra: _nixos-rebuild-install
    nixos-rebuild switch --flake {{target}} --target-host {{ip}} {{extra}}

rebuild-boot ip target *extra: _nixos-rebuild-install
    nixos-rebuild boot --flake {{target}} --target-host {{ip}} {{extra}}

rebuild-switch-boot ip target *extra: _nixos-rebuild-install
    nixos-rebuild switch --flake {{target}} --target-host {{ip}} {{extra}}
    nixos-rebuild boot --flake {{target}} --target-host {{ip}} {{extra}}

copy-ssh-pub-key serial-port-dev:
    tio {{serial-port-dev}} --script-file bin/copy-ssh-pub-key.lua
