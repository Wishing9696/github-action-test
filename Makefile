APP_NAME := myapp
VERSION ?= 1.0.0
BUILD_DIR := ./bin
DOCKER_IMAGE := golang
BUILD_CONTAINER_NAME := go-builder
GO_MOD_CACHE := $(shell go env GOMODCACHE)
GOCACHE := $(shell go env GOCACHE)
DOCKER_REPO := wishing9696

.PHONY: all build docker-pull docker-build clean test docker-image-build docker-image-push

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

test:
	@echo "Testing $(APP_NAME) $(VERSION)..."
	@go test -v ./hello

docker-image-build:
	@echo "Building Docker image..."
	@docker build -t $(APP_NAME):$(VERSION) .
	@echo "Docker image $(APP_NAME):$(VERSION) built successfully."
	@echo "To run the Docker container, use: docker run --rm -it $(APP_NAME):$(VERSION)"

docker-image-push:
	@echo "Pushing Docker image..."
	@echo "Building Docker image..."
	@docker build -t $(DOCKER_REPO)/$(APP_NAME):$(VERSION) .
	@echo "Docker image $(DOCKER_REPO)/$(APP_NAME):$(VERSION) built successfully."
	# @docker tag $(APP_NAME):$(VERSION) $(DOCKER_REPO)/$(APP_NAME):$(VERSION)
	@docker push $(DOCKER_REPO)/$(APP_NAME):$(VERSION)
	@echo "Docker image $(DOCKER_REPO)/$(APP_NAME):$(VERSION) pushed successfully."