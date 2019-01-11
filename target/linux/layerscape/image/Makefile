#
# Copyright (C) 2016 Jiang Yutang <jiangyutang1978@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

ITB_BOARDS = traverse-five64

LS_SD_ROOTFSPART_OFFSET = 64
LS_SD_IMAGE_SIZE = $(shell echo $$((($(LS_SD_ROOTFSPART_OFFSET) + \
	$(CONFIG_TARGET_ROOTFS_PARTSIZE)) * 1024 * 1024)))

define Build/ls-clean
	rm -f $@
endef

define Build/ls-append
	dd if=$(STAGING_DIR_IMAGE)/$(1) >> $@
endef

define Build/ls-append-dtb
	$(call Image/BuildDTB,$(DTS_DIR)/$(1).dts,$(DTS_DIR)/$(1).dtb)
	dd if=$(DTS_DIR)/$(1).dtb >> $@
endef

define Build/ls-append-sdhead
	./gen_sdcard_head_img.sh $(STAGING_DIR_IMAGE)/$(1)-sdcard-head.img \
		$(LS_SD_ROOTFSPART_OFFSET) $(CONFIG_TARGET_ROOTFS_PARTSIZE)
	dd if=$(STAGING_DIR_IMAGE)/$(1)-sdcard-head.img >> $@
endef

define Build/traverse-fit
	./mkits-multiple-config.sh -o $@.its -A $(LINUX_KARCH) \
		-v $(LINUX_VERSION) -k $@ -a $(KERNEL_LOADADDR) \
		-e $(if $(KERNEL_ENTRY),$(KERNEL_ENTRY),$(KERNEL_LOADADDR)) \
		-C gzip -c 1 -c 2 \
		-d $(DEVICE_DTS_DIR)/freescale/traverse-ls1043s.dtb \
		-D "Traverse_LS1043S" -n "ls1043s" -a $(FDT_LOADADDR) -c 1 \
		-d $(DEVICE_DTS_DIR)/freescale/traverse-ls1043v.dtb \
		-D "Traverse_LS1043V" -n "ls1043v" -a $(FDT_LOADADDR) -c 2
	PATH=$(LINUX_DIR)/scripts/dtc:$(PATH) mkimage -f $@.its $@.new
	@mv -f $@.new $@
endef

define Build/g3000-MuImage
	rm -rf $@.fakerd $@.new

	dd if=/dev/zero of=$@.fakerd bs=32 count=1 conv=sync

	$(call Image/BuildDTB,$(DTS_DIR)/g3000.dts,$(DTS_DIR)/g3000.dtb)

	# g3000 uboot doesn't have FIT support so we use the older
	# "multi" image approach.
	#
	# Sadly, the "multi" image has to consists of three
	# "fixed" parts in the following "fixed" order:
	# 1. The kernel which is in $@
	# 2. The (fake) initrd which is in $@.fakerd
	# 3. The device tree binary which is in $@.dtb
	#
	# Now, given that we use the function for the kernel which
	# already has a initramfs image inside, we still have to
	# add a "fake" initrd (which a mkimage header) in the second
	# part of the legacy multi image. Since we need to put the
	# device tree stuff into part 3.

	echo STAGING_DIR_IMAGE=$(STAGING_DIR_IMAGE)
	echo DEVICE_DTS_DIR=$(DEVICE_DTS_DIR)
	echo DTS_DIR=$(DTS_DIR)
	echo KERNEL_ENTRY=$(KERNEL_ENTRY)
	echo KERNEL_ENTRY_POINT=$(KERNEL_ENTRY_POINT)

	$(STAGING_DIR_HOST)/bin/mkimage -A $(LINUX_KARCH) -O linux -T multi \
		-C gzip -a $(KERNEL_LOADADDR) -e $(KERNEL_ENTRY_POINT) \
		-n 'kernel+dtb' -d $@:$@.fakerd:$(DTS_DIR)/g3000.dtb $@.new
	mv $@.new $@
	rm -rf $@.fakerd
endef

ifeq ($(SUBTARGET),armv8_64b)
include armv8_64b.mk
endif

ifeq ($(SUBTARGET),armv8_32b)
include armv8_32b.mk
endif

ifeq ($(SUBTARGET),armv7)
include armv7.mk
endif

$(eval $(call BuildImage))
