# Shutdown button

This feature is quite simple: a physical button which signals the NVida Orin NX module to shutdown gracefully. It can be compared to a power button in a laptop computer. It is implemented on Saluki v3 and Saluki v3s. In Saluki v3 the flight controller will not receive the shutdown signal and it will remain running although the NVidia Orin NX is powered off already.

The target of the feature is to reduce some of the file system corruptions seen in some cases when the device suddenly loses power while writing data to disk. In some cases the physical button may not be accessible but use it whenever it is possible.

## Where is the button located?

### Saluki v3
The power button is named "Programmable SW button". See the "Saluki v3 Switches & SW button" picture in the [Saluki v3 User Guide document](https://confluence.tii.ae/spaces/DRON/pages/40894710/Saluki+v3+User+Guide#Salukiv3UserGuide-Procedures).

### Saluki v3s
The power button is named "Programmable SW button". See the "Front Panel 2D-view" picture in the [Saluki v3s User Guide document](https://confluence.tii.ae/spaces/DRON/pages/79298675/Saluki+v3s+User+Guide#Salukiv3sUserGuide-HardwareInterfaces).


## How to trigger the shutdown process

Press the button once and wait until the device is turned off.

## How to know when the device is powered off

The easiest way to know is to follow the UART debug console of the NVidia Orin NX and check when the shutdown messages appears: `Shutting down system ...`.

If you don't have access to the UART debug console of the NVidia Orin NX, then you can check several things to know when the device is off and it is of to unplug the device from the power supply:
* Saluki v3
  * The fan stops spinning
  * The `NV PW` green LED is turned off
* Saluki v3s
  * The fans start spinning at maximum speed
  * The `NV` blue LED is turned off
