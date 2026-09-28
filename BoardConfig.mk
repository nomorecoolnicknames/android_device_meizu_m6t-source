#
# BoardConfig.mk - Meizu M6T (M6T / M811H), MediaTek MT6750
# LineageOS 18.1 / Android 11 bring-up device tree.
#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# ---------------------------------------------------------------------------
# EVIDENCE POLICY (see /srv/forge/android/CLAUDE.md §2)
# FACT       = read off a file / image header / scatter on this disk.
# INFERENCE  = derived from one or more FACTs.
# HYPOTHESIS = untested; carries a falsification step.
#
# Companion report: /srv/forge/android/meizu-fleet/trees/M6T_LOS20_TREE.md
#
# ###########################################################################
# BENCH TREE. NO HARDWARE EXISTS FOR THIS DEVICE IN THIS PROJECT.
# FACT (M6T_ROADMAP.md §1): not one M6T artifact has ever been flashed or booted;
# adb and fastboot were both empty when the lane was last active (2026-07-25).
# Nothing below has been observed on a running M6T. Where a number comes from the
# factory dump it is FACT about the dump; where it comes from M6 it is INFERENCE
# and says so.
# ###########################################################################
#
# 2026-09-25, branch lineage-20-treble: FULL TREBLE, like m95. /vendor is the
# real `custom` partition (p3, ~1 GiB per the factory scatter), every N blob of
# the factory dump lives there (vendor-blobs.mk), VNDK = current. Report with
# the evidence: meizu-fleet/designs/TREBLE_M6_M6T_20260924.md.
# ---------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------
# Architecture
#
# FACT (/srv/forge/m6t-dump/system/build.prop):
#   ro.board.platform=mt6750, ro.mediatek.platform=MT6750, chip_ver=S01,
#   ro.product.cpu.abi=arm64-v8a, abilist=arm64-v8a,armeabi-v7a,armeabi,
#   branch alps-mp-n0.mp7.
# FACT: MT6750 is 8x Cortex-A53 - the down-binned bin of the same silicon as
#   MT6755 (BSP directory mt6755, CONFIG_ARCH_MT6755=y;
#   meizu-fleet/factbase/mt6755_family.md §7). Cortex-A53 has no LSE atomics
#   (FEAT_LSE is ARMv8.1-A).
# FACT: the decompiled stock appended DTB has model = "MT6755"
#   (M6T_DUMP_ANALYSIS_2026-07-22.md §3).
#
# FACT: build/soong/cc/config/arm64_device.go:31-33 maps "armv8-a" to exactly
#   `-march=armv8-a`; :57-59 maps "cortex-a53" to `-mcpu=cortex-a53`. Neither
#   enables +lse. Forbidden neighbours in the same table: "armv8-2a",
#   "cortex-a55". NEITHER is used here.
#
# DO NOT change TARGET_ARCH_VARIANT to armv8-2a or TARGET_CPU_VARIANT to
# cortex-a55/kryo*/exynos-m*.
#
# CHANGED vs the existing M6T tree, deliberately: it inherits
#   TARGET_CPU_VARIANT := generic from m3_meizu_m6-common. `generic` costs the
#   A53 erratum workaround (-Wl,--fix-cortex-a53-843419) for no benefit.
#
# ALSO REJECTED for this tree: M6_PURE_ARM64 := true, which the existing M6T
#   BoardConfig sets (it publishes only arm64-v8a and refuses to start
#   zygote_secondary, because "app_process32 still aborts and kills zygote64").
#   That was an Oreo workaround for a specific 32-bit abort on Nougat blobs. On a
#   device that has never booted anything, carrying a workaround for an
#   unreproduced bug is guessing twice over.
# ---------------------------------------------------------------------------
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
# FACT: the existing tree asserts `M6T`. The rest are the factory identity
# strings from /srv/forge/m6t-dump/system/build.prop.
TARGET_OTA_ASSERT_DEVICE := M6T,MeizuM6T,M811H,m1811

