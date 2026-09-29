# Meizu M6T: LineageOS 16.0

Device configuration, init rules, SELinux policy and compatibility code for Android 9.
Place this tree at `device/meizu/M6T` in the matching LineageOS source tree.

The build requires the referenced common and MediaTek platform trees, matching kernel
source/headers and prebuilt image where selected, and this board’s proprietary inputs.
Use `proprietary-files.txt`, dependency manifests and kernel checks provided by this branch.
Prebuilt firmware and complete ROM images are not supplied by this repository.

After providing those inputs, select `lunch lineage_M6T-userdebug`.
These sources remain under development; compiling them does not certify all hardware
or establish a tested installable release.

Retain the copyright and license notices in individual files.

The default kernel route uses a prebuilt. `M6_KERNEL_FROM_SOURCE=true` selects the M6T
source route, preferring the in-tree AArch64 GCC 4.9. If absent, set an absolute
`M6T_KERNEL_CROSS_COMPILE_PREFIX` for that same toolchain.
