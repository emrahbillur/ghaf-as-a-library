# SCIF Mission Computer Enroll and DAC howto

## Prerequisites
- [SCIF PC and Assembly server setup done](https://github.com/tiiuae/fog_system/blob/develop/doc/scif-pc-and-assembly-server-setup.md)
- Terminal application in the SCIF PC
- Saluki v3s (Mission Computer) LAN2 port connected to the SCIF PC directly with Ethernet cable
- Flight Controller (NXP93) ethernet port connected to Saluki v3s LAN4 port (same connection as in operational configuration)
- USB installer with a fog-system image with SCIF tools
- Serial port Linux console connection to the Mission Computer of Saluki v3s
- Terminal application to send commands to the Mission Computer over the serial port Linux console (eg. Picocom)

## Enroll and DAC creation steps

### Boot the Mission Computer (MC)
Boot the MC using the USB installer which contains the SCIF tools.

Note that you may need to clear the partition table of the MC before it can boot from the USB installer.

### Prepare persistent partition
On the serial port Linux console execute the command:
``` bash
sudo prepare-persistent-partition
```

### Enroll MC
On the serial port Linux console execute the command:
``` bash
sudo dac-kms-enrollment
```

### Start the DAC agent
On the serial port Linux console execute the command:
``` bash
sudo dac-agent -d <device-name>
```
Take note of the DEVICE_NAME used by dac-agent. Use the same name in the device-name parameter in the next step.
Now this command will wait until the next step is executed.

### Create the DAC for MC
**IMPORTANT**: The DAC creation for MC only is used for testing purposes. If you are creating DAC for a drone, then stop here and continue with the [SCIF Saluki v3s DAC creation](https://github.com/tiiuae/fog_system/doc/scif-salukiv3s-dac-creation-howto.md).
On the terminal of the SCIF PC execute the command:
``` bash
docker run \
--rm \
--volume ./das.conf:/app/das.conf \
--volume ./data:/app/data \
--volume ./tokens:/var/lib/softhsm/tokens \
--network host \
--name assembly-server \
ghcr.io/tiiuae/tii-device-assembly-server:latest create-dac --device-name=<device_name> --components=mc --pin 0000 --save-dac=/app/data --docker true
```
On the previous step we are creating a DAC that contains only one component: MC. If the DAC needs to be created for a device with more components, then the values given should be different. Give the values as a comma separated list; valid values: `mc`, `fc` and `cm`, for example `--components fc,mc,cm`.
`--save-dac` is optional parameter. If given, DAC will be stored (from command above) in `/app/data/dac_<device_name>.json`.

### Check persistent partition contents (optional)
Mount the persistent partition:
``` bash
mkdir /var/run/persistent
mount /dev/nvme0n1p1 /var/run/persistent
```

Persistent partition root:
``` bash
ls /var/run/persistent
PERSIST_PARTITION  certificates  lost+found  provisioning-data
```

DAC is stored in:
``` bash
ls /var/run/persistent/certificates
ca.pem  dac.json  identity.pem
```

Unmount persistent partition:
``` bash
umount /var/run/persistent
```

## Next steps

The next steps are optional.

### Install fog-system
Now the device can be flashed with the fog-system available in the USB installer.
``` bash
sudo fog-install
```
