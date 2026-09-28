#
# device.mk - Meizu M6T (M6T / M811H), MT6750, LineageOS 20 (Android 13)
#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# BENCH TREE - no M6T hardware exists in this project.
#

LOCAL_PATH := device/meizu/M6T

# ---------------------------------------------------------------------------
# Soong namespaces (device-tree isolation)
#
# FACT (measured 2026-09-16): Soong parses every Android.bp in the workspace
# for every product and has no TARGET_DEVICE guard, so a bp module declared in
# one device tree lands in installs-<product>.mk of ALL products — a plain
# `m nothing` for lineage_m5s carried 51 install-rule lines from
# device/meizu/m95 (27 modules), two of them colliding with real m5s blobs
# (vendor/lib{,64}/libperfservicenative.so, via the `stem:` of
# libm95shim_perfservice).  Modules of a namespace reach Make only for the
# products that list that namespace here
# (build/soong/cmd/soong_build/main.go:99-112 -> android/namespace.go:204 ->
# android/androidmk.go:919).  Each tree carries a root Android.bp with
# `soong_namespace {}`; this line is the other half of the pair.
# ---------------------------------------------------------------------------
PRODUCT_SOONG_NAMESPACES += \
    device/meizu/M6T
# No vendor/meizu/M6T tree exists in this workspace (see the blob note
# further down); add it here together with that tree.

# ---------------------------------------------------------------------------
# Screen density
#
# FACT: ro.sf.lcd_density=320 in the device's own factory build.prop
#   (/srv/forge/m6t-dump/system/build.prop). Panel is 720x1440 (BoardConfig.mk),
#   so 320 dpi => xhdpi.
# ---------------------------------------------------------------------------
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xhdpi

DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

# ---------------------------------------------------------------------------
# Ramdisk / fstab
# A13 first-stage init mounts every fstab entry carrying `first_stage_mount` and,
# if there is a /system entry, calls SwitchRoot("/system")
# (system/core/init/first_stage_mount.cpp:505-525).
# ---------------------------------------------------------------------------
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6755:$(TARGET_COPY_OUT_RAMDISK)/fstab.mt6755 \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6755:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.mt6755

# Vendor init and ueventd for A13 (Treble, 2026-09-25): the meizu_m6 set
# (device/meizu/meizu_m6 d1e1ec9, audit meizu-fleet/designs/treble-m6-m6t/
# rootdir/INSTALL.txt) with the M6T stock-ramdisk differences applied - see
# the header of each file. A13 init imports only /vendor/etc/init/hw/
# init.${ro.hardware}.rc (mt6755); the hw/ siblings are imported from it by
# installed path. /system/etc/ueventd.rc imports /vendor/etc/ueventd.rc.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/ueventd.mt6755.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.rc \
    $(LOCAL_PATH)/rootdir/etc/init/hw/init.mt6755.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.mt6755.rc \
    $(LOCAL_PATH)/rootdir/etc/init/hw/init.mt6755.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.mt6755.usb.rc \
    $(LOCAL_PATH)/rootdir/etc/init/hw/init.M6T.nvram.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.M6T.nvram.rc \
    $(LOCAL_PATH)/rootdir/etc/init/hw/init.M6T.modem.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.M6T.modem.rc \
    $(LOCAL_PATH)/rootdir/etc/init/hw/init.M6T.tee.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.M6T.tee.rc \
    $(LOCAL_PATH)/rootdir/etc/init/hw/init.M6T.connectivity.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.M6T.connectivity.rc \
    $(LOCAL_PATH)/rootdir/etc/init/hw/init.M6T.thermal.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.M6T.thermal.rc \
    $(LOCAL_PATH)/rootdir/etc/init/init.M6T.sensors.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.M6T.sensors.rc

# ---------------------------------------------------------------------------
# VINTF
# ---------------------------------------------------------------------------
DEVICE_MANIFEST_FILE := $(LOCAL_PATH)/manifest.xml

# ---------------------------------------------------------------------------
# Wi-Fi / supplicant
# ---------------------------------------------------------------------------
# NOTE: `wpa_supplicant.conf` is NOT a module in Android 13 - putting it in
# PRODUCT_PACKAGES fails main.mk:1312 "includes non-existent modules".
PRODUCT_PACKAGES += \
    libwpa_client \
    wpa_supplicant \
    hostapd

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/wifi/wpa_supplicant.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant.conf \
    $(LOCAL_PATH)/wifi/p2p_supplicant.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant.conf

