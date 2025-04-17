APP_NAME := myapp
VERSION ?= 1.0.0
BUILD_DIR := ./bin
DOCKER_IMAGE := golang
BUILD_CONTAINER_NAME := go-builder
GO_MOD_CACHE := $(shell go env GOMODCACHE)
GOCACHE := $(shell go env GOCACHE)

.PHONY: all build docker-pull docker-build clean

all: build

build:
	@echo "Building $(APP_NAME) $(VERSION)..."
	@mkdir -p $(BUILD_DIR)
	@go build -buildvcs=false -ldflags="-X 'main.version=$(VERSION)'" -o $(BUILD_DIR)/$(APP_NAME) ./hello

docker-pull:
	@echo "Pulling $(DOCKER_IMAGE)..."
	@docker pull $(DOCKER_IMAGE)

docker-build: docker-pull
	@echo "Building in Docker..."
	@mkdir -p $(BUILD_DIR)
	@docker run --rm \
		-v $(PWD):/workspace \
		-v $(GO_MOD_CACHE):/go/pkg/mod \
		-v $(GOCACHE):/root/.cache/go-build \
		-w /workspace \
		--name $(BUILD_CONTAINER_NAME) \
		$(DOCKER_IMAGE) \
		make build VERSION=$(VERSION)

clean:
	@echo "Cleaning up..."
	@rm -rf $(BUILD_DIR)
	@docker rm -f $(BUILD_CONTAINER_NAME) 2>/dev/null || true
