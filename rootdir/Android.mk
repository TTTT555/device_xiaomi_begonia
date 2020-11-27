LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

# init.d
include $(CLEAR_VARS)
LOCAL_MODULE       := sysinit
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_SRC_FILES    := bin/sysinit
LOCAL_MODULE_PATH  := $(TARGET_OUT_EXECUTABLES)
include $(BUILD_PREBUILT)
