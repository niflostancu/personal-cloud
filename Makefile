# Docker build script based on make

# variables passed to the other Makefiles
IMAGE_PREFIX?=
VERSION_SUFFIX?=
NO_CACHE?=
BUILD_ARGS?=
export IMAGE_PREFIX VERSION_SUFFIX NO_CACHE BUILD_ARGS

all: base frontend mysql seafile ttrss

push:
	make -C ./images/base/ push
	make -C ./images/frontend-nginx/ push
	make -C ./images/mysql/ push
	make -C ./images/seafile/ push
	make -C ./images/ttrss-nginx/ push
	make -C ./images/phabricator/ push

base:
	make -C ./images/base/ build

frontend:
	make -C ./images/frontend-nginx/ build

mysql:
	make -C ./images/mysql/ build

seafile:
	make -C ./images/seafile/ build

phabricator:
	make -C ./images/phabricator/ build

ttrss:
	make -C ./images/ttrss-nginx/ build

.PHONY: all push base frontend mysql seafile ttrss

