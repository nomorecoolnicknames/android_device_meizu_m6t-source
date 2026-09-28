LOCAL_PATH := device/meizu/M6T
TARGET_MEIZU_MT675X_DEVICE := M6T

# Inherit from the proprietary version
-include vendor/meizu/M6T/BoardConfigVendor.mk

include device/meizu/m3_meizu_m6-common/BoardConfigCommon.mk

# PROPER-FIX: M6T factory geometry, not the inherited M6 layout.
# /srv/forge/m6t-dump/boot.img SHA256 49aadf45...684c0f, stock scatter.
TARGET_CPU_VARIANT := cortex-a53
TARGET_SCREEN_WIDTH := 720
TARGET_SCREEN_HEIGHT := 1440
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 4294967296
BOARD_MKBOOTIMG_ARGS := --kernel_offset 0x00008000 --ramdisk_offset 0x04f88000 --second_offset 0x00e88000 --tags_offset 0x03f88000 --board 1550465732

# Build Station: MTK's Oreo libril wrapper requires MTK telephony/ril.h
# extensions before the AOSP hardware/ril include directory is searched.
TARGET_SPECIFIC_HEADER_PATH := vendor/mediatek/include $(COMMON_PATH)/include


# system.prop
TARGET_SYSTEM_PROP := $(LOCAL_PATH)/system.prop

# Radio
ADD_RADIO_FILES := true
TARGET_RELEASETOOLS_EXTENSIONS := $(LOCAL_PATH)
# Build Station: use the MTK Oreo HIDL RIL wrapper for stock MTK modem blobs.
BOARD_PROVIDES_RILD := true
BOARD_PROVIDES_LIBRIL := true

# Bluetooth
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(LOCAL_PATH)/bluetooth

# Build Station: target device identity override
TARGET_OTA_ASSERT_DEVICE := M6T
BOARD_NAME := M6T
TARGET_SYSTEM_PROP := device/meizu/M6T/system.prop
# Build Station: gatekeeper HAL service is absent during M6 Oreo bring-up.
# Use gatekeeperd's software fallback instead of blocking forever on HIDL.
BOARD_USE_SOFT_GATEKEEPER := true
# Stock M6T advertises both app ABIs. M6-only app_process32 failures are
# not M6T evidence. Keep pure64 as an explicit diagnostic override only.
M6_PURE_ARM64 ?= false
ifeq ($(M6_PURE_ARM64),true)
TARGET_CPU_ABI_LIST_64_BIT := $(TARGET_CPU_ABI)
TARGET_CPU_ABI_LIST_32_BIT :=
TARGET_CPU_ABI_LIST := $(TARGET_CPU_ABI_LIST_64_BIT)
TARGET_SUPPORTS_32_BIT_APPS := false
TARGET_SUPPORTS_64_BIT_APPS := true
else
TARGET_SUPPORTS_32_BIT_APPS := true
TARGET_SUPPORTS_64_BIT_APPS := true
endif
# Stock MTK audio.primary is unstable in the 64-bit HIDL service path. Keep
# the audio HAL service on the 32-bit vendor bridge while the app runtime stays
# zygote64-only.
AUDIOSERVER_MULTILIB := 32
# Build Station: pure64 camera bring-up. AOSP Oreo cameraserver is 32-bit-only
# here, so publish CameraService from the already-64-bit mediaserver instead.
TARGET_HAS_LEGACY_CAMERA_HAL1 := true
# Build Station: stock MTK camera blobs reference legacy graphics symbols, and
# stock vendor ICU must coexist with Oreo system libs that need ICU 58 symbols.
TARGET_LD_SHIM_LIBS += \
    /system/lib/libandroid_runtime.so|/system/lib/libicuuc.so \
    /system/lib/libmedia.so|/system/lib/libicuuc.so \
    /system/lib/libmedia.so|/system/lib/libicui18n.so \
    /system/lib/libsqlite.so|/system/lib/libicuuc.so \
    /system/lib/libsqlite.so|/system/lib/libicui18n.so \
    /system/vendor/lib/libicui18n.so|/system/vendor/lib/libicuuc.so \
    /system/vendor/lib/libxml2.so|/system/vendor/lib/libicuuc.so \
    /system/vendor/lib/libcam_utils.so|/system/vendor/lib/libmtkshim_gui.so \
    /system/vendor/lib/libcam.client.so|/system/vendor/lib/libmtkshim_gui.so \
    /system/vendor/lib/libcam.camnode.so|/system/vendor/lib/libmtkshim_gui.so \
    /system/vendor/lib/libeffecthal.base.so|/system/vendor/lib/libmtkshim_gui.so \
    /system/vendor/lib/libjni_lomoeffect.so|/system/vendor/lib/libmtkshim_gui.so \
    /system/vendor/lib/libvfb_render.so|/system/vendor/lib/libmtkshim_gui.so \
    /system/vendor/lib/libMtkOmxVenc.so|/system/vendor/lib/libmtkshim_gui.so \
    /system/vendor/lib/libmtk_mmutils.so|/system/vendor/lib/libmtkshim_gui.so \
    /system/vendor/lib/libshowlogo.so|/system/vendor/lib/libmtkshim_gui.so \
    /system/vendor/lib/libgui_ext.so|/system/vendor/lib/libmtkshim_gui.so \
    /system/vendor/lib/libui_ext.so|/system/vendor/lib/libmtkshim_gui.so \
    /system/vendor/lib64/libcam_utils.so|/system/vendor/lib64/libmtkshim_gui.so \
    /system/vendor/lib64/libcam.client.so|/system/vendor/lib64/libmtkshim_gui.so \
    /system/vendor/lib64/libcam.camnode.so|/system/vendor/lib64/libmtkshim_gui.so \
    /system/vendor/lib64/libeffecthal.base.so|/system/vendor/lib64/libmtkshim_gui.so \
    /system/vendor/lib64/libjni_lomoeffect.so|/system/vendor/lib64/libmtkshim_gui.so \
    /system/vendor/lib64/libvfb_render.so|/system/vendor/lib64/libmtkshim_gui.so \
    /system/vendor/lib64/libmtk_mmutils.so|/system/vendor/lib64/libmtkshim_gui.so \
    /system/vendor/lib64/libgui_ext.so|/system/vendor/lib64/libmtkshim_gui.so \
    /system/vendor/lib64/libui_ext.so|/system/vendor/lib64/libmtkshim_gui.so \
    /system/lib64/libandroid_runtime.so|/system/lib64/libicuuc.so \
    /system/lib64/libmedia.so|/system/lib64/libicuuc.so \
    /system/lib64/libmedia.so|/system/lib64/libicui18n.so \
    /system/lib64/libsqlite.so|/system/lib64/libicuuc.so \
    /system/lib64/libsqlite.so|/system/lib64/libicui18n.so \
    /system/vendor/lib64/libicui18n.so|/system/vendor/lib64/libicuuc.so \
    /system/vendor/lib64/libxml2.so|/system/vendor/lib64/libicuuc.so
