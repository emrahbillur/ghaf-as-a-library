# QSPI flashing instructions
The following instructions can be used to flash the QSPI memory of Salukiv3 family devices.

The QSPI flashing process replaces the [salukiv3-nvidia-firmware-flashing-instructions.md](https://github.com/tiiuae/fog_system/blob/develop/doc/salukiv3-nvidia-firmware-flashing-instructions.md).

## Prerequisites
You need to have a machine with NixOS or Nix tools installed.

## Steps

Check which version of fog-ghaf is needed.

IMPORTANT: You must know what version of fog-ghaf is running or will be installed in your device. The following instructions are an example so they are using develop branch of fog-ghaf. The version if develop which you may be using during the time of writing these instructions may be different from the one you may be using in the future.

Clone this repository in the Nix machine:
```bash
git clone git@github.com:tiiuae/fog-ghaf.git
cd fog-ghaf
# Checkout the tag
git checkout develop
```

Build the QSPI flashing script:
```bash
# For SalukiV3

# In fog-ghaf directory
nix build .#packages.x86_64-linux.nvidia-jetson-orin-nx-salukiv3-debug-from-x86_64-flash-qspi
```
```bash
# For SalukiV3s

# In fog-ghaf directory
nix build .#packages.x86_64-linux.nvidia-jetson-orin-nx-salukiv3s-debug-from-x86_64-flash-qspi
```
```bash
# For SalukiV3x

# In fog-ghaf directory
nix build .#packages.x86_64-linux.nvidia-jetson-orin-agx-industrial-salukiv3x-debug-from-x86_64-flash-qspi
```
The build time depends on what is found from cache. Connect the build machine to TII VPN to get Ghaf cache servers and reduce build time.

Optional. If you are not sure what is the target to build, you can check the available targets with the command:
```bash
# In fog-ghaf directory
nix flake show
```

Put the device into recovery mode.

[Instructions how to boot NVidia Orin NX in SalukiV3 into recovery mode (APX mode).](https://confluence.tii.ae/spaces/DRON/pages/40894710/SalukiV3+User+Guide#SalukiV3UserGuide-BootingOrinNXintorecoverymode(APXmode))

[Instructions how to boot SalukiV3s into recovery mode (APX mode).](https://confluence.tii.ae/display/RIS/Saluki+3S+recovery+mode)

[Instructions how to boot SalukiV3x into recovery mode (APX mode).](https://confluence.tii.ae/spaces/DRON/pages/91442315/Saluki+v3x+User+Guide#Salukiv3xUserGuide-BootingOrinAGXintorecoverymode(APXmode))

Connect a USB cable to the device to be flashed and the computer with the QSPI flashing script.

Validate that it is in recovery mode:
```bash
lsusb | grep APX
```

You should find the following line in the list of USB devices found:
```bash
# Note that the bus and device number may be different.
Bus 001 Device 003: ID 0955:7323 NVIDIA Corp. APX
```

If previous steps are executed successfully you can now flash the QSPI memory with the command:
```bash
# In fog-ghaf directory
sudo result/bin/flash-ghaf-host
```

Make sure that the script was executed successfully before powering off the device.

Now the device can be put into normal boot mode.
