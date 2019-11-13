ifneq (,)
.error This Makefile requires GNU Make.
endif

# -------------------------------------------------------------------------------------------------
# Default configuration
# -------------------------------------------------------------------------------------------------
.PHONY: help build run enter exec _accept_eula $(DATA_DIR)


# -------------------------------------------------------------------------------------------------
# Server Variables
# -------------------------------------------------------------------------------------------------

# Build args
IMAGE          = cytopia/minecraft-server
JAVA_VERSION   = 14
SERVER_VERSION = 1.14

# Runtime args
JAVA_XMX    = 4096M
PORT        = 25565
DATA_DIR    = data
CONT_NAME   = $(subst /,-, $(IMAGE))-$(SERVER_VERSION)


# -------------------------------------------------------------------------------------------------
# Default Target
# -------------------------------------------------------------------------------------------------
help:
	@echo
	@echo "Minecraft Server Makefile"
	@echo
	@echo "Targets:"
	@echo "----------------------------------------------------------------------------------------"
	@echo "build                 Build the Docker image."
	@echo "run ACCEPT_EULA=true  Accept EULA and start the server."
	@echo "enter                 Start the container and launch a shell instead of the server."
	@echo "exec                  Enter running container with a shell."
	@echo
	@echo "Additional run args:"
	@echo "----------------------------------------------------------------------------------------"
	@echo "JAVA_XMX              Defaults to JAVA_XMX=4096M"
	@echo "PORT                  Defaults to PORT=25565"
	@echo "DATA_DIR              Defaults to DATA_DIR=data"


# -------------------------------------------------------------------------------------------------
# Main Targets
# -------------------------------------------------------------------------------------------------
build:
	docker build \
		--build-arg JAVA_VERSION=$(JAVA_VERSION) \
		--build-arg SERVER_VERSION=$(SERVER_VERSION) \
		-t $(IMAGE):$(SERVER_VERSION) \
		-f Dockerfile .

run: $(DATA_DIR) _accept_eula
	docker run --rm $$(tty -s && echo "-it" || echo) \
		--name $(CONT_NAME) \
		-v "$(PWD)/$(DATA_DIR)/$(SERVER_VERSION)":/data \
		-p $(PORT):$(PORT)/tcp \
		-p $(PORT):$(PORT)/udp \
		-e PORT=$(PORT) \
		-e JAVA_XMX=$(JAVA_XMX) \
		-e ACCEPT_EULA=$(ACCEPT_EULA) \
		$(IMAGE):$(SERVER_VERSION) \
		$(ARGS)

enter: $(DATA_DIR)
	docker run --rm -it \
		--name $(CONT_NAME) \
		-v "$(PWD)/$(DATA_DIR)/$(SERVER_VERSION)":/data \
		-p $(PORT):$(PORT)/tcp \
		-p $(PORT):$(PORT)/udp \
		-e PORT=$(PORT) \
		-e JAVA_XMX=$(JAVA_XMX) \
		-e ACCEPT_EULA=$(ACCEPT_EULA) \
		$(IMAGE):$(SERVER_VERSION) \
		sh

exec:
	docker exec -it $(CONT_NAME) sh


# -------------------------------------------------------------------------------------------------
# Helper Targets
# -------------------------------------------------------------------------------------------------
_accept_eula:
ifneq ($(ACCEPT_EULA),true)
	$(error You must specify ACCEPT_EULA=true in order to accept the eula)
endif

# Ensure the data dir exists
$(DATA_DIR):
	mkdir -p "$(DATA_DIR)/$(SERVER_VERSION)"