# ---------------------------------------------------------------------------
# Screen - AND A CORRECTION TO THE EXISTING TREE.
#
# FACT: M6T is 720 x 1440 (18:9). Read out of the decompiled stock appended DTB:
#   `tpd-resolution <0x2d0 0x5a0>` = 720 x 1440
#   (meizu_m6t/M6T_DUMP_ANALYSIS_2026-07-22.md §3, which states it as the "hard
#    fact" that separates M6T from M6).
# FACT: ro.sf.lcd_density=320 in /srv/forge/m6t-dump/system/build.prop.
#
# REJECTED: TARGET_SCREEN_HEIGHT := 1280 - the value in the existing tree
#   (meizu_m6/rom-lineage-15.1-meizu_m6-experimental/device/meizu/M6T/cm.mk:22).
#   It is M6's 720x1280 copied unchanged when the M6T tree was bootstrapped from
#   M6, and the dump analysis explicitly flags this as the main display delta:
#   "different physical panel modules, different timing/init. At most the
#   ILI9881C driver IC is reusable as a base".
#
# PANEL - open, and open in a specific way worth writing down.
#   FACT: stock registers THREE LCM drivers, lcm_count = 3 @0xffffffc00116cf38,
#     and selection is BY NAME - disp_lcm_probe() does strcmp(lcm_drv->name,
#     plcm_name) against the name LK passes; compare_id is not in that path
#     (M6T_ROADMAP.md §2.1, which also records the two earlier claims it
#     REJECTED: "four drivers" and "selection by compare_id").
#   FACT: our kernel has reverse-engineered and ported ft8613_hd_dsi_vdo_tcl and
#     nt36525_hd_dsi_vdo_djn and fixed hx83102b_hd_dsi_vdo_lide (kernel commits
#     d0b07a18b8a, ed518f2db0e).
#   FACT: `atag,videolfb-lcmname = "ili9881c_hd_dsi_txd"` in the stock M6T DTB -
#     but that field is NOT a reliable panel identity: the stock M6 DTB carries
#     nt35695_fhd_dsi_cmd_truly_nt50358_drv while the M6 runtime lights ili9881c
#     (M6T_DUMP_ANALYSIS §3).
#   HYPOTHESIS: an M6T body will select one of the three ported drivers by name
#     and light up. FALSIFICATION: first flash on real hardware - read the
#     lcmname LK passes (atag/expdb) and check whether it matches one of the
#     three compiled names. Until then no panel is pinned anywhere in this tree,
#     which is the correct behaviour for a name-dispatched LCM stack.
# ---------------------------------------------------------------------------
TARGET_SCREEN_WIDTH := 720
TARGET_SCREEN_HEIGHT := 1440
TARGET_RECOVERY_PIXEL_FORMAT := BGRA_8888

# ---------------------------------------------------------------------------
# Partitions - A-only, no slots, no dynamic partitions, no super.
#
# GROUND TRUTH = the factory scatter shipped in the stock dump,
#   /srv/forge/m6t-dump/scatter.txt. Sizes are the deltas between consecutive
#   start offsets (FACT):
#     recovery 0x00008000  -> para     0x04008000   => 0x04000000 =   64 MiB
#     custom   0x04088000  -> expdb    0x44085c00   => 0x3fffdc00 = 1023.99 MiB
#     expdb    0x44085c00  -> frp      0x44a85c00   => 0x00a00000 =   10 MiB
#     boot     0x4e300000  -> logo     0x4f300000   => 0x01000000 =   16 MiB
#     system   0x52800000  -> cache    0x152800000  => 0x100000000 = 4096 MiB
#     cache    0x152800000 -> userdata 0x16d800000  => 0x1b000000  =  432 MiB
#   There is NO `vendor` entry.
#
# M6T IS NOT M6 HERE, and this is the single most useful number in the file:
#   M6's system is 2560 MiB, M6T's is 4096 MiB. m5c's whole LOS20 lane is blocked
#   on a 174 MiB system-image deficit (BRINGUP_STATE.md §1, M5C_LOS20_TREE.md §7).
#   M6T has 1.5 GiB of headroom over M6 for the same payload. Whoever schedules
#   this fleet should know that.
#   Also different: recovery is 64 MiB (M6: 32, m681: 16) and `custom` is ~1 GiB
#   (M6 and m681: 512 MiB).
#   Verified by diffing the two scatters: 29 of 34 lines differ.
#
# BOARD_RECOVERYIMAGE_PARTITION_SIZE is set to the scatter value, 64 MiB. The
#   existing M6T tree inherits 33554432 (32 MiB) from m3_meizu_m6-common, i.e.
#   M6's value - that is under-declaring, harmless for flashing but wrong.
#
# INFERENCE, not FACT: BOARD_USERDATAIMAGE_PARTITION_SIZE. The scatter has no end
#   offset for userdata and no M6T eMMC capacity has been read. The value below
#   is M6's, carried purely so the variable is not empty; it is inert because we
#   do not build userdata.img. Do not use it for anything.
# ---------------------------------------------------------------------------
BOARD_FLASH_BLOCK_SIZE := 131072

