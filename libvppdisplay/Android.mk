# Copyright (C) 2008 The Android Open Source Project
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

LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_PRELINK_MODULE := false
LOCAL_SHARED_LIBRARIES := liblog libutils libcutils libexynosutils \
	libexynosv4l2 libsync libhwcutils
#ifeq ($(BOARD_USES_FIMC), true)
#LOCAL_SHARED_LIBRARIES += libexynosfimc
#else
#LOCAL_SHARED_LIBRARIES += libexynosgscaler
#endif

ifeq ($(BOARD_USES_FB_PHY_LINEAR),true)
	LOCAL_SHARED_LIBRARIES += libfimg
	LOCAL_C_INCLUDES += $(TOP)/hardware/samsung_slsi/exynos/libfimg4x
endif

LOCAL_C_INCLUDES := \
	$(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include \
	$(TOP)/hardware/samsung_slsi/$(TARGET_SOC)/include \
	$(TOP)/hardware/samsung_slsi/$(TARGET_BOARD_PLATFORM)/include \
	$(LOCAL_PATH)/../include \
	$(LOCAL_PATH)/../libhwc \
	$(LOCAL_PATH)/../libhwcutils \
	$(TOP)/hardware/samsung_slsi/exynos/libexynosutils \
	$(TOP)/hardware/samsung_slsi/exynos/libmpp \
	$(TOP)/hardware/samsung_slsi/$(TARGET_SOC)/libhwcmodule \
	$(TOP)/hardware/samsung_slsi/$(TARGET_SOC)/libhwcutilsmodule \
	$(TOP)/hardware/samsung_slsi/$(TARGET_SOC)/libdisplaymodule

LOCAL_ADDITIONAL_DEPENDENCIES += \
	$(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

ifeq ($(BOARD_HDMI_INCAPABLE), true)
	LOCAL_C_INCLUDES += $(LOCAL_PATH)/../libhdmi_dummy
else
	LOCAL_C_INCLUDES += $(LOCAL_PATH)/../libvpphdmi
endif

ifeq ($(BOARD_USES_VIRTUAL_DISPLAY), true)
ifeq ($(BOARD_USES_VPP), true)
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../libvppvirtualdisplay
else
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../libvirtualdisplay
endif
endif

LOCAL_SRC_FILES := \
	ExynosDisplay.cpp \
	ExynosOverlayDisplay.cpp \
	ExynosDisplayResourceManager.cpp

ifeq ($(BOARD_USES_DUAL_DISPLAY), true)
LOCAL_SRC_FILES += ExynosSecondaryDisplay.cpp
endif

include $(TOP)/hardware/samsung_slsi/$(TARGET_SOC)/libdisplaymodule/Android.mk

LOCAL_MODULE_TAGS :=
LOCAL_MODULE := libexynosdisplay

include $(TOP)/hardware/samsung_slsi/exynos/BoardConfigCFlags.mk
include $(BUILD_SHARED_LIBRARY)

