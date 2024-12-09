# BPI-R3-OpenWrt Image Builder

Banana Pi BPI-R3 OpenWrt Image Builder

[![Build Firmware](https://github.com/codekow/bpi-r3-openwrt/actions/workflows/bpi-r3-23.05.yml/badge.svg)](https://github.com/codekow/bpi-r3-openwrt/actions/workflows/bpi-r3-23.05.yml)

## Jumper Settings

```
1 = On, High
0 = Off, Down
X = Secondary storage selector
```

| Selected Storage | A | B | C | D |
|-|-|-|-|-|
| NOR  | 0 | 0 | 0 | X |
| NAND | 1 | 0 | 1 | X |
| eMMC | 0 | 1 | X | 0 |
| SD   | 1 | 1 | X | 1 |

```
A = Select boot storage
B = Select boot storage
C = NAND [1] or NOR [0] connected to CPU's SPI bus
D = SD Card or eMMC connected to CPU's eMMC bus
```

## Quick Start

Download [23.05.5 SD card](https://downloads.openwrt.org/releases/23.05.5/targets/mediatek/filogic/openwrt-23.05.5-mediatek-filogic-bananapi_bpi-r3-sdcard.img.gz)

Write image to SD card

```sh
URL=https://downloads.openwrt.org/releases/23.05.5/targets/mediatek/filogic/openwrt-23.05.5-mediatek-filogic-bananapi_bpi-r3-sdcard.img.gz

wget "${URL}"

zcat openwrt-*.gz | sudo dd of=/dev/mmcblk0 bs=4k
```

```sh
# boot from sdcard, flash nand
# A=1, B=1, C=1, D=1
fw_setenv bootcmd "env default bootcmd ; saveenv ; run ubi_init ; bootmenu 0"
reboot
```

```sh
# boot from sdcard, flash nor
# A=1, B=1, C=0, D=1
fw_setenv bootcmd "env default bootcmd ; saveenv ; run nor_init ; bootmenu 0"
reboot
```

```sh
# boot from nand, flash emmc
# A=1, B=0, C=1, D=0
fw_setenv bootcmd "env default bootcmd ; saveenv ; run emmc_init ; bootmenu 0"
reboot
```

Fix `emmc` size

```sh
opkg install parted

parted /dev/mmcblk0 -- mkpart f2fs 768MiB -34s resizepart 5 768MiB resizepart 4 67.1M resizepart 3 12.6M 
# say F to fix gpt global size
reboot

mount /dev/mmcblk0p66 /mnt
umount /mnt
resize.f2fs /dev/mmcblk0p66
# if resize.f2fs fails, a sysupgrade may fix
```

Use the rest of storage

```sh
opkg update
opkg install uvol autopart
uvol create userdata $(uvol free) rw
```

```
# boot from emmc, w/ nand
# A=0, B=1, C=1, D=0

# boot from emmc, w/ nor
# A=0, B=1, C=0, D=0
```

Fix `Image check failed: Cannot open file '/etc/opkg/keys`

```sh
opkg remove ucert
```

## Build Custom Image

```sh
./setup.sh
```

## Links

- [Buy - Amazon](https://www.amazon.com/gp/product/B0BDG6R41Q)
- [Docs - Hardware Overview](https://wiki.fw-web.de/doku.php?id=en:bpi-r3:start)
- [Docs - Install, OpenWrt](https://openwrt.org/toh/sinovoip/bananapi_bpi-r3)
- [Docs - Install, Old](https://forum.banana-pi.org/t/banana-pi-bpi-r3-openwrt-image/13236/4)
- [Fix - eMMC resize](https://forum.banana-pi.org/t/bpi-r3-how-to-flash-openwrt-snapshot-on-emmc/14055/5)
- [Docs - eMMC resize advice](https://forum.banana-pi.org/t/bpi-r3-mini-how-to-extend-emmc-overlayfs/17732/43)
- [Docs - Image Builder](https://openwrt.org/docs/guide-user/additional-software/imagebuilder#using_the_image_builder)
- [Wiki - BPI-R3](https://wiki.banana-pi.org/Getting_Started_with_BPI-R3)
- [Docs - Docker on OpenWrt](https://openwrt.org/docs/guide-user/virtualization/docker_host)
