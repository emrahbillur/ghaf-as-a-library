# Identity key creation

Short summary how to create Identity Key into HSM.

Fog-ghaf (develop) contains Identity Key handling. Please use the PINs as stated here to keep things compatible. Also, triggering the key creation requires that `--label device-component-identity-key` is used.

## Prerequisites

Before executing the following steps you need to make sure that the contents of the QSPI memory of the device has this feature enabled.

Execute the [qspi-flashing-instructions](https://github.com/tiiuae/fog-ghaf/blob/develop/docs/qspi-flashing-instructions.md) and then continue with the identity key creation instructions.

Note: if you know that your device has the QSPI contents up-to-date with with feature, then you can skip the QSPI flashing instructions and continue with the steps below.

## Steps

Note: the steps below are executed in the device's host environment (ghaf-host) after fog-system has been installed in the device, right before provisioning. Root permission is required to execute the commands.

The Identity Key cannot be exported anywhere so it is relatively safe to use PINs as follows.

``` bash
PIN=$(cat /sys/class/dmi/id/board_serial | tr -d "\n")
SO_PIN=$(echo -n ''${PIN} | rev)
```

Check if the Identity Key is present already.

``` bash
pkcs11-tool-optee --token-label component_identity_key --label device-component-identity-key \
--login --pin ${PIN} -O | grep device-component-identity-key

# If something listed, the Identity Key is there already.
```

Create the key.

``` bash
pkcs11-tool-optee --init-token --label component_identity_key --so-pin ${SO_PIN} --slot-index 0
pkcs11-tool-optee --init-pin --login --label component_identity_key --so-pin ${SO_PIN} --pin ${PIN} --slot-index 0
pkcs11-tool-optee --keypairgen --token-label component_identity_key --pin ${PIN} --key-type EC:secp384r1 \
--id 11 --label device-component-identity-key --slot-index 0
```
