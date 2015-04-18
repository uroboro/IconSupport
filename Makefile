SUBPROJECTS = Extension extrainst_

export ARCHS = armv7 arm64
export APP_ID := com.chpwn.iconsupport
export TARGET := iphone:7.1:3.0

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

distclean: clean
	- rm -f $(THEOS_PROJECT_DIR)/$(APP_ID)*.deb
	- rm -f $(THEOS_PROJECT_DIR)/.theos/packages/*
