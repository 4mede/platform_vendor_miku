#
# Copyright (C) 2018 The Android Open Source Project
# Copyright (C) 2021-2022 Miku UI
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Inherit from custom extra
$(call inherit-product-if-exists, vendor/extra/product.mk)

# Exclude repos from bp scanning
PRODUCT_SOURCE_ROOT_DIRS += -kernel/platform
PRODUCT_SOURCE_ROOT_DIRS += -prebuilts/misc/protobuf_vendorcompat

# Allow vendor prebuilt repos to exclude themselves from bp scanning
-include $(sort $(wildcard vendor/*/*/exclude-bp.mk))

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PRODUCT_PROPERTIES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PRODUCT_PROPERTIES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.software.sip.voip.xml

# Credential storage
PRODUCT_PACKAGES += \
    android.software.credentials.prebuilt.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:$(TARGET_COPY_OUT_PRODUCT)/usr/keylayout/Vendor_045e_Product_0719.kl
    
# Enforce privapp-permissions whitelist
PRODUCT_PRODUCT_PROPERTIES += \
    ro.control_privapp_permissions=enforce

# Inherit from our versioning
$(call inherit-product, vendor/miku/config/versioning.mk)

# Inherit from our overlay
$(call inherit-product, vendor/miku/config/overlay.mk)

# Sign for official build
ifeq ($(TARGET_FORCE_SIGN_CHECK),true)
$(call inherit-product, vendor/miku-secret/keys/sign.mk)
else
$(call inherit-product-if-exists, vendor/miku-secret/keys/sign.mk)
endif

ifneq ($(TARGET_DISABLE_EPPE),true)
# Require all requested packages to exist
$(call enforce-product-packages-exist-internal,$(lastword $(_include_stack)),product_manifest.xml rild Calendar Launcher3 Launcher3Go Launcher3QuickStep Launcher3QuickStepGo android.hidl.memory@1.0-impl.vendor vndk_apex_snapshot_package)
endif

# Applications
ifneq ($(TARGET_NO_APERTURE),true)
    PRODUCT_PACKAGES += Aperture
else
    PRODUCT_PACKAGES += Camera2
endif

# Miku UI Music Center
ifneq ($(TARGET_EXCLUDE_MUSIC_CENTER),true)
PRODUCT_PACKAGES += MikuUIMusicCenter
endif

PRODUCT_PACKAGES += \
    Gboard \
    LiveWallpapersPicker \
    MUBB \
    MULS_Dummy \
    PartnerBookmarksProvider \
    ThemePicker \
    ThemesStub

# Lineage AudioFX
ifneq ($(TARGET_EXCLUDES_AUDIOFX),true)
PRODUCT_PACKAGES += \
    AudioFX
endif

# Bootanimation
PRODUCT_PACKAGES += \
    bootanimation.zip \
    bootanimation-dark.zip

# Charger mode images
PRODUCT_PACKAGES += \
    charger_res_images \
    product_charger_res_images
    
# FRP
PRODUCT_COPY_FILES += \
    vendor/miku/prebuilt/common/bin/wipe-frp.sh:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/wipe-frp
    
# OverlayFS
PRODUCT_PACKAGES_DEBUG += \
    disable-overlays

# Ringtone
PRODUCT_COPY_FILES += \
    vendor/miku/ringtone/miku_secret.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/miku_secret.ogg \
    vendor/miku/ringtone/miku_deep_sea_girl.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/miku_deep_sea_girl.ogg \
    vendor/miku/ringtone/miku_noti_msg.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/miku_noti_msg.ogg

PRODUCT_PRODUCT_PROPERTIES += \
    ro.config.ringtone=miku_secret.ogg \
    ro.config.notification_sound=miku_noti_msg.ogg
    
# Storage manager
PRODUCT_PRODUCT_PROPERTIES += \
    ro.storage_manager.enabled=true

# Performance Mode
PRODUCT_COPY_FILES += \
    vendor/miku/prebuilt/common/etc/init/init.miku.performance_mode.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/init.miku.performance_mode.rc

# Enable Material Design 3 ExpressiveAdd commentMore actions
PRODUCT_PRODUCT_PROPERTIES += \
    is_expressive_design_enabled=true

# MikuWallpapers
PRODUCT_PACKAGES += \
    MikuWallpapers

# ThemeOverlays
include packages/overlays/Themes/themes.mk

# Do not include art debug targets
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

# Enable whole-program R8 Java optimizations for SystemUI and system_server,
# but also allow explicit overriding for testing and development.
SYSTEM_OPTIMIZE_JAVA ?= true
SYSTEMUI_OPTIMIZE_JAVA ?= true

# SystemUI
PRODUCT_DEXPREOPT_SPEED_APPS += \
    SystemUI

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    dalvik.vm.systemuicompilerfilter=speed

ifeq ($(TARGET_BUILD_VARIANT),userdebug)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    debug.sf.enable_transaction_tracing=false
endif

# Compile everything
PRODUCT_DEX_PREOPT_DEFAULT_COMPILER_FILTER := everything

# Disable extra StrictMode features on all non-engineering builds
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.sys.strictmode.disable=true

# Boost Framework
ifneq ($(TARGET_MIKU_BOOST_FRAMEWORK_PLATFORM),)
$(call inherit-product, device/qcom/perf/BoostFramework.mk)
endif
