#
# lineage_M6T.mk - Meizu M6T (M6T / M811H), MediaTek MT6750
# LineageOS 18.1 (Android 11)
#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Companion report: /srv/forge/android/meizu-fleet/trees/M6T_LOS20_TREE.md
#
# ###########################################################################
# READ THIS FIRST: THIS IS A BENCH TREE. THERE IS NO M6T HARDWARE.
#
# FACT (meizu_m6t/M6T_ROADMAP.md §1, 2026-07-25): "ни один артефакт никогда не
# прошивался и не загружался" - not one M6T artifact has ever been flashed or
# booted; `adb devices` and `fastboot devices` were both empty. Every green build
# on this lane proves compilation and packaging, and nothing else.
#
# Consequently EVERY runtime claim about M6T in this tree is INFERENCE from the
# stock dump (github.com/TadiT7/meizu_meizum6t_dump, local copy /srv/forge/m6t-dump)
# or from its sibling M6, and is labelled as such. Where the dump is silent, the
# comment says HYPOTHESIS and names the test.
# ###########################################################################
#

# arm64 with a 32-bit second ABI.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Device configuration.
$(call inherit-product, device/meizu/M6T/device.mk)

# LineageOS common phone stack.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# ---------------------------------------------------------------------------
# Identity - codename `M6T`, taken from the existing device tree.
#
# FACT: the LOS 15.1 tree sets PRODUCT_DEVICE := M6T, PRODUCT_NAME :=
#   lineage_M6T, TARGET_OTA_ASSERT_DEVICE := M6T
#   (meizu_m6/rom-lineage-15.1-meizu_m6-experimental/device/meizu/M6T/lineage_M6T.mk),
#   and the LOS 16.0 tree on gunwest uses the same directory name
#   (gunwest-import/m6rom16/rom-work/device/meizu/M6T).
#
# NOTE the factory strings, which are all different from each other (FACT,
#   /srv/forge/m6t-dump/system/build.prop):
#     ro.product.device = MeizuM6T      ro.product.board  = M6T
#     ro.product.model  = M6T           ro.product.name   = Meizu_M6T_RU
#     ro.product.flyme.model = m1811    (the marketing model is M811H)
#   The project's trees have used `M6T` since the 15.1 lane. Kept, and the
#   aliases go into TARGET_OTA_ASSERT_DEVICE.
# ---------------------------------------------------------------------------
PRODUCT_DEVICE := M6T
PRODUCT_NAME := lineage_M6T
PRODUCT_BRAND := Meizu
PRODUCT_MODEL := M6T
PRODUCT_MANUFACTURER := Meizu

PRODUCT_GMS_CLIENTID_BASE := android-meizu

# ---------------------------------------------------------------------------
# Shipping API level.
#
# FACT, and for once this one is not an inference at all - it is read straight
#   off the device's own factory system image (/srv/forge/m6t-dump/system/build.prop):
#     ro.build.version.sdk=24
#     ro.build.version.release=7.0
#     ro.build.id=NRD90M
#     ro.product.first_api_level=24
#     ro.build.fingerprint=Meizu/Meizu_M6T_RU/MeizuM6T:7.0/NRD90M/1550240131:user/release-keys
#     ro.build.version.security_patch=2019-02-05
#   ro.product.first_api_level=24 is the strongest form of this evidence: the
#   device declares, itself, that it launched on API 24.
#
# (Until 2026-09-24 the paragraph below was the whole story. Treble is now
# forced on by the override further down; everything else it lists still
# follows the level 24.)
# Declaring 24 turns OFF, by the build system's own rules: PRODUCT_FULL_TREBLE
# (needs >= 26, build/make/core/config.mk:668-676), PRODUCT_USE_VNDK /
# BOARD_VNDK_VERSION (needs > 27 AND full treble, config.mk:721-736),
# PRODUCT_TREBLE_LINKER_NAMESPACES / PRODUCT_SEPOLICY_SPLIT /
# PRODUCT_ENFORCE_VINTF_MANIFEST (config.mk:683-695),
# PRODUCT_ENFORCE_PRODUCT_PARTITION_INTERFACE (> 29),
# PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS (>= 29),
# PRODUCT_SET_DEBUGFS_RESTRICTIONS (>= 31).
#
# FACT: the stock dump is "Android-7 layout (no separate vendor partition;
#   system-as-root)" (M6T_DUMP_ANALYSIS_2026-07-22.md §4), which the scatter
#   confirms - there is no `vendor` entry in /srv/forge/m6t-dump/scatter.txt.
# ---------------------------------------------------------------------------
PRODUCT_SHIPPING_API_LEVEL := 24

# FULL TREBLE, forced (owner directive 2026-09-24; m95 does the same from
# BoardConfig.mk). The shipping level above stays the honest 24 - raising it
# would claim a launch that never happened. build/make/core/config.mk:668-676
# takes the override before looking at the level; LINKER_NAMESPACES,
# SEPOLICY_SPLIT and ENFORCE_VINTF_MANIFEST follow (config.mk:678-694). The
# rest of the switch is in BoardConfig.mk ("Treble / VNDK"), the reasoning in
# meizu-fleet/designs/TREBLE_M6_M6T_20260924.md.
PRODUCT_FULL_TREBLE_OVERRIDE := true

PRODUCT_CHARACTERISTICS := phone

# FACT: 720x1440 panel (BoardConfig.mk).
TARGET_BOOT_ANIMATION_RES := 720

# FACT: copied verbatim from /srv/forge/m6t-dump/system/build.prop.
PRODUCT_BUILD_PROP_OVERRIDES += \
    TARGET_DEVICE=MeizuM6T \
    PRIVATE_BUILD_DESC="Meizu_M6T_RU-user 7.0 NRD90M 1550240131 release-keys"

BUILD_FINGERPRINT := Meizu/Meizu_M6T_RU/MeizuM6T:7.0/NRD90M/1550240131:user/release-keys

# ---------------------------------------------------------------------------
# Dual SIM. INFERENCE from the family, not measured: the stock dump carries the
# same MTK dual-modem property set as M6 and the M6T is sold as a dual-SIM
# handset. No M6T has ever registered on a network under our software.
# ---------------------------------------------------------------------------
PRODUCT_PROPERTY_OVERRIDES += \
    persist.radio.multisim.config=dsds \
    ro.telephony.default_network=10,10

# This private product belongs to the API 30 platform; reject accidental A13 overlays.
ifneq ($(PLATFORM_SDK_VERSION),30)
$(error M6T lineage-18.1 requires PLATFORM_SDK_VERSION=30)
endif
