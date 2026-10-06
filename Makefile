THEOS ?= /workspace/tooling/theos
TARGET := iphone:clang:16.5:16.0
ifeq ($(shell uname -s),Darwin)
ARCHS := arm64 arm64e
else
# Linux OSS clang cannot produce the stable arm64e ABI required on iOS 14+.
# This package is for build validation; build device releases using Xcode.
ARCHS := arm64
_THEOS_PLATFORM_DPKG_DEB := $(CURDIR)/Scripts/dpkg-root-deb.sh
THEOS_PLATFORM_DEB_COMPRESSION_TYPE := xz
endif
THEOS_PACKAGE_SCHEME := rootless
INSTALL_TARGET_PROCESSES := SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := Vela
Vela_FILES := Sources/VelaCore/VLLayout.c Sources/VelaCore/VLStore.m Sources/VelaCompatibility/VLHomeAdapter.m Sources/VelaEditor/VLEditor.m Sources/VelaHome/Tweak.xm
Vela_CFLAGS := -fobjc-arc -Wall -Wextra -I$(THEOS_PROJECT_DIR)/Sources -fmodules-cache-path=$(THEOS_PROJECT_DIR)/.theos/module-cache
Vela_FRAMEWORKS := UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

before-package::
	chmod -R a+rX "$(THEOS_STAGING_DIR)"

.PHONY: test
test:
	@mkdir -p build
	$(HOST_CC) -std=c11 -Wall -Wextra -Werror -fsanitize=address,undefined -g -ISources Sources/VelaCore/VLLayout.c Tests/layout_test.c -lm -o build/layout_test
	./build/layout_test

HOST_CC ?= gcc
