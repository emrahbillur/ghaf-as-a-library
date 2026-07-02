# Identity key removal

Short summary how to remove Identity Key from HSM.

If for any reason, you need to remove Identity Key from HSM follow the steps. Do note, creating identity key on the same Nvidia device produces always identical key-pair.

## Steps

The Identity Key cannot be exported anywhere so it is relatively safe to use PINs as follows.

``` bash
PIN=$(cat /sys/class/dmi/id/board_serial | tr -d "\n")
```

Check if the Identity Key is present already.

``` bash
pkcs11-tool-optee -O | grep "component_identity_key"

# If key object is listed, the Identity Key is in HSM.
```

Remove the key.

``` bash
pkcs11-tool-optee --delete-object --token-label component_identity_key --label device-component-identity-key \
    --pin=${PIN} --login --type=pubkey --id 11

pkcs11-tool-optee --delete-object --token-label component_identity_key --label device-component-identity-key \
    --pin=${PIN} --login --type=privkey --id 11

# DO NOTE, for now, the token remains in HSM
```