# Kernel — toggle between prebuilt (default) and in-tree source build.
# Default prebuilt is the extracted M6T STOCK 3.18.35+ kernel, sha256
# e45de551e526f1c792bf531664e42afabc2ece5881f5485159e2f003a474e60c.
# It matches the factory boot.img kernel bytes; it is not M6 #209.
# M6_KERNEL_FROM_SOURCE=true selects the separate M6T board port. Neither
# path has a custom-ROM runtime claim on a physical M6T in this workspace.
TARGET_NO_KERNEL := false

M6_KERNEL_FROM_SOURCE ?= false

ifeq ($(M6_KERNEL_FROM_SOURCE),true)
# --- In-tree source build ---
# Kernel source: kernel/meizu/M6T/kernel-3.18 (symlink into LOS tree)
# Matches off-tree recipe: ARCH=arm64, gcc-4.9, M6T_defconfig, Image.gz-dtb
TARGET_KERNEL_SOURCE := kernel/meizu/M6T/kernel-3.18
TARGET_KERNEL_CONFIG := M6T_defconfig
TARGET_KERNEL_ARCH := arm64
# Toolchain: prefer the in-tree prebuilt so the source-kernel lane is
# portable between the local host and west (which has no /srv/forge).
# kernel.mk runs $(MAKE) -C $(KERNEL_SRC), so CROSS_COMPILE must be
# ABSOLUTE - a tree-relative path would resolve against the kernel source
# dir and fail. $(abspath ) is evaluated with make cwd == tree root.
# The in-tree gcc is a python2 wrapper; the build container pins
# python -> python2 (build-m6-16.sh), so it resolves there.
M6T_KERNEL_TC_INTREE := $(abspath prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin)/aarch64-linux-android-
ifneq ($(wildcard $(M6T_KERNEL_TC_INTREE)gcc),)
TARGET_KERNEL_CROSS_COMPILE_PREFIX := $(M6T_KERNEL_TC_INTREE)
else
TARGET_KERNEL_CROSS_COMPILE_PREFIX := /srv/forge/toolchains/aarch64-linux-android-4.9/bin/aarch64-linux-android-
endif
BOARD_KERNEL_IMAGE_NAME := Image.gz-dtb
# Clear prebuilt vars so kernel.mk takes the FULL_KERNEL_BUILD path
TARGET_PREBUILT_KERNEL :=
M6_DISPLAY_KERNEL_PREBUILT :=
else
# --- Prebuilt kernel (default, current behaviour) ---
# Keep UAPI/header generation tied to the M6T source, even in prebuilt mode.
TARGET_KERNEL_SOURCE := kernel/meizu/M6T/kernel-3.18
TARGET_KERNEL_CONFIG :=
M6_DISPLAY_KERNEL_PREBUILT := device/meizu/M6T/prebuilt-kernel/Image.gz-dtb
TARGET_PREBUILT_KERNEL := $(M6_DISPLAY_KERNEL_PREBUILT)
BOARD_KERNEL_IMAGE_NAME := kernel
PRODUCT_COPY_FILES += \
    $(M6_DISPLAY_KERNEL_PREBUILT):kernel
endif

# Build Station: SurfaceFlinger vsync phase offsets — REMOVED 2026-06-21.
# These were the prime bootloop suspect (handoff M6-HANDOFF-TODO.md §2.4) and were never
# isolated. We are now enabling HWC (system.prop debug.sf.disable_hwc=0) to fix UI lag; to
# keep ONE variable per CLAUDE.md §3 we test HWC with DEFAULT vsync (no offset) first.
# If HWC boots cleanly but judders, re-introduce the -8000000 offsets below:
#   SF_VSYNC_EVENT_PHASE_OFFSET_NS := -8000000
#   VSYNC_EVENT_PHASE_OFFSET_NS := -8000000
