# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
# lineage_M6T.mk - Meizu M6T (M6T / M811H), MediaTek MT6750

# arm64 with a 32-bit second ABI.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Device configuration.
$(call inherit-product, device/meizu/M6T/device.mk)

# LineageOS common phone stack.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Keep the case-sensitive M6T codename for product selection and OTA assertions.
PRODUCT_DEVICE := M6T
PRODUCT_NAME := lineage_M6T
PRODUCT_BRAND := Meizu
PRODUCT_MODEL := M6T
PRODUCT_MANUFACTURER := Meizu

PRODUCT_GMS_CLIENTID_BASE := android-meizu

# The stock vendor ABI is Android 7.0 / API 24. Select Treble explicitly without changing the shipping API.
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

# Stock build description and fingerprint.
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
