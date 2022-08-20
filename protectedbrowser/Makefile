ARCHS = arm64 arm64e
TARGET = iphone:clang:15.5:14.4

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = protectedbrowser

protectedbrowser_LIBRARIES = gscommon
protectedbrowser_EXTRA_FRAMEWORKS = AltList
protectedbrowser_FILES = $(shell find Sources/protectedbrowser -name '*.swift') $(shell find Sources/protectedbrowserC -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
protectedbrowser_SWIFTFLAGS = -ISources/protectedbrowserC/include
protectedbrowser_INSTALL_PATH = /Library/PreferenceBundles
protectedbrowser_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
