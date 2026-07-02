# Storing built fog-ghaf into container image registry (with ORAS)

## Prerequisites

- Have [ORAS](https://oras.land/) installed (you can just download their single-binary to `/usr/local/bin/`)
- Be logged in to GHCR with *your own user account* (ssrcdevops can't write packages, just read).
  * So [create a PAT](https://github.com/settings/tokens) and give it to `$ docker login -u <your username> ghcr.io`


## Build the image

This is outside the scope of this document.

After this step you should have file `result/sd-image/nixos-sd-image-*-aarch64-linux.img.zst`


## Extract the image into boot and root partitions

```console
$ zstd -d -o sd-image.img result/sd-image/nixos-sd-image-*-aarch64-linux.img.zst
$ sudo losetup --find --partscan sd-image.img
$ losetup | grep sd-image
$ echo "Enter device:"
$ read dev
$ sudo dd if="${dev}p1" of=boot.img bs=1M status=progress
$ sudo dd if="${dev}p2" of=root.img bs=1M status=progress
$ sudo losetup --detach "$dev"
```

You should now have `boot.img` and `root.img`


## Push to image registry

```shell
oras push ghcr.io/tiiuae/fog-ghaf:sha-0aff6d5 boot.img:application/octet-stream root.img:application/octet-stream --annotation org.opencontainers.image.revision='0aff6d561c809a3df721a5b6eb8804997e37cb06' --annotation org.opencontainers.image.description='fog-ghaf partitions'
```

**NOTE**: replace revision number with your revision number from Git AND the image ref with first 7 hexits of the revision.