# wpa_supplicant service with the AIDL interface name the A13 framework asks
# for (m95 lesson 161682f; nothing else in this image defines the service —
# see the header of that rc).
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/init/init.M6T.wifi.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.M6T.wifi.rc

# ---------------------------------------------------------------------------
# Health - AOSP generic implementation.
# ---------------------------------------------------------------------------
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service

# ---------------------------------------------------------------------------
# Feature declarations.
#
# THE HONEST RULE FOR THIS DEVICE: nothing has ever run on an M6T, so no feature
# can be declared on the strength of observation. What IS declarable is what the
# FACTORY DEVICE TREE says the hardware physically contains - that is evidence
# about the board, not about our software.
#
# FACT, from the decompiled stock appended DTB (M6T_DUMP_ANALYSIS_2026-07-22.md §3):
#   fingerprint  - `goodix,goodix-fp` node present (same Goodix family as M6's
#                  GF3208 and m681's GF516M; the roadmap names the part GF3258
#                  on EINT12);
#   touchscreen  - `mediatek,cap_touch@5d` + `mediatek,cap_touch2@62`,
#                  `mediatek,mt6755-touch`, 3 hardware keys;
#   telephony    - dual SIM MTK modem stack in the stock build.prop.
# FACT, from /srv/forge/m6t-dump: the Wi-Fi/BT combo blobs and firmware are
#   present and are the same MTK WMT family as M6's.
#
# Deliberately NOT declared:
#   android.hardware.camera*  - the biggest known gap. Stock compiles SIX sensor
#                  drivers (imx278 hi846 ov13855 s5k4h7 gc2375 sp2509); our
#                  kernel has four and one (s5k4h8) is the wrong chip; three are
#                  in no local BSP. M6T is DUAL rear where M6 is single. On the
#                  sibling M6, which HAS hardware, camera open still crashes.
#   sensors       - the stock cust_* DTS block names epl259x / mpu6515g /
#                  bmp280new / bma253 in nodes for which the stock kernel has NO
#                  drivers, i.e. M6T probably has neither gyroscope nor
#                  barometer. Declaring sensor features would be a guess in the
#                  wrong direction.
#   vibrator      - AW869X, no driver in any source we have (firmware blob is in
#                  the dump, so the port is not data-blocked, only work-blocked).
# ---------------------------------------------------------------------------
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/handheld_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/handheld_core_hardware.xml

