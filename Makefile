# 目标设备最低版本
export TARGET = iphone:clang:latest
export ARCHS = arm64 arm64e
export FINALPACKAGE = 0
export DEBUG = 1

# 项目名称
TWEAK_NAME = NewFeature

# 作用是为名为 NewFeature 的Tweak指定签名工具和签名方式
NewFeature_CODESIGN = ldid -S

# 源文件
NewFeature_FILES = NewFeature.xm \
                   $(wildcard Hooks/*.xm) \
                   $(wildcard Controllers/*.m)
# 编译标志
NewFeature_CFLAGS = -fobjc-arc \
                   -I$(THEOS_PROJECT_DIR)/Headers \
                   -I$(THEOS_PROJECT_DIR)/Hooks \
                   -Wno-error \
                   -Wno-nonnull \
                   -Wno-deprecated-declarations \
                   -Wno-incompatible-pointer-types \
                   -Wno-unicode-whitespace
# 框架依赖
NewFeature_FRAMEWORKS = UIKit Foundation LocalAuthentication UserNotifications

include $(THEOS_MAKE_PATH)/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
