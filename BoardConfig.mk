# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
# BoardConfig.mk - Meizu M6T (M6T / M811H), MediaTek MT6750

# N-era blobs go in with PRODUCT_COPY_FILES (vendor-blobs.mk), the way
# vendor/meizu/m95/m95-vendor.mk does it. Android 11+ rejects ELF files in
# PRODUCT_COPY_FILES; this flag only lifts that check (m95 BoardConfig.mk carries
# the same debt): nothing validates the blobs' DT_NEEDED at build time, so the
# closure is checked offline instead - meizu-fleet/tools/treble-closure.py and
# treble_blob_audit.py, results in the report above.
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

# Blob vs AOSP module at the same /vendor path (e.g. hw/fingerprint.default.so)
# warns instead of erroring, as on m95. The winner per path must be checked by
# sha256 against proprietary/SHA256SUMS after a full build.
BUILD_BROKEN_DUP_RULES := true

DEVICE_PATH := device/meizu/M6T

# MT6750 uses eight ARMv8.0 Cortex-A53 cores; the BSP names this platform MT6755.
# Do not enable LSE atomics or inherit an unrelated 32-bit-zygote workaround.
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := cortex-a53

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a53

TARGET_USES_64_BIT_BINDER := true

# ---------------------------------------------------------------------------
# Board / platform identity
#
# TARGET_BOARD_PLATFORM mt6750 - FACT from the stock build.prop; it is what
#   selects hw modules named *.mt6750.so, which is what the blobs are called.
# ro.hardware stays mt6755 (see cmdline) - INFERENCE from M6, where it is
#   measured ([ro.boot.hardware]: [mt6755]) and where the same fstab.mt6755 /
#   init.mt6755.rc naming is used. The M6T stock ramdisk also ships
#   fstab.mt6755 (M6T_DUMP_ANALYSIS §4), which is consistent.
#
# GPU: INFERENCE. MT6750 is the down-binned MT6755, so Mali-T860MP2. Nothing on
#   this disk quotes a GPU string off an M6T. Cosmetic - feeds egl fallbacks.
# ---------------------------------------------------------------------------
TARGET_BOARD_PLATFORM := mt6750
TARGET_BOOTLOADER_BOARD_NAME := mt6750
TARGET_BOARD_PLATFORM_GPU := mali-t860mp2

TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true

BOARD_NAME := M6T
# Preserve M6T factory identity strings and the case-sensitive M6T product name.
TARGET_OTA_ASSERT_DEVICE := M6T,MeizuM6T,M811H,m1811

# M6T is 720x1440 at density 320; M6 is 720x1280.
# The bootloader selects LCM drivers by name. Keep board panel variants and do not infer panel identity from a donor DTB.
TARGET_SCREEN_WIDTH := 720
TARGET_SCREEN_HEIGHT := 1440
TARGET_RECOVERY_PIXEL_FORMAT := BGRA_8888

# M6T is A-only. Keep factory scatter geometry and avoid dynamic partition assumptions.
BOARD_FLASH_BLOCK_SIZE := 131072

BOARD_BOOTIMAGE_PARTITION_SIZE := 16777216
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 4294967296
BOARD_CACHEIMAGE_PARTITION_SIZE := 452984832
BOARD_USERDATAIMAGE_PARTITION_SIZE := 11683216896

# The custom partition size follows the factory scatter. Verify it against the physical storage variant.
BOARD_VENDORIMAGE_PARTITION_SIZE := 1073729536
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4

TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := ext4

# A-only. NOTE: PRODUCT_USE_DYNAMIC_PARTITIONS must NOT be assigned here - it is
# a product variable marked .KATI_READONLY before BoardConfig.mk is read.
AB_OTA_UPDATER := false
BOARD_USES_RECOVERY_AS_BOOT := false
BOARD_BUILD_SYSTEM_ROOT_IMAGE := false

# Treble uses the real custom partition for /vendor and an explicit VNDK version.
# Keep board-specific Nougat vendor inputs.
TARGET_COPY_OUT_VENDOR := vendor
BOARD_VNDK_VERSION := current
BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED := true

# Vendor-owned properties (hw module suffixes, RIL, legacy-kernel VINTF flag).
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# M6T boot geometry follows its factory header. Keep base and offsets consistent.
BOARD_KERNEL_BASE := 0x40078000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x04f88000
BOARD_SECOND_OFFSET := 0x00e88000
BOARD_TAGS_OFFSET := 0x03f88000
BOARD_MKBOOTIMG_ARGS := --board 1550465732 --ramdisk_offset $(BOARD_RAMDISK_OFFSET) --second_offset $(BOARD_SECOND_OFFSET) --tags_offset $(BOARD_TAGS_OFFSET)

BOARD_BOOT_HEADER_VERSION := 0
BOARD_INCLUDE_DTB_IN_BOOTIMG :=
BOARD_INCLUDE_RECOVERY_DTBO :=

# The kernel command line must select the MT6755 init/fstab identity and all required binder devices.
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2 androidboot.hardware=mt6755 androidboot.selinux=permissive binder.devices=binder,hwbinder,vndbinder androidboot.usb.config=adb buildvariant=userdebug