BOARD_BOOTIMAGE_PARTITION_SIZE := 16777216
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 4294967296
BOARD_CACHEIMAGE_PARTITION_SIZE := 452984832
BOARD_USERDATAIMAGE_PARTITION_SIZE := 11683216896

# /vendor = the `custom` partition. INFERENCE for its place and size, not FACT -
# there is no M6T to read a GPT from:
#   FACT: factory scatter custom 0x04088000 -> expdb 0x44085c00 = 0x3fffdc00
#     = 1 073 732 608 B, third user-area partition (table above). (The
#     "1 073 723 392" in trees/M6T_LOS20_TREE.md §2.4 is an arithmetic slip,
#     9216 B short; python: 0x44085c00 - 0x4088000.)
#   FACT: on M6 the same kind of Flyme scatter matches the live GPT exactly
#     (p3 custom 524288 KiB = the scatter delta; meizu_m6/captures/
#     m6cap-20260725-1305/03-partitions), and the M6T scatter has the same
#     names in the same order (29 of 34 lines differ only by offset).
#   => custom = mmcblk0p3, 1 073 732 608 B. That is not a multiple of 4096
#   (3072 B over), so the image size is rounded DOWN to whole 4 KiB blocks:
#   0x3fffd000 = 1 073 729 536 B. Never round up - a larger image would run into
#   expdb.
# FACT: stock keeps only regional data there - /srv/forge/m6t-dump/custom has
#   3rd-party/apk language packs; back it up before the first vendor.img flash.
# FACT: the vendor payload is 295 MiB of blobs (proprietary/, 724 files) plus
#   the AOSP HAL modules.
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

# ---------------------------------------------------------------------------
# Treble / VNDK - ON (owner directive 2026-09-24: "all of the fleet Treble",
# template device/meizu/m95). Until 2026-09-24 this block said OFF; its facts
# still hold and are why this is a conversion, not a flag flip:
#   FACT: the stock dump is NOT Treble - no `vendor` partition in the factory
#     scatter, "Android-7 layout (no separate vendor partition; system-as-root)"
#     (M6T_DUMP_ANALYSIS §4), ro.product.first_api_level=24 and no ro.treble /
#     ro.vndk in /srv/forge/m6t-dump/system/build.prop;
#   INFERENCE (from M6): the Nougat MTK blob set needed a 40-entry
#     TARGET_LD_SHIM_LIBS cascade on Pie.
#
# What the conversion is (same as meizu_m6, same as m95):
#   * PRODUCT_FULL_TREBLE_OVERRIDE := true (lineage_M6T.mk); the shipping level
#     stays the honest 24; LINKER_NAMESPACES, SEPOLICY_SPLIT and
#     ENFORCE_VINTF_MANIFEST follow the override (config.mk:668-694);
#   * a real /vendor image (partition block above, fstab first_stage_mount);
#   * BOARD_VNDK_VERSION := current (m95 measured that a pinned older VNDK cannot
#     build on A13); no PRODUCT_EXTRA_VNDK_VERSIONS - there is no older M6T
#     vendor image to stay compatible with.
# What it costs (report §4, model treble_blob_audit.py): a vendor process no
# longer sees /system/lib*, so blobs NEEDing libmedia, libskia,
# libandroid_runtime, libstagefright, libnativehelper, ... need vendor copies or
# shims (m95: shims/Android.bp); SurfaceFlinger loads libGLES_mali in the sphal
# namespace, where libui.so and libnetutils.so (both NEEDed by this Mali
# closure) are not visible - libbinder is, via the platform branch
# system/linkerconfig meizu-legacy-vendor.
# ---------------------------------------------------------------------------
TARGET_COPY_OUT_VENDOR := vendor
BOARD_VNDK_VERSION := current
BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED := true

