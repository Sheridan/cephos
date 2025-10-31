.PHONY: build build_container clean

CURRENT_UID := $(shell id -u)
CURRENT_GID := $(shell id -g)
DOCKER_COMPOSE := CURRENT_UID=$(CURRENT_UID) CURRENT_GID=$(CURRENT_GID) docker compose
WORK_DIR := tmp/work

build_container:
	mkdir -p $(WORK_DIR)
	cd container && $(DOCKER_COMPOSE) build

build: build_container
	cd container && $(DOCKER_COMPOSE) up

clean:
	cd container && $(DOCKER_COMPOSE) down --volumes --remove-orphans

purge:
	rm -rf tmp/*