# ---------------------------------------------------------------------------
# Vendor blobs - in the real /vendor image (Treble, 2026-09-25).
#
# Until 2026-09-24 this block explained why NO blobs were imported (a non-Treble
# tree with no vendor partition, fleet rule TREES.md §3.4). With a real /vendor
# the blobs ARE the vendor image, so they are imported - into this tree, not a
# separate vendor/meizu/M6T (proprietary/ is in .gitignore; only the
# generated makefile is versioned).
#
# vendor-blobs.mk is GENERATED from the M6T list of the LOS 16.0 workspace
# (713 pairs; FACT: every one of the 713 source files is byte-identical to the
# same path in the factory dump /srv/forge/m6t-dump/system - checked by content
# 2026-09-25) plus the 4 files that tree declared as modules (librilmtk,
# mtk-ril) plus 12 files taken straight from that dump, which the list - made
# BY ANALOGY from M6 - never had although M6T blobs NEED them (model
# treble_blob_audit.py): libimsg_log (teei_daemon, keystore/gatekeeper.mt6750),
# libcamera_bokehutils (libcam.camnode/client/paramsmgr) and the two
# libDepthBokehEffect{,Base} it NEEDs, libarcsoft_beautyshot and
# libarcsoft_high_dynamic_range (libcam.camadapter), lib and lib64 each.
# Not taken: libopenshort, libext4_utils - only the factory-mode `factory`
# binary NEEDs them. Every destination - system/vendor/<x> AND system/<x> - becomes
# $(TARGET_COPY_OUT_VENDOR)/<x>, as in vendor/meizu/m95/m95-vendor.mk:
# FACT (report §4): the stock /system/lib* files in the list are HAL closure
# (camera.mt6750 -> libmeizucamera, libcam.* -> libcam.common.meizu/arcsoft/
# mpbase; the goodix FP stack), which a vendor process can only reach inside
# /vendor.
# Excluded: system/lib/libcurl.so - libcurl is VNDK-core, a /vendor copy would
# shadow the VNDK one in every vendor process (m95 lesson 5, libbinder); and
# vendor/lib{,64}/mediadrm/lib{drmclearkey,mockdrmcrypto}plugin.so - AOSP's own
# reference plugins, which A13 builds to the same path and which a copy rule
# would silently beat (fleet blob audit 2026-09-16, commit 27f353f; the first
# `m nothing` of this branch warned "overriding commands" on exactly these).
# Hard-coded paths: every /system/vendor/... string in the blobs keeps working,
# because the A13 system image carries system/vendor -> /vendor (FACT,
# out-m95 system/vendor symlink); no blob hard-codes a /system/lib* path of a
# file that moved (treble-closure.py scan).
#
# Regenerate (from /srv/forge/android):
#   R=gunwest-import/m6rom16/rom-work
#   python3 meizu-fleet/tools/treble-import-blobs.py \
#     --src-mk $R/vendor/meizu/M6T/M6T-vendor-blobs.mk --src-root $R \
#     --src-prop $R/vendor/meizu/M6T/proprietary \
#     --device-path device/meizu/M6T --out-mk <this dir>/vendor-blobs.mk \
#     --copy-to los20/device/meizu/M6T/proprietary \
#     --extra vendor/lib/librilmtk.so,vendor/lib64/librilmtk.so,vendor/lib/mtk-ril.so,vendor/lib64/mtk-ril.so \
#     --extra2-root /srv/forge/m6t-dump/system \
#     --extra2 vendor/lib/libimsg_log.so,vendor/lib64/libimsg_log.so,vendor/lib/libcamera_bokehutils.so,vendor/lib64/libcamera_bokehutils.so,lib/libarcsoft_beautyshot.so,lib64/libarcsoft_beautyshot.so,lib/libarcsoft_high_dynamic_range.so,lib64/libarcsoft_high_dynamic_range.so,vendor/lib/libDepthBokehEffect.so,vendor/lib64/libDepthBokehEffect.so,vendor/lib/libDepthBokehEffectBase.so,vendor/lib64/libDepthBokehEffectBase.so \
#     --exclude libcurl.so,libdrmclearkeyplugin.so,libmockdrmcryptoplugin.so,init.mal.rc,init.wod.rc \
#     --wiring <this dir>/shims/wiring.txt --bytepatch <this dir>/shims/bytepatch.txt \
#     --prune --name vendor-blobs.mk
# The copies in proprietary/ are therefore NOT the stock files: 128 carry
# patched DT_NEEDED (shims/wiring.txt, model meizu-fleet/tools/
# treble-shim-wiring.py) and libui_ext.so (lib, lib64) a patched operator new
# size (shims/bytepatch.txt). SHA256SUMS holds the hashes of the patched copies.
# ---------------------------------------------------------------------------
$(call inherit-product, $(LOCAL_PATH)/vendor-blobs.mk)

# ---------------------------------------------------------------------------
# Vendor-side providers for libraries the blobs NEED and a Treble vendor
# process cannot take from /system (model: meizu-fleet/tools/
# treble_blob_audit.py, numbers = vendor ELFs whose closure breaks without it).
#
#   libstdc++.vendor         188 - bionic's small libstdc++; not LLNDK/VNDK,
#                                  vendor_available (bionic/libc/Android.bp:2034).
#                                  m95 ships the same (device/meizu/m95/device.mk).
#   libgui (forwarder)        95 - libgui is VNDK-core AND VNDK-private
#                                  (build/make/target/product/gsi/current.txt), so
#                                  the vendor namespace has no link to it. m95
#                                  lesson 6, adapted: here the blobs NEED the plain
#                                  name libgui.so (not rewired like m95's
#                                  libgui_m95), so the forwarder carries stem
#                                  "libgui" - see Android.bp.
#   libcamera_client_vendor   83 - m95 lesson 7: frameworks/av branch
#                                  meizu-legacy-vendor; VendorLegacyCompat.cpp
#                                  exports exactly the two symbols libsource.so of
#                                  this blob set imports (FLEET_PORT report §3.7).
#   libfs_mgr (N-ABI shim)    97 - libnvram imports exactly fs_mgr_read_fstab /
#                                  fs_mgr_get_entry_for_mount_point /
#                                  fs_mgr_free_fstab (nm -D, lib and lib64), the
#                                  same three as m95's libnvram, so m95's shim is
#                                  taken verbatim (shims/fs_mgr.c).
#   libtinycompress, libtinyxml, libalsautils - vendor: true modules the audio
#                                  HAL blobs NEED (audio.primary/audio.usb).
# What is still missing after these (libnativehelper, libandroid_runtime,
# libmedia, libskia, libstagefright, ...) is the shim lane: report §4.
# ---------------------------------------------------------------------------
# N-ABI shims (Android.bp; sources from m95 + graphicbuffer.cpp). Which blob
# NEEDs which is in shims/wiring.txt; counts are consumers (lib + lib64):
#   ui 25 (hwcomposer, libui_ext, camera/OMX), utils 20 (RIL, gralloc, nvram),
#   gui 17 (hwcomposer, libgui_ext, camera), audioutils 11 (audio.primary),
#   sf 7 (libaal, libgui_ext, libshowlogo), net 5 (mtk-ril, thermal),
#   region 2 (Mali's libui.so, replaced). libM6Tshim_power: 0 consumers in
#   this set, not installed. netd_client: stem libnetd_client, NEEDed by
#   name by mtk-ril/mtk-rilmd2 (protectFromVpn) and the IMS blobs. ssl: SSLv3_*
#   for mtk_agpsd, whose libandroid.so NEED is replaced by LLNDK libandroid_net.
PRODUCT_PACKAGES += \
    libM6Tshim_netd_client \
    libM6Tshim_ssl \
    libM6Tshim_gui \
    libM6Tshim_ui \
    libM6Tshim_sf \
    libM6Tshim_utils \
    libM6Tshim_audioutils \
    libM6Tshim_region \
    libM6Tshim_net

