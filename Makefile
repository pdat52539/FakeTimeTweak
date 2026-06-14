THEOS_PACKAGE_SCHEME = rootless
TARGET       := iphone:clang:16.5:15.0
ARCHS        := arm64
include $(THEOS)/makefiles/common.mk
TWEAK_NAME              = FakeTimeTweak
FakeTimeTweak_FILES     = Tweak.x
FakeTimeTweak_CFLAGS    = -fobjc-arc
FakeTimeTweak_LIBRARIES = substrate
include $(THEOS)/makefiles/tweak.mk