# Vendor-owned properties (hw module suffixes, RIL, legacy-kernel VINTF flag).
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# ---------------------------------------------------------------------------
# Boot image geometry
#
# FACT - read directly out of the FACTORY boot image in the stock dump,
#   /srv/forge/m6t-dump/boot.img (10 640 256 B,
#   sha256 49aadf452084d3eec271bff16c5e5ddd42494d11d491e31bad43350138684c0f -
#   the same hash M6T_DUMP_ANALYSIS_2026-07-22.md §2 records). Header v0:
#     kernel_addr  0x40080000  => BOARD_KERNEL_BASE 0x40078000 (addr - 0x8000)
#     ramdisk_addr 0x45000000  => ramdisk_offset 0x04f88000
#     second_addr  0x40f00000  => second_offset  0x00e88000  (second_size = 0)
#     tags_addr    0x44000000  => tags_offset    0x03f88000
#     page_size    2048        name "1550465732"  header_version 0
#
# This is the ONE artifact in this whole tree that is known to have run on M6T
# hardware, so its numbers win over everything else.
#
# NOTE, and this is a real difference from the existing tree: the LOS 15.1 M6T
#   build (meizu_m6t/out/boot.img) carries second_offset 0x00f00000 and board
#   "1552631950" - both inherited from m3_meizu_m6-common, i.e. M6's values, not
#   M6T's. second_size is 0 everywhere so the offset is inert; the board id is a
#   16-byte string LK does not check on this family. Still, factory numbers are
#   used here because there is no reason to prefer a copy of another device's.
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Kernel command line
#
# FACT: the factory boot.img cmdline is exactly
#   `bootopt=64S3,32N2,64N2 androidboot.selinux=permissive`
#   (header parse of /srv/forge/m6t-dump/boot.img - yes, the factory image ships
#   permissive).
#
# ADDED here, each with its reason:
#   androidboot.hardware=mt6755   - INFERENCE from M6, where it is measured; it
#     is what names init.mt6755.rc / ueventd.mt6755.rc / fstab.mt6755, all of
#     which the M6T stock ramdisk also carries (M6T_DUMP_ANALYSIS §4).
#   binder.devices=binder,hwbinder,vndbinder - the 3.18 kernel this tree pins has
#     CONFIG_ANDROID_BINDER_DEVICES (unlike m681's 4.4, where the symbol does not
#     exist in Kconfig at all), and every HIDL service needs /dev/hwbinder. The
#     M6 LOS16 images that boot carry exactly this string.
#   androidboot.usb.config=adb    - a device with no UART and no owner in the
#     room needs adb to be the first thing that comes up.
# ---------------------------------------------------------------------------
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2 androidboot.hardware=mt6755 androidboot.selinux=permissive binder.devices=binder,hwbinder,vndbinder androidboot.usb.config=adb buildvariant=userdebug

