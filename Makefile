ARCHS = arm64 arm64e
THEOS_DEVICE_IP = localhost -p 2222
INSTALL_TARGET_PROCESSES = SpringBoard
TARGET = iphone:clang:15.5:14.4
PACKAGE_VERSION = 1.1.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ProtectedBrowser

ProtectedBrowser_FILES = $(shell find Sources/ProtectedBrowser -name '*.swift') $(shell find Sources/ProtectedBrowserC -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
ProtectedBrowser_SWIFTFLAGS = -ISources/ProtectedBrowserC/include
ProtectedBrowser_CFLAGS = -fobjc-arc -ISources/ProtectedBrowserC/include

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += protectedbrowser
include $(THEOS_MAKE_PATH)/aggregate.mk
