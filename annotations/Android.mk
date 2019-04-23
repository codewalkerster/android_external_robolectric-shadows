##############################################
# Compile Robolectric annotations
##############################################
LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE := Robolectric_annotations

LOCAL_STATIC_JAVA_LIBRARIES := \
  Robolectric_shadowapi \
  jsr305

LOCAL_JAVA_LIBRARIES := \
  robolectric-host-android_all

LOCAL_SRC_FILES := $(call all-java-files-under, src/main/java)

include $(BUILD_HOST_JAVA_LIBRARY)
