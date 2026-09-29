# Meizu M6T: LineageOS 16.0

Device configuration, init rules, policy and compatibility code.
Place at `device/meizu/M6T` in the matching LineageOS source tree.
Provide the referenced common/MediaTek trees, matching kernel source or prebuilt,
and board-specific vendor inputs from `proprietary-files.txt` and dependency manifests.
Keep the included kernel/input checksum checks enabled.
Select `lunch lineage_M6T-userdebug`.

The default kernel route uses a prebuilt. `M6_KERNEL_FROM_SOURCE=true` selects the M6T
source route, preferring the in-tree AArch64 GCC 4.9. If absent, set an absolute
`M6T_KERNEL_CROSS_COMPILE_PREFIX` for that same toolchain.
