# Docker build script based on make

IMAGE_PREFIX=nicloud/
IMAGE_VERSION=latest
BUILD_ARGS=

ifeq ($(NO_CACHE),1)
BUILD_ARGS+="--pull --no-cache"
endif

all: base frontend mysql seafile ttrss

base:
	docker build $(BUILD_ARGS) -t $(IMAGE_PREFIX)base:$(IMAGE_VERSION) -f ./images/base/Dockerfile ./images/base/

frontend:
	docker build $(BUILD_ARGS) -t $(IMAGE_PREFIX)frontend-nginx:$(IMAGE_VERSION) -f ./images/frontend-nginx/Dockerfile ./images/frontend-nginx/

mysql:
	docker build $(BUILD_ARGS) -t $(IMAGE_PREFIX)mysql:$(IMAGE_VERSION) -f ./images/mysql/Dockerfile ./images/mysql/

seafile:
	docker build $(BUILD_ARGS) -t $(IMAGE_PREFIX)seafile:$(IMAGE_VERSION) -f ./images/seafile/Dockerfile ./images/seafile/

ttrss:
	docker build $(BUILD_ARGS) -t $(IMAGE_PREFIX)ttrss-nginx:$(IMAGE_VERSION) -f ./images/ttrss-nginx/Dockerfile ./images/ttrss-nginx/

.PHONY: all base frontend mysql seafile ttrss

