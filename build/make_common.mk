#
# Common Makefile routines for image building
#

-include ./custom.mk

ifeq ($(IMAGE_PREFIX),)
IMAGE_PREFIX = nicloud/
endif
VERSION_SUFFIX ?= 

# computed variables
IMAGE_NAME = $(shell basename "$$(pwd)")
IMAGE_VERSION_FILE = $(shell cat VERSION | head -1)
VERSION_DATE = $(shell date +'%y-%m-%d')
IMAGE_VERSION = $(IMAGE_VERSION_FILE)$(IMAGE_VERSION_SUFFIX)
FULL_IMAGE_NAME=$(IMAGE_PREFIX)$(IMAGE_NAME)

BUILD_ARGS = --pull
ifeq ($(NO_CACHE),1)
BUILD_ARGS += --no-cache
endif

build:
	docker build $(BUILD_ARGS) -t $(FULL_IMAGE_NAME):$(IMAGE_VERSION) -f Dockerfile .
	docker tag $(FULL_IMAGE_NAME):$(IMAGE_VERSION) $(FULL_IMAGE_NAME):latest

push:
	docker push $(FULL_IMAGE_NAME):$(IMAGE_VERSION)
	docker push $(FULL_IMAGE_NAME):latest

.PHONY: build push