# ---------------------------------------------------------------------------
# Kernel - PREBUILT. This tree never compiles a kernel.
#
# 2026-09-25 19:10 - prebuilt/Image.gz-dtb is now the eBPF kernel of lane
#   kernel-ebpf-318: 7 808 706 B, sha256 36fdb32cd1908290c64fded0c5d191684dad822d6deb4b75dab2c3881940954d
#   (= meizu-fleet/artifacts/kernel-M6T/Image.gz-dtb-ebpf-78a4abe48f0, checked against its SHA256SUMS),
#   3.18.140 #1 SMP PREEMPT Fri Sep 25 18:16:18 MSK 2026, source forge/M6T-ebpf 78a4abe48f0
#   (meizu-fleet/wt/kernel_*_ebpf, M6T_a13_defconfig; design
#   meizu-fleet/designs/KERNEL_EBPF_FLEET_20260925.md). FACT (that lane): the
#   real 3.18.140 verifier (UML) accepts all 19 critical LOS20 BPF programs.
#   78a4abe48f0 (parent 616d06bebd6) fixes fs/proc/dcheck_root.c: the Huawei
#   late_initcall opened /default.prop and checked filp only for NULL; the A13
#   ramdisk has no /default.prop, filp_open returns ERR_PTR(-ENOENT) -> panic
#   before init with an A13 ramdisk in EVERY earlier image, the LOS16 kernel
#   below included (an A9 ramdisk has /default.prop, which is why LOS16 boots).
#   First-boot check: dmesg | grep DEFAULT_PROP_FILE -> "OPEN FAIL!", no oops.
#   CONFIG_MTK_LCM_PHYSICAL_ROTATION_HW=y, as in M6T_defconfig that the previous
#   prebuilt was built from (the M6 body's upside-down lesson is NOT verified for
#   the M6T panel - check on first boot, there is no M6T hardware yet).
#   The paragraphs below describe the PREVIOUS prebuilt and are kept as history.
#
# HISTORY - the previous prebuilt/Image.gz-dtb was 7 763 313 B,
#   sha256 49c789054765bf378efe9880260c242a079bdc7b6288e38c6ee03167a34bbe73.
#   Copied 2026-09-16 from
#   /srv/forge/android/meizu_m6t/kernel-3.18-m6t/kernel-3.18/out/
#   forge-M6T_defconfig/arch/arm64/boot/Image.gz-dtb
#   (the same binary is also present as
#    meizu_m6/rom-lineage-15.1-meizu_m6-experimental/device/meizu/M6T/
#    prebuilt-kernel/Image.gz-dtb.forge-source).
# FACT: its gzip payload carries the banner
#   "Linux version 3.18.140 (n8n@n8nagent) (gcc version 4.9 20150123
#    (prerelease) (GCC)) #7 SMP PREEMPT Sat Jul 25 14:56:03 MSK 2026".
# FACT: that is the newest M6T kernel on this disk, from the worktree
#   kernel-3.18-m6t/kernel-3.18 built with M6T_defconfig - a defconfig
#   RECONSTRUCTED FROM kallsyms because the stock kernel has no CONFIG_IKCONFIG
#   (M6T_ROADMAP.md §1, KERNEL_REVERSE_HANDOFF.md) - plus meizu_m6t.dts and the
#   three reverse-engineered LCM drivers.
# FACT: IT HAS NEVER BEEN FLASHED OR BOOTED. Nothing on this lane ever has.
#
# WHY NOT THE STOCK KERNEL. The factory Image.gz-dtb is on disk too:
#   8 030 464 B, sha256
#   e45de551e526f1c792bf531664e42afabc2ece5881f5485159e2f003a474e60c,
#   "Linux version 3.18.35+ (flyme@Mz-Builder-L19) ... #1 SMP PREEMPT Mon Feb 18
#    13:14:56 CST 2019", extractable from /srv/forge/m6t-dump/boot.img and also
#   sitting as device/meizu/M6T/prebuilt-kernel/Image.gz-dtb in the LOS15.1 tree.
#   It is the only kernel FACT-known to have run on an M6T - but it does not
#   contain the lane's work (the three ported LCM drivers, the corrected cust.dtsi
#   EINT lines - als was on EINT 6 instead of 11, gyro on 4 instead of 75, kernel
#   99c306d5f89). Pinning stock would throw that away. If a first bring-up needs
#   a known-good fallback, that hash is the fallback. Swap the two files; nothing
#   else in this tree changes.
#
# HONEST LABEL: Android 13 will NOT start on either kernel. Both are 3.18: no
#   CONFIG_CGROUP_BPF, so bpfloader fails, and A13's bpfloader.rc carries
#   `reboot_on_failure reboot,bpfloader-failed` - a permanent reboot loop, not a
#   degraded boot. Gap table: meizu-fleet/trees/M681_LOS20_TREE.md §3.1.
#
# 2026-09-25 (Treble report §3): FACT M6T_defconfig sets no CONFIG_BPF* at all,
#   so bpf() is absent and bpfloader's own createMap(BPF_MAP_TYPE_ARRAY) fails
#   (system/bpf/bpfloader/BpfLoader.cpp:202-208) -> exit 1 -> reboot. FACT: m95
#   boots A13 on 3.18.22 with a backport series in meizu_mx6_m95/kernel/m685
#   (bff848dd, 8a7d274c, ee0cebee, d3f29d6a, cf625052 - eBPF; 71d371d4,
#   9c36a785, a17f1228 - apex/adbd; 65654a98 - remount soft lockup). Porting it
#   to kernel-3.18-m6t (3.18.140, the same source line as M6) is the shortest
#   path; cgroup v2 is handled in userspace (system/core meizu-legacy-kernel).
# Treble itself needs NO kernel change: FACT, neither this prebuilt's appended
#   DTB nor the stock one (/srv/forge/m6t-dump/boot.img) has a firmware/android
#   node (dtc), so first-stage init reads the ramdisk fstab; the by-name paths
#   there need the kernel to emit PARTNAME - FACT for the M6 kernel of the same
#   source line (by-name links on the live M6), INFERENCE for M6T.
#
# The LOS kernel task takes the prebuilt branch only when KERNEL_SRC does not
# exist on disk (vendor/lineage/build/tasks/kernel.mk:127-148). (Superseded
# 2026-09-25: the source exists now, TARGET_FORCE_PREBUILT_KERNEL below keeps the
# prebuilt.)
# ---------------------------------------------------------------------------
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
