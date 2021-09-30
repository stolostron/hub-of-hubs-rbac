# Copyright IBM Corp All Rights Reserved.
# Copyright London Stock Exchange Group All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# -------------------------------------------------------------
# This makefile defines the following targets
#
#   - build-images - builds docker image locally for running the components using docker
#   - push-images - pushes the local docker image to docker registry
#   - test	  - run tests
#   - run	  - runs the server

COMPONENT := $(shell basename $(shell pwd))
IMAGE_TAG ?= latest
IMAGE := ${REGISTRY}/${COMPONENT}:${IMAGE_TAG}


.PHONY: build-images			##builds docker image locally for running the components using docker
build-images:
	docker build -t ${IMAGE} -f build/Dockerfile .

.PHONY: push-images			##pushes the local docker image to docker registry
push-images: build-images
	@docker push ${IMAGE}

.PHONY: test				##run tests
test:
	@opa test ./*.rego testdata -v

.PHONY: run				##run the server
run:
	@opa run --server ./*.rego testdata/*.json


.PHONY: help				##show this help message
help:
	@echo "usage: make [target]\n"; echo "options:"; \fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//' | sed 's/.PHONY:*//' | sed -e 's/^/  /'; echo "";
