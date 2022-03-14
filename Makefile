SYSTEM_PART_NUM ?= 12
LIN_VERSION ?= 5.16.2
LOCAL_VERSION ?= -amazon-otter
IMAGES_DIR = $(CURDIR)/buildroot/output/images
MODULES_DIR = $(CURDIR)/buildroot/output/target/lib/modules/$(LIN_VERSION)$(LOCAL_VERSION)
BUILDROOT_CONFIG ?= $(CURDIR)/buildroot_config
CMDLINE ?= "rw rootwait console=ttyS2,115200 console=tty1 root=/dev/mmcblk0p$(SYSTEM_PART_NUM) mem=512M"
MKBOOTIMG_BIN = $(CURDIR)/android_system_core/mkbootimg/mkbootimg

.PHONY: all
all: boot.img

.PHONY: prep
android_system_core:
	git submodule update --init android_system_core
buildroot:
	git submodule update --init buildroot
prep: android_system_core buildroot

.PHONY: boot
boot: boot.img
	fastboot boot $<

.PHONY: wait_recovery
wait_recovery:
	$(eval STATUS=$(shell adb devices | tail -n +2 | awk '{print $$2}'))
	@if [ "$(STATUS)" != "recovery" ]; then \
		sleep 5; \
		echo "Device not found; sleeping for 5 seconds..."; \
		$(MAKE) wait_recovery; \
	fi

.PHONY: push_modules
push_modules: wait_recovery
	test -e $(MODULES_DIR)
	adb shell mount /dev/block/mmcblk0p$(SYSTEM_PART_NUM) /system
	adb shell rm -rf /system/lib/modules/$(LIN_VERSION)$(LOCAL_VERSION)
	adb push $(MODULES_DIR) /system/lib/modules/
	adb shell sync
	@echo 'Run `adb shell busybox reboot && make boot`'

$(IMAGES_DIR)/zImage: $(MKBOOTIMG_BIN) buildroot buildroot_config kc1_config
	-cp $(BUILDROOT_CONFIG) buildroot/.config
	$(MAKE) -C buildroot linux-rebuild

$(IMAGES_DIR)/omap4-kc1.dtb: $(IMAGES_DIR)/zImage
	cp buildroot/output/build/linux-$(LIN_VERSION)/arch/arm/boot/dts/omap4-kc1.dtb $(IMAGES_DIR)

boot.img: $(IMAGES_DIR)/zImage $(IMAGES_DIR)/omap4-kc1.dtb
	$(MKBOOTIMG_BIN) --kernel $(IMAGES_DIR)/zImage \
		--dt $(IMAGES_DIR)/omap4-kc1.dtb \
		--pagesize 4096 --base 0x80000000 \
		--ramdisk_offset 0x01000000  --kernel_offset 0x00008000 \
		--second_offset 0x00f00000 --tags_offset 0x100 \
		--cmdline $(CMDLINE) -o $@

.PHONY: clean
clean:
	-rm boot.img
	-rm $(IMAGES_DIR)/zImage*
	-$(MAKE) -C buildroot linux-dirclean
	#-rm -rf buildroot/output

# Wipe entire repo
.PHONY: bleach_all
bleach_all:
	git clean -xdf; git submodule deinit -f .

.PHONY: help
help:
	@echo "Available options:"
	@echo "  help             : print help message"
	@echo "  prep             : retrieve submodules"
	@echo "  boot             : build and boot boot.img with fastboot"
	@echo "  boot.img         : build Android boot image"
	@echo "  push_modules     : push kernel modules via adb"
	@echo "  clean            : clean built targets"
	@echo "  bleach_all       : wipe entire repo"
