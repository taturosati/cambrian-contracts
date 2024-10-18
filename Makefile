RPC_URL:=http://localhost:8545
KEYSTORE_PATH:=./anvil.keystore.json

-include .env

# Default target
.PHONY: all
all: clean build

# Target to build the project
.PHONY: build
build:
	@forge build

# Target to clean the project
.PHONY: clean
clean:
	@forge clean

.PHONY: anvil-start
anvil-start:
	@anvil

.PHONY: deploy-router
deploy-router: build
	@echo "Using keystore path: $(KEYSTORE_PATH)"

	@forge script ./script/DeployRouter.s.sol \
	    --rpc-url $(RPC_URL) \
		--keystore $(KEYSTORE_PATH) \
		--broadcast

.PHONY: upgrade-router
upgrade-router: build
	@echo "Using keystore path: $(KEYSTORE_PATH)"

	@forge script ./script/UpgradeRouter.s.sol \
	    --rpc-url $(RPC_URL) \
		--keystore $(KEYSTORE_PATH) \
		--broadcast
