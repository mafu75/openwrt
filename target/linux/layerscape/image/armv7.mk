#
# Copyright 2018 NXP
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Device/Default
  PROFILES := Default
  FILESYSTEMS := squashfs
  IMAGES := firmware.bin
  KERNEL := kernel-bin | uImage none
  KERNEL_NAME := zImage
  KERNEL_LOADADDR := 0x80008000
  KERNEL_ENTRY_POINT := 0x80008000
endef

define Device/ls1021atwr
  DEVICE_TITLE := LS1021ATWR
  DEVICE_PACKAGES += layerscape-rcw-ls1021atwr
  DEVICE_DTS := ls1021a-twr
  IMAGE/firmware.bin := \
    ls-clean | \
    ls-append $(1)-rcw.bin | pad-to 1M | \
    ls-append $(1)-uboot.bin | pad-to 3M | \
    ls-append $(1)-uboot-env.bin | pad-to 15M | \
    ls-append-dtb $$(DEVICE_DTS) | pad-to 16M | \
    append-kernel | pad-to 32M | \
    append-rootfs | pad-rootfs | check-size 67108865
endef
TARGET_DEVICES += ls1021atwr

define Device/ls1021atwr-sdboot
  DEVICE_TITLE := LS1021ATWR (SD Card Boot)
  DEVICE_DTS := ls1021a-twr
  FILESYSTEMS := ext4
  IMAGES := sdcard.img
  IMAGE/sdcard.img := \
    ls-clean | \
    ls-append-sdhead $(1) | pad-to 4K | \
    ls-append $(1)-uboot.bin | pad-to 3M | \
    ls-append $(1)-uboot-env.bin | pad-to 15M | \
    ls-append-dtb $$(DEVICE_DTS) | pad-to 16M | \
    append-kernel | pad-to $(LS_SD_ROOTFSPART_OFFSET)M | \
    append-rootfs | check-size $(LS_SD_IMAGE_SIZE)
endef
TARGET_DEVICES += ls1021atwr-sdboot

define Device/ls1021aiot-sdboot
  DEVICE_TITLE := LS1021AIOT (SD Card Boot)
  DEVICE_DTS := ls1021a-iot
  FILESYSTEMS := ext4
  IMAGES := sdcard.img
  IMAGE/sdcard.img := \
    ls-clean | \
    ls-append-sdhead $(1) | pad-to 4K | \
    ls-append $(1)-uboot.bin | pad-to 1M | \
    ls-append $(1)-uboot-env.bin | pad-to 15M | \
    ls-append-dtb $$(DEVICE_DTS) | pad-to 16M | \
    append-kernel | pad-to $(LS_SD_ROOTFSPART_OFFSET)M | \
    append-rootfs | check-size $(LS_SD_IMAGE_SIZE)
endef
TARGET_DEVICES += ls1021aiot-sdboot

define Device/g3000-nand
  DEVICE_TITLE := G3000 (NAND Boot)
  DEVICE_DTS := g3000
  FILESYSTEMS := ubifs
  BLOCKSIZE := 128k
  PAGESIZE := 2048
  UBIFS_OPTS := -m 2048 -e 124KiB -c 4096
  UBINIZE_OPTS := -E 5
#  KERNELNAME:=uImage dtbs
  KERNELNAME:=zImage dtbs
  IMAGES := factory_ubi.bin factory_kernel.bin factory_dtb.bin sysupgrade.tar
  KERNEL := kernel-bin # | gzip # | g3000-MuImage
# TODO: factory_kernel.bin is zImage -> fine for inital boot, but ledenand needs uImage
  IMAGE/factory_dtb.bin := ls-append-dtb $$(DEVICE_DTS) # dtb
  IMAGE/factory_ubi.bin := append-ubi       # ubi'nized image
  IMAGE/factory_kernel.bin := append-kernel # MuImage (kernel + fake.rd + dtb)
#  IMAGE/factory_rootfs.bin := append-rootfs # ubifs partition image
  IMAGE/sysupgrade.tar := sysupgrade-tar
endef
TARGET_DEVICES += g3000-nand
