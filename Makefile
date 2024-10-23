GOPATH?=$(shell go env GOPATH)

BUILD_BINARY=sql2ent
MAIN_FILE_NAME=main
DOCKER_USER_NAME=codewithyou

.PHONY: build
build:
	go build -ldflags="-s -w" $(MAIN_FILE_NAME).go
	#mv $(MAIN_FILE_NAME) $(GOPATH)/bin/$(MAIN_FILE_NAME)
	#$(BUILD_BINARY)) template clean
	#$(BUILD_BINARY)) template init
	$(if $(shell command -v upx), upx $(BUILD_BINARY))

.PHONY: mac
mac:
	@echo ${GOPATH}
	GOOS=darwin go build -ldflags="-s -w" -o $(BUILD_BINARY) $(MAIN_FILE_NAME).go
	$(if $(shell command -v upx), upx $(BUILD_BINARY)-darwin)
	# mv $(BUILD_BINARY) $(GOPATH)/bin/$(BUILD_BINARY)
	go env -u CGO_ENABLED GOOS GOARCH

.PHONY: win
win:
	GOOS=windows go build -ldflags="-s -w" -o $(BUILD_BINARY).exe $(MAIN_FILE_NAME).go
	$(if $(shell command -v upx), upx $(MAIN_FILE_NAME).exe)
	# mv $(BUILD_BINARY).exe $(GOPATH)/bin/$(BUILD_BINARY).exe
	go env -u CGO_ENABLED GOOS GOARCH

.PHONY: linux
linux:
	GOOS=linux go build -ldflags="-s -w" -o $(BUILD_BINARY) $(MAIN_FILE_NAME).go
	$(if $(shell command -v upx), upx $(BUILD_BINARY)-linux)
	#mv $(BUILD_BINARY) $(GOPATH)/bin/$(BUILD_BINARY)
	go env -u CGO_ENABLED GOOS GOARCH

.PHONY: image
image:
	docker build --rm --platform linux/amd64 -t $(DOCKER_USER_NAME)/$(MAIN_FILE_NAME):$(version) .
	docker tag $(DOCKER_USER_NAME)/$(BUILD_BINARY):$(version) $(DOCKER_USER_NAME)/$(BUILD_BINARY):latest
	docker push $(DOCKER_USER_NAME)/$(BUILD_BINARY):$(version)
	docker push $(DOCKER_USER_NAME)/$(BUILD_BINARY):latest
	docker build --rm --platform linux/arm64 -t $(DOCKER_USER_NAME)/$(BUILD_BINARY):$(version)-arm64 .
	docker tag $(DOCKER_USER_NAME)/$(BUILD_BINARY):$(version)-arm64 $(DOCKER_USER_NAME)/$(BUILD_BINARY):latest-arm64
	docker push $(DOCKER_USER_NAME)/$(BUILD_BINARY):$(version)-arm64
	docker push $(DOCKER_USER_NAME)/$(BUILD_BINARY):latest-arm64

#.PHONY: help
#help: # 显示帮助
#	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done
