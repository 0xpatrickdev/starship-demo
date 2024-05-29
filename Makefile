NAME = starship-getting-started
FILE = starship.yaml

HELM_REPO = starship
HELM_CHART = devnet/devnet-0.1.49-agoric.tgz
# HELM_CHART = devnet
HELM_VERSION = v0.1.49-agoric

###############################################################################
###                              All commands                               ###
###############################################################################

.PHONY: setup
setup: setup-deps setup-helm setup-kind

.PHONY: stop
stop: stop-forward delete

.PHONY: clean
clean: stop clean-kind

###############################################################################
###                          Dependency check                               ###
###############################################################################

.PHONY: check
setup-deps:
	bash $(CURDIR)/scripts/dev-setup.sh

###############################################################################
###                              Helm Charts                                ###
###############################################################################

install:
	bash $(CURDIR)/scripts/install.sh --config $(FILE) --name $(NAME) --chart $(HELM_CHART)

delete:
	-helm delete $(NAME)

###############################################################################
###                                 Port forward                            ###
###############################################################################

.PHONY: port-forward
port-forward:
	bash $(CURDIR)/scripts/port-forward.sh --config=$(FILE)

.PHONY: stop-forward
stop-forward:
	-pkill -f "port-forward"

###############################################################################
###                          Local Kind Setup                               ###
###############################################################################
KIND_CLUSTER=starship

.PHONY: setup-kind
setup-kind:
	kind create cluster --name $(KIND_CLUSTER)

.PHONY: clean-kind
clean-kind:
	kind delete cluster --name $(KIND_CLUSTER)

###############################################################################
###                          Agoric Setup                                   ###
###############################################################################
PROVISION_POOL_ADDR=agoric1megzytg65cyrgzs6fvzxgrcqvwwl7ugpt62346

fund-provision-pool:
	kubectl exec -it agoriclocal-genesis-0 -c validator -- agd tx bank send faucet $(PROVISION_POOL_ADDR) 1000000000uist -y -b block

ADDR=agoric1ldmtatp24qlllgxmrsjzcpe20fvlkp448zcuce
COIN=1000000000uist

fund-wallet:
	kubectl exec -it agoriclocal-genesis-0 -c validator -- agd tx bank send faucet $(ADDR) $(COIN) -y -b block

provision-smart-wallet:
	kubectl exec -it agoriclocal-genesis-0 -c validator -- agd tx swingset provision-one wallet $(ADDR) SMART_WALLET --from faucet -y -b block

# view agoric swingset logs from slog file, until we can set `DEBUG=SwingSet:vat,SwingSet:ls`
tail-slog:
	kubectl exec -it agoriclocal-genesis-0 -c validator -- tail -f slog.slog
