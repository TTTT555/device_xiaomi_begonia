LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

include $(CLEAR_VARS)
LOCAL_MODULE       := init.xiaomi_parts.rc
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := etc/init.xiaomi_parts.rc
LOCAL_MODULE_PATH  := $(TARGET_OUT_SYSTEM_ETC)/init/hw
include $(BUILD_PREBUILT)

# init.d
include $(CLEAR_VARS)
LOCAL_MODULE       := sysinit
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_SRC_FILES    := bin/sysinit
LOCAL_MODULE_PATH  := $(TARGET_OUT_EXECUTABLES)
include $(BUILD_PREBUILT)
