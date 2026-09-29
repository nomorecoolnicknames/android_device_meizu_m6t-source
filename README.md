# Meizu M6T

**LineageOS 16.0 · Android 9 · ARM64**

Device configuration and compatibility code maintained by [ReMeizu](https://github.com/nomorecoolnicknames/remeizu).

| Target | Configuration |
| --- | --- |
| Product | `lineage_M6T-userdebug` |
| Device path | `device/meizu/M6T` |
| Platform | MT6750 |
| Display | 720 × 1440 |
| Kernel route | Stock 3.18.35+ prebuilt; optional M6T source build |

## Status

The device configuration is present, but this branch has no verified M6T hardware run. Earlier ROM/graph builds establish build integration only; the panel, touch, radio and camera still need testing on an M6T.

**Source available** means the listed implementation or configuration is in this repository. **External** means it also needs the matching platform, kernel or vendor inputs. **Untested** means there is no functional test for this branch.

## Components

| Subsystem | Implementation / source | Availability | Working status |
| --- | --- | --- | --- |
| Boot / storage | [BoardConfig.mk](BoardConfig.mk) · inherited common init/fstab | Config; kernel image external | Current kernel route untested |
| Display / touch | [overlay](overlay) · [device_M6T.mk](device_M6T.mk) · external MTK HWC/Mali stack | Config; kernel drivers external | Untested with this kernel/ROM configuration |
| Wi-Fi | [wifi](wifi) · [device_M6T.mk](device_M6T.mk) | Configuration; HAL/firmware external | Untested |
| Bluetooth | [bluetooth](bluetooth) · stock MTK transport | Config; controller firmware/vendor transport external | Untested |
| SIM / LTE / calls | [rild-mtk-hidl.rc](rild-mtk-hidl.rc) | RIL service configuration; modem and MTK vendor ABI external | Untested; board-specific modem inputs required |
| Camera | [camera_compat](camera_compat) | GLConsumer/TSF compatibility source; camera HAL external | Untested; calibration and vendor ABI remain board-specific |
| Audio | [device_M6T.mk](device_M6T.mk) · [proprietary-files.txt](proprietary-files.txt) | MTK audio service/configuration; primary HAL external | Untested on this branch |
| Sensors | [device_M6T.mk](device_M6T.mk) · [proprietary-files.txt](proprietary-files.txt) | Init/HAL configuration; board sensor drivers external | Untested |
| Fingerprint | [init.fingerprint.rc](init.fingerprint.rc) | Service/TEE configuration; fingerprint HAL external | Untested |
| GPS | [gps.conf](gps.conf) | Configuration/vendor inputs; GNSS stack external | Location fix unverified |
| Power / USB / SELinux | [BoardConfig.mk](BoardConfig.mk) | Kernel/HAL configuration and policy | Functional testing and enforcing policy pending |

## Build

Use a matching LineageOS 16.0 source tree and place this checkout at `device/meizu/M6T`. LOS16 uses JDK 8. Provide these inputs before running lunch:

| Input | Location / requirement |
| --- | --- |
| Common device tree | `device/meizu/m3_meizu_m6-common` |
| MTK RIL/HAL integration | Matching `vendor/mediatek` sources, including MTK telephony headers |
| Vendor inputs | Prepared `vendor/meizu/M6T` tree matching this device and branch |
| Kernel source / headers | `kernel/meizu/M6T/kernel-3.18` |
| Kernel image | `device/meizu/M6T/prebuilt-kernel/Image.gz-dtb`; use the matching board kernel and DTB |

```sh
source build/envsetup.sh
lunch lineage_M6T-userdebug
m -j4 bacon
```

`M6_KERNEL_FROM_SOURCE=true` selects `kernel/meizu/M6T/kernel-3.18` with `M6T_defconfig`. It prefers the in-tree AArch64 GCC 4.9; if absent, set an absolute `M6T_KERNEL_CROSS_COMPILE_PREFIX`. The `M6_` selector name is retained for compatibility.

## Next steps

- Complete a first hardware boot using M6T-specific panel, touch and partition inputs.
- Validate dual-camera, fingerprint, modem and power behaviour independently of the M6 donor.

The [ReMeizu overview](https://github.com/nomorecoolnicknames/remeizu/blob/main/PROJECT_STATUS.md) tracks the broader project; the [source index](https://github.com/nomorecoolnicknames/remeizu/blob/main/SOURCE_INDEX.md) links device, common and kernel trees.

## Credits

LineageOS and CyanogenMod contributors, the original device-tree authors, and ReMeizu contributors. Historical upstream build notes and links are retained in [UPSTREAM_README.md](UPSTREAM_README.md). Copyright and license notices remain with their source files.
