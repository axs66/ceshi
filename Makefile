# 环境变量预设
THEOS ?= /opt/theos
THEOS_MAKE_PATH ?= $(THEOS)/makefiles

# 目标配置
export TARGET = iphone:clang:latest
export ARCHS = arm64 arm64e
export FINALPACKAGE = 0
export DEBUG = 1

# 项目名称
TWEAK_NAME = NewFeature
NewFeature_CODESIGN = ldid -S

# 源文件与头文件路径
NewFeature_FILES = Tweak.xm \
                   $(wildcard Hooks/*.xm) \
                   $(wildcard Controllers/*.m)
NewFeature_CFLAGS = -fobjc-arc \
                   -I$(THEOS_PROJECT_DIR)/Headers \
                   -I$(THEOS_PROJECT_DIR)/Hooks \
                   -Wno-error \
                   -Wno-nonnull \
                   -Wno-deprecated-declarations \
                   -Wno-arc-performSelector-leaks \
                   -Wno-incompatible-pointer-types \
                   -Wno-unicode-whitespace

# 框架依赖
NewFeature_FRAMEWORKS = UIKit Foundation LocalAuthentication UserNotifications
NewFeature_PRIVATE_FRAMEWORKS = AppSupport  # 按需添加
NewFeature_LDFLAGS += -weak_framework AppSupport  # 弱链接私有框架

# 加载构建规则
include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