PRODUCT_PACKAGES += \
    libstdc++.vendor \
    libgui_vendor \
    libgui_fwd_M6T \
    libcamera_client_vendor \
    libfs_mgr_shim_M6T \
    libtinycompress \
    libtinyxml \
    libalsautils

# ---------------------------------------------------------------------------
# Treble HAL backbone - the m95 list (device/meizu/m95/device.mk, proven to
# reach the setup wizard on the MX6), cut to what THIS blob set can back (the
# hw modules of the M6T dump carry the same names as M6's):
#   kept:  graphics (gralloc.mt6750 + hwcomposer.mt6755), memtrack.mt6750,
#          lights.mt6750, audio (audio.primary.mt6750), keymaster 3.0
#          (keystore.mt6750), gnss 1.0 (gps.mt6750), camera provider 2.4
#          (camera.mt6750), sensors 1.0 (sensors.mt6750), vibrator 1.0
#          (vibrator.default -> the timed_output node), clearkey DRM, software
#          gatekeeper (m95: the N gatekeeper blob imports an ABI A13 lacks);
#   left out, each with its wall in report §5: power (no power.* blob), IR (no
#          IR blob), renderscript (libRSDriver_mtk NEEDs libLLVM/libbcc),
#          bluetooth (only a 32-bit libbt-vendor.so; m95 needed its
#          libm95shim_btvendor), wifi HAL (libwifi-hal-mt66xx lives in the m95
#          tree), fingerprint (m95 needed a patched service), legacy DRM
#          plugins (Widevine NEEDs libprotobuf-cpp-lite).
# Every passthrough *-service needs its *-impl in /vendor/lib*/hw or it exits
# 5 s after start, forever (m95 note) - check installed-files-vendor.txt.
# media.omx@1.0-service and configstore@1.1-service come from base_vendor.mk
# (shipping level <= 29).
# ---------------------------------------------------------------------------
PRODUCT_PACKAGES += \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.allocator@2.0-service \
    android.hardware.graphics.composer@2.1-service \
    android.hardware.graphics.mapper@2.0-impl-2.1 \
    android.hardware.memtrack@1.0-impl \
    android.hardware.memtrack@1.0-service \
    android.hardware.light@2.0-impl \
    android.hardware.light@2.0-service \
    android.hardware.vibrator@1.0-impl \
    android.hardware.vibrator@1.0-service \
    vibrator.default \
    android.hardware.audio.service \
    android.hardware.audio@6.0-impl \
    android.hardware.audio.effect@6.0-impl \
    android.hardware.keymaster@3.0-impl \
    android.hardware.keymaster@3.0-service \
    android.hardware.gatekeeper@1.0-service.software \
    android.hardware.drm@1.3-service.clearkey \
    android.hardware.gnss@1.0-impl \
    android.hardware.gnss@1.0-service \
    android.hardware.camera.provider@2.4-impl \
    android.hardware.camera.provider@2.4-service \
    android.hardware.sensors@1.0-impl \
    android.hardware.sensors@1.0-service
