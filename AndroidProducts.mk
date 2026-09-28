# Pie derives the product NAME from the basename of a path-only entry; use the
# explicit name:path form (same fix as meizu_m6).
PRODUCT_MAKEFILES := \
    lineage_M6T:$(LOCAL_DIR)/lineage.mk

COMMON_LUNCH_CHOICES := \
    lineage_M6T-userdebug \
    lineage_M6T-eng