# Use the matching M6T prebuilt and board DTB.
# Android 13 requires the eBPF interfaces in the selected kernel; source compilation does not establish device boot.
TARGET_NO_KERNEL := false
TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64
# 2026-09-25 (Treble): the kernel SOURCE is needed after all, while the
# prebuilt above stays what boot.img carries. FACT (first `m vendorimage` of
# branch lineage-20-treble, build-meizu_m6-treble-vendorimage_systemimage_
# check-vintf-all.log): the Soong genrule generated_kernel_includes
# (vendor/lineage/build/soong/Android.bp:21) runs
# `make -C $(TARGET_KERNEL_SOURCE) headers_install`, and with no source the
# vendor image fails on .dummy_dep with "kernel/meizu/meizu_m6: No such file or
# directory" (that is M6; this tree is set up the same way) - the same wall m95 hit on 2026-09-16 (device/meizu/m95/
# BoardConfig.mk, kernel block). Same fix as m95:
#   * kernel/meizu/M6T is a symlink to the eBPF worktree of this device's
#     3.18.140 kernel, meizu-fleet/wt/kernel_M6T_ebpf/kernel-3.18 (branch
#     forge/M6T-ebpf: the m95 eBPF series + M6T_a13_defconfig + the kbuild
#     host-csingle/HOSTLDFLAGS fix m95 needed for headers_install, m95 kernel
#     3522613e). Created by hand, like kernel/meizu/m95; see
#     meizu-fleet/designs/TREBLE_M6_M6T_20260924.md §6.
#   * TARGET_FORCE_PREBUILT_KERNEL keeps kernel.mk on the prebuilt branch
#     (kernel.mk:180-190: FULL_KERNEL_BUILD := false, KERNEL_BIN :=
#     TARGET_PREBUILT_KERNEL); without it a present source + config means a
#     from-source kernel build.
# Headers vs ABI: the prebuilt is the same 3.18.140 line without the eBPF
# commits; the uapi difference is linux/bpf.h, which no vendor module of this
# tree includes. When the eBPF kernel becomes the boot kernel, drop
# TARGET_FORCE_PREBUILT_KERNEL (or swap the prebuilt) and headers and binary
# come from one tree.
TARGET_KERNEL_SOURCE := kernel/meizu/M6T
TARGET_KERNEL_CONFIG := M6T_a13_defconfig
TARGET_FORCE_PREBUILT_KERNEL := true
TARGET_KERNEL_VERSION := 3.18
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image.gz-dtb
BOARD_KERNEL_IMAGE_NAME := kernel

# ---------------------------------------------------------------------------
# Recovery / fstab
# ---------------------------------------------------------------------------
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.mt6755
BOARD_SUPPRESS_SECURE_ERASE := true
BOARD_CHARGER_SHOW_PERCENTAGE := true

# ---------------------------------------------------------------------------
# Wi-Fi - MediaTek WMT / conn_soc combo chip. INFERENCE from M6 (same SoC, same
# blob family: 721 of 744 M6 blob entries matched the M6T dump). The existing
# M6T tree ships wifi/init.m6.wifi.rc and wifi/wpa_supplicant.conf, both copied
# from M6.
#
# WIFI_DRIVER_STATE_CTRL_PARAM is present and not just FW_PATH_PARAM because
# frameworks/opt/net/wifi/libwifi_hal only compiles wifi_change_driver_state()
# when the board defines it; without it /dev/wmtWifi is never written and wlan0
# never appears. Measured on M6 hardware 2026-08-03.
# ---------------------------------------------------------------------------
BOARD_WLAN_DEVICE := MediaTek
WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_mt66xx
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_mt66xx
WIFI_DRIVER_STATE_CTRL_PARAM := /dev/wmtWifi
WIFI_DRIVER_STATE_ON := 1
WIFI_DRIVER_STATE_OFF := 0
WIFI_DRIVER_OPERSTATE_PATH := /sys/class/net/wlan0/operstate
WIFI_DRIVER_STATE_CTRL_RETRIES := 8
WIFI_DRIVER_STATE_CTRL_RETRY_DELAY_US := 1000000

# ---------------------------------------------------------------------------
# Bluetooth - INFERENCE from M6 / the shared blob set.
# ---------------------------------------------------------------------------
BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_MTK := true

# ---------------------------------------------------------------------------
# SELinux. The factory image itself boots permissive
# (androidboot.selinux=permissive in the factory cmdline, FACT), and the Nougat
# MTK blob set trips A13 public-policy neverallows wholesale - measured one
# release down on the sibling M6 lane. Acknowledged debt.
# ---------------------------------------------------------------------------
SELINUX_IGNORE_NEVERALLOWS := true
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor

# Mount points for the fstab's /protect_f, /protect_s, /nvdata (nofail). On A13
# the root after switch_root IS system.img, read-only, so init cannot mkdir them;
# without the directory mount_all skips the entry -> no /nvdata -> no NVRAM ->
# no IMEI/modem (init.M6T.nvram.rc). system/core/rootdir/Android.mk:93-95
# splices this list into the mkdir of init.environ.rc's post-install. Same as
# m5c/m5s/m2note/meizu_m6; labels in sepolicy/vendor/file_contexts.
BOARD_ROOT_EXTRA_FOLDERS := nvdata protect_f protect_s

# Not-Qualcomm.
BOARD_USES_QCOM_HARDWARE := false
TARGET_USES_QCOM_BSP := false

TARGET_SYSTEM_PROP := $(DEVICE_PATH)/system.prop
